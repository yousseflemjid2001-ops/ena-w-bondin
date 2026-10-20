import pandas as pd
import numpy as np
import os

DATA_DIR = r"c:\ena w bonda\data_dwh"

ventes = pd.read_csv(os.path.join(DATA_DIR, "Fait_Ventes_Fidelite.csv"))
clients = pd.read_csv(os.path.join(DATA_DIR, "Dim_Client.csv"))
magasins = pd.read_csv(os.path.join(DATA_DIR, "Dim_Magasin.csv"))
mouvements = pd.read_csv(os.path.join(DATA_DIR, "Fait_Mouvements_Points.csv"))

print("="*70)
print("AUDIT TAB 4: ANALYSES AVANCEES & COHORTES VS DWH")
print("="*70)

# 1. HEATMAP (Jour x Creneau)
ventes['Datetime'] = pd.to_datetime(ventes['Date'] + ' ' + ventes['Heure'])
ventes['DayName'] = ventes['Datetime'].dt.day_name()
ventes['Hour'] = ventes['Datetime'].dt.hour

def get_slot(h):
    if 7 <= h < 10: return "07h - 10h (Matin)"
    elif 10 <= h < 12: return "10h - 12h (Midi)"
    elif 12 <= h < 14: return "12h - 14h (Déjeuner)"
    elif 14 <= h < 17: return "14h - 17h (Après-midi)"
    elif 17 <= h < 20: return "17h - 20h (Sortie Bureau)"
    else: return "20h - 23h (Soirée)"

ventes['Slot'] = ventes['Hour'].apply(get_slot)

day_map = {
    'Monday': 'Lundi', 'Tuesday': 'Mardi', 'Wednesday': 'Mercredi',
    'Thursday': 'Jeudi', 'Friday': 'Vendredi', 'Saturday': 'Samedi', 'Sunday': 'Dimanche'
}
ventes['Jour_FR'] = ventes['DayName'].map(day_map)

day_order = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
slot_order = [
    "07h - 10h (Matin)", "10h - 12h (Midi)", "12h - 14h (Déjeuner)",
    "14h - 17h (Après-midi)", "17h - 20h (Sortie Bureau)", "20h - 23h (Soirée)"
]

heatmap = pd.crosstab(ventes['Jour_FR'], ventes['Slot']).reindex(index=day_order, columns=slot_order, fill_value=0)
print("\n--- 1. HEATMAP EXACTE (Total scans = {}) ---".format(heatmap.values.sum()))
print(heatmap)

# 2. COHORT RETENTION
# Cohort based on client Date_Inscription
clients['Date_Inscription_DT'] = pd.to_datetime(clients['Date_Inscription'])
clients['Cohorte_Mois'] = clients['Date_Inscription_DT'].dt.to_period('M')

ventes['Mois_Vente'] = pd.to_datetime(ventes['Date']).dt.to_period('M')
ventes_client = pd.merge(ventes[['ID_Client_Hache', 'Mois_Vente']].drop_duplicates(), 
                         clients[['ID_Client_Hache', 'Cohorte_Mois']], 
                         on='ID_Client_Hache', how='inner')

ventes_client['Mois_Index'] = (ventes_client['Mois_Vente'].dt.year - ventes_client['Cohorte_Mois'].dt.year) * 12 + (ventes_client['Mois_Vente'].dt.month - ventes_client['Cohorte_Mois'].dt.month)

cohort_sizes = clients.groupby('Cohorte_Mois')['ID_Client_Hache'].nunique()
cohort_retention = ventes_client.groupby(['Cohorte_Mois', 'Mois_Index'])['ID_Client_Hache'].nunique().unstack(fill_value=0)

print("\n--- 2. COHORTE DE RETENTION EXACTE ---")
print("Taille des cohortes d'inscription:")
print(cohort_sizes)
print("\nMatrice de rétention (Nombre de clients actifs):")
print(cohort_retention)

# 3. RADAR BENCHMARK SUCCURSALES VS CAFETERIAS
v_mag = pd.merge(ventes, magasins[['ID_Magasin', 'Type_Etablissement']], on='ID_Magasin', how='left')
radar_stats = v_mag.groupby('Type_Etablissement').agg(
    CA_Total=('Montant_TND', 'sum'),
    Nb_Scans=('ID_Transaction', 'count'),
    AOV=('Montant_TND', 'mean'),
    Clients_Uniques=('ID_Client_Hache', 'nunique'),
    Points_Distribues=('Points_Gagnes', 'sum')
).reset_index()

radar_stats['Frequence_Moyenne'] = radar_stats['Nb_Scans'] / radar_stats['Clients_Uniques']
print("\n--- 3. RADAR BENCHMARK SUCCURSALES VS CAFETERIAS ---")
print(radar_stats)

# 4. PRODUITS / TYPES D'ACHATS (POUR LA MATRICE BCG)
print("\n--- 4. TYPES D'ACHATS & CATEGORIES ---")
type_achat_stats = ventes.groupby('Type_Achat').agg(
    CA_Total=('Montant_TND', 'sum'),
    Nb_Transactions=('ID_Transaction', 'count'),
    Panier_Moyen=('Montant_TND', 'mean'),
    Points_Total=('Points_Gagnes', 'sum')
).reset_index()
print(type_achat_stats)

# 5. DEMOGRAPHIE CLIENTS (POUR LE GRAPHIQUE AGE / GENRE)
print("\n--- 5. DEMOGRAPHIE CLIENTS ---")
print("Genre:")
print(clients['Genre'].value_counts())
print("\nProfil Réseau:")
print(clients['Profil_Reseau'].value_counts())
print("\nSegment Client:")
print(clients['Segment_Client'].value_counts())
