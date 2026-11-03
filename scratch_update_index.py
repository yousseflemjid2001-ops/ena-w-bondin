import shutil

with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Replace Section 2 (lines around 977 to 1097)
target_section_old = '''      <div class="bondin-report-section-header" style="margin: 10px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">2</span>
        <h2 class="bondin-section-title">Répartition par Point de Vente &amp; Gammes</h2>
      </div>
      
      <div class="visuals-grid-3x2">
        
        <!-- CARTE 1 (HAUT-GAUCHE) : DONUT CHART AVEC CALLOUT LABELS -->
        <div class="visual-card">
          <div class="visual-header">
            <div class="visual-title-center">Chiffre d'Affaires par Type d'Établissement</div>
            <div style="display:flex; align-items:center; gap:6px;">
              
              <span class="visual-info-icon" title="Répartition du CA scanné entre les Succursales de vente en gros et les Cafétérias au comptoir">?</span>
            </div>
          </div>
          <div class="chart-custom-legend">
            <span><span class="legend-dot purple-dark"></span> Succursales (63.39%)</span>
            <span><span class="legend-dot purple-light"></span> Cafétérias (36.61%)</span>
          </div>
          <div class="chart-container-mockup">
            <canvas id="chart-etablissements-donut"></canvas>
          </div>
        </div>

        <!-- CARTE 2 (HAUT-MILIEU) : BARRES HORIZONTALES EMPILÉES GAMMES -->
        <div class="visual-card">
          <div class="visual-header">
            <div class="visual-title-center">CA par Gamme de Café &amp; Type d'Établissement</div>
            <div style="display:flex; align-items:center; gap:6px;">
              
              <span class="visual-info-icon" title="Ventilation des ventes de café en Succursales vs Cafétérias selon la nomenclature officielle">?</span>
            </div>
          </div>
          <div class="chart-custom-legend">
            <span><span class="legend-dot purple-light"></span> Succursales (Gros)</span>
            <span><span class="legend-dot purple-dark"></span> Cafétérias (Détail)</span>
          </div>
          <div class="chart-container-mockup">
            <canvas id="chart-gammes-stacked"></canvas>
          </div>
        </div>

        <!-- CARTE 3 (HAUT-DROITE) : BARRES HORIZONTALES TOP MAGASINS -->
        <div class="visual-card">
          <div class="visual-header">
            <div class="visual-title-center">Top 5 Établissements BONDIN par Chiffre d'Affaires</div>
            <div style="display:flex; align-items:center; gap:6px;">
              
              <span class="visual-info-icon" title="Classement des 5 points de vente leaders du réseau BONDIN en volume de CA scanné">?</span>
            </div>
          </div>
          <div class="chart-custom-legend">
            <span><span class="legend-dot purple-light"></span> Succursales</span>
            <span><span class="legend-dot purple-dark"></span> Cafétérias</span>
          </div>
          <div class="chart-container-mockup">
            <canvas id="chart-top-magasins-mockup"></canvas>
          </div>
        </div>

        <!-- CARTE 4 (BAS-GAUCHE) : BARRES VERTICALES TIMELINE MENSUELLE -->
        <div class="visual-card">
          <div class="visual-header">
            <div class="visual-title-center">Évolution Mensuelle du Chiffre d'Affaires &amp; Panier Moyen</div>
            <div style="display:flex; align-items:center; gap:6px;">
              
              <span class="visual-info-icon" title="Historique mensuel d'Avril à Octobre 2026 en temps réel Live DWH">?</span>
            </div>
          </div>
          <div class="chart-custom-legend">
            <span><span class="legend-dot purple-light"></span> CA Mensuel (TND)</span>
            <span><span class="legend-dot purple-dark"></span> Panier Moyen (AOV)</span>
          </div>
          <div class="chart-container-mockup">
            <canvas id="chart-monthly-mockup"></canvas>
          </div>
        </div>

        <!-- CARTE 5 (BAS-MILIEU) : BARRES VERTICALES SEGMENTS PARETO -->
        <div class="visual-card">
          <div class="visual-header">
            <div class="visual-title-center">Chiffre d'Affaires par Segment Consommateur (Pareto)</div>
            <div style="display:flex; align-items:center; gap:6px;">
              
              <span class="visual-info-icon" title="Loi de Pareto : les 161 Champions VIP génèrent 78.4% du CA total scanné">?</span>
            </div>
          </div>
          <div class="chart-custom-legend">
            <span><span class="legend-dot purple-light"></span> CA Cumulé (TND)</span>
            <span><span class="legend-dot purple-dark"></span> Clients</span>
          </div>
          <div class="chart-container-mockup">
            <canvas id="chart-segments-mockup"></canvas>
          </div>
        </div>

        <!-- CARTE 6 (BAS-DROITE) : CARTE INTERACTIVE LEAFLET AVEC BULLES VIOLETTES -->
        <div class="visual-card">
          <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
            <div style="display: flex; flex-direction: column; gap: 2px;">
              <div class="visual-title-center" style="margin: 0; text-align: left;">Cartographie par Région &amp; Magasins (Tunisie)</div>
              <div id="map-live-ticker" style="font-size: 0.72rem; color: #059669; font-weight: 700; display: flex; align-items: center; gap: 4px;">
                <span class="live-dot-pulse" style="width: 5px; height: 5px;"></span>
                <span>Flux Caisse Direct : Dernier scan à Tunis Liberté</span>
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 6px;">
              <button type="button" class="btn-dwh-ping" style="padding: 3px 8px; font-size: 0.69rem;" onclick="window.simulateLiveScan()" title="Simuler un scan caisse magasin et voir la bulle pulser">
                <span class="live-dot-pulse" style="width: 5px; height: 5px;"></span>
                <span>Tester Scan Magasin</span>
              </button>
              
              <span class="visual-info-icon" title="Trafic scanné et volume de ventes par gouvernorat">?</span>
            </div>
          </div>
          <div id="map-tunisie-container"></div>
        </div>

      </div>'''

