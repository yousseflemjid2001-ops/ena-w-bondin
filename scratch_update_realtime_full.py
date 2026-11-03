import shutil, re

with open('app.js', 'r', encoding='utf-8') as f:
    app_code = f.read()

# 1. Update renderDecompositionTree to support liveCA
old_decomp_fn = '''function renderDecompositionTree() {
  const container = document.getElementById('decomp-tree-container');
  if (!container) return;

  const tree = DASHBOARD_DATA.decomposition_tree;

  container.innerHTML = `
    <div class="decomp-tree-flex">
      
      <!-- Racine -->
      <div class="decomp-root-card">
        <div class="decomp-title-root">SOURCE GLOBALE</div>
        <div class="decomp-label-root">${tree.label}</div>
        <div class="decomp-value-root">59 480,655 DT</div>
        <div class="decomp-bar-track">
          <div class="decomp-bar-fill" style="width: 100%;"></div>
        </div>
      </div>

      <!-- Niveau 1 : Segments -->
      <div class="decomp-col-segments">
        ${tree.children.map((seg, idx) => `
          <div class="decomp-node-card ${idx === 0 ? 'active' : ''}" onclick="selectDecompSegmentMockup(${idx})">
            <div class="decomp-node-header">
              <span>${seg.label}</span>
              <span class="decomp-pct-text">${seg.pct}%</span>
            </div>
            <div class="decomp-node-val">${Number(seg.valeur).toLocaleString('fr-FR')} DT</div>
            <div class="decomp-bar-track">
              <div class="decomp-bar-fill" style="width: ${seg.pct}%;"></div>
            </div>
          </div>
        `).join('')}
      </div>

      <!-- Niveau 2 : Gammes -->
      <div id="col-gammes-mockup" class="decomp-col-gammes">
        ${tree.children[0].children.map(g => `
          <div class="decomp-node-card">
            <div class="decomp-node-header">
              <span>${g.label}</span>
              <span class="decomp-pct-text blue">${g.pct}%</span>
            </div>
            <div class="decomp-node-val">${Number(g.valeur).toLocaleString('fr-FR')} DT</div>
            <div class="decomp-bar-track">
              <div class="decomp-bar-fill blue" style="width: ${g.pct}%;"></div>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}'''

new_decomp_fn = '''function renderDecompositionTree(liveCA) {
  const container = document.getElementById('decomp-tree-container');
  if (!container) return;

  const scale = liveCA ? (Number(liveCA) / 153316.55) : 1;
  const tree = DASHBOARD_DATA.decomposition_tree;
  const rootVal = (59480.655 * scale).toFixed(3);

  container.innerHTML = `
    <div class="decomp-tree-flex">
      
      <!-- Racine -->
      <div class="decomp-root-card">
        <div class="decomp-title-root">SOURCE GLOBALE</div>
        <div class="decomp-label-root">${tree.label}</div>
        <div class="decomp-value-root">${Number(rootVal).toLocaleString('fr-FR', {minimumFractionDigits: 3, maximumFractionDigits: 3})} DT</div>
        <div class="decomp-bar-track">
          <div class="decomp-bar-fill" style="width: 100%;"></div>
        </div>
      </div>

      <!-- Niveau 1 : Segments -->
      <div class="decomp-col-segments">
        ${tree.children.map((seg, idx) => `
          <div class="decomp-node-card ${idx === 0 ? 'active' : ''}" onclick="selectDecompSegmentMockup(${idx})">
            <div class="decomp-node-header">
              <span>${seg.label}</span>
              <span class="decomp-pct-text">${seg.pct}%</span>
            </div>
            <div class="decomp-node-val">${Math.round(Number(seg.valeur) * scale).toLocaleString('fr-FR')} DT</div>
            <div class="decomp-bar-track">
              <div class="decomp-bar-fill" style="width: ${seg.pct}%;"></div>
            </div>
          </div>
        `).join('')}
      </div>

      <!-- Niveau 2 : Gammes -->
      <div id="col-gammes-mockup" class="decomp-col-gammes">
        ${tree.children[0].children.map(g => `
          <div class="decomp-node-card">
            <div class="decomp-node-header">
              <span>${g.label}</span>
              <span class="decomp-pct-text blue">${g.pct}%</span>
            </div>
            <div class="decomp-node-val">${Math.round(Number(g.valeur) * scale).toLocaleString('fr-FR')} DT</div>
            <div class="decomp-bar-track">
              <div class="decomp-bar-fill blue" style="width: ${g.pct}%;"></div>
            </div>
          </div>
        `).join('')}
      </div>

    </div>
  `;
}'''

