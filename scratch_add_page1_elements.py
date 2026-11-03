import json, shutil, re

# ========================================================
# 1. Update data.js with inscriptions_timeseries
# ========================================================
with open('data.js', 'r', encoding='utf-8') as f:
    data_content = f.read()

inscriptions_ts = {
    'jour': {
        'labels': ['01 Oct', '02 Oct', '03 Oct', '04 Oct', '05 Oct', '06 Oct', '07 Oct', '08 Oct', '09 Oct', '10 Oct',
                   '11 Oct', '12 Oct', '13 Oct', '14 Oct', '15 Oct', '16 Oct', '17 Oct', '18 Oct', '19 Oct', '20 Oct'],
        'values': [8, 6, 8, 4, 3, 5, 10, 7, 4, 3, 1, 7, 6, 6, 2, 5, 6, 5, 6, 3],
        'total': 105,
        'badge': "105 Inscrits · Octobre 2026",
        'unit': "Inscriptions / Jour"
    },
    'mois': {
        'labels': ['Déc 2025', 'Jan 2026', 'Fév 2026', 'Mar 2026', 'Avr 2026', 'Mai 2026', 'Juin 2026', 'Juil 2026', 'Août 2026', 'Sept 2026', 'Oct 2026'],
        'values': [11, 12, 13, 7, 13, 17, 1456, 501, 306, 274, 105],
        'total': 2715,
        'badge': "2 715 Inscrits · Base CRM",
        'unit': "Inscriptions / Mois"
    },
    'trimestre': {
        'labels': ['T4 2025 (Q4)', 'T1 2026 (Q1)', 'T2 2026 (Q2)', 'T3 2026 (Q3)', 'T4 2026 (Q4 en cours)'],
        'values': [11, 32, 1486, 1081, 105],
        'total': 2715,
        'badge': "5 Trimestres Consolidés",
        'unit': "Inscriptions / Trimestre"
    }
}

if 'inscriptions_timeseries:' not in data_content:
    idx_close = data_content.rfind('};')
    ts_json = json.dumps(inscriptions_ts, ensure_ascii=False, indent=2)
    data_content = data_content[:idx_close] + ',\n  inscriptions_timeseries: ' + ts_json + '\n};\n'
    with open('data.js', 'w', encoding='utf-8') as f:
        f.write(data_content)
    print("Added inscriptions_timeseries to data.js")

shutil.copy('data.js', 'dashboard_bi/data.js')
print("Synced data.js to dashboard_bi/data.js")