new_section_content = '''      <!-- SECTION 2 : RÉPARTITION & CLASSEMENT DES POINTS DE VENTE (RÉSEAU ENA w BONDIN) -->
      <div class="bondin-report-section-header" style="margin: 14px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">2</span>
        <h2 class="bondin-section-title">Répartition &amp; Classement des Points de Vente (Réseau ENA w BONDIN)</h2>
      </div>
      
      <!-- GRILLE 3 COLONNES : RÉPARTITION (DONUT) + CLASSEMENT ACHATS + CLASSEMENT CA -->
      <div class="visuals-grid-pdv" style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; margin-bottom: 20px;">
        
        <!-- CARTE 1 : RÉPARTITION PAR POINT DE VENTE (DONUT) -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 330px;">
          <div class="visual-header">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.88rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 6px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 2a10 10 0 0 1 10 10h-10z"/></svg>
              <span>Répartition par Point de Vente</span>
            </div>
            <span class="tag-badge gold" style="font-size: 0.65rem;">527 achats · Semaine</span>
          </div>
          <div class="report-donut-wrapper" style="padding: 10px 0; display: flex; align-items: center; justify-content: space-around; gap: 10px; flex: 1;">
            <div class="report-donut-chart-box" style="position: relative; width: 135px; height: 135px; flex-shrink: 0;">
              <canvas id="chart-etablissements-donut"></canvas>
              <div class="report-donut-center-text" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; pointer-events: none;">
                <div class="report-donut-center-num" id="donut-center-num" style="font-size: 1.15rem; font-weight: 900; color: #111827; line-height: 1;">527</div>
                <div class="report-donut-center-sub" id="donut-center-sub" style="font-size: 0.65rem; font-weight: 700; color: #8E0E14; text-transform: uppercase;">achats</div>
              </div>
            </div>
            <div class="report-donut-legend" id="donut-report-legend" style="flex: 1; display: flex; flex-direction: column; gap: 4px; font-size: 0.72rem; min-width: 0;">
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#8E0E14; flex-shrink: 0;"></span>Cafétéria Le Kef</span>
                <strong style="color: #8E0E14; margin-left: 4px;">27%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#C00E29; flex-shrink: 0;"></span>Tunis Liberté</span>
                <strong style="color: #C00E29; margin-left: 4px;">17%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#D97706; flex-shrink: 0;"></span>La Marsa</span>
                <strong style="color: #D97706; margin-left: 4px;">16%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#B45309; flex-shrink: 0;"></span>Menzah VI</span>
                <strong style="color: #B45309; margin-left: 4px;">13%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#7C3AED; flex-shrink: 0;"></span>Succ. Menzah</span>
                <strong style="color: #7C3AED; margin-left: 4px;">5%</strong>
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <span style="display:flex; align-items:center; gap: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><span class="report-donut-legend-dot" style="width: 8px; height: 8px; border-radius: 2px; background:#9CA3AF; flex-shrink: 0;"></span>Autres</span>
                <strong style="color: #6B7280; margin-left: 4px;">22%</strong>
              </div>
            </div>
          </div>
          <div style="margin-top: 6px; font-size: 0.68rem; color: #6B7280; text-align: center; border-top: 1px solid rgba(0,0,0,0.04); padding-top: 4px;">
            Cliquer sur un magasin pour filtrer en direct
          </div>
        </div>

        <!-- CARTE 2 : CLASSEMENT DES POINTS DE VENTE — NOMBRE D'ACHATS -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 330px;">
          <div class="visual-header">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.88rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 6px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
              <span>Classement PDV · Nombre d'Achats</span>
            </div>
            <span class="tag-badge info" style="font-size: 0.65rem;">Top 8 Magasins</span>
          </div>
          <div style="position: relative; flex: 1; min-height: 220px; padding-top: 4px;">
            <canvas id="chart-top-pdv-achats"></canvas>
          </div>
          <div style="margin-top: 6px; font-size: 0.68rem; color: #6B7280; text-align: right; border-top: 1px solid rgba(0,0,0,0.04); padding-top: 4px;">
            Nombre d'achats enregistrés
          </div>
        </div>

        <!-- CARTE 3 : CLASSEMENT DES POINTS DE VENTE — CHIFFRE D'AFFAIRES (DT) -->
        <div class="visual-card" style="display: flex; flex-direction: column; min-height: 330px;">
          <div class="visual-header">
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.88rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 6px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
              <span>Classement PDV · Chiffre d'Affaires</span>
            </div>
            <span class="tag-badge gold" style="font-size: 0.65rem;">Montant (DT)</span>
          </div>
          <div style="position: relative; flex: 1; min-height: 220px; padding-top: 4px;">
            <canvas id="chart-top-magasins-mockup"></canvas>
          </div>
          <div style="margin-top: 6px; font-size: 0.68rem; color: #6B7280; text-align: right; border-top: 1px solid rgba(0,0,0,0.04); padding-top: 4px;">
            CA scanné (Dinars Tunisiens)
          </div>
        </div>

      </div>

      <!-- VISUEL 4 : CARTOGRAPHIE PAR RÉGION & MAGASINS (TUNISIE) - PLEINE LARGEUR -->
      <div class="visual-card" style="margin-bottom: 24px;">
        <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
          <div style="display: flex; flex-direction: column; gap: 2px;">
            <div class="visual-title-center" style="margin: 0; text-align: left; font-size: 0.95rem; font-weight: 800; display: flex; align-items: center; gap: 8px;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polygon points="3 6 9 3 15 6 21 3 21 18 15 21 9 18 3 21"/><line x1="9" y1="3" x2="9" y2="18"/><line x1="15" y1="6" x2="15" y2="21"/></svg>
              <span>Cartographie par Région &amp; Magasins (Tunisie)</span>
            </div>
            <div id="map-live-ticker" style="font-size: 0.74rem; color: #059669; font-weight: 700; display: flex; align-items: center; gap: 4px;">
              <span class="live-dot-pulse" style="width: 5px; height: 5px;"></span>
              <span>Flux Caisse Direct : Dernier scan à Tunis Liberté</span>
            </div>
          </div>
          <div style="display: flex; align-items: center; gap: 8px;">
            <button type="button" class="btn-dwh-ping" style="padding: 4px 10px; font-size: 0.72rem;" onclick="window.simulateLiveScan()" title="Simuler un scan caisse magasin et voir la bulle pulser">
              <span class="live-dot-pulse" style="width: 5px; height: 5px;"></span>
              <span>Tester Scan Magasin</span>
            </button>
            <span class="tag-badge info" style="font-size: 0.7rem;">Réseau National BONDIN</span>
          </div>
        </div>
        <div id="map-tunisie-container" style="height: 380px; width: 100%; border-radius: 8px; overflow: hidden;"></div>
      </div>

      <!-- ======================================================== -->
      <!-- SECTION 3 : LISTE DES INSCRITS CRM & RECHERCHE AVANCÉE   -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 14px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">3</span>
        <h2 class="bondin-section-title">Liste des Clients Inscrits · Programme ENA w BONDIN</h2>
      </div>

      <div class="visual-card" style="margin-bottom: 24px; padding: 20px 22px;">
        <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 14px;">
          <div>
            <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.95rem; font-weight: 800; display: flex; align-items: center; gap: 8px;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
              <span>Répertoire Officiel des Adhérents &amp; Inscrits CRM (2 715 Membres DWH)</span>
            </div>
            <div style="font-size: 0.74rem; color: #6B7280; font-weight: 500; margin-top: 2px;">
              Base certifiée PostgreSQL · Filtre dynamique par Jour, Semaine et Mois · Exportation PDF Haute Fidélité
            </div>
          </div>

          <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
            <span class="tag-badge" id="inscrits-count-badge" style="background: rgba(142,14,20,0.1); color: #8E0E14; border: 1px solid rgba(142,14,20,0.25); font-weight: 800; padding: 6px 12px; font-size: 0.78rem;">
              Chargement...
            </span>
            <button type="button" class="btn-action" onclick="window.exportInscritsPDF()" style="background: #8E0E14; color: #FFFFFF; font-weight: 700; padding: 7px 14px; border-radius: 8px; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 8px rgba(142,14,20,0.3); transition: all 0.2s;" title="Générer et télécharger la liste filtrée en document PDF officiel">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
              <span>Extraire PDF</span>
            </button>
          </div>
        </div>

        <!-- BARRE DE FILTRAGE PAR JOUR, SEMAINE, MOIS, TOUT + RECHERCHE -->
        <div style="display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 14px; padding: 10px 14px; background: #F9FAFB; border: 1px solid #E5E7EB; border-radius: 10px; flex-wrap: wrap;">
          <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
            <span style="font-size: 0.74rem; font-weight: 800; color: #4B5563; text-transform: uppercase; margin-right: 4px;">Période d'inscription :</span>
            <div class="inscrits-period-btn-group" style="display: inline-flex; background: #FFFFFF; padding: 3px; border-radius: 8px; border: 1px solid #D1D5DB; gap: 3px;">
              <button type="button" class="btn-period-inscrits" id="btn-period-jour" onclick="window.filterInscritsByPeriod('jour')" style="border: none; background: transparent; padding: 5px 12px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                Jour (Aujourd'hui)
              </button>
              <button type="button" class="btn-period-inscrits active" id="btn-period-semaine" onclick="window.filterInscritsByPeriod('semaine')" style="border: none; background: #8E0E14; color: #FFFFFF; padding: 5px 12px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; cursor: pointer; box-shadow: 0 1px 4px rgba(142,14,20,0.3);">
                Semaine (7 jours)
              </button>
              <button type="button" class="btn-period-inscrits" id="btn-period-mois" onclick="window.filterInscritsByPeriod('mois')" style="border: none; background: transparent; padding: 5px 12px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                Mois (30 jours)
              </button>
              <button type="button" class="btn-period-inscrits" id="btn-period-all" onclick="window.filterInscritsByPeriod('all')" style="border: none; background: transparent; padding: 5px 12px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                Tous (Global)
              </button>
            </div>
          </div>

          <div style="display: flex; align-items: center; gap: 8px; flex: 1; max-width: 380px; min-width: 200px;">
            <input type="text" id="inscrits-search-input" placeholder="🔍 Rechercher par nom, téléphone, email, magasin..." oninput="window.filterInscritsTable()"
              style="width: 100%; padding: 7px 12px; border-radius: 8px; border: 1px solid #D1D5DB; font-size: 0.78rem; outline: none; background: #FFFFFF; transition: border-color 0.2s;">
          </div>
        </div>

        <!-- TABLEAU DES INSCRITS -->
        <div class="table-responsive" style="max-height: 480px; overflow-y: auto;">
          <table class="data-table" id="table-inscrits-list">
            <thead>
              <tr>
                <th style="width: 35px; text-align: center;">#</th>
                <th style="width: 95px;">Date d'Inscr.</th>
                <th>Client / Nom &amp; Prénom</th>
                <th>Numéro Téléphone</th>
                <th>Email</th>
                <th>Magasin d'Adhésion</th>
                <th style="text-align: center;">Achats</th>
                <th style="text-align: center;">Total Points</th>
                <th style="text-align: center;">Segment / Statut</th>
              </tr>
            </thead>
            <tbody id="tbody-inscrits-list">
              <!-- Rendu dynamique par app.js -->
            </tbody>
          </table>
        </div>

        <!-- PIED DE TABLE AVEC STATS ET PAGINATION -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 12px; padding-top: 10px; border-top: 1px solid #E5E7EB; font-size: 0.74rem; color: #6B7280; flex-wrap: wrap; gap: 8px;">
          <div id="inscrits-summary-stat">
            Affichage des inscrits
          </div>
          <div style="display: flex; align-items: center; gap: 6px;">
            <button type="button" class="btn-pagination" id="btn-inscrits-prev" onclick="window.prevInscritsPage()" style="padding: 4px 10px; border-radius: 6px; border: 1px solid #D1D5DB; background: #FFF; font-weight: 700; cursor: pointer;">&larr; Précédent</button>
            <span id="inscrits-page-info" style="font-weight: 700; color: #111827; padding: 0 4px;">Page 1 / 1</span>
            <button type="button" class="btn-pagination" id="btn-inscrits-next" onclick="window.nextInscritsPage()" style="padding: 4px 10px; border-radius: 6px; border: 1px solid #D1D5DB; background: #FFF; font-weight: 700; cursor: pointer;">Suivant &rarr;</button>
          </div>
        </div>
      </div>'''