if old_decomp_fn in app_code:
    app_code = app_code.replace(old_decomp_fn, new_decomp_fn, 1)
    print("Updated renderDecompositionTree with liveCA parameter")

# 2. Update renderInscritsTable cells with ellipsis styling
old_inscrits_rows = '''      <tr>
        <td style="text-align: center; font-weight: 700; color: #9CA3AF; font-size: 0.75rem;">${globalIdx}</td>
        <td style="font-family: monospace; font-size: 0.8rem; color: #4B5563;">${item.date}</td>
        <td>
          <div style="font-weight: 700; color: var(--text-primary); font-size: 0.85rem;">${item.nom}</div>
          <div style="font-size: 10px; opacity: 0.65; font-family: monospace;">${item.id}</div>
        </td>
        <td>
          <div style="font-weight: 600; color: #1F2937; font-size: 0.82rem; white-space: nowrap;">
            <span style="color: #8E0E14; margin-right: 2px;">📞</span>${item.tel}
          </div>
        </td>
        <td>
          <div style="color: #4B5563; font-size: 0.8rem; font-family: monospace;">
            <a href="mailto:${item.email}" style="color: inherit; text-decoration: none;">${item.email}</a>
          </div>
        </td>
        <td>
          <div style="font-weight: 600; color: #374151; font-size: 0.82rem;">${item.magasin}</div>
        </td>
        <td style="text-align: center;">
          <span style="font-weight: 800; color: ${item.achats > 0 ? '#8E0E14' : '#9CA3AF'}; font-size: 0.85rem;">
            ${item.achats}
          </span>
        </td>
        <td style="text-align: center;">
          <span class="tag-badge gold" style="font-weight: 800; font-size: 0.78rem;">
            ${item.points.toLocaleString('fr-FR')} pts
          </span>
        </td>
        <td style="text-align: center;">
          <span class="tag-badge ${badgeClass}" style="font-size: 0.72rem;">${item.statut || 'Nouveau Membre'}</span>
        </td>
      </tr>'''

new_inscrits_rows = '''      <tr>
        <td style="text-align: center; font-weight: 700; color: #9CA3AF; font-size: 0.75rem;">${globalIdx}</td>
        <td style="font-family: monospace; font-size: 0.78rem; color: #4B5563; white-space: nowrap;">${item.date}</td>
        <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
          <div style="font-weight: 700; color: var(--text-primary); font-size: 0.83rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${item.nom}</div>
          <div style="font-size: 10px; opacity: 0.65; font-family: monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${item.id}</div>
        </td>
        <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
          <div style="font-weight: 600; color: #1F2937; font-size: 0.80rem; white-space: nowrap;">
            <span style="color: #8E0E14; margin-right: 2px;">📞</span>${item.tel}
          </div>
        </td>
        <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
          <div style="color: #4B5563; font-size: 0.78rem; font-family: monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
            <a href="mailto:${item.email}" style="color: inherit; text-decoration: none;" title="${item.email}">${item.email}</a>
          </div>
        </td>
        <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
          <div style="font-weight: 600; color: #374151; font-size: 0.80rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${item.magasin}</div>
        </td>
        <td style="text-align: center; white-space: nowrap;">
          <span style="font-weight: 800; color: ${item.achats > 0 ? '#8E0E14' : '#9CA3AF'}; font-size: 0.82rem;">
            ${item.achats}
          </span>
        </td>
        <td style="text-align: center; white-space: nowrap;">
          <span class="tag-badge gold" style="font-weight: 800; font-size: 0.75rem; padding: 2px 6px;">
            ${item.points.toLocaleString('fr-FR')} pts
          </span>
        </td>
        <td style="text-align: center; white-space: nowrap;">
          <span class="tag-badge ${badgeClass}" style="font-size: 0.70rem; padding: 2px 6px;">${item.statut || 'Nouveau Membre'}</span>
        </td>
      </tr>'''

