# -*- coding: utf-8 -*-
import os

fix_code = r'''
function initTopCadeauxVisual() {
  window.initTopCadeauxVisual = initTopCadeauxVisual;
  const canvas = document.getElementById('chart-top-cadeaux-bar');
  const tbody = document.getElementById('tbody-stocks-cadeaux');

  if (tbody) {
    tbody.innerHTML = TOP_10_CADEAUX_DATA.map(function(item) {
      return '<tr style="border-bottom: 1px solid rgba(0,0,0,0.05); transition: background 0.15s;">' +
        '<td style="padding: 9px 10px; font-weight: 800; color: #8E0E14;">#' + item.rang + '</td>' +
        '<td style="padding: 9px 10px; font-weight: 700; color: #1F2937;">' +
          item.nom +
          '<div style="font-size: 0.70rem; color: #6B7280; font-weight: 500;">' + item.coutPts.toLocaleString() + ' pts / unit\u00e9</div>' +
        '</td>' +
        '<td style="padding: 9px 10px; text-align: center;">' +
          '<span style="font-size: 0.70rem; font-weight: 700; padding: 2px 7px; border-radius: 4px; background: rgba(0,0,0,0.05); color: #4B5563;">' +
            item.tier +
          '</span>' +
        '</td>' +
        '<td style="padding: 9px 10px; text-align: right; font-weight: 800; color: #8E0E14;">' + item.delivres + '</td>' +
        '<td style="padding: 9px 10px; text-align: right; font-weight: 700; color: #111827;">' + item.stock + ' ex.</td>' +
        '<td style="padding: 9px 10px; text-align: center;">' +
          '<span class="tag-badge ' + item.badgeClass + '" style="font-size: 0.68rem; font-weight: 800; padding: 3px 8px;">' +
            item.statut +
          '</span>' +
        '</td>' +
      '</tr>';
    }).join('');
  }

  if (canvas) {
    if (charts.topCadeauxBar) {
      try { charts.topCadeauxBar.destroy(); } catch(e) {}
    }

    const labels = TOP_10_CADEAUX_DATA.map(function(d) { return d.nom.replace(' BO PFID', ''); });
    const dataDelivres = TOP_10_CADEAUX_DATA.map(function(d) { return d.delivres; });

    charts.topCadeauxBar = new Chart(canvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Cadeaux D\u00e9livr\u00e9s',
          data: dataDelivres,
          backgroundColor: [
            '#8E0E14', '#9B111E', '#AB1624', '#BC1B2A', '#CD2030',
            '#D97706', '#E58A15', '#EA9928', '#F0A93B', '#B45309'
          ],
          borderRadius: 6,
          barThickness: 16
        }]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(26, 12, 8, 0.95)',
            titleFont: { size: 12, weight: 'bold' },
            bodyFont: { size: 12, weight: '600' },
            padding: 12,
            cornerRadius: 8,
            callbacks: {
              label: function(context) {
                const item = TOP_10_CADEAUX_DATA[context.dataIndex];
                const totalPts = (item.delivres * item.coutPts).toLocaleString('fr-FR');
                const totalTnd = (item.delivres * item.valTnd).toFixed(3);
                return [
                  ' D\u00e9livr\u00e9s : ' + item.delivres + ' unit\u00e9s',
                  ' Co\u00fbt : ' + item.coutPts + ' pts / ex. (Total : ' + totalPts + ' pts)',
                  ' \u00c9quivalent : ' + totalTnd + ' TND'
                ];
              }
            }
          }
        },
        scales: {
          x: {
            beginAtZero: true,
            grid: { color: 'rgba(0, 0, 0, 0.05)' },
            ticks: { font: { size: 10, weight: '600' }, color: '#4B5563' }
          },
          y: {
            grid: { display: false },
            ticks: { font: { size: 11, weight: '700' }, color: '#1F2937' }
          }
        }
      }
    });
  }
}
'''

for path in [r'c:\ena w bonda\app.js', r'c:\ena w bonda\dashboard_bi\app.js']:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    idx = content.find('function initTopCadeauxVisual() {')
    if idx != -1:
        content = content[:idx] + fix_code.strip() + '\n'
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

print('Replaced initTopCadeauxVisual in both files!')