# ========================================================
# 2. Update index.html
# ========================================================
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Graphique Inscriptions HTML to insert in Section 3 above the table
graphique_inscriptions_html = '''      <!-- ======================================================== -->
      <!-- SECTION 3 : DYNAMIQUE DES INSCRIPTIONS & RÉPERTOIRE CRM  -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 18px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">3</span>
        <h2 class="bondin-section-title">Dynamique d'Acquisition &amp; Répertoire des Clients Inscrits (2 715 Membres DWH)</h2>
      </div>

      <!-- VISUALISATION GRAPHIQUE DU NOMBRE D'INSCRITS (JOUR / MOIS / TRIMESTRE) -->
      <div class="visual-card" style="margin-bottom: 20px; padding: 22px 24px;">
        <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 14px;">
          <div>
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
              <span>Évolution du Rythme d'Inscription des Adhérents ENA w BONDIN</span>
            </div>
            <div style="font-size: 0.76rem; color: #6B7280; font-weight: 500; margin-top: 3px;">
              Suivi chronologique des adhésions CRM certifiées PostgreSQL · Sélecteur d'échelle temporelle dynamique
            </div>
          </div>

          <!-- SÉLECTEUR DE GRANULARITÉ : JOUR / MOIS / TRIMESTRE -->
          <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
            <div class="inscriptions-granularity-group" style="display: inline-flex; background: #F3F4F6; padding: 3px; border-radius: 9px; border: 1px solid #D1D5DB; gap: 3px;">
              <button type="button" class="btn-inscri-gran" id="btn-inscri-jour" onclick="window.setInscriptionsGranularity('jour')" 
                style="border: none; background: transparent; padding: 6px 14px; border-radius: 7px; font-size: 0.76rem; font-weight: 700; color: #4B5563; cursor: pointer; transition: all 0.2s;">
                Jour (Octobre)
              </button>
              <button type="button" class="btn-inscri-gran active" id="btn-inscri-mois" onclick="window.setInscriptionsGranularity('mois')" 
                style="border: none; background: #8E0E14; color: #FFFFFF; padding: 6px 14px; border-radius: 7px; font-size: 0.76rem; font-weight: 700; cursor: pointer; box-shadow: 0 2px 6px rgba(142,14,20,0.3); transition: all 0.2s;">
                Mois (2026)
              </button>
              <button type="button" class="btn-inscri-gran" id="btn-inscri-trimestre" onclick="window.setInscriptionsGranularity('trimestre')" 
                style="border: none; background: transparent; padding: 6px 14px; border-radius: 7px; font-size: 0.76rem; font-weight: 700; color: #4B5563; cursor: pointer; transition: all 0.2s;">
                Trimestre (Q)
              </button>
            </div>

            <span class="tag-badge gold" id="inscriptions-chart-badge" style="font-size: 0.76rem; font-weight: 800; padding: 5px 12px;">
              2 715 Inscrits · Base CRM
            </span>
          </div>
        </div>

        <!-- 3 BADGES STATS RÉCAPITULATIFS -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 16px;">
          <div style="background: rgba(142,14,20,0.04); border: 1px solid rgba(142,14,20,0.12); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Total Base CRM</div>
            <div style="font-size: 1.25rem; font-weight: 900; color: #8E0E14; margin-top: 2px;">2 715 membres</div>
          </div>
          <div style="background: rgba(217,119,6,0.06); border: 1px solid rgba(217,119,6,0.18); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Pic Campagne Lancement</div>
            <div style="font-size: 1.25rem; font-weight: 900; color: #D97706; margin-top: 2px;">1 456 inscrits (Juin 2026)</div>
          </div>
          <div style="background: rgba(16,185,129,0.06); border: 1px solid rgba(16,185,129,0.18); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Moyenne Journalière Active</div>
            <div style="font-size: 1.25rem; font-weight: 900; color: #059669; margin-top: 2px;">5.25 inscrits / jour</div>
          </div>
        </div>

        <!-- ZONE DU GRAPHIQUE -->
        <div style="position: relative; height: 280px; width: 100%;">
          <canvas id="chart-inscriptions-evolution"></canvas>
        </div>
      </div>
'''

# Find Section 3 start in index.html
s3_pos = html.find('<!-- SECTION 3 : LISTE DES INSCRITS CRM & RECHERCHE AVANCÉE   -->')
if s3_pos == -1:
    s3_pos = html.find('<h2 class="bondin-section-title">Liste des Clients Inscrits · Programme ENA w BONDIN</h2>')
    s3_pos = html.rfind('<div class="bondin-report-section-header"', 0, s3_pos)

# Find the end of Section 3 visual-card (the inscrits table card)
s3_card_end = html.find('<!-- Module IA CDC : Arbre de Décomposition IA -->', s3_pos)

