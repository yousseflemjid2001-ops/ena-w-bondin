import os
import pandas as pd

DATA_DIR = r"c:\ena w bonda\data_dwh"
OUTPUT_XLSX = r"c:\ena w bonda\BONDIN_DATA_WAREHOUSE.xlsx"

print("Création du classeur Excel consolidé DWH BONDIN...")

with pd.ExcelWriter(OUTPUT_XLSX, engine='xlsxwriter') as writer:
    workbook = writer.book
    
    # Formats
    header_fmt = workbook.add_format({
        'bold': True,
        'bg_color': '#B22222',
        'font_color': '#FFFFFF',
        'border': 1
    })
    
    # 1. Fait_Ventes_Fidelite
    f_ventes = os.path.join(DATA_DIR, "Fait_Ventes_Fidelite.csv")
    if os.path.exists(f_ventes):
        df = pd.read_csv(f_ventes)
        df.to_excel(writer, sheet_name='Fait_Ventes', index=False)
        print(f"  • Fait_Ventes : {len(df)} lignes")
        
    # 2. Dim_Client
    f_client = os.path.join(DATA_DIR, "Dim_Client.csv")
    if os.path.exists(f_client):
        df = pd.read_csv(f_client)
        df.to_excel(writer, sheet_name='Dim_Client', index=False)
        print(f"  • Dim_Client : {len(df)} clients")

    # 3. Dim_Magasin
    f_mag = os.path.join(DATA_DIR, "Dim_Magasin.csv")
    if os.path.exists(f_mag):
        df = pd.read_csv(f_mag)
        df.to_excel(writer, sheet_name='Dim_Magasin', index=False)
        print(f"  • Dim_Magasin : {len(df)} magasins")

    # 4. Dim_Recompense
    f_rec = os.path.join(DATA_DIR, "Dim_Recompense.csv")
    if os.path.exists(f_rec):
        df = pd.read_csv(f_rec)
        df.to_excel(writer, sheet_name='Dim_Recompense', index=False)
        print(f"  • Dim_Recompense : {len(df)} récompenses")

    # 5. Fait_Mouvements_Points
    f_mvt = os.path.join(DATA_DIR, "Fait_Mouvements_Points.csv")
    if os.path.exists(f_mvt):
        df = pd.read_csv(f_mvt)
        df.to_excel(writer, sheet_name='Fait_Mouvements', index=False)
        print(f"  • Fait_Mouvements : {len(df)} mouvements")

    # 6. Fait_Parrainages
    f_parr = os.path.join(DATA_DIR, "Fait_Parrainages.csv")
    if os.path.exists(f_parr):
        df = pd.read_csv(f_parr)
        df.to_excel(writer, sheet_name='Fait_Parrainages', index=False)
        print(f"  • Fait_Parrainages : {len(df)} parrainages")

print(f"Classeur généré avec succès dans : {OUTPUT_XLSX}")
