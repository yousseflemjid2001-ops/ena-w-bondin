import shutil

# 1. Update index.html to add the prominent live stream badge button
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

old_simulate_btn = '''          <!-- Bouton Test & Simulation Scan Caisse Live -->
          <button id="btn-simulate-scan" onclick="window.simulateLiveScan()" class="group relative inline-flex items-center gap-1.5 px-3 py-2.5 rounded-xl text-xs font-semibold text-amber-200 bg-amber-500/10 hover:bg-amber-500/25 border border-amber-400/30 hover:border-amber-400/60 backdrop-blur-md transition-all duration-300 active:scale-95 shadow-sm" title="Simuler un ticket de caisse en direct (+18,500 TND) et observer la propagation instantanée">
            <i data-lucide="zap" class="w-3.5 h-3.5 text-amber-300 fill-amber-300/20"></i>
            <span class="hidden xl:inline font-bold">Simuler Scan</span>
          </button>'''

new_live_controls = '''          <!-- Badge & Contrôle Flux DWH Continu en Temps Réel -->
          <button id="btn-toggle-live-stream" onclick="window.toggleLiveStreaming()" 
            class="group relative inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs sm:text-sm font-bold bg-emerald-500/15 text-emerald-200 border border-emerald-400/50 hover:bg-emerald-500/25 transition-all duration-300 active:scale-95 shadow-[0_0_15px_rgba(16,185,129,0.25)]" 
            title="Activer ou mettre en pause le streaming continu en direct de transactions caisse (3.5s)">
            <span class="live-dot-pulse" style="width: 8px; height: 8px; background: #10B981;"></span>
            <span id="label-live-stream">Temps Réel : ACTIF (3.5s)</span>
          </button>

          <!-- Bouton Scan Manuel Express -->
          <button id="btn-simulate-scan" onclick="window.simulateLiveScan()" class="group relative inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold text-amber-200 bg-amber-500/10 hover:bg-amber-500/25 border border-amber-400/30 hover:border-amber-400/60 backdrop-blur-md transition-all duration-300 active:scale-95 shadow-sm" title="Injecter un ticket de caisse immédiat">
            <i data-lucide="zap" class="w-3.5 h-3.5 text-amber-300 fill-amber-300/20"></i>
            <span class="hidden xl:inline font-bold">+1 Scan Direct</span>
          </button>'''

if old_simulate_btn in html:
    html = html.replace(old_simulate_btn, new_live_controls, 1)
    print("Replaced simulate button with live streaming controls in index.html")
else:
    print("old_simulate_btn not found directly in index.html")

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)
shutil.copy('index.html', 'dashboard_bi/index.html')


# 2. Add real-time engine to app.js
with open('app.js', 'r', encoding='utf-8') as f:
    code = f.read()

# Add window.startLiveStreamLoop() to DOMContentLoaded
old_dcl_call = "  if (typeof window.renderInscritsTable === 'function') window.renderInscritsTable();"
new_dcl_call = '''  if (typeof window.renderInscritsTable === 'function') window.renderInscritsTable();
  if (typeof window.startLiveStreamLoop === 'function') window.startLiveStreamLoop();'''

if old_dcl_call in code and 'window.startLiveStreamLoop()' not in code:
    code = code.replace(old_dcl_call, new_dcl_call, 1)
    print("Added startLiveStreamLoop to DOMContentLoaded")

