import re

with open('c:/ena w bonda/dashboard_bi/index.html', 'r', encoding='utf-8') as f:
    html = f.read()

with open('c:/ena w bonda/dashboard_bi/app.js', 'r', encoding='utf-8') as f:
    js = f.read()

combined = html + js

print("=" * 60)
print("AUDIT DASHBOARD vs CAHIER DES CHARGES")
print("=" * 60)

# ONGLETS / TABS
tabs = re.findall(r'tab-btn[^>]*>([^<]+)', html)
print("\n[ONGLETS DETECTES]")
for t in tabs:
    print(f"  - {t.strip()}")

# KPI CARDS
print("\n[KPIs EXECOTIFS - cartes indicateurs]")
kpi_checks = {
    "CA Fidelite Global (TND)": any(x in combined for x in ["CA Fidélité", "ca-fidelite", "CA Global", "ca_total"]),
    "Panier Moyen (AOV)": any(x in combined for x in ["Panier Moyen", "panier-moyen", "AOV", "aov"]),
    "Frequence Achat": any(x in combined for x in ["Fréquence", "frequence", "freq-achat"]),
    "Taux Croissance CA": any(x in combined for x in ["Croissance", "taux-croissance", "croissance-ca"]),
    "Volume Transactions": any(x in combined for x in ["Transactions", "transactions", "nb-transactions"]),
    "Encours Points (TND)": any(x in combined for x in ["Encours", "dette", "encours-points", "passif"]),
    "Taux Retention 30/60/90j": any(x in combined for x in ["Rétention", "retention", "30 jours", "90 jours"]),
    "Taux Redemption": any(x in combined for x in ["Rédemption", "redemption", "taux-redemption"]),
}
for kpi, found in kpi_checks.items():
    status = "OK" if found else "MANQUANT"
    print(f"  [{status}] {kpi}")

# FONCTIONNALITES CLES
print("\n[FONCTIONNALITES CDC]")
features = {
    "Dashboard 1 - Cockpit CA": any(x in combined for x in ["Cockpit", "cockpit", "CA Fidelite", "CA Fidélité"]),
    "Dashboard 2 - Segmentation RFM": any(x in combined for x in ["RFM", "rfm", "Segmentation", "Champions"]),
    "Dashboard 3 - Cagnotte Earn&Burn": any(x in combined for x in ["Earn", "Burn", "earn", "burn", "Cagnotte"]),
    "Simulateur What-If": any(x in combined for x in ["What-If", "what-if", "simulateur", "Simulateur"]),
    "Arbre Decomposition IA": any(x in combined for x in ["Décomposition", "decomposition", "arbre", "Arbre"]),
    "Diagramme Sankey": any(x in combined for x in ["Sankey", "sankey"]),
    "Scoring Churn ML": any(x in combined for x in ["Churn", "churn", "attrition"]),
    "Moteur IA Cadeaux/Recompenses": any(x in combined for x in ["Récompense", "recompense", "moteur IA", "IA Client"]),
    "Palmarès Recompenses": any(x in combined for x in ["Palmarès", "palmares", "Récompenses", "top-recompenses"]),
    "Analyse Parrainage": any(x in combined for x in ["Parrainage", "parrainage", "Filleul", "filleul"]),
    "Market Basket (Associations Produits)": any(x in combined for x in ["Market Basket", "market basket", "Association", "co-achat"]),
    "RLS (Securite Roles)": any(x in combined for x in ["RLS", "rls", "Rôle", "role"]),
    "Carte Geographique Regions": any(x in combined for x in ["carte", "map", "Tunis", "Sfax", "Gafsa"]),
    "Filtre Temporal (Periode)": any(x in combined for x in ["période", "Période", "filtre-periode", "date-range"]),
    "Export PDF": any(x in combined for x in ["Export", "PDF", "pdf"]),
    "Mode Sombre": any(x in combined for x in ["dark", "sombre", "theme", "toggleDarkMode"]),
    "Chat IA RAG": any(x in combined for x in ["RAG", "rag", "Copilot", "copilot"]),
    "Cross-filtering interactif": any(x in combined for x in ["crossfilter", "cross-filter", "applyCrossFilter"]),
    "Ventilation par Gamme Cafe": any(x in combined for x in ["Gamme", "gamme", "Grains", "Capsules", "Moulu"]),
    "Pareto (20/80)": any(x in combined for x in ["Pareto", "pareto", "20%", "80%"]),
}
for feat, found in features.items():
    status = "OK" if found else "MANQUANT"
    print(f"  [{status}] {feat}")

# CHARTS PRESENT
print("\n[GRAPHIQUES CHART.JS]")
canvases = re.findall(r'id=.([^"\']+chart[^"\']+|[^"\']+canvas[^"\']+).', html, re.IGNORECASE)
for c in canvases:
    print(f"  - {c}")

# DATA.JS
print("\n[DATA.JS - Tables simulées]")
with open('c:/ena w bonda/dashboard_bi/data.js', 'r', encoding='utf-8') as f:
    data_js = f.read()

tables = re.findall(r'(Fait_\w+|Dim_\w+|fait_\w+|dim_\w+)', data_js)
for t in set(tables):
    print(f"  - {t}")

print("\n" + "=" * 60)
