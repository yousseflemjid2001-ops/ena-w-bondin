# -*- coding: utf-8 -*-
import os

new_section1_html = """            <!-- SECTION 1 : DYNAMIQUE DES INSCRIPTIONS & RÉPERTOIRE CRM (PLACÉ EN PREMIER) -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 18px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">1</span>
        <h2 class="bondin-section-title">Dynamique d'Acquisition &amp; Répertoire des Clients Inscrits (2 715 Membres DWH)</h2>
      </div>

      <!-- GRILLE 2 COLONNES SUR LA MÊME LIGNE : RYTHME D'INSCRIPTION & RÉPERTOIRE CRM -->
      <div class="visuals-grid-2x2 section1-inscriptions-grid" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 20px; margin-bottom: 24px; align-items: stretch;">

        <!-- COLONNE 1 (GAUCHE) : VISUALISATION GRAPHIQUE DU NOMBRE D'INSCRITS (JOUR / MOIS / TRIMESTRE) -->
        <div class="visual-card" style="display: flex; flex-direction: column; padding: 20px 22px; min-height: 520px;">
          <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; margin-bottom: 12px;">
            <div>
              <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.95rem; font-weight: 800; color: #8E0E14; display: flex; align-items: center; gap: 8px;">
                <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                <span>Évolution du Rythme d'Inscription des Adhérents ENA w BONDIN</span>
              </div>
              <div style="font-size: 0.74rem; color: #6B7280; font-weight: 500; margin-top: 2px;">
                Adhésions CRM certifiées PostgreSQL · Sélecteur d'échelle temporelle dynamique
              </div>
            </div>

            <!-- SÉLECTEUR DE GRANULARITÉ : JOUR / MOIS / TRIMESTRE -->
            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
              <div class="inscriptions-granularity-group" style="display: inline-flex; background: #F3F4F6; padding: 2px; border-radius: 8px; border: 1px solid #D1D5DB; gap: 2px;">
                <button type="button" class="btn-inscri-gran" id="btn-inscri-jour" onclick="window.setInscriptionsGranularity('jour')" 
                  style="border: none; background: transparent; padding: 5px 11px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; color: #4B5563; cursor: pointer; transition: all 0.2s;">
                  Jour
                </button>
                <button type="button" class="btn-inscri-gran active" id="btn-inscri-mois" onclick="window.setInscriptionsGranularity('mois')" 
                  style="border: none; background: #8E0E14; color: #FFFFFF; padding: 5px 11px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; cursor: pointer; box-shadow: 0 2px 6px rgba(142,14,20,0.3); transition: all 0.2s;">
                  Mois
                </button>
                <button type="button" class="btn-inscri-gran" id="btn-inscri-trimestre" onclick="window.setInscriptionsGranularity('trimestre')" 
                  style="border: none; background: transparent; padding: 5px 11px; border-radius: 6px; font-size: 0.74rem; font-weight: 700; color: #4B5563; cursor: pointer; transition: all 0.2s;">
                  Trimestre
                </button>
              </div>

              <span class="tag-badge gold" id="inscriptions-chart-badge" style="font-size: 0.74rem; font-weight: 800; padding: 4px 10px;">
                2 715 Inscrits
              </span>
            </div>
          </div>

          <!-- 3 BADGES STATS RÉCAPITULATIFS -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 14px;">
            <div style="background: rgba(142,14,20,0.04); border: 1px solid rgba(142,14,20,0.12); border-radius: 8px; padding: 8px 10px; text-align: center;">
              <div style="font-size: 0.68rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Total Base CRM</div>
              <div id="badge-total-crm-count" style="font-size: 1.15rem; font-weight: 900; color: #8E0E14; margin-top: 2px;">2 715 membres</div>
            </div>
            <div style="background: rgba(217,119,6,0.06); border: 1px solid rgba(217,119,6,0.18); border-radius: 8px; padding: 8px 10px; text-align: center;">
              <div style="font-size: 0.68rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Pic Campagne</div>
              <div style="font-size: 1.15rem; font-weight: 900; color: #D97706; margin-top: 2px;">1 456 (Juin)</div>
            </div>
            <div style="background: rgba(16,185,129,0.06); border: 1px solid rgba(16,185,129,0.18); border-radius: 8px; padding: 8px 10px; text-align: center;">
              <div style="font-size: 0.68rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Moyenne Active</div>
              <div id="badge-moy-inscri-count" style="font-size: 1.15rem; font-weight: 900; color: #059669; margin-top: 2px;">5.25 / jour</div>
            </div>
          </div>

          <!-- ZONE DU GRAPHIQUE -->
          <div style="position: relative; height: 330px; width: 100%; flex: 1; min-height: 280px;">
            <canvas id="chart-inscriptions-evolution"></canvas>
          </div>
        </div>

        <!-- COLONNE 2 (DROITE) : RÉPERTOIRE OFFICIEL DES ADHÉRENTS & INSCRITS CRM -->
        <div class="visual-card" style="display: flex; flex-direction: column; padding: 20px 22px; min-height: 520px;">
          <div class="visual-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; margin-bottom: 12px;">
            <div>
              <div class="visual-title-center" style="text-align: left; margin: 0; font-size: 0.95rem; font-weight: 800; display: flex; align-items: center; gap: 8px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8E0E14" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                <span>Répertoire Officiel des Adhérents &amp; Inscrits CRM</span>
              </div>
              <div style="font-size: 0.74rem; color: #6B7280; font-weight: 500; margin-top: 2px;">
                Base certifiée PostgreSQL · Filtre dynamique &amp; Exportation PDF
              </div>
            </div>

            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
              <span class="tag-badge" id="inscrits-count-badge" style="background: rgba(142,14,20,0.1); color: #8E0E14; border: 1px solid rgba(142,14,20,0.25); font-weight: 800; padding: 4px 10px; font-size: 0.74rem;">
                Chargement...
              </span>
              <button type="button" class="btn-action" onclick="window.exportInscritsPDF()" style="background: #8E0E14; color: #FFFFFF; font-weight: 700; padding: 6px 12px; border-radius: 8px; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 8px rgba(142,14,20,0.3); font-size: 0.76rem; transition: all 0.2s;" title="Générer et télécharger la liste filtrée en document PDF officiel">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                <span>PDF</span>
              </button>
            </div>
          </div>

          <!-- BARRE DE FILTRAGE PAR JOUR, SEMAINE, MOIS, TOUT + RECHERCHE -->
          <div style="display: flex; justify-content: space-between; align-items: center; gap: 10px; margin-bottom: 12px; padding: 8px 12px; background: #F9FAFB; border: 1px solid #E5E7EB; border-radius: 10px; flex-wrap: wrap;">
            <div style="display: flex; align-items: center; gap: 4px; flex-wrap: wrap;">
              <span style="font-size: 0.72rem; font-weight: 800; color: #4B5563; text-transform: uppercase; margin-right: 2px;">Période :</span>
              <div class="inscrits-period-btn-group" style="display: inline-flex; background: #FFFFFF; padding: 2px; border-radius: 8px; border: 1px solid #D1D5DB; gap: 2px;">
                <button type="button" class="btn-period-inscrits" id="btn-period-jour" onclick="window.filterInscritsByPeriod('jour')" style="border: none; background: transparent; padding: 4px 9px; border-radius: 6px; font-size: 0.72rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                  Jour
                </button>
                <button type="button" class="btn-period-inscrits active" id="btn-period-semaine" onclick="window.filterInscritsByPeriod('semaine')" style="border: none; background: #8E0E14; color: #FFFFFF; padding: 4px 9px; border-radius: 6px; font-size: 0.72rem; font-weight: 700; cursor: pointer; box-shadow: 0 1px 4px rgba(142,14,20,0.3);">
                  7j
                </button>
                <button type="button" class="btn-period-inscrits" id="btn-period-mois" onclick="window.filterInscritsByPeriod('mois')" style="border: none; background: transparent; padding: 4px 9px; border-radius: 6px; font-size: 0.72rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                  30j
                </button>
                <button type="button" class="btn-period-inscrits" id="btn-period-all" onclick="window.filterInscritsByPeriod('all')" style="border: none; background: transparent; padding: 4px 9px; border-radius: 6px; font-size: 0.72rem; font-weight: 700; color: #4B5563; cursor: pointer;">
                  Tous
                </button>
              </div>
            </div>

            <div style="display: flex; align-items: center; gap: 6px; flex: 1; max-width: 280px; min-width: 160px;">
              <input type="text" id="inscrits-search-input" placeholder="🔍 Rechercher client, tél, email..." oninput="window.filterInscritsTable()"
                style="width: 100%; padding: 5px 10px; border-radius: 8px; border: 1px solid #D1D5DB; font-size: 0.75rem; outline: none; background: #FFFFFF; transition: border-color 0.2s;">
            </div>
          </div>

          <!-- TABLEAU DES INSCRITS SANS AUCUNE BARRE DE SCROLL HORIZONTAL -->
          <div class="table-responsive no-horizontal-scroll" style="height: 330px; max-height: 330px; overflow-y: auto; overflow-x: hidden; flex: 1;">
            <table class="data-table fixed-table" id="table-inscrits-list" style="width: 100%; table-layout: fixed;">
              <thead>
                <tr>
                  <th style="width: 4%; text-align: center;">#</th>
                  <th style="width: 10%;">Date</th>
                  <th style="width: 20%;">Client</th>
                  <th style="width: 14%;">Téléphone</th>
                  <th style="width: 17%;">Email</th>
                  <th style="width: 15%;">Magasin</th>
                  <th style="width: 6%; text-align: center;">Ach.</th>
                  <th style="width: 7%; text-align: center;">Pts</th>
                  <th style="width: 7%; text-align: center;">Statut</th>
                </tr>
              </thead>
              <tbody id="tbody-inscrits-list">
                <!-- Rendu dynamique par app.js -->
              </tbody>
            </table>
          </div>

          <!-- PIED DE TABLE AVEC STATS ET PAGINATION -->
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 10px; padding-top: 8px; border-top: 1px solid #E5E7EB; font-size: 0.72rem; color: #6B7280; flex-wrap: wrap; gap: 6px;">
            <div id="inscrits-summary-stat">
              Affichage des inscrits
            </div>
            <div style="display: flex; align-items: center; gap: 5px;">
              <button type="button" class="btn-pagination" id="btn-inscrits-prev" onclick="window.prevInscritsPage()" style="padding: 3px 8px; border-radius: 6px; border: 1px solid #D1D5DB; background: #FFF; font-weight: 700; cursor: pointer; font-size: 0.72rem;">&larr; Préc.</button>
              <span id="inscrits-page-info" style="font-weight: 700; color: #111827; padding: 0 4px;">Page 1 / 1</span>
              <button type="button" class="btn-pagination" id="btn-inscrits-next" onclick="window.nextInscritsPage()" style="padding: 3px 8px; border-radius: 6px; border: 1px solid #D1D5DB; background: #FFF; font-weight: 700; cursor: pointer; font-size: 0.72rem;">Suiv. &rarr;</button>
            </div>
          </div>
        </div>

      </div>
"""