# Append Real-Time Engine code at the end
realtime_engine_code = '''
// ==========================================================================
// 15. MOTEUR UNIFIÉ DE STREAMING EN TEMPS RÉEL (FLUX DWH LIVE CONTINU)
// ==========================================================================
let isLiveStreaming = true;
let liveStreamInterval = null;

window.updateMapLiveFeed = function(scan) {
  if (!scan) return;
  const storeName = scan.magasin || '';
  if (!window.liveMapRegions) return;

  let targetRegion = window.liveMapRegions.find(r => 
    storeName.includes(r.name) || (r.store && storeName.includes(r.store)) || (r.code && storeName.toLowerCase().includes(r.code))
  );
  if (!targetRegion) {
    if (storeName.includes('Kef')) targetRegion = window.liveMapRegions.find(r => r.id === 'kef');
    else if (storeName.includes('Tunis') || storeName.includes('Marsa') || storeName.includes('Menzah')) targetRegion = window.liveMapRegions.find(r => r.id === 'tunis');
    else if (storeName.includes('Gafsa')) targetRegion = window.liveMapRegions.find(r => r.id === 'gafsa');
    else if (storeName.includes('Gabès') || storeName.includes('Gabes')) targetRegion = window.liveMapRegions.find(r => r.id === 'gabes');
    else if (storeName.includes('Sfax')) targetRegion = window.liveMapRegions.find(r => r.id === 'sfax');
    else if (storeName.includes('Sousse')) targetRegion = window.liveMapRegions.find(r => r.id === 'sousse');
    else if (storeName.includes('Bizerte')) targetRegion = window.liveMapRegions.find(r => r.id === 'bizerte');
    else if (storeName.includes('Nabeul')) targetRegion = window.liveMapRegions.find(r => r.id === 'nabeul');
  }
  if (!targetRegion) targetRegion = window.liveMapRegions[0];

  targetRegion.scans += 1;
  targetRegion.ca = Math.round((targetRegion.ca + Number(scan.montant_tnd || 15)) * 100) / 100;
  targetRegion.lastClient = scan.client;
  targetRegion.lastTicket = scan.ticket;
  targetRegion.lastTime = "À l'instant";

  const bubbleEl = document.getElementById(`map-bubble-${targetRegion.id}`);
  if (bubbleEl) {
    bubbleEl.innerText = targetRegion.scans.toLocaleString('fr-FR');
    bubbleEl.classList.add('map-bubble-pulse');
    setTimeout(() => bubbleEl.classList.remove('map-bubble-pulse'), 1800);
  }

  const ticker = document.getElementById('map-live-ticker');
  if (ticker) {
    ticker.innerHTML = `
      <span class="live-dot-pulse" style="width: 6px; height: 6px; background: #10B981;"></span>
      <span>Flux Caisse Direct : Dernier scan à <strong>${scan.magasin}</strong> (${scan.client} &bull; <strong style="color:#059669;">+${Number(scan.montant_tnd).toFixed(3)} DT</strong>)</span>
    `;
  }
};

window.triggerLiveTransactionStep = function() {
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

  // 2. Mettre à jour DASHBOARD_DATA
  if (typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.kpis) {
    DASHBOARD_DATA.kpis.ca_total = lastKnownCaAmount;
    DASHBOARD_DATA.kpis.nb_scans = lastKnownScansCount;
    DASHBOARD_DATA.kpis.panier_moyen = Math.round((lastKnownCaAmount / lastKnownScansCount) * 1000) / 1000;
  }

  // 3. Compteur Scans HUD et KPIs avec animation
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

  // 4. Header Ticker direct
  const clock = document.getElementById('hdr-live-clock');
  if (clock) {
    clock.innerHTML = `Client : <strong class="text-white font-bold">${chosenClient}</strong> &bull; Montant : <strong class="text-emerald-400 font-bold">+${amount.toFixed(3)} DT</strong> &bull; Ticket <span class="text-amber-300 font-bold">#${ticket}</span> <span class="text-amber-200/90 font-sans">(${chosenStore.name})</span>`;
    clock.classList.remove('ticket-slide-enter');
    void clock.offsetWidth;
    clock.classList.add('ticket-slide-enter');
  }

  // 5. Donut Répartition & Center Count
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

  // 6. Classement PDV - Achats
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

  // 7. Classement PDV - CA DT
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

  // 8. Animation de la Cartographie (Bulle beacon)
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

  // 10. Inscrits CRM : nouvelle adhésion occasionnelle
  if (Math.random() < 0.12 && typeof DASHBOARD_DATA !== 'undefined' && DASHBOARD_DATA.inscrits_list) {
    const firstNames = ["Syrine", "Mohamed", "Hedi", "Yasmine", "Bilel", "Chaima", "Kais", "Rim", "Aziz", "Mariem", "Youssef", "Nour"];
    const lastNames = ["Bouazizi", "Trabelsi", "Ben Amor", "Gharbi", "Dridi", "Mansour", "Karray", "Ayari", "Khemir", "Jaziri"];
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
  }
};

window.toggleLiveStreaming = function() {
  isLiveStreaming = !isLiveStreaming;
  const btn = document.getElementById('btn-toggle-live-stream');
  const lbl = document.getElementById('label-live-stream');
  if (btn && lbl) {
    if (isLiveStreaming) {
      lbl.innerText = 'Temps Réel : ACTIF (3.5s)';
      btn.className = 'group relative inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs sm:text-sm font-bold bg-emerald-500/15 text-emerald-200 border border-emerald-400/50 hover:bg-emerald-500/25 transition-all duration-300 active:scale-95 shadow-[0_0_15px_rgba(16,185,129,0.25)]';
      if (typeof showToast === 'function') showToast('🟢 Flux Temps Réel DWH Activé (Cadence: 3.5s)', 'success');
      window.startLiveStreamLoop();
    } else {
      lbl.innerText = 'Temps Réel : EN PAUSE';
      btn.className = 'group relative inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs sm:text-sm font-bold bg-slate-700/40 text-slate-300 border border-slate-500/50 hover:bg-slate-700/60 transition-all duration-300 active:scale-95 shadow-sm';
      if (typeof showToast === 'function') showToast('⏸️ Flux Temps Réel en pause', 'info');
      if (liveStreamInterval) clearInterval(liveStreamInterval);
    }
  }
};

window.startLiveStreamLoop = function() {
  if (liveStreamInterval) clearInterval(liveStreamInterval);
  liveStreamInterval = setInterval(() => {
    if (isLiveStreaming) {
      window.triggerLiveTransactionStep();
    }
  }, 3500);
};
'''

if 'window.triggerLiveTransactionStep' not in code:
    code = code + '\n' + realtime_engine_code
    print("Appended unified real-time engine to app.js")

with open('app.js', 'w', encoding='utf-8') as f:
    f.write(code)
shutil.copy('app.js', 'dashboard_bi/app.js')
print("Saved and synced app.js")
