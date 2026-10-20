import pandas as pd
import numpy as np
import os

DATA_DIR = r"c:\ena w bonda\data_dwh"

def enrich_dim_client():
    ventes_path = os.path.join(DATA_DIR, "Fait_Ventes_Fidelite.csv")
    magasins_path = os.path.join(DATA_DIR, "Dim_Magasin.csv")
    mouvements_path = os.path.join(DATA_DIR, "Fait_Mouvements_Points.csv")
    clients_path = os.path.join(DATA_DIR, "Dim_Client.csv")
    
    ventes = pd.read_csv(ventes_path)
    magasins = pd.read_csv(magasins_path)
    mouvements = pd.read_csv(mouvements_path)
    clients = pd.read_csv(clients_path)
    
    ventes['Date'] = pd.to_datetime(ventes['Date'])
    mouvements['Date'] = pd.to_datetime(mouvements['Date'])
    
    # 1. Merge ventes with magasin type
    vm = ventes.merge(magasins[['ID_Magasin', 'Type_Etablissement']], on='ID_Magasin', how='left')
    vm['Type_Clean'] = vm['Type_Etablissement'].apply(lambda x: 'Succursale' if 'Succ' in str(x) else 'Cafeteria')
    
    # Aggregation par client et type d'établissement
    gp = vm.groupby(['ID_Client_Hache', 'Type_Clean'])['Montant_TND'].agg(['sum', 'count', 'max']).unstack(fill_value=0)
    gp.columns = [f'{col[0]}_{col[1]}' for col in gp.columns]
    
    gp['Achats_Succursale_TND'] = gp['sum_Succursale'].round(3)
    gp['Achats_Cafeteria_TND'] = gp['sum_Cafeteria'].round(3)
    gp['Max_Ticket_Succursale_TND'] = gp['max_Succursale'].round(3)
    gp['Max_Ticket_Cafeteria_TND'] = gp['max_Cafeteria'].round(3)
    gp['Nb_Scans_Succursale'] = gp['count_Succursale']
    gp['Nb_Scans_Cafeteria'] = gp['count_Cafeteria']
    
    # Classification Profil Réseau & Grossiste Suspect
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
    
    # 2. Fréquence hebdomadaire
    ventes['YearWeek'] = ventes['Date'].dt.strftime('%Y-%U')
    weekly_scans = ventes.groupby(['ID_Client_Hache', 'YearWeek']).size().reset_index(name='scans_semaine')
    avg_weekly = weekly_scans.groupby('ID_Client_Hache')['scans_semaine'].mean().round(2)
    max_weekly = weekly_scans.groupby('ID_Client_Hache')['scans_semaine'].max()
    
    gp['Scans_Par_Semaine_Moyen'] = gp.index.map(avg_weekly).fillna(0)
    gp['Scans_Semaine_Pic'] = gp.index.map(max_weekly).fillna(0)
    gp['Flag_Ultra_Frequent'] = gp['Scans_Par_Semaine_Moyen'].apply(lambda x: 1 if x >= 3.0 else 0)
    
    # 3. CA généré avant le 1er cadeau (Burn)
    burns = mouvements[mouvements['Points'] < 0].sort_values('Date')
    first_burn = burns.groupby('ID_Client_Hache')['Date'].min().reset_index()
    first_burn.rename(columns={'Date': 'Date_Premier_Burn'}, inplace=True)
    count_burns = burns.groupby('ID_Client_Hache').size()
    
    v_burn = ventes.merge(first_burn, on='ID_Client_Hache', how='inner')
    v_before = v_burn[v_burn['Date'] <= v_burn['Date_Premier_Burn']]
    ca_before = v_before.groupby('ID_Client_Hache')['Montant_TND'].sum().round(3)
    
    gp['CA_Avant_Premier_Cadeau_TND'] = gp.index.map(ca_before)
    gp['Nb_Cadeaux_Reclames'] = gp.index.map(count_burns).fillna(0).astype(int)
    
    # Reset index pour merge
    gp = gp.reset_index()
    
    cols_to_merge = [
        'ID_Client_Hache', 'Profil_Reseau', 'Flag_Grossiste_Suspect', 
        'Achats_Succursale_TND', 'Achats_Cafeteria_TND', 'Max_Ticket_Succursale_TND',
        'Scans_Par_Semaine_Moyen', 'Flag_Ultra_Frequent',
        'CA_Avant_Premier_Cadeau_TND', 'Nb_Cadeaux_Reclames'
    ]
    
    # Enrichir Dim_Client
    clients_enriched = clients.merge(gp[cols_to_merge], on='ID_Client_Hache', how='left')
    
    # Remplir les inactifs
    clients_enriched['Profil_Reseau'] = clients_enriched['Profil_Reseau'].fillna('Inactif / Jamais scanné')
    clients_enriched['Flag_Grossiste_Suspect'] = clients_enriched['Flag_Grossiste_Suspect'].fillna(0).astype(int)
    clients_enriched['Achats_Succursale_TND'] = clients_enriched['Achats_Succursale_TND'].fillna(0.0)
    clients_enriched['Achats_Cafeteria_TND'] = clients_enriched['Achats_Cafeteria_TND'].fillna(0.0)
    clients_enriched['Max_Ticket_Succursale_TND'] = clients_enriched['Max_Ticket_Succursale_TND'].fillna(0.0)
    clients_enriched['Scans_Par_Semaine_Moyen'] = clients_enriched['Scans_Par_Semaine_Moyen'].fillna(0.0)
    clients_enriched['Flag_Ultra_Frequent'] = clients_enriched['Flag_Ultra_Frequent'].fillna(0).astype(int)
    clients_enriched['Nb_Cadeaux_Reclames'] = clients_enriched['Nb_Cadeaux_Reclames'].fillna(0).astype(int)
    
    # Sauvegarde
    clients_enriched.to_csv(clients_path, index=False)
    print(f"Dim_Client enrichie avec succès : {len(clients_enriched)} lignes.")
    print("Répartition des profils réseau :")
    print(clients_enriched['Profil_Reseau'].value_counts())
    print("\nClients Grossistes Suspects identifiés :", clients_enriched['Flag_Grossiste_Suspect'].sum())
    print("Clients Ultra Fréquents (>= 3 scans/sem) :", clients_enriched['Flag_Ultra_Frequent'].sum())

if __name__ == "__main__":
    enrich_dim_client()
