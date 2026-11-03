import shutil

with open('app.js', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Update Top PDV Achats chart options for maximum readability
old_achats_chart = '''    charts.topPdvAchats = new Chart(ctxTopAchats, {
      type: 'bar',
      data: {
        labels: achatsData.map(d => d.pdv),
        datasets: [{
          label: "Nombre d'Achats",
          data: achatsData.map(d => d.achats),
          backgroundColor: '#8E0E14',
          borderRadius: 4,
          borderSkipped: false
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        onClick: (event, elements) => {
          if (elements.length > 0) {
            const idx = elements[0].index;
            const clickedLabel = achatsData[idx].pdv;
            let magCode = 'all';
            if (clickedLabel.includes('Kef')) magCode = 'le-kef';
            else if (clickedLabel.includes('Liberté')) magCode = 'tunis-liberte';
            else if (clickedLabel.includes('Marsa')) magCode = 'la-marsa';
            else if (clickedLabel.includes('Menzah')) magCode = 'el-menzah';
            else if (clickedLabel.includes('Gafsa')) magCode = 'gafsa';
            else if (clickedLabel.includes('Gabès')) magCode = 'gabes';
            window.applyCrossFilter('magasin', magCode, clickedLabel, 'topAchats');
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (ctx) => ` ${ctx.raw} achats (${achatsData[ctx.dataIndex].pct}% du total)`
            }
          }
        },
        scales: {
          x: { grid: { color: 'rgba(0,0,0,0.05)' } },
          y: { grid: { display: false }, ticks: { font: { size: 11, weight: '600' } } }
        }
      }
    });'''

new_achats_chart = '''    charts.topPdvAchats = new Chart(ctxTopAchats, {
      type: 'bar',
      data: {
        labels: achatsData.map(d => d.pdv),
        datasets: [{
          label: "Nombre d'Achats",
          data: achatsData.map(d => d.achats),
          backgroundColor: '#8E0E14',
          hoverBackgroundColor: '#B91C1C',
          borderRadius: 6,
          barPercentage: 0.72,
          categoryPercentage: 0.85
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        layout: {
          padding: { left: 5, right: 20, top: 5, bottom: 5 }
        },
        onClick: (event, elements) => {
          if (elements.length > 0) {
            const idx = elements[0].index;
            const clickedLabel = achatsData[idx].pdv;
            let magCode = 'all';
            if (clickedLabel.includes('Kef')) magCode = 'le-kef';
            else if (clickedLabel.includes('Liberté')) magCode = 'tunis-liberte';
            else if (clickedLabel.includes('Marsa')) magCode = 'la-marsa';
            else if (clickedLabel.includes('Menzah')) magCode = 'el-menzah';
            else if (clickedLabel.includes('Gafsa')) magCode = 'gafsa';
            else if (clickedLabel.includes('Gabès')) magCode = 'gabes';
            window.applyCrossFilter('magasin', magCode, clickedLabel, 'topAchats');
          }
        },
        onHover: (event, elements) => {
          if (event && event.native && event.native.target) {
            event.native.target.style.cursor = (elements && elements.length) ? "pointer" : "default";
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(26, 12, 8, 0.94)',
            padding: 10,
            callbacks: {
              label: (ctx) => `  ${ctx.raw} achats enregistrés (${achatsData[ctx.dataIndex] ? achatsData[ctx.dataIndex].pct : ''}% du volume total)`
            }
          }
        },
        scales: {
          x: {
            grid: { color: 'rgba(0,0,0,0.06)' },
            ticks: {
              font: { size: 12, weight: '700' },
              color: '#4B5563'
            }
          },
          y: {
            grid: { display: false },
            ticks: {
              font: { size: 12.5, weight: '700' },
              color: '#111827'
            }
          }
        }
      }
    });'''

if old_achats_chart in code:
    code = code.replace(old_achats_chart, new_achats_chart, 1)
    print("Updated topPdvAchats chart options")
else:
    print("old_achats_chart not matched directly")

# 2. Update Top Magasins CA chart options for maximum readability and distinct amber gold color
old_top_mag_block = '''    charts.topMagasinsMockup = new Chart(ctxTopMag, {
      type: 'bar',
      data: {
        labels: caData.map(d => d.pdv),
        datasets: [
          {
            label: 'CA (DT)',
            data: caData.map(d => d.ca),
            backgroundColor: '#D97706',
            borderRadius: 4,
            borderSkipped: false
          }
        ]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,'''

new_top_mag_block = '''    charts.topMagasinsMockup = new Chart(ctxTopMag, {
      type: 'bar',
      data: {
        labels: caData.map(d => d.pdv),
        datasets: [
          {
            label: 'Chiffre d\'Affaires (DT)',
            data: caData.map(d => d.ca),
            backgroundColor: '#D97706',
            hoverBackgroundColor: '#B45309',
            borderRadius: 6,
            barPercentage: 0.72,
            categoryPercentage: 0.85
          }
        ]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        layout: {
          padding: { left: 5, right: 20, top: 5, bottom: 5 }
        },'''

if old_top_mag_block in code:
    code = code.replace(old_top_mag_block, new_top_mag_block, 1)
    print("Updated topMagasinsMockup chart options")
else:
    print("old_top_mag_block not matched directly")

# Update scales for topMagasinsMockup
old_scales = '''        scales: {
          x: { grid: { color: 'rgba(0,0,0,0.05)' } },
          y: { grid: { display: false } }
        }'''

new_scales = '''        scales: {
          x: {
            grid: { color: 'rgba(0,0,0,0.06)' },
            ticks: {
              font: { size: 12, weight: '700' },
              color: '#4B5563',
              callback: (val) => `${val} DT`
            }
          },
          y: {
            grid: { display: false },
            ticks: {
              font: { size: 12.5, weight: '700' },
              color: '#111827'
            }
          }
        }'''

# Replace only within the topMagasinsMockup options
pos_topmag = code.find('charts.topMagasinsMockup = new Chart')
if pos_topmag != -1:
    pos_scales = code.find('scales: {', pos_topmag)
    pos_scales_end = code.find('}\n      }\n    });', pos_scales)
    if pos_scales != -1 and pos_scales_end != -1:
        code = code[:pos_scales] + new_scales[8:] + code[pos_scales_end + 1:]
        print("Updated scales for topMagasinsMockup")

# 3. Add mapInstance.invalidateSize() in initLeafletMap and tab changes
old_map_init = "  window.liveMapRegions.forEach(r => {"
new_map_init = '''  setTimeout(() => {
    if (mapInstance) {
      mapInstance.invalidateSize();
      mapInstance.setView([35.2, 9.6], 6.0);
    }
  }, 250);

  window.liveMapRegions.forEach(r => {'''

if old_map_init in code:
    code = code.replace(old_map_init, new_map_init, 1)
    print("Added map invalidateSize on init")

with open('app.js', 'w', encoding='utf-8') as f:
    f.write(code)

shutil.copy('app.js', 'dashboard_bi/app.js')
print("app.js updated and synced to dashboard_bi/app.js")
