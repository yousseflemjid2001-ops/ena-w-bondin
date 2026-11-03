import shutil

with open('app.js', 'r', encoding='utf-8') as f:
    app_code = f.read()

inscriptions_chart_code = """
// ==========================================================================
// 11. VISUALISATION DU RYTHME D'INSCRIPTIONS CRM (JOUR / MOIS / TRIMESTRE)
// ==========================================================================
window.currentInscriptionsGranularity = 'mois';

window.initInscriptionsChart = function() {
  const canvas = document.getElementById('chart-inscriptions-evolution');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  const tsData = (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.inscriptions_timeseries) 
    ? DASHBOARD_DATA.inscriptions_timeseries[window.currentInscriptionsGranularity] 
    : null;

  if (!tsData) return;

  if (charts.inscriptionsEvolution) {
    charts.inscriptionsEvolution.destroy();
  }

  // Création du gradient de fond prestige
  const gradient = ctx.createLinearGradient(0, 0, 0, 260);
  gradient.addColorStop(0, 'rgba(142, 14, 20, 0.38)');
  gradient.addColorStop(0.5, 'rgba(142, 14, 20, 0.12)');
  gradient.addColorStop(1, 'rgba(142, 14, 20, 0.01)');

  charts.inscriptionsEvolution = new Chart(canvas, {
    type: 'line',
    data: {
      labels: tsData.labels,
      datasets: [{
        label: tsData.unit,
        data: tsData.values,
        borderColor: '#8E0E14',
        borderWidth: 3,
        backgroundColor: gradient,
        fill: true,
        tension: 0.38,
        pointBackgroundColor: '#8E0E14',
        pointBorderColor: '#FFFFFF',
        pointBorderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 7,
        pointHoverBackgroundColor: '#B91C1C',
        pointHoverBorderColor: '#FFFFFF',
        pointHoverBorderWidth: 3
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        mode: 'index',
        intersect: false
      },
      plugins: {
        legend: {
          display: true,
          position: 'top',
          align: 'end',
          labels: {
            boxWidth: 12,
            boxHeight: 12,
            usePointStyle: true,
            font: { size: 11, weight: '700' },
            color: '#4B5563'
          }
        },
        tooltip: {
          backgroundColor: 'rgba(26, 12, 8, 0.95)',
          titleFont: { size: 12, weight: 'bold' },
          bodyFont: { size: 13, weight: '600' },
          padding: 12,
          cornerRadius: 8,
          borderColor: 'rgba(217, 119, 6, 0.4)',
          borderWidth: 1,
          displayColors: false,
          callbacks: {
            title: (items) => `Période : ${items[0].label}`,
            label: (ctx) => `👥 Inscriptions validées : ${ctx.raw.toLocaleString('fr-FR')} adhérents`
          }
        }
      },
      scales: {
        x: {
          grid: {
            display: false
          },
          ticks: {
            font: { size: 11, weight: '600' },
            color: '#4B5563',
            maxRotation: 45
          }
        },
        y: {
          beginAtZero: true,
          grid: {
            color: 'rgba(0, 0, 0, 0.06)',
            borderDash: [3, 3]
          },
          ticks: {
            font: { size: 11, weight: '600' },
            color: '#6B7280',
            callback: (v) => v.toLocaleString('fr-FR')
          }
        }
      }
    }
  });

  // Mettre à jour le badge
  const badge = document.getElementById('inscriptions-chart-badge');
  if (badge && tsData.badge) {
    badge.innerText = tsData.badge;
  }
};

window.setInscriptionsGranularity = function(granularity) {
  if (!granularity || !['jour', 'mois', 'trimestre'].includes(granularity)) return;
  window.currentInscriptionsGranularity = granularity;

  // Mise à jour visuelle des boutons
  ['jour', 'mois', 'trimestre'].forEach(g => {
    const btn = document.getElementById('btn-inscri-' + g);
    if (btn) {
      if (g === granularity) {
        btn.classList.add('active');
        btn.style.background = '#8E0E14';
        btn.style.color = '#FFFFFF';
        btn.style.boxShadow = '0 2px 6px rgba(142,14,20,0.3)';
      } else {
        btn.classList.remove('active');
        btn.style.background = 'transparent';
        btn.style.color = '#4B5563';
        btn.style.boxShadow = 'none';
      }
    }
  });

  const tsData = (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.inscriptions_timeseries) 
    ? DASHBOARD_DATA.inscriptions_timeseries[granularity] 
    : null;

  if (tsData) {
    const badge = document.getElementById('inscriptions-chart-badge');
    if (badge && tsData.badge) {
      badge.innerText = tsData.badge;
    }

    if (charts.inscriptionsEvolution) {
      charts.inscriptionsEvolution.data.labels = tsData.labels;
      charts.inscriptionsEvolution.data.datasets[0].data = tsData.values;
      charts.inscriptionsEvolution.data.datasets[0].label = tsData.unit;
      charts.inscriptionsEvolution.update();
    } else {
      window.initInscriptionsChart();
    }
  }

  if (typeof showToast === 'function') {
    const labelsMap = { 'jour': 'Journalière (Octobre)', 'mois': 'Mensuelle (2025-2026)', 'trimestre': 'Trimestrielle (Q)' };
    showToast(`Rythme Inscriptions : Échelle ${labelsMap[granularity]} activée`, 'info');
  }
};
"""

if 'setInscriptionsGranularity' not in app_code:
    app_code += "\n" + inscriptions_chart_code + "\n"
    with open('app.js', 'w', encoding='utf-8') as f:
        f.write(app_code)
    print("Added setInscriptionsGranularity to app.js")

shutil.copy('app.js', 'dashboard_bi/app.js')
print("Synced app.js to dashboard_bi/app.js")
