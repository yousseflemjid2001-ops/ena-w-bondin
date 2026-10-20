import os
import hashlib
import pg8000.native
import pandas as pd
import numpy as np
from datetime import datetime

OUTPUT_DIR = r"c:\ena w bonda\data_dwh"

def pseudonymize_id(val):
    if pd.isna(val) or val is None or val == '':
        return 'UNKNOWN'
    return 'CLI_' + hashlib.md5(str(val).encode()).hexdigest()[:10].upper()

def sync_dwh():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Connexion à PostgreSQL Live 57.131.30.69:5432...")
    
    con = pg8000.native.Connection(
        user='fidness',
        host='57.131.30.69',
        port=5432,
        database='fidness',
        password='6a7ce156b7bc9445'
    )
    
    # 1. Extraction Purchases
    print("Extraction des achats BONDIN (company_id = 2)...")
    res_p = con.run("""
        SELECT id, user_id, sell_point_id, created_at, ticket, purchase_type, amount, coalesce(points, 0)
        FROM public.purchase
        WHERE company_id = 2
        ORDER BY created_at ASC
    """)
    cols_p = ['id', 'user_id', 'sell_point_id', 'created_at', 'ticket', 'purchase_type', 'amount', 'points']
    df_purch = pd.DataFrame(res_p, columns=cols_p)
    
    # 2. Extraction Users
    print("Extraction des utilisateurs ENA W BONDIN...")
    res_u = con.run("""
        SELECT id, gender, birthday, created_at, app_name
        FROM public."user"
        WHERE app_name = 'bondin' 
           OR id IN (SELECT user_id FROM public.purchase WHERE company_id = 2)
        ORDER BY created_at ASC
    """)
    cols_u = ['id', 'gender', 'birthday', 'created_at', 'app_name']
    df_users = pd.DataFrame(res_u, columns=cols_u)
    
    # 3. Extraction Sell Points
    print("Extraction des points de vente...")
    res_sp = con.run("""
        SELECT id, name, code, address, pos_location
        FROM public.sell_points
        WHERE company_id = 2
        ORDER BY id ASC
    """)
    cols_sp = ['id', 'name', 'code', 'address', 'pos_location']
    df_sp = pd.DataFrame(res_sp, columns=cols_sp)
    
    # 4. Extraction Gifts
    print("Extraction des cadeaux (gifts)...")
    res_g = con.run("""
        SELECT id, title, cost_points, description
        FROM public.gift
        WHERE company_id = 2
        ORDER BY id ASC
    """)
    cols_g = ['id', 'title', 'cost_points', 'description']
    df_gift = pd.DataFrame(res_g, columns=cols_g)
    
    # 5. Extraction Vouchers
    print("Extraction des vouchers (burn)...")
    res_v = con.run("""
        SELECT v.id, v.user_id, v.gift_id, v.created_at, g.cost_points
        FROM public.voucher v
        JOIN public.gift g ON v.gift_id = g.id
        WHERE g.company_id = 2
        ORDER BY v.created_at ASC
    """)
    cols_v = ['id', 'user_id', 'gift_id', 'created_at', 'cost_points']
    df_vouch = pd.DataFrame(res_v, columns=cols_v)
    
    # 6. Extraction Sponsorships
    print("Extraction des parrainages...")
    res_s = con.run("""
        SELECT id, created_at, owner_id, recipient_id, coalesce(points, 0)
        FROM public.sponsorship
        WHERE owner_id IN (
            SELECT id FROM public."user" 
            WHERE app_name = 'bondin' OR id IN (SELECT user_id FROM public.purchase WHERE company_id = 2)
        )
        ORDER BY created_at ASC
    """)
    cols_s = ['id', 'created_at', 'owner_id', 'recipient_id', 'points']
    df_spon = pd.DataFrame(res_s, columns=cols_s)
    
    con.close()
    print("Données brutes récupérées avec succès !")
    
    # -------------------------------------------------------------
    # 1. Construction DIM_MAGASIN
    # -------------------------------------------------------------
    print("Génération de Dim_Magasin.csv...")
    dim_magasin = df_sp[['id', 'name', 'code', 'address', 'pos_location']].copy()
    dim_magasin.rename(columns={
        'id': 'ID_Magasin',
        'name': 'Nom_Magasin',
        'code': 'Code_Magasin',
        'address': 'Adresse',
        'pos_location': 'Localisation'
    }, inplace=True)
    
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
    # 2. Construction FAIT_VENTES_FIDELITE
    # -------------------------------------------------------------
    print("Génération de Fait_Ventes_Fidelite.csv...")
    fait_ventes = df_purch.copy()
    fait_ventes['created_at'] = pd.to_datetime(fait_ventes['created_at'])
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
    # 3. Construction DIM_RECOMPENSE
    # -------------------------------------------------------------
    print("Génération de Dim_Recompense.csv...")
    dim_recomp = df_gift[['id', 'title', 'cost_points', 'description']].copy()
    dim_recomp.rename(columns={
        'id': 'ID_Recompense',
        'title': 'Nom_Cadeau',
        'cost_points': 'Cout_Points'
    }, inplace=True)
    dim_recomp['Cout_Points'] = pd.to_numeric(dim_recomp['Cout_Points'], errors='coerce')
    
    def cible_ia(points):
        if points >= 4000: return 'Exclusif - Gros Consommateur'
        if points >= 1500: return 'Privilège - Régulier'
        return 'Access - Tout Public'
        
    dim_recomp['Cible_IA'] = dim_recomp['Cout_Points'].apply(cible_ia)
    dim_recomp.to_csv(os.path.join(OUTPUT_DIR, "Dim_Recompense.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 4. Construction FAIT_MOUVEMENTS_POINTS
    # -------------------------------------------------------------
    print("Génération de Fait_Mouvements_Points.csv...")
    earn_pts = fait_ventes_clean[['ID_Transaction', 'ID_Client_Hache', 'Date', 'Points_Gagnes']].copy()
    earn_pts = earn_pts[earn_pts['Points_Gagnes'] > 0]
    earn_pts['Type_Mouvement'] = 'EARN (Attribution Achat)'
    earn_pts['Points'] = earn_pts['Points_Gagnes']
    
    df_vouch['created_at'] = pd.to_datetime(df_vouch['created_at'])
    burn_pts = pd.DataFrame({
        'ID_Transaction': df_vouch['id'],
        'ID_Client_Hache': df_vouch['user_id'].apply(pseudonymize_id),
        'Date': df_vouch['created_at'].dt.strftime('%Y-%m-%d'),
        'Points_Gagnes': 0,
        'Type_Mouvement': 'BURN (Échange Cadeau)',
        'Points': -pd.to_numeric(df_vouch['cost_points'], errors='coerce').fillna(0)
    })
    
    mouvements_points = pd.concat([
        earn_pts[['ID_Client_Hache', 'Date', 'Type_Mouvement', 'Points']],
        burn_pts[['ID_Client_Hache', 'Date', 'Type_Mouvement', 'Points']]
    ], ignore_index=True)
    mouvements_points.to_csv(os.path.join(OUTPUT_DIR, "Fait_Mouvements_Points.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 5. Construction FAIT_PARRAINAGES
    # -------------------------------------------------------------
    print("Génération de Fait_Parrainages.csv...")
    if not df_spon.empty:
        df_spon['created_at'] = pd.to_datetime(df_spon['created_at'])
        df_spon['Date'] = df_spon['created_at'].dt.strftime('%Y-%m-%d')
        df_spon['ID_Parrain_Hache'] = df_spon['owner_id'].apply(pseudonymize_id)
        df_spon['ID_Filleul_Hache'] = df_spon['recipient_id'].apply(pseudonymize_id)
        df_spon['Points_Parrainage'] = pd.to_numeric(df_spon['points'], errors='coerce').fillna(0)
        
        fait_parrainage = df_spon[['id', 'Date', 'ID_Parrain_Hache', 'ID_Filleul_Hache', 'Points_Parrainage']].rename(
            columns={'id': 'ID_Parrainage'}
        )
        fait_parrainage.to_csv(os.path.join(OUTPUT_DIR, "Fait_Parrainages.csv"), index=False, encoding='utf-8-sig')

    # -------------------------------------------------------------
    # 6. Construction DIM_TEMPS
    # -------------------------------------------------------------
    print("Génération de Dim_Temps.csv...")
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

    # -------------------------------------------------------------
    # 7. Construction DIM_CLIENT enrichie (RFM + Profils)
    # -------------------------------------------------------------
    print("Génération de Dim_Client.csv enrichie...")
    dim_client = df_users[['id', 'gender', 'birthday', 'created_at']].copy()
    dim_client['ID_Client_Hache'] = dim_client['id'].apply(pseudonymize_id)
    dim_client['Date_Inscription'] = pd.to_datetime(dim_client['created_at'], errors='coerce').dt.strftime('%Y-%m-%d')
    dim_client['Genre'] = dim_client['gender'].replace({'male': 'Homme', 'female': 'Femme', 'None': 'Non précisé'}).fillna('Non précisé')
    
    # RFM
    rfm_stats = fait_ventes.groupby('ID_Client_Hache').agg(
        CA_Total=('Montant_TND', 'sum'),
        Nombre_Achats=('Montant_TND', 'count'),
        Dernier_Achat=('created_at', 'max'),
        Premier_Achat=('created_at', 'min'),
        Total_Points=('Points_Gagnes', 'sum')
    ).reset_index()
    
    ref_date = fait_ventes['created_at'].max()
    rfm_stats['Recence_Jours'] = (ref_date - rfm_stats['Dernier_Achat']).dt.days
    rfm_stats['Panier_Moyen_TND'] = (rfm_stats['CA_Total'] / rfm_stats['Nombre_Achats']).round(3)
    
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
    
    # Merge RFM avec dim_client
    dim_client_merged = pd.merge(dim_client, rfm_stats, on='ID_Client_Hache', how='left')
    dim_client_merged['Segment_Client'] = dim_client_merged['Segment_Client'].fillna('Inactif / Jamais scanné')
    dim_client_merged['CA_Total'] = dim_client_merged['CA_Total'].fillna(0.0).round(3)
    dim_client_merged['Nombre_Achats'] = dim_client_merged['Nombre_Achats'].fillna(0).astype(int)
    dim_client_merged['Total_Points'] = dim_client_merged['Total_Points'].fillna(0.0).round(1)

    # Profil Réseau & Grossiste Suspect
    vm = fait_ventes.merge(dim_magasin[['ID_Magasin', 'Type_Etablissement']], on='ID_Magasin', how='left')
    vm['Type_Clean'] = vm['Type_Etablissement'].apply(lambda x: 'Succursale' if 'Succ' in str(x) else 'Cafeteria')
    
    gp = vm.groupby(['ID_Client_Hache', 'Type_Clean'])['Montant_TND'].agg(['sum', 'count', 'max']).unstack(fill_value=0)
    gp.columns = [f'{col[0]}_{col[1]}' for col in gp.columns]
    
    gp['Achats_Succursale_TND'] = gp['sum_Succursale'].round(3) if 'sum_Succursale' in gp.columns else 0.0
    gp['Achats_Cafeteria_TND'] = gp['sum_Cafeteria'].round(3) if 'sum_Cafeteria' in gp.columns else 0.0
    gp['Max_Ticket_Succursale_TND'] = gp['max_Succursale'].round(3) if 'max_Succursale' in gp.columns else 0.0
    gp['Nb_Scans_Succursale'] = gp['count_Succursale'] if 'count_Succursale' in gp.columns else 0
    gp['Nb_Scans_Cafeteria'] = gp['count_Cafeteria'] if 'count_Cafeteria' in gp.columns else 0
    
    def classify_profile(r):
        if r['Nb_Scans_Succursale'] > 0 and r['Nb_Scans_Cafeteria'] > 0:
            if r['Max_Ticket_Succursale_TND'] >= 20.0 or r['Achats_Succursale_TND'] >= 50.0:
                return 'Grossiste / Mixte Suspect'
            else:
                return 'Client Mixte Particulier'
        elif r['Nb_Scans_Succursale'] > 0:
            if r['Max_Ticket_Succursale_TND'] >= 20.0 or r['Achats_Succursale_TND'] >= 50.0:
                return 'Grossiste Pur (Succursale)'
            else:
                return 'Particulier (Succursale)'
        else:
            return 'Consommateur 100% Cafeteria'
            
    gp['Profil_Reseau'] = gp.apply(classify_profile, axis=1)
    gp['Flag_Grossiste_Suspect'] = gp['Profil_Reseau'].apply(lambda x: 1 if 'Grossiste' in x else 0)
    
    # Fréquence hebdomadaire
    fait_ventes['YearWeek'] = fait_ventes['Date'].apply(lambda d: pd.to_datetime(d).strftime('%Y-%U'))
    weekly_scans = fait_ventes.groupby(['ID_Client_Hache', 'YearWeek']).size().reset_index(name='scans_semaine')
    avg_weekly = weekly_scans.groupby('ID_Client_Hache')['scans_semaine'].mean().round(2)
    gp['Scans_Par_Semaine_Moyen'] = gp.index.map(avg_weekly).fillna(0)
    gp['Flag_Ultra_Frequent'] = gp['Scans_Par_Semaine_Moyen'].apply(lambda x: 1 if x >= 3.0 else 0)
    
    # Burns cadeaux
    burns = mouvements_points[mouvements_points['Points'] < 0].sort_values('Date')
    if not burns.empty:
        first_burn = burns.groupby('ID_Client_Hache')['Date'].min().reset_index().rename(columns={'Date': 'Date_Premier_Burn'})
        count_burns = burns.groupby('ID_Client_Hache').size()
        v_burn = fait_ventes.merge(first_burn, on='ID_Client_Hache', how='inner')
        v_before = v_burn[v_burn['Date'] <= v_burn['Date_Premier_Burn']]
        ca_before = v_before.groupby('ID_Client_Hache')['Montant_TND'].sum().round(3)
        gp['CA_Avant_Premier_Cadeau_TND'] = gp.index.map(ca_before)
        gp['Nb_Cadeaux_Reclames'] = gp.index.map(count_burns).fillna(0).astype(int)
    else:
        gp['CA_Avant_Premier_Cadeau_TND'] = np.nan
        gp['Nb_Cadeaux_Reclames'] = 0

    gp = gp.reset_index()
    cols_to_merge = [
        'ID_Client_Hache', 'Profil_Reseau', 'Flag_Grossiste_Suspect', 
        'Achats_Succursale_TND', 'Achats_Cafeteria_TND', 'Max_Ticket_Succursale_TND',
        'Scans_Par_Semaine_Moyen', 'Flag_Ultra_Frequent',
        'CA_Avant_Premier_Cadeau_TND', 'Nb_Cadeaux_Reclames'
    ]
    
    dim_client_enriched = dim_client_merged.merge(gp[cols_to_merge], on='ID_Client_Hache', how='left')
    dim_client_enriched['Profil_Reseau'] = dim_client_enriched['Profil_Reseau'].fillna('Inactif / Jamais scanné')
    dim_client_enriched['Flag_Grossiste_Suspect'] = dim_client_enriched['Flag_Grossiste_Suspect'].fillna(0).astype(int)
    dim_client_enriched['Achats_Succursale_TND'] = dim_client_enriched['Achats_Succursale_TND'].fillna(0.0)
    dim_client_enriched['Achats_Cafeteria_TND'] = dim_client_enriched['Achats_Cafeteria_TND'].fillna(0.0)
    dim_client_enriched['Max_Ticket_Succursale_TND'] = dim_client_enriched['Max_Ticket_Succursale_TND'].fillna(0.0)
    dim_client_enriched['Scans_Par_Semaine_Moyen'] = dim_client_enriched['Scans_Par_Semaine_Moyen'].fillna(0.0)
    dim_client_enriched['Flag_Ultra_Frequent'] = dim_client_enriched['Flag_Ultra_Frequent'].fillna(0).astype(int)
    dim_client_enriched['Nb_Cadeaux_Reclames'] = dim_client_enriched['Nb_Cadeaux_Reclames'].fillna(0).astype(int)

    final_client_cols = [
        'ID_Client_Hache', 'Genre', 'Date_Inscription', 'Segment_Client', 
        'CA_Total', 'Nombre_Achats', 'Panier_Moyen_TND', 'Recence_Jours', 'Total_Points',
        'Profil_Reseau', 'Flag_Grossiste_Suspect', 'Achats_Succursale_TND', 'Achats_Cafeteria_TND',
        'Max_Ticket_Succursale_TND', 'Scans_Par_Semaine_Moyen', 'Flag_Ultra_Frequent',
        'CA_Avant_Premier_Cadeau_TND', 'Nb_Cadeaux_Reclames'
    ]
    dim_client_enriched[final_client_cols].to_csv(os.path.join(OUTPUT_DIR, "Dim_Client.csv"), index=False, encoding='utf-8-sig')

    print("\n" + "="*60)
    print("SYNCHRONISATION LIVE DU DWH RÉUSSIE !")
    print(f"Transactions: {len(fait_ventes_clean)} (du {min_date} au {max_date})")
    print(f"Clients: {len(dim_client_enriched)} (dont {len(rfm_stats)} actifs)")
    print(f"Chiffre d'affaires total: {fait_ventes['Montant_TND'].sum():.2f} TND")
    print("="*60)

if __name__ == "__main__":
    sync_dwh()
