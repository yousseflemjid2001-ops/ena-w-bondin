import subprocess

expr_ca = 'SUMX(Fait_Ventes, IFERROR(1 * SUBSTITUTE(Fait_Ventes[Column8], ",", "."), 0))'
expr_pts = 'SUMX(Fait_Ventes, IFERROR(1 * SUBSTITUTE(Fait_Ventes[Column9], ",", "."), 0))'
expr_aov = 'DIVIDE([Total_CA_TND], [Nb_Transactions], 0)'

p1 = subprocess.run(['pbi', 'measure', 'update', 'Total_CA_TND', '-t', 'Fait_Ventes', '-e', '-'], input=expr_ca, text=True, capture_output=True)
print("Total_CA_TND:", p1.stdout.strip())

p2 = subprocess.run(['pbi', 'measure', 'update', 'Total_Points_Gagnes', '-t', 'Fait_Ventes', '-e', '-'], input=expr_pts, text=True, capture_output=True)
print("Total_Points_Gagnes:", p2.stdout.strip())

p3 = subprocess.run(['pbi', 'measure', 'update', 'Panier_Moyen_TND', '-t', 'Fait_Ventes', '-e', '-'], input=expr_aov, text=True, capture_output=True)
print("Panier_Moyen_TND:", p3.stdout.strip())