if target_section_old in html:
    html = html.replace(target_section_old, new_section_content, 1)
    print('Replaced section 2 & added section 3 in index.html')
else:
    print('target_section_old NOT FOUND in index.html! Trying substring replacement.')
    # Substring search
    start_pos = html.find('<h2 class="bondin-section-title">Répartition par Point de Vente &amp; Gammes</h2>')
    if start_pos != -1:
        # Find start of section header
        header_pos = html.rfind('<div class="bondin-report-section-header"', 0, start_pos)
        # Find end of visuals-grid-3x2
        grid_end = html.find('<!-- Module IA CDC : Arbre de Décomposition IA -->', start_pos)
        if header_pos != -1 and grid_end != -1:
            html = html[:header_pos] + new_section_content + '\n\n      ' + html[grid_end:]
            print('Replaced section 2 via substring search!')

# 2. Update table-grossistes header to include Numéro, Email, Total Points
old_grossistes_thead = '''          <table class="data-table" id="table-grossistes">
            <thead>
              <tr>
                <th>Client (Grossiste / B2B)</th>
                <th>Achats Succursale</th>
                <th>Achats Cafétéria</th>
                <th>Total CA Dépensé</th>
                <th>Max Ticket Succursale</th>
                <th>Fréquence Hebdo</th>
                <th>Statut d'Alerte</th>
              </tr>
            </thead>'''

new_grossistes_thead = '''          <table class="data-table" id="table-grossistes">
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
            </thead>'''

if old_grossistes_thead in html:
    html = html.replace(old_grossistes_thead, new_grossistes_thead, 1)
    print('Updated table-grossistes header with Numéro, Email, and Total Points!')
else:
    print('old_grossistes_thead not matched directly, doing regex replace')
    import re
    html = re.sub(
        r'<table class="data-table" id="table-grossistes">\s*<thead>\s*<tr>\s*<th>Client \(Grossiste / B2B\)</th>.*?</tr>\s*</thead>',
        new_grossistes_thead,
        html,
        flags=re.DOTALL
    )
    print('Regex replace performed on table-grossistes')

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

shutil.copy('index.html', 'dashboard_bi/index.html')
print('index.html saved and copied to dashboard_bi/index.html')