if old_inscrits_rows in app_code:
    app_code = app_code.replace(old_inscrits_rows, new_inscrits_rows, 1)
    print("Updated renderInscritsTable rows with ellipsis")

# 3. Update updateFilteredTables grossistes rows with ellipsis
old_grossistes_rows = '''        <tr>
          <td>
            <div style="font-weight: 700; color: var(--text-primary); font-size: 0.85rem;">${g.nom || g.id}</div>
            <div style="font-size: 11px; opacity: 0.7; font-family: monospace;">${g.id}</div>
          </td>
          <td>
            <div style="font-weight: 600; color: #374151; font-size: 0.82rem; white-space: nowrap;">
              <span style="color: #8E0E14; margin-right: 3px;">📞</span>${telVal}
            </div>
          </td>
          <td>
            <div style="color: #4B5563; font-size: 0.8rem; font-family: monospace;">
              <a href="mailto:${emailVal}" style="color: inherit; text-decoration: none;">${emailVal}</a>
            </div>
          </td>
          <td style="text-align: right;"><strong style="color: #111827; font-size: 0.88rem;">${tVal.toFixed(3)} DT</strong></td>
          <td style="text-align: center;"><span class="tag-badge gold" style="font-weight: 800; font-size: 0.78rem;">${ptsVal.toLocaleString('fr-FR')} pts</span></td>
          <td style="text-align: right;"><strong style="color: #8E0E14">${sVal.toFixed(3)} DT</strong></td>
          <td style="text-align: right; color: #4B5563;">${cVal.toFixed(3)} DT</td>
          <td style="text-align: right; font-weight: 600;">${maxVal.toFixed(2)} DT</td>
          <td style="text-align: center;"><span class="tag-badge ${g.freq_sem >= 3 ? 'gold' : 'info'}">${g.freq_sem} / sem</span></td>
          <td style="text-align: center;"><span class="tag-badge ${g.status && g.status.includes('Alerte') ? 'alert' : 'gold'}">${g.status}</span></td>
        </tr>'''

new_grossistes_rows = '''        <tr>
          <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
            <div style="font-weight: 700; color: var(--text-primary); font-size: 0.83rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${g.nom || g.id}</div>
            <div style="font-size: 10px; opacity: 0.7; font-family: monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${g.id}</div>
          </td>
          <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
            <div style="font-weight: 600; color: #374151; font-size: 0.80rem; white-space: nowrap;">
              <span style="color: #8E0E14; margin-right: 2px;">📞</span>${telVal}
            </div>
          </td>
          <td style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
            <div style="color: #4B5563; font-size: 0.78rem; font-family: monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
              <a href="mailto:${emailVal}" style="color: inherit; text-decoration: none;" title="${emailVal}">${emailVal}</a>
            </div>
          </td>
          <td style="text-align: right; white-space: nowrap;"><strong style="color: #111827; font-size: 0.85rem;">${tVal.toFixed(3)} DT</strong></td>
          <td style="text-align: center; white-space: nowrap;"><span class="tag-badge gold" style="font-weight: 800; font-size: 0.75rem; padding: 2px 6px;">${ptsVal.toLocaleString('fr-FR')} pts</span></td>
          <td style="text-align: right; white-space: nowrap;"><strong style="color: #8E0E14; font-size: 0.82rem;">${sVal.toFixed(3)} DT</strong></td>
          <td style="text-align: right; color: #4B5563; font-size: 0.82rem; white-space: nowrap;">${cVal.toFixed(3)} DT</td>
          <td style="text-align: right; font-weight: 600; font-size: 0.82rem; white-space: nowrap;">${maxVal.toFixed(2)} DT</td>
          <td style="text-align: center; white-space: nowrap;"><span class="tag-badge ${g.freq_sem >= 3 ? 'gold' : 'info'}" style="font-size: 0.70rem; padding: 2px 6px;">${g.freq_sem}/s</span></td>
          <td style="text-align: center; white-space: nowrap;"><span class="tag-badge ${g.status && g.status.includes('Alerte') ? 'alert' : 'gold'}" style="font-size: 0.70rem; padding: 2px 6px;">${g.status}</span></td>
        </tr>'''

