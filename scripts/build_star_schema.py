import os
import re
import hashlib
import pgdumplib
import pandas as pd
import numpy as np

DUMP_PATH = r"c:\ena w bonda\dump-fidness-202608121035 (1).sql"
OUTPUT_DIR = r"c:\ena w bonda\data_dwh"

def get_table_df(dump, table_name):
    entry = None
    for e in dump.entries:
        if e.desc == 'TABLE DATA' and e.tag == table_name:
            entry = e
            break
    if not entry:
        return pd.DataFrame()
    
    m = re.search(r'\((.*?)\)', entry.copy_stmt)
    cols = [c.strip().strip('"') for c in m.group(1).split(',')] if m else []
    rows = list(dump.table_data('public', table_name))
    df = pd.DataFrame(rows, columns=cols if cols else None)
    return df

def pseudonymize_id(val):
    if pd.isna(val) or val is None or val == '':
        return 'UNKNOWN'
    return 'CLI_' + hashlib.md5(str(val).encode()).hexdigest()[:10].upper()

def run_etl():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("Chargement du dump PostgreSQL Fidness...")
    dump = pgdumplib.load(DUMP_PATH)
    
    # -------------------------------------------------------------
    # 1. Extraction des données brutes
    # -------------------------------------------------------------
    print("Extraction des tables sources...")
    df_users = get_table_df(dump, 'user')
    df_purch = get_table_df(dump, 'purchase')
    df_sp = get_table_df(dump, 'sell_points')
    df_outlet = get_table_df(dump, 'outlet')
    df_gift = get_table_df(dump, 'gift')
    df_voucher = get_table_df(dump, 'voucher')
    df_history = get_table_df(dump, 'history')
    df_sponsorship = get_table_df(dump, 'sponsorship')
    
    # -------------------------------------------------------------
    # 2. Filtrage spécifique ENA W BONDIN (company_id = 2 / app_name = 'bondin')
    # -------------------------------------------------------------
    print("Filtrage du périmètre BONDIN...")
    df_purch_bondin = df_purch[df_purch['company_id'] == '2'].copy()
    df_users_bondin = df_users[(df_users['app_name'] == 'bondin') | (df_users['id'].isin(df_purch_bondin['user_id']))].copy()
    df_sp_bondin = df_sp[df_sp['company_id'] == '2'].copy()
    df_gift_bondin = df_gift[df_gift['company_id'] == '2'].copy()
    
    # -------------------------------------------------------------
    # 3. Construction DIM_MAGASIN (Points de vente / Boutiques)
    # -------------------------------------------------------------
    print("Génération de Dim_Magasin...")
    dim_magasin = df_sp_bondin[['id', 'name', 'code', 'address', 'pos_location']].copy()
    dim_magasin.rename(columns={
        'id': 'ID_Magasin',
        'name': 'Nom_Magasin',
        'code': 'Code_Magasin',
        'address': 'Adresse',
        'pos_location': 'Localisation'
    }, inplace=True)
    
    # Déduire le type de magasin (Succursale vs Cafétéria) et la Ville
    def infer_type(name):
        name_str = str(name).lower()
        if 'caf' in name_str: return 'Cafétéria'
        if 'succursale' in name_str: return 'Succursale'
        return 'Point de Vente'
        
    def infer_ville(name):
        name_str = str(name).lower()
        if 'tunis' in name_str or 'marsa' in name_str or 'menzah' in name_str or 'ariana' in name_str: return 'Grand Tunis'
        if 'sfax' in name_str: return 'Sfax'
        if 'gab' in name_str: return 'Gabès'
        if 'gafsa' in name_str: return 'Gafsa'
        if 'kef' in name_str: return 'Le Kef'
        if 'nabeul' in name_str: return 'Nabeul'
        return 'Autre Région'

    dim_magasin['Type_Etablissement'] = dim_magasin['Nom_Magasin'].apply(infer_type)
    dim_magasin['Region_Gouvernorat'] = dim_magasin['Nom_Magasin'].apply(infer_ville)
    dim_magasin.to_csv(os.path.join(OUTPUT_DIR, "Dim_Magasin.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 4. Construction FAIT_VENTES_FIDELITE
    # -------------------------------------------------------------
    print("Génération de Fait_Ventes_Fidelite...")
    fait_ventes = df_purch_bondin.copy()
    fait_ventes['created_at'] = pd.to_datetime(fait_ventes['created_at'])
    
    # Conversion Montant millimes -> TND (1 TND = 1000 millimes)
    fait_ventes['Montant_TND'] = pd.to_numeric(fait_ventes['amount'], errors='coerce') / 1000.0
    fait_ventes['Points_Gagnes'] = pd.to_numeric(fait_ventes['points'], errors='coerce').fillna(0.0)
    
    fait_ventes['ID_Client_Hache'] = fait_ventes['user_id'].apply(pseudonymize_id)
    fait_ventes['ID_Magasin'] = fait_ventes['sell_point_id']
    fait_ventes['ID_Ticket'] = fait_ventes['ticket']
    fait_ventes['Type_Achat'] = fait_ventes['purchase_type']
    fait_ventes['Date'] = fait_ventes['created_at'].dt.strftime('%Y-%m-%d')
    fait_ventes['Heure'] = fait_ventes['created_at'].dt.strftime('%H:%M:%S')
    
    fait_ventes_clean = fait_ventes[[
        'id', 'ID_Client_Hache', 'ID_Magasin', 'Date', 'Heure', 'ID_Ticket', 'Type_Achat', 'Montant_TND', 'Points_Gagnes'
    ]].rename(columns={'id': 'ID_Transaction'})
    fait_ventes_clean.to_csv(os.path.join(OUTPUT_DIR, "Fait_Ventes_Fidelite.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 5. Construction DIM_CLIENT & Segmentation RFM
    # -------------------------------------------------------------
    print("Génération de Dim_Client avec segmentation RFM...")
    dim_client = df_users_bondin[['id', 'gender', 'birthday', 'created_at']].copy()
    dim_client['ID_Client_Hache'] = dim_client['id'].apply(pseudonymize_id)
    dim_client['Date_Inscription'] = pd.to_datetime(dim_client['created_at'], errors='coerce').dt.strftime('%Y-%m-%d')
    dim_client['Genre'] = dim_client['gender'].replace({'male': 'Homme', 'female': 'Femme', 'None': 'Non précisé'}).fillna('Non précisé')
    
    # Calcul RFM par client
    rfm_stats = fait_ventes.groupby('ID_Client_Hache').agg(
        CA_Total=('Montant_TND', 'sum'),
        Nombre_Achats=('Montant_TND', 'count'),
        Dernier_Achat=('created_at', 'max'),
        Premier_Achat=('created_at', 'min'),
        Total_Points=('Points_Gagnes', 'sum')
    ).reset_index()
    
    ref_date = fait_ventes['created_at'].max()
    rfm_stats['Recence_Jours'] = (ref_date - rfm_stats['Dernier_Achat']).dt.days
    rfm_stats['Panier_Moyen_TND'] = rfm_stats['CA_Total'] / rfm_stats['Nombre_Achats']
    
    # Segmentation selon le cahier des charges : Gros buveurs, Réguliers, Occasionnels
    # Pareto : Top 20% en CA
    ca_threshold_80 = rfm_stats['CA_Total'].quantile(0.80)
    ca_threshold_50 = rfm_stats['CA_Total'].quantile(0.50)
    
    def segment_client(row):
        ca = row['CA_Total']
        freq = row['Nombre_Achats']
        rec = row['Recence_Jours']
        if pd.isna(ca) or ca == 0:
            return 'Inactif / Jamais scanné'
        if rec > 60:
            return 'En Risque d\'Attrition (Churn)'
        if ca >= ca_threshold_80 or freq >= 15:
            return 'Gros Consommateur (Champion)'
        if ca >= ca_threshold_50 or freq >= 5:
            return 'Consommateur Régulier'
        return 'Consommateur Occasionnel'

    rfm_stats['Segment_Client'] = rfm_stats.apply(segment_client, axis=1)
    
    # Fusion avec dim_client
    dim_client_merged = pd.merge(dim_client, rfm_stats, on='ID_Client_Hache', how='left')
    dim_client_merged['Segment_Client'] = dim_client_merged['Segment_Client'].fillna('Inactif / Jamais scanné')
    dim_client_merged['CA_Total'] = dim_client_merged['CA_Total'].fillna(0.0)
    dim_client_merged['Nombre_Achats'] = dim_client_merged['Nombre_Achats'].fillna(0).astype(int)
    dim_client_merged['Total_Points'] = dim_client_merged['Total_Points'].fillna(0.0)
    
    # Sauvegarde Dim_Client sans aucune donnée personnelle (conforme RLS & RGPD)
    dim_client_final = dim_client_merged[[
        'ID_Client_Hache', 'Genre', 'Date_Inscription', 'Segment_Client', 
        'CA_Total', 'Nombre_Achats', 'Panier_Moyen_TND', 'Recence_Jours', 'Total_Points'
    ]]
    dim_client_final.to_csv(os.path.join(OUTPUT_DIR, "Dim_Client.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 6. Construction DIM_RECOMPENSE (Gifts / Cadeaux)
    # -------------------------------------------------------------
    print("Génération de Dim_Recompense...")
    dim_recomp = df_gift_bondin[['id', 'title', 'cost_points', 'description']].copy()
    dim_recomp.rename(columns={
        'id': 'ID_Recompense',
        'title': 'Nom_Cadeau',
        'cost_points': 'Cout_Points'
    }, inplace=True)
    dim_recomp['Cout_Points'] = pd.to_numeric(dim_recomp['Cout_Points'], errors='coerce')
    
    # Classification Cible IA selon le coût des points
    def cible_ia(points):
        if points >= 4000: return 'Exclusif - Gros Consommateur'
        if points >= 1500: return 'Privilège - Régulier'
        return 'Access - Tout Public'
        
    dim_recomp['Cible_IA'] = dim_recomp['Cout_Points'].apply(cible_ia)
    dim_recomp.to_csv(os.path.join(OUTPUT_DIR, "Dim_Recompense.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 7. Construction FAIT_MOUVEMENTS_POINTS (Earn & Burn)
    # -------------------------------------------------------------
    print("Génération de Fait_Mouvements_Points...")
    # Points gagnés (Earn)
    earn_pts = fait_ventes_clean[['ID_Transaction', 'ID_Client_Hache', 'Date', 'Points_Gagnes']].copy()
    earn_pts = earn_pts[earn_pts['Points_Gagnes'] > 0]
    earn_pts['Type_Mouvement'] = 'EARN (Attribution Achat)'
    earn_pts['Points'] = earn_pts['Points_Gagnes']
    
    # Points brûlés/consommés (Burn) via Vouchers
    df_vouch_bondin = df_voucher[df_voucher['gift_id'].isin(df_gift_bondin['id'])].copy()
    df_vouch_bondin = pd.merge(df_vouch_bondin, df_gift_bondin[['id', 'cost_points']], left_on='gift_id', right_on='id', how='left')
    df_vouch_bondin['created_at'] = pd.to_datetime(df_vouch_bondin['created_at'])
    
    burn_pts = pd.DataFrame({
        'ID_Transaction': df_vouch_bondin['id_x'],
        'ID_Client_Hache': df_vouch_bondin['user_id'].apply(pseudonymize_id),
        'Date': df_vouch_bondin['created_at'].dt.strftime('%Y-%m-%d'),
        'Points_Gagnes': 0,
        'Type_Mouvement': 'BURN (Échange Cadeau)',
        'Points': -pd.to_numeric(df_vouch_bondin['cost_points'], errors='coerce').fillna(0)
    })
    
    mouvements_points = pd.concat([
        earn_pts[['ID_Client_Hache', 'Date', 'Type_Mouvement', 'Points']],
        burn_pts[['ID_Client_Hache', 'Date', 'Type_Mouvement', 'Points']]
    ], ignore_index=True)
    mouvements_points.to_csv(os.path.join(OUTPUT_DIR, "Fait_Mouvements_Points.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 8. Construction FAIT_PARRAINAGES
    # -------------------------------------------------------------
    print("Génération de Fait_Parrainages...")
    if not df_sponsorship.empty:
        df_sp_clean = df_sponsorship.copy()
        df_sp_clean['created_at'] = pd.to_datetime(df_sp_clean['created_at'])
        df_sp_clean['Date'] = df_sp_clean['created_at'].dt.strftime('%Y-%m-%d')
        df_sp_clean['ID_Parrain_Hache'] = df_sp_clean['owner_id'].apply(pseudonymize_id)
        df_sp_clean['ID_Filleul_Hache'] = df_sp_clean['recipient_id'].apply(pseudonymize_id)
        df_sp_clean['Points_Parrainage'] = pd.to_numeric(df_sp_clean['points'], errors='coerce').fillna(0)
        
        fait_parrainage = df_sp_clean[['id', 'Date', 'ID_Parrain_Hache', 'ID_Filleul_Hache', 'Points_Parrainage']].rename(
            columns={'id': 'ID_Parrainage'}
        )
        fait_parrainage.to_csv(os.path.join(OUTPUT_DIR, "Fait_Parrainages.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 9. Construction DIM_TEMPS
    # -------------------------------------------------------------
    print("Génération de Dim_Temps...")
    min_date = fait_ventes['created_at'].min().date()
    max_date = fait_ventes['created_at'].max().date()
    date_range = pd.date_range(start=min_date, end=max_date, freq='D')
    
    dim_temps = pd.DataFrame({'Date_Obj': date_range})
    dim_temps['Date'] = dim_temps['Date_Obj'].dt.strftime('%Y-%m-%d')
    dim_temps['Jour_Mois'] = dim_temps['Date_Obj'].dt.day
    dim_temps['Nom_Jour'] = dim_temps['Date_Obj'].dt.day_name()
    dim_temps['Semaine'] = dim_temps['Date_Obj'].dt.isocalendar().week
    dim_temps['Mois'] = dim_temps['Date_Obj'].dt.month
    dim_temps['Nom_Mois'] = dim_temps['Date_Obj'].dt.month_name()
    dim_temps['Trimestre'] = 'T' + dim_temps['Date_Obj'].dt.quarter.astype(str)
    dim_temps['Annee'] = dim_temps['Date_Obj'].dt.year
    dim_temps.drop(columns=['Date_Obj'], inplace=True)
    dim_temps.to_csv(os.path.join(OUTPUT_DIR, "Dim_Temps.csv"), index=False, encoding='utf-8-sig')

    print("\n" + "="*60)
    print("ETL TERMINE AVEC SUCCES !")
    print(f"Tous les fichiers du Data Warehouse sont créés dans : {OUTPUT_DIR}")
    print("="*60)
    for f in os.listdir(OUTPUT_DIR):
        fpath = os.path.join(OUTPUT_DIR, f)
        print(f"  [OK] {f:<25} ({os.path.getsize(fpath):,} octets)")

if __name__ == "__main__":
    run_etl()