# Grossistes Section 4 HTML to insert right after the Inscrits Table card
grossistes_section4_html = '''
      <!-- ======================================================== -->
      <!-- SECTION 4 : DÉTECTION DES PROFILS GROSSISTES & VOLUMES B2B -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 22px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">4</span>
        <h2 class="bondin-section-title">Détection des Profils Grossistes &amp; Volumes B2B Suspects (Réseau Succursales)</h2>
      </div>

      <div class="visual-card" style="margin-bottom: 24px; padding: 22px 24px;">
        <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 14px;">
          <div>
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <span>Surveillance des Gros Volumes d'Achats &amp; Risque Détournement B2B</span>
            </div>
            <div style="font-size: 0.76rem; color: #6B7280; font-weight: 500; margin-top: 3px;">
              Comptes professionnels achetant en succursale (panier moyen &gt; 35 DT, fréquence &gt; 2/semaine) · Contrôle des volumes
            </div>
          </div>
          
          <div style="display: flex; align-items: center; gap: 10px;">
            <span style="font-size: 0.74rem; font-weight: 800; color: #4B5563; text-transform: uppercase;">Affichage :</span>
            <div class="grossistes-top-filter-group" role="group" aria-label="Filtrer top grossistes">
              <button type="button" class="btn-grossiste-top active" data-top="5" onclick="window.filterTopGrossistes(5)" title="Afficher le Top 5 des plus grands grossistes">Top 5</button>
              <button type="button" class="btn-grossiste-top" data-top="10" onclick="window.filterTopGrossistes(10)" title="Afficher le Top 10 des plus grands grossistes">Top 10</button>
              <button type="button" class="btn-grossiste-top" data-top="20" onclick="window.filterTopGrossistes(20)" title="Afficher le Top 20 des plus grands grossistes">Top 20</button>
            </div>
            <span class="tag-badge alert" style="font-size: 0.72rem; font-weight: 800; padding: 4px 10px;">⚡ Surveillance B2B</span>
          </div>
        </div>

        <div class="table-responsive">
          <table class="data-table table-grossistes-sync" id="table-grossistes-cockpit">
            <thead>
              <tr>
                <th>Client (Grossiste / B2B)</th>
                <th>Numéro</th>
                <th>Email</th>
                <th style="text-align: right;">Total CA Dépensé</th>
                <th style="text-align: center;">Total Points</th>
                <th style="text-align: right;">Achats Succursale</th>
                <th style="text-align: right;">Achats Cafétéria</th>
                <th style="text-align: right;">Max Ticket</th>
                <th style="text-align: center;">Fréquence</th>
                <th style="text-align: center;">Statut d'Alerte</th>
              </tr>
            </thead>
            <tbody>
              <!-- Injecté et synchronisé par app.js -->
            </tbody>
          </table>
        </div>
      </div>
'''

# Update the section header of Arbre de Décomposition to Section 5
old_decomp_header = '<h2 class="bondin-section-title">Arbre de Décomposition Stratégique du CA Client</h2>'
# Wait, let's check what Arbre de Décomposition header looks like
decomp_header_start = html.find('Arbre de Décomposition Stratégique du CA Client', s3_pos)

# Replace Section 3 header and add Section 4
# Let's inspect the exact lines of Section 3 in index.html
s3_header_old = '''      <!-- ======================================================== -->
      <!-- SECTION 3 : LISTE DES INSCRITS CRM & RECHERCHE AVANCÉE   -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 14px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">3</span>
        <h2 class="bondin-section-title">Liste des Clients Inscrits · Programme ENA w BONDIN</h2>
      </div>'''

if s3_header_old in html:
    html = html.replace(s3_header_old, graphique_inscriptions_html, 1)
    print("Replaced Section 3 header with Graphique Inscriptions + Section 3 in index.html")
else:
    print("s3_header_old not matched directly, doing substring replace")
    start_tag = html.find('<div class="bondin-report-section-header"', s3_pos)
    end_tag = html.find('<div class="visual-card"', start_tag)
    html = html[:start_tag] + graphique_inscriptions_html + html[end_tag:]

# Now insert Section 4 before Arbre de Décomposition
decomp_pos = html.find('<!-- Module IA CDC : Arbre de Décomposition IA -->')
if decomp_pos != -1:
    html = html[:decomp_pos] + grossistes_section4_html + '\n      ' + html[decomp_pos:]
    print("Inserted Section 4 (Grossistes) before Arbre de Décomposition in index.html")

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)
shutil.copy('index.html', 'dashboard_bi/index.html')
print("index.html written and synced to dashboard_bi/index.html")
