import re

with open(r'c:\ena w bonda\dashboard_bi\app.js', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. FIX CHART.DEFAULTS ANIMATION & TOOLTIP
old_anim = '''// Configuration globale des courbes d'animation fluides Chart.js
if (typeof Chart !== 'undefined') {
  Chart.defaults.animation = {
    duration: 850,
    easing: 'easeOutQuart'
  };
}'''

new_anim = '''// Configuration globale de l'affichage des infobulles (Tooltips) et animations Chart.js
if (typeof Chart !== 'undefined' && Chart.defaults) {
  try {
    if (Chart.defaults.animation && typeof Chart.defaults.animation === 'object') {
      Chart.defaults.animation.duration = 600;
    }
  } catch (e) {}

  // Configuration universelle des infobulles (Tooltips interactives au survol)
  Chart.defaults.plugins = Chart.defaults.plugins || {};
  Chart.defaults.plugins.tooltip = Chart.defaults.plugins.tooltip || {};
  Chart.defaults.plugins.tooltip.enabled = true;
  Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(22, 14, 33, 0.94)';
  Chart.defaults.plugins.tooltip.titleColor = '#FFFFFF';
  Chart.defaults.plugins.tooltip.bodyColor = '#E9D5FF';
  Chart.defaults.plugins.tooltip.borderColor = '#8E4A9E';
  Chart.defaults.plugins.tooltip.borderWidth = 1.5;
  Chart.defaults.plugins.tooltip.padding = 10;
  Chart.defaults.plugins.tooltip.cornerRadius = 8;
  Chart.defaults.plugins.tooltip.displayColors = true;
}'''

if old_anim in code:
    code = code.replace(old_anim, new_anim, 1)
    print('1. Chart.defaults fixed!')
else:
    print('1. Warning: old_anim not found')

# 2. FIX INITSUBBARTABS RESIZE & UPDATE
old_tabs = '''        // Redimensionnement automatique de Leaflet et Chart.js
        setTimeout(() => {
          if (mapInstance) {
            mapInstance.invalidateSize();
          }
          Object.values(charts).forEach(c => {
            if (c && typeof c.resize === 'function') c.resize();
          });
        }, 80);'''

new_tabs = '''        // Redimensionnement et actualisation automatique de Leaflet et Chart.js
        setTimeout(() => {
          if (mapInstance && typeof mapInstance.invalidateSize === 'function') {
            try { mapInstance.invalidateSize(); } catch(e) {}
          }
          Object.values(charts).forEach(c => {
            if (c) {
              if (typeof c.resize === 'function') try { c.resize(); } catch(e) {}
              if (typeof c.update === 'function') try { c.update('none'); } catch(e) {}
            }
          });
        }, 80);'''

if old_tabs in code:
    code = code.replace(old_tabs, new_tabs, 1)
    print('2. initSubbarTabs fixed!')
else:
    print('2. Warning: old_tabs not found')

# 3. FIX WATERFALL & LTV TOOLTIPS
old_waterfall = '''  // --- CARTE WATERFALL DU TAB 3 ---
  const ctxWaterfall = document.getElementById('chart-waterfall-mockup');
  if (ctxWaterfall) {
    charts.waterfallMockup = new Chart(ctxWaterfall, {
      type: 'bar',
      data: {
        labels: ['1. Émis (Earn)', '2. Brûlés (Burn)', '3. Solde (Dette)'],
        datasets: [{
          data: [
            [0, 188294],
            [87794, 188294],
            [0, 87794]
          ],
          backgroundColor: ['#288764', '#DC2626', '#8E4A9E'],
          borderRadius: 5
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { display: false } },
          y: { grid: { color: 'rgba(0,0,0,0.05)' } }
        }
      }
    });
  }

  // --- CARTE LTV DU TAB 3 ---
  const ctxLTV = document.getElementById('chart-ltv-mockup');
  if (ctxLTV) {
    charts.ltvMockup = new Chart(ctxLTV, {
      type: 'bar',
      data: {
        labels: ['Champions VIP', 'Grossistes B2B', 'Réguliers', 'Occasionnels'],
        datasets: [{
          label: 'LTV (TND)',
          data: [289.83, 238.96, 51.70, 14.14],
          backgroundColor: ['#4B2B5E', '#6A2B7C', '#8E4A9E', '#B768C7'],
          borderRadius: 5
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        onClick: (event, elements) => {
          if (elements.length > 0) {
            const idx = elements[0].index;
            const ltvMap = [
              { dim: 'segment', code: 'champions', label: 'Champions VIP' },
              { dim: 'reseau', code: 'grossistes', label: 'Grossistes B2B' },
              { dim: 'segment', code: 'loyaux', label: 'Consommateurs Réguliers' },
              { dim: 'segment', code: 'hibernants', label: 'Clients Occasionnels' }
            ];
            if (ltvMap[idx]) {
              window.applyCrossFilter(ltvMap[idx].dim, ltvMap[idx].code, ltvMap[idx].label, 'ltv');
            }
          }
        },
        onHover: (event, elements) => {
          event.native.target.style.cursor = elements.length ? 'pointer' : 'default';
        },
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { display: false } },
          y: { grid: { color: 'rgba(0,0,0,0.05)' } }
        }
      }
    });
  }'''

new_waterfall = '''  // --- CARTE WATERFALL DU TAB 3 ---
  const ctxWaterfall = document.getElementById('chart-waterfall-mockup');
  if (ctxWaterfall) {
    charts.waterfallMockup = new Chart(ctxWaterfall, {
      type: 'bar',
      data: {
        labels: ['1. Émis (Earn)', '2. Brûlés (Burn)', '3. Solde (Dette)'],
        datasets: [{
          data: [
            [0, 188294],
            [87794, 188294],
            [0, 87794]
          ],
          backgroundColor: ['#288764', '#DC2626', '#8E4A9E'],
          borderRadius: 5
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        onHover: (event, elements) => {
          if (event && event.native && event.native.target) {
            event.native.target.style.cursor = (elements && elements.length) ? 'pointer' : 'default';
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            enabled: true,
            callbacks: {
              label: (ctx) => {
                const val = ctx.raw;
                if (Array.isArray(val)) {
                  const pts = val[1] - val[0];
                  return ' ' + ctx.label + ' : ' + pts.toLocaleString('fr-FR') + ' pts (' + (pts * 0.01).toFixed(3) + ' TND)';
                }
                return ' ' + ctx.label + ' : ' + val;
              }
            }
          }
        },
        scales: {
          x: { grid: { display: false } },
          y: {
            grid: { color: 'rgba(150,150,150,0.1)' },
            title: { display: true, text: "Points de Fidélité", font: { size: 10, weight: 600 } }
          }
        }
      }
    });
  }

  // --- CARTE LTV DU TAB 3 ---
  const ctxLTV = document.getElementById('chart-ltv-mockup');
  if (ctxLTV) {
    charts.ltvMockup = new Chart(ctxLTV, {
      type: 'bar',
      data: {
        labels: ['Champions VIP', 'Grossistes B2B', 'Réguliers', 'Occasionnels'],
        datasets: [{
          label: 'LTV (TND)',
          data: [289.83, 238.96, 51.70, 14.14],
          backgroundColor: ['#4B2B5E', '#6A2B7C', '#8E4A9E', '#B768C7'],
          borderRadius: 5
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        onClick: (event, elements) => {
          if (elements.length > 0) {
            const idx = elements[0].index;
            const ltvMap = [
              { dim: 'segment', code: 'champions', label: 'Champions VIP' },
              { dim: 'reseau', code: 'grossistes', label: 'Grossistes B2B' },
              { dim: 'segment', code: 'loyaux', label: 'Consommateurs Réguliers' },
              { dim: 'segment', code: 'hibernants', label: 'Clients Occasionnels' }
            ];
            if (ltvMap[idx]) {
              window.applyCrossFilter(ltvMap[idx].dim, ltvMap[idx].code, ltvMap[idx].label, 'ltv');
            }
          }
        },
        onHover: (event, elements) => {
          if (event && event.native && event.native.target) {
            event.native.target.style.cursor = (elements && elements.length) ? 'pointer' : 'default';
          }
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            enabled: true,
            callbacks: {
              label: (ctx) => ' Valeur LTV : ' + Number(ctx.raw).toFixed(3) + ' TND (Cliquer pour filtrer)'
            }
          }
        },
        scales: {
          x: { grid: { display: false } },
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(150,150,150,0.1)' },
            title: { display: true, text: "Customer Lifetime Value (TND)", font: { size: 10, weight: 600 } }
          }
        }
      }
    });
  }'''

if old_waterfall in code:
    code = code.replace(old_waterfall, new_waterfall, 1)
    print('3. Waterfall & LTV fixed!')
else:
    print('3. Warning: old_waterfall not found')

# 4. FIX ONHOVER IN ALL CHARTS SAFELY
code = re.sub(r'event\.native\.target\.style\.cursor\s*=\s*elements\.length\s*\?\s*\'pointer\'\s*:\s*\'default\';?',
              'if (event && event.native && event.native.target) { event.native.target.style.cursor = (elements && elements.length) ? "pointer" : "default"; }',
              code)
print('4. All onHover shielded!')

# 5. FIX LEAFLET FITBOUNDS
old_map_bounds = '''  setTimeout(() => {
    if (mapInstance) {
      mapInstance.invalidateSize();
      const bounds = L.latLngBounds(regionsData.map(r => [r.lat, r.lng]));
      mapInstance.fitBounds(bounds, { padding: [30, 30], maxZoom: 8 });
    }
  }, 150);'''

new_map_bounds = '''  setTimeout(() => {
    if (mapInstance && typeof L !== 'undefined') {
      try {
        mapInstance.invalidateSize();
        const validCoords = regionsData.filter(r => typeof r.lat === 'number' && !isNaN(r.lat) && typeof r.lng === 'number' && !isNaN(r.lng)).map(r => [r.lat, r.lng]);
        if (validCoords.length > 0) {
          const bounds = L.latLngBounds(validCoords);
          if (bounds.isValid()) {
            mapInstance.fitBounds(bounds, { padding: [30, 30], maxZoom: 8 });
          }
        }
      } catch(e) {
        console.warn("Leaflet fitBounds error:", e);
      }
    }
  }, 150);'''

if old_map_bounds in code:
    code = code.replace(old_map_bounds, new_map_bounds, 1)
    print('5. Leaflet fitBounds guarded!')

with open(r'c:\ena w bonda\dashboard_bi\app.js', 'w', encoding='utf-8') as f:
    f.write(code)

print('All patches written to app.js! Size:', len(code))