if old_grossistes_rows in app_code:
    app_code = app_code.replace(old_grossistes_rows, new_grossistes_rows, 1)
    print("Updated grossistes table rows with ellipsis")

# 4. Replace entire triggerLiveTransactionStep with comprehensive real-time engine
old_trigger_start = "window.triggerLiveTransactionStep = function() {"
old_trigger_end = "window.toggleLiveStreaming = function() {"

start_idx = app_code.find(old_trigger_start)
end_idx = app_code.find(old_trigger_end)

if start_idx != -1 and end_idx != -1:
    new_trigger_code = '''window.triggerLiveTransactionStep = function() {
  const stores = [
    { name: "Cafétéria Le Kef", pdv: "Cafétéria Le Kef" },
    { name: "Cafétéria Tunis Liberté", pdv: "Cafétéria Tunis Liberté" },
    { name: "Cafétéria Tunis La Marsa", pdv: "Cafétéria Tunis La Marsa" },
    { name: "Cafétéria Tunis MENZAH VI", pdv: "Cafétéria Tunis MENZAH VI" },
    { name: "Succursale Tunis Menzah VI", pdv: "Succursale Tunis Menzah VI" },
    { name: "Cafétéria Tunis France", pdv: "Cafétéria Tunis France" },
    { name: "Succursale Tunis Liberté", pdv: "Succursale Tunis Liberté" },
    { name: "Succursale Gafsa", pdv: "Succursale Gafsa" },
    { name: "Cafétéria Gafsa Ville", pdv: "Cafétéria Gafsa Ville" },
    { name: "Succursale Gabès Jara", pdv: "Succursale Gabès Jara" },
    { name: "Succursale Sfax Moulinville", pdv: "Succursale Sfax Moulinville" },
    { name: "Succursale Sousse Corniche", pdv: "Succursale Sousse Corniche" }
  ];

  const clients = [
    "Mondher Trabelsi", "Amira Ben Romdhane", "Sonia Bouazizi", "Yassine Dridi",
    "Leila Jaziri", "Néji Ben Amor (VIP)", "Amine Bouaziz (Ambassadeur)", "Dorra Rihani",
    "Slim Abid", "Sarra Mansour", "Kamel Dridi", "Mariem Chebbi",
    "Walid Khemir", "Nizar Gharbi", "Hichem Miled", "Inès Belhadj",
    "Zied Ferchichi", "Farah Ben Achour", "Tarek Louati", "Bilel Hammami",
    "Olfa Mahjoub", "Karim Chaabane", "Anis Dakhli", "Sofiene Marzouki"
  ];

  const chosenStore = stores[Math.floor(Math.random() * stores.length)];
  const chosenClient = clients[Math.floor(Math.random() * clients.length)];
  const amount = Math.round((2.100 + Math.random() * 26.500) * 1000) / 1000;
  const points = Math.round(amount * 10);
  const ticket = 'bondin' + Math.floor(6170000 + Math.random() * 20000);
  const now = new Date();
  const dateStr = now.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' }) + ' ' + now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });

  // 1. Incrémenter Scans et CA en temps réel
  lastKnownScansCount = (lastKnownScansCount || 13317) + 1;
  lastKnownCaAmount = Math.round(((lastKnownCaAmount || 156158.84) + amount) * 100) / 100;
  window.currentLiveCA = lastKnownCaAmount;

  // 2. Mettre à jour DASHBOARD_DATA
  if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.kpis) {
    DASHBOARD_DATA.kpis.ca_total = lastKnownCaAmount;
    DASHBOARD_DATA.kpis.nb_scans = lastKnownScansCount;
    DASHBOARD_DATA.kpis.panier_moyen = Math.round((lastKnownCaAmount / lastKnownScansCount) * 1000) / 1000;
  }

  // 3. Compteur Scans HUD et KPIs Exécutifs avec animation
  const scanCounter = document.getElementById('scan-counter');
  if (scanCounter) {
    scanCounter.innerText = lastKnownScansCount.toLocaleString('fr-FR');
    scanCounter.classList.add('counter-bump');
    setTimeout(() => scanCounter.classList.remove('counter-bump'), 400);
  }

  const kpiCa = document.getElementById('kpi-ca-val') || document.getElementById('ctx-total-ca');
  if (kpiCa) {
    kpiCa.innerText = `${Math.round(lastKnownCaAmount).toLocaleString('fr-FR')} DT`;
  }
  const kpiScans = document.getElementById('kpi-scans-summary') || document.getElementById('ctx-scans');
  if (kpiScans) {
    kpiScans.innerText = `${lastKnownScansCount.toLocaleString('fr-FR')} scans`;
  }
  const kpiAov = document.getElementById('kpi-aov-val');
  if (kpiAov && lastKnownScansCount > 0) {
    kpiAov.innerText = `${(lastKnownCaAmount / lastKnownScansCount).toFixed(2)} DT`;
  }

  // 4. Header Ticker direct
  const clock = document.getElementById('hdr-live-clock');
  if (clock) {
    clock.innerHTML = `Client : <strong class="text-white font-bold">${chosenClient}</strong> &bull; Montant : <strong class="text-emerald-400 font-bold">+${amount.toFixed(3)} DT</strong> &bull; Ticket <span class="text-amber-300 font-bold">#${ticket}</span> <span class="text-amber-200/90 font-sans">(${chosenStore.name})</span>`;
    clock.classList.remove('ticket-slide-enter');
    void clock.offsetWidth;
    clock.classList.add('ticket-slide-enter');
  }

  // 5. Donut Répartition & Center Count (Temps Réel)
  const centerNum = document.getElementById('donut-center-num');
  if (centerNum) {
    const curVal = parseInt(centerNum.innerText.replace(/\\s/g, '')) || 527;
    centerNum.innerText = (curVal + 1).toLocaleString('fr-FR');
  }
  if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.rapport_repartition_pdv) {
    const item = DASHBOARD_DATA.rapport_repartition_pdv.find(p => chosenStore.name.includes(p.pdv) || p.pdv.includes(chosenStore.name));
    if (item) item.achats = (item.achats || 0) + 1;
    const totalAchats = DASHBOARD_DATA.rapport_repartition_pdv.reduce((a, b) => a + (b.achats || 0), 0);
    DASHBOARD_DATA.rapport_repartition_pdv.forEach(p => {
      p.pct = Math.round((p.achats / totalAchats) * 100);
    });
    if (charts.donutEtablissement) {
      charts.donutEtablissement.data.datasets[0].data = DASHBOARD_DATA.rapport_repartition_pdv.map(d => d.pct);
      charts.donutEtablissement.update('none');
    }
  }

  // 6. Classement PDV - Achats (Temps Réel)
  if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.rapport_top_pdv_achats) {
    let item = DASHBOARD_DATA.rapport_top_pdv_achats.find(p => chosenStore.name.includes(p.pdv) || p.pdv.includes(chosenStore.name));
    if (item) {
      item.achats = (item.achats || 0) + 1;
      item.ca = Math.round(((item.ca || 0) + amount) * 100) / 100;
    }
    DASHBOARD_DATA.rapport_top_pdv_achats.sort((a, b) => b.achats - a.achats);
    if (charts.topPdvAchats) {
      charts.topPdvAchats.data.labels = DASHBOARD_DATA.rapport_top_pdv_achats.map(d => d.pdv);
      charts.topPdvAchats.data.datasets[0].data = DASHBOARD_DATA.rapport_top_pdv_achats.map(d => d.achats);
      charts.topPdvAchats.update('none');
    }
  }

  // 7. Classement PDV - CA DT (Temps Réel)
  if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.rapport_top_pdv_ca) {
    let item = DASHBOARD_DATA.rapport_top_pdv_ca.find(p => chosenStore.name.includes(p.pdv) || p.pdv.includes(chosenStore.name));
    if (item) {
      item.ca = Math.round(((item.ca || 0) + amount) * 100) / 100;
    }
    DASHBOARD_DATA.rapport_top_pdv_ca.sort((a, b) => b.ca - a.ca);
    if (charts.topMagasinsMockup) {
      charts.topMagasinsMockup.data.labels = DASHBOARD_DATA.rapport_top_pdv_ca.map(d => d.pdv);
      charts.topMagasinsMockup.data.datasets[0].data = DASHBOARD_DATA.rapport_top_pdv_ca.map(d => d.ca);
      charts.topMagasinsMockup.update('none');
    }
  }

  // 8. Animation de la Cartographie (Bulle beacon sur Leaflet)
  const scanObj = {
    ticket: ticket,
    client: chosenClient,
    magasin: chosenStore.name,
    montant_tnd: amount,
    points: points,
    date: dateStr
  };
  window.updateMapLiveFeed(scanObj);

  // 9. Tableau Live Transactions (Tab 2)
  const tbodyLive = document.getElementById('tbody-live-transactions');
  if (tbodyLive) {
    const initials = chosenClient.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();
    const tr = document.createElement('tr');
    tr.className = 'bg-emerald-500/15 border-l-4 border-emerald-500 font-semibold';
    tr.innerHTML = `
      <td>
        <span class="inline-block px-2.5 py-1 rounded-md font-mono font-bold text-xs text-amber-900 dark:text-amber-300 bg-amber-500/15 border border-amber-500/40 shadow-sm">
          #${ticket}
        </span>
      </td>
      <td>
        <div style="display: flex; align-items: center; gap: 8px;">
          <div style="width: 28px; height: 28px; border-radius: 50%; background: linear-gradient(135deg, #8E0E14 0%, #C31C23 100%); color: #FFF; font-size: 11px; font-weight: 900; display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: 0 1px 4px rgba(142, 14, 20, 0.35);">
            ${initials}
          </div>
          <div>
            <strong class="text-slate-900 dark:text-slate-100" style="font-size: 0.86rem; display: block; line-height: 1.2;">${chosenClient}</strong>
            <span style="font-size: 11px; font-family: monospace; color: #D97706; font-weight: 600;">N° Ticket : #${ticket}</span>
          </div>
        </div>
      </td>
      <td><strong class="text-slate-900 dark:text-slate-100">${chosenStore.name}</strong></td>
      <td><strong class="text-emerald-700 dark:text-emerald-400 font-mono text-[13px] font-bold">${amount.toFixed(3)} DT</strong></td>
      <td><span class="tag-badge gold font-bold">+${points} pts</span></td>
      <td><span class="font-mono text-xs font-medium text-slate-700 dark:text-slate-300">${dateStr}</span></td>
      <td><span class="tag-badge green flex items-center gap-1 font-semibold"><span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>✓ Enregistré DWH</span></td>
    `;
    tbodyLive.insertBefore(tr, tbodyLive.firstChild);
    if (tbodyLive.children.length > 8) {
      tbodyLive.removeChild(tbodyLive.lastChild);
    }
  }

  // 10. Inscrits CRM & Graphique d'Évolution (Cadence régulière temps réel)
  if (Math.random() < 0.35 && typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.inscrits_list) {
    const firstNames = ["Syrine", "Mohamed", "Hedi", "Yasmine", "Bilel", "Chaima", "Kais", "Rim", "Aziz", "Mariem", "Youssef", "Nour", "Sami", "Farah", "Anis", "Meriem"];
    const lastNames = ["Bouazizi", "Trabelsi", "Ben Amor", "Gharbi", "Dridi", "Mansour", "Karray", "Ayari", "Khemir", "Jaziri", "Miled", "Belhadj"];
    const fn = firstNames[Math.floor(Math.random() * firstNames.length)];
    const ln = lastNames[Math.floor(Math.random() * lastNames.length)];
    const newClientNom = `${fn} ${ln}`;
    const newClientEmail = `${fn.toLowerCase()}.${ln.toLowerCase()}${Math.floor(Math.random() * 90 + 10)}@gmail.com`;
    const newClientTel = `+216 ${[20,21,22,23,24,25,26,27,28,29,50,51,52,53,54,55,90,91,92,93,94,95,96,97,98,99][Math.floor(Math.random()*26)]} ${Math.floor(100+Math.random()*899)} ${Math.floor(100+Math.random()*899)}`;
    const newId = 'CLI_' + Math.random().toString(36).substring(2, 12).toUpperCase();
    
    const newInscrit = {
      id: newId,
      nom: newClientNom,
      date: new Date().toISOString().split('T')[0],
      tel: newClientTel,
      email: newClientEmail,
      magasin: chosenStore.name,
      achats: 1,
      points: points,
      segment: "Nouveau Membre",
      statut: "Adhésion Validée"
    };

    DASHBOARD_DATA.inscrits_list.unshift(newInscrit);
    if (typeof window.renderInscritsTable === 'function') {
      window.renderInscritsTable();
    }

    // Incrémenter les séries temporelles du graphique d'inscriptions
    if (DASHBOARD_DATA.inscriptions_timeseries) {
      const ts = DASHBOARD_DATA.inscriptions_timeseries;
      if (ts.jour && ts.jour.values) {
        ts.jour.values[ts.jour.values.length - 1] += 1;
        ts.jour.total += 1;
        ts.jour.badge = `${ts.jour.total} Inscrits · Octobre 2026`;
      }
      if (ts.mois && ts.mois.values) {
        ts.mois.values[ts.mois.values.length - 1] += 1;
        ts.mois.total += 1;
        ts.mois.badge = `${ts.mois.total.toLocaleString('fr-FR')} Inscrits · Base CRM`;
      }
      if (ts.trimestre && ts.trimestre.values) {
        ts.trimestre.values[ts.trimestre.values.length - 1] += 1;
        ts.trimestre.total += 1;
      }

      // Mise à jour du graphique Chart.js
      if (charts.inscriptionsEvolution) {
        const curGrain = window.currentInscriptionsGranularity || 'mois';
        const curTs = ts[curGrain];
        charts.inscriptionsEvolution.data.datasets[0].data = curTs.values;
        charts.inscriptionsEvolution.update('none');

        const badge = document.getElementById('inscriptions-chart-badge');
        if (badge && curTs.badge) badge.innerText = curTs.badge;
      }

      // Mise à jour du badge récapitulatif
      const totalCrmEl = document.getElementById('badge-total-crm-count');
      if (totalCrmEl && ts.mois) {
        totalCrmEl.innerText = `${ts.mois.total.toLocaleString('fr-FR')} membres`;
      }
      const kpiInscrits = document.getElementById('kpi-inscrits-val');
      if (kpiInscrits && ts.mois) {
        kpiInscrits.innerText = `${(759 + (ts.mois.total - 2715)).toLocaleString('fr-FR')} clients`;
      }
    }
  }

  // 11. Grossistes & B2B en temps réel
  if (chosenStore.name.includes('Succursale') || Math.random() < 0.25) {
    if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.top_grossistes_table && DASHBOARD_DATA.top_grossistes_table.length > 0) {
      const gIdx = Math.floor(Math.random() * Math.min(5, DASHBOARD_DATA.top_grossistes_table.length));
      const g = DASHBOARD_DATA.top_grossistes_table[gIdx];
      g.succ = Math.round((g.succ + amount) * 1000) / 1000;
      g.total = Math.round((g.total + amount) * 1000) / 1000;
      g.points = (g.points || Math.round(g.total * 10)) + points;
      if (amount > (g.max_succ || 0)) g.max_succ = Math.round(amount * 100) / 100;

      // Actualiser les tableaux sans réinitialiser la pagination
      renderTables(lastKnownCaAmount);
    }
  }

  // 12. Arbre de Décomposition Stratégique du CA en temps réel
  if (typeof renderDecompositionTree === 'function') {
    renderDecompositionTree(lastKnownCaAmount);
  }

  // 13. Gammes empilées (Tab 2)
  if (charts.gammesStacked && charts.gammesStacked.data.datasets) {
    const dsIdx = Math.floor(Math.random() * charts.gammesStacked.data.datasets.length);
    const ds = charts.gammesStacked.data.datasets[dsIdx];
    if (ds && ds.data) {
      const dIdx = Math.floor(Math.random() * ds.data.length);
      ds.data[dIdx] = Math.round((ds.data[dIdx] + amount) * 100) / 100;
      charts.gammesStacked.update('none');
    }
  }
};

'''
    app_code = app_code[:start_idx] + new_trigger_code + app_code[end_idx:]
    print("Replaced triggerLiveTransactionStep with comprehensive real-time engine")

with open('app.js', 'w', encoding='utf-8') as f:
    f.write(app_code)

shutil.copy('app.js', 'dashboard_bi/app.js')
print("Synced app.js to dashboard_bi/app.js")
