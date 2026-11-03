import shutil, re

# 1. Update index.html Section 2 layout to 2x2 grid (putting Cartographie next to Répartition Donut)
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

old_section2_start = html.find('<!-- SECTION 2 : RÉPARTITION & CLASSEMENT DES POINTS DE VENTE (RÉSEAU ENA w BONDIN) -->')
old_section3_start = html.find('<!-- ======================================================== -->\n      <!-- SECTION 3 : LISTE DES INSCRITS CRM & RECHERCHE AVANCÉE   -->')

if old_section2_start == -1:
    old_section2_start = html.find('<h2 class="bondin-section-title">Répartition &amp; Classement des Points de Vente (Réseau ENA w BONDIN)</h2>')
    old_section2_start = html.rfind('<div class="bondin-report-section-header"', 0, old_section2_start)

if old_section3_start == -1:
    old_section3_start = html.find('<h2 class="bondin-section-title">Liste des Clients Inscrits · Programme ENA w BONDIN</h2>')
    old_section3_start = html.rfind('<div class="bondin-report-section-header"', 0, old_section3_start)

new_section2_html = '''<!-- SECTION 2 : RÉPARTITION, CLASSEMENT ET CARTOGRAPHIE DES POINTS DE VENTE (GRILLE 2x2 ÉQUILIBRÉE) -->
      <div class="bondin-report-section-header" style="margin: 14px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">2</span>
        <h2 class="bondin-section-title">Répartition, Classement &amp; Cartographie des Points de Vente (Réseau ENA w BONDIN)</h2>
      </div>
      
      <!-- GRILLE 2x2 ÉQUILIBRÉE : VISUALISATIONS LISIBLES ET GRANDES, CARTO EN CADRE À CÔTÉ -->
      <div class="visuals-grid-2x2" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 20px; margin-bottom: 24px;">
        
        <!-- CARTE 1 (HAUT-GAUCHE) : RÉPARTITION PAR POINT DE VENTE (DONUT GRAND & LISIBLE) -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 440px; padding: 22px 24px;">
          <div class="visual-header" style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 2a10 10 0 0 1 10 10h-10z"/></svg>
              <span>Répartition par Point de Vente</span>
            </div>
            <span class="tag-badge gold" style="font-size: 0.74rem; padding: 4px 10px;">527 achats · Semaine</span>
          </div>
          
          <div class="report-donut-wrapper" style="padding: 12px 0; display: flex; align-items: center; justify-content: space-around; gap: 24px; flex: 1;">
            <div class="report-donut-chart-box" style="position: relative; width: 220px; height: 220px; flex-shrink: 0;">
              <canvas id="chart-etablissements-donut"></canvas>
              <div class="report-donut-center-text" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; pointer-events: none;">
                <div class="report-donut-center-num" id="donut-center-num" style="font-size: 1.65rem; font-weight: 900; color: #111827; line-height: 1;">527</div>
                <div class="report-donut-center-sub" id="donut-center-sub" style="font-size: 0.75rem; font-weight: 800; color: #8E0E14; text-transform: uppercase; margin-top: 4px;">achats</div>
              </div>
            </div>
            
            <div class="report-donut-legend" id="donut-report-legend" style="flex: 1; display: flex; flex-direction: column; gap: 7px; font-size: 0.85rem; min-width: 0;">
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px; background: rgba(142,14,20,0.05);">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#8E0E14; flex-shrink: 0;"></span>Cafétéria Le Kef</span>
                <strong style="color: #8E0E14; font-size: 0.95rem;">27%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#C00E29; flex-shrink: 0;"></span>Tunis Liberté</span>
                <strong style="color: #C00E29; font-size: 0.95rem;">17%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#D97706; flex-shrink: 0;"></span>La Marsa</span>
                <strong style="color: #D97706; font-size: 0.95rem;">16%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#B45309; flex-shrink: 0;"></span>Menzah VI</span>
                <strong style="color: #B45309; font-size: 0.95rem;">13%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#7C3AED; flex-shrink: 0;"></span>Succ. Menzah</span>
                <strong style="color: #7C3AED; font-size: 0.95rem;">5%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 700; color: #1F2937;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#10B981; flex-shrink: 0;"></span>Cafétéria France</span>
                <strong style="color: #10B981; font-size: 0.95rem;">5%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px;">
                <span style="display:flex; align-items:center; gap: 8px; font-weight: 600; color: #6B7280;"><span class="report-donut-legend-dot" style="width: 10px; height: 10px; border-radius: 3px; background:#9CA3AF; flex-shrink: 0;"></span>Autres Magasins</span>
                <strong style="color: #6B7280; font-size: 0.95rem;">17%</strong>
              </div>
            </div>
          </div>
          
          <div style="margin-top: 10px; font-size: 0.76rem; color: #6B7280; text-align: center; border-top: 1px solid rgba(0,0,0,0.06); padding-top: 8px;">
            💡 Cliquer sur un magasin pour filtrer l'ensemble du tableau de bord
          </div>
        </div>

        <!-- CARTE 2 (HAUT-DROITE) : CARTOGRAPHIE PAR RÉGION & MAGASINS (TUNISIE) - EN CADRE À CÔTÉ -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 440px; padding: 22px 24px;">
          <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">
            <div style="display: flex; flex-direction: column; gap: 2px;">
              <div class="visual-title-center" style="margin: 0; text-align: left; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polygon points="3 6 9 3 15 6 21 3 21 18 15 21 9 18 3 21"/><line x1="9" y1="3" x2="9" y2="18"/><line x1="15" y1="6" x2="15" y2="21"/></svg>
                <span>Cartographie par Région &amp; Magasins (Tunisie)</span>
              </div>
              <div id="map-live-ticker" style="font-size: 0.76rem; color: #059669; font-weight: 700; display: flex; align-items: center; gap: 4px;">
                <span class="live-dot-pulse" style="width: 6px; height: 6px;"></span>
                <span>Flux Caisse Direct : Dernier scan à Tunis Liberté</span>
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <button type="button" class="btn-dwh-ping" style="padding: 5px 12px; font-size: 0.75rem; font-weight: 700;" onclick="window.simulateLiveScan()" title="Simuler un scan caisse magasin et voir la bulle pulser">
                <span class="live-dot-pulse" style="width: 6px; height: 6px;"></span>
                <span>Tester Scan</span>
              </button>
              <span class="tag-badge info" style="font-size: 0.72rem; padding: 4px 8px;">Réseau National</span>
            </div>
          </div>
          
          <div id="map-tunisie-container" style="height: 335px; width: 100%; border-radius: 8px; overflow: hidden; flex: 1;"></div>
        </div>

        <!-- CARTE 3 (BAS-GAUCHE) : CLASSEMENT DES POINTS DE VENTE — NOMBRE D'ACHATS -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 440px; padding: 22px 24px;">
          <div class="visual-header" style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
              <span>Classement PDV · Nombre d'Achats</span>
            </div>
            <span class="tag-badge info" style="font-size: 0.74rem; padding: 4px 10px;">Top 8 Magasins</span>
          </div>
          
          <div style="position: relative; flex: 1; height: 335px;">
            <canvas id="chart-top-pdv-achats"></canvas>
          </div>
          
          <div style="margin-top: 8px; font-size: 0.76rem; color: #6B7280; text-align: right; border-top: 1px solid rgba(0,0,0,0.06); padding-top: 6px;">
            Volume des achats enregistrés en caisse (Données vérifiées)
          </div>
        </div>

        <!-- CARTE 4 (BAS-DROITE) : CLASSEMENT DES POINTS DE VENTE — CHIFFRE D'AFFAIRES (DT) -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 440px; padding: 22px 24px;">
          <div class="visual-header" style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 1rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
              <span>Classement PDV · Chiffre d'Affaires</span>
            </div>
            <span class="tag-badge gold" style="font-size: 0.74rem; padding: 4px 10px;">Montant (DT)</span>
          </div>
          
          <div style="position: relative; flex: 1; height: 335px;">
            <canvas id="chart-top-magasins-mockup"></canvas>
          </div>
          
          <div style="margin-top: 8px; font-size: 0.76rem; color: #6B7280; text-align: right; border-top: 1px solid rgba(0,0,0,0.06); padding-top: 6px;">
            Montant total du CA scanné (Dinars Tunisiens)
          </div>
        </div>

      </div>

      '''

html = html[:old_section2_start] + new_section2_html + html[old_section3_start:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

shutil.copy('index.html', 'dashboard_bi/index.html')
print("index.html updated with 2x2 grid and synced to dashboard_bi/index.html")
