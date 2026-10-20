import pandas as pd
import os

DATA_DIR = r"c:\ena w bonda\data_dwh"

def main():
    ventes = pd.read_csv(os.path.join(DATA_DIR, "Fait_Ventes_Fidelite.csv"))
    clients = pd.read_csv(os.path.join(DATA_DIR, "Dim_Client.csv"))
    magasins = pd.read_csv(os.path.join(DATA_DIR, "Dim_Magasin.csv"))
    mouvements = pd.read_csv(os.path.join(DATA_DIR, "Fait_Mouvements_Points.csv"))
    
    total_ca = ventes['Montant_TND'].sum()
    nb_trans = len(ventes)
    panier_moyen = total_ca / nb_trans
    total_pts_distribues = ventes['Points_Gagnes'].sum()
    
    # Points brûlés
    burn_pts = mouvements[mouvements['Points'] < 0]['Points'].sum()
    burn_pts_abs = abs(burn_pts)
    ratio_earn_burn = (burn_pts_abs / total_pts_distribues) * 100 if total_pts_distribues > 0 else 0
    
    print("="*60)
    print("TABLEAU DE BORD EXÉCUTIF - ENA W BONDIN (RÉSULTATS CLÉS)")
    print("="*60)
    print(f"Chiffre d'Affaires Fidélité Global : {total_ca:,.3f} TND")
    print(f"Nombre Total de Transactions Scannées : {nb_trans:,}")
    print(f"Panier Moyen Fidélité (AOV) : {panier_moyen:.3f} TND")
    print(f"Points Distribués (Earn) : {total_pts_distribues:,.0f} pts")
    print(f"Points Consommés en Cadeaux (Burn) : {burn_pts_abs:,.0f} pts")
    print(f"Ratio Earn & Burn : {ratio_earn_burn:.1f} %")
    
    print("\n--- RÉPARTITION DES CLIENTS PAR SEGMENT RFM ---")
    seg_counts = clients['Segment_Client'].value_counts()
    for seg, cnt in seg_counts.items():
        pct = (cnt / len(clients)) * 100
        print(f"  • {seg:<32} : {cnt:4d} clients ({pct:.1f}%)")
        
    print("\n--- TOP 5 MAGASINS PAR CHIFFRE D'AFFAIRES ---")
    m_ca = ventes.groupby('ID_Magasin')['Montant_TND'].agg(['sum', 'count']).reset_index()
    m_ca = pd.merge(m_ca, magasins[['ID_Magasin', 'Nom_Magasin', 'Region_Gouvernorat']], on='ID_Magasin', how='left')
    m_ca.rename(columns={'sum': 'CA_TND', 'count': 'Transactions'}, inplace=True)
    m_ca = m_ca.sort_values(by='CA_TND', ascending=False)
    for idx, row in m_ca.head(5).iterrows():
        print(f"  • {row['Nom_Magasin']:<28} ({row['Region_Gouvernorat']}): {row['CA_TND']:,.2f} TND ({row['Transactions']} scans)")

if __name__ == "__main__":
    main()
