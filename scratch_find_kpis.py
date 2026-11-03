with open('index.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, l in enumerate(lines):
    if 'id="kpi-' in l or 'id="ctx-' in l or 'id="spark-' in l or 'id="chart-' in l or 'donut-center' in l:
        print(f'{i+1}: {l.strip()[:100]}')
