with open('index.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'id="tab-cockpit"' in l or 'bondin-report-section-header' in l or 'SECTION ' in l or 'id="tab-produits"' in l or 'id="tab-segmentation"' in l:
        print(f"{i+1}: {l.strip()[:100]}")