s1_marker = '<!-- SECTION 1 : DYNAMIQUE DES INSCRIPTIONS & RÉPERTOIRE CRM (PLACÉ EN PREMIER) -->'
s2_marker = '<!-- SECTION 2 : RÉPARTITION, CLASSEMENT ET CARTOGRAPHIE DES POINTS DE VENTE'

for filepath in ['c:/ena w bonda/index.html', 'c:/ena w bonda/dashboard_bi/index.html']:
    with open(filepath, 'r', encoding='utf-8') as f:
        html = f.read()

    pos1 = html.find(s1_marker)
    pos2 = html.find(s2_marker)

    if pos1 == -1 or pos2 == -1:
        print(f"Error: markers not found in {filepath}")
        continue

    # Also ensure responsive style rule in <head>
    responsive_css = """
    @media (max-width: 1150px) {
      .section1-inscriptions-grid {
        grid-template-columns: 1fr !important;
      }
    }
"""
    if '.section1-inscriptions-grid' not in html:
        style_pos = html.find('</style>')
        if style_pos != -1:
            html = html[:style_pos] + responsive_css + html[style_pos:]
            # Recompute pos1 and pos2 since html length changed
            pos1 = html.find(s1_marker)
            pos2 = html.find(s2_marker)

    # Perform replacement
    new_html = html[:pos1] + new_section1_html + "\n\n      <!-- ======================================================== -->\n      \n      " + html[pos2:]

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_html)

    print(f"Successfully updated {filepath}")
