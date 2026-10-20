import os
import re
import hashlib
import pgdumplib
import pandas as pd

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
    return pd.DataFrame(rows, columns=cols if cols else None)

def pseudonymize_id(val):
    if pd.isna(val) or val is None or val == '':
        return 'UNKNOWN'
    return 'CLI_' + hashlib.md5(str(val).encode()).hexdigest()[:10].upper()

def run_aligned_etl():
    print("Mise à jour du Data Warehouse STRICTEMENT aligné sur le Cahier des Charges...")
    dump = pgdumplib.load(DUMP_PATH)
    
    # Remove Dim_Magasin if exists
    magasin_path = os.path.join(OUTPUT_DIR, "Dim_Magasin.csv")
    if os.path.exists(magasin_path):
        os.remove(magasin_path)
        print("Dim_Magasin.csv retiré avec succès.")

    # 1. Extraction
    df_users = get_table_df(dump, 'user')
    df_purch = get_table_df(dump, 'purchase')
    df_outlet = get_table_df(dump, 'outlet')
    df_cat = get_table_df(dump, 'category')
    df_gift = get_table_df(dump, 'gift')
    df_voucher = get_table_df(dump, 'voucher')
    df_sponsorship = get_table_df(dump, 'sponsorship')

    # Filtrage Bondin
    df_purch_bondin = df_purch[df_purch['company_id'] == '2'].copy()
    df_users_bondin = df_users[(df_users['app_name'] == 'bondin') | (df_users['id'].isin(df_purch_bondin['user_id']))].copy()
    df_gift_bondin = df_gift[df_gift['company_id'] == '2'].copy()
    df_outlet_bondin = df_outlet[df_outlet['company_id'] == '2'].copy()
    df_cat_bondin = df_cat[df_cat['company_id'] == '2'].copy()

    # 2. DIM_PRODUIT (538 produits / articles Bondin)
    print("Création de Dim_Produit...")
    cat_dict = dict(zip(df_cat_bondin['id'], df_cat_bondin['name']))
    df_outlet_bondin['Nom_Categorie'] = df_outlet_bondin['category_id'].map(cat_dict).fillna('Café & Dérivés')
    
    # Classer en Gammes officielles (Grains, Moulu, Pur, Dérivés / Accessoires)
    def classifier_gamme(cat_name):
        c = str(cat_name).lower()
        if 'pur' in c: return 'Café Pur'
        if 'mélangé' in c or 'melange' in c: return 'Café Mélangé'
        if 'décaf' in c or 'decaf' in c: return 'Café Décaféiné'
        if 'arabica' in c: return 'Café 100% Arabica'
        if 'torrefie' in c or 'torréfié' in c: return 'Café Torréfié'
        if 'boisson' in c: return 'Boissons & Cafés Préparés'
        return 'Gamme Dérivés & Accessoires'

    dim_produit = pd.DataFrame({
        'ID_Produit': df_outlet_bondin['id'],
        'Reference_Produit': df_outlet_bondin['reference'],
        'Categorie': df_outlet_bondin['Nom_Categorie'],
        'Gamme_Cafe': df_outlet_bondin['Nom_Categorie'].apply(classifier_gamme),
        'Points_Fidelite': pd.to_numeric(df_outlet_bondin['points'], errors='coerce').fillna(0)
    })
    dim_produit.to_csv(os.path.join(OUTPUT_DIR, "Dim_Produit.csv"), index=False, encoding='utf-8-sig')

    # 3. DIM_SEGMENT_CLIENT (Définition officielle des 5 segments du cahier des charges)
    print("Création de Dim_Segment_Client...")
    dim_segment = pd.DataFrame([
        {'ID_Segment': 1, 'Nom_Segment': 'Gros Consommateur (Champion)', 'Cible_Marketing': 'Clients VIP à fidéliser par cadeaux exclusifs (Top 20% CA)', 'Seuil_Dépense': '>= 80e percentile'},
        {'ID_Segment': 2, 'Nom_Segment': 'Consommateur Régulier', 'Cible_Marketing': 'Clients réguliers à stimuler pour augmenter le panier moyen', 'Seuil_Dépense': '50e à 80e percentile'},
        {'ID_Segment': 3, 'Nom_Segment': 'Consommateur Occasionnel', 'Cible_Marketing': 'Clients ponctuels à convertir en habitués', 'Seuil_Dépense': '< 50e percentile'},
        {'ID_Segment': 4, 'Nom_Segment': 'En Risque d\'Attrition (Churn)', 'Cible_Marketing': 'Clients en baisse d\'activité sous 30-60 jours (Campagnes Push)', 'Seuil_Dépense': 'Récence > 60 jours'},
        {'ID_Segment': 5, 'Nom_Segment': 'Inactif / Jamais scanné', 'Cible_Marketing': 'Nouveaux inscrits à activer avec offre de premier scan', 'Seuil_Dépense': '0 scan'}
    ])
    dim_segment.to_csv(os.path.join(OUTPUT_DIR, "Dim_Segment_Client.csv"), index=False, encoding='utf-8-sig')

    # 4. FAIT_VENTES_FIDELITE (sans magasin, 100% conforme cahier des charges)
    print("Mise à jour de Fait_Ventes_Fidelite sans magasin...")
    df_purch_bondin['created_at'] = pd.to_datetime(df_purch_bondin['created_at'])
    fait_ventes = pd.DataFrame({
        'ID_Transaction': df_purch_bondin['id'],
        'ID_Client_Hache': df_purch_bondin['user_id'].apply(pseudonymize_id),
        'Date': df_purch_bondin['created_at'].dt.strftime('%Y-%m-%d'),
        'Heure': df_purch_bondin['created_at'].dt.strftime('%H:%M:%S'),
        'ID_Ticket': df_purch_bondin['ticket'],
        'Type_Achat': df_purch_bondin['purchase_type'],
        'Montant_TND': pd.to_numeric(df_purch_bondin['amount'], errors='coerce') / 1000.0,
        'Points_Gagnes': pd.to_numeric(df_purch_bondin['points'], errors='coerce').fillna(0.0)
    })
    fait_ventes.to_csv(os.path.join(OUTPUT_DIR, "Fait_Ventes_Fidelite.csv"), index=False, encoding='utf-8-sig')

    print("Tables DWH mises à jour avec succès !")
    for f in sorted(os.listdir(OUTPUT_DIR)):
        p = os.path.join(OUTPUT_DIR, f)
        print(f"  [OK] {f:<25} ({len(pd.read_csv(p))} lignes)")

if __name__ == "__main__":
    run_aligned_etl()
