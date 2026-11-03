import shutil

with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Update Inscrits Table Header with explicit percentage widths
old_inscrits_table = '''        <!-- TABLEAU DES INSCRITS -->
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
            </thead>'''

new_inscrits_table = '''        <!-- TABLEAU DES INSCRITS SANS AUCUNE BARRE DE SCROLL HORIZONTAL -->
        <div class="table-responsive no-horizontal-scroll" style="max-height: 480px; overflow-y: auto; overflow-x: hidden;">
          <table class="data-table fixed-table" id="table-inscrits-list" style="width: 100%; table-layout: fixed;">
            <thead>
              <tr>
                <th style="width: 4%; text-align: center;">#</th>
                <th style="width: 9%;">Date</th>
                <th style="width: 18%;">Client / Nom &amp; Prénom</th>
                <th style="width: 14%;">Numéro Téléphone</th>
                <th style="width: 18%;">Email</th>
                <th style="width: 16%;">Magasin d'Adhésion</th>
                <th style="width: 6%; text-align: center;">Achats</th>
                <th style="width: 7.5%; text-align: center;">Total Points</th>
                <th style="width: 7.5%; text-align: center;">Statut</th>
              </tr>
            </thead>'''

if old_inscrits_table in html:
    html = html.replace(old_inscrits_table, new_inscrits_table, 1)
    print("Updated Inscrits table header in index.html")
else:
    print("WARNING: old_inscrits_table not matched directly")

# 2. Update Grossistes Table Header with explicit percentage widths
old_grossistes_table = '''        <div class="table-responsive">
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
            </thead>'''

new_grossistes_table = '''        <div class="table-responsive no-horizontal-scroll" style="overflow-x: hidden;">
          <table class="data-table fixed-table table-grossistes-sync" id="table-grossistes-cockpit" style="width: 100%; table-layout: fixed;">
            <thead>
              <tr>
                <th style="width: 17%;">Client (Grossiste / B2B)</th>
                <th style="width: 13%;">Numéro</th>
                <th style="width: 16%;">Email</th>
                <th style="width: 9%; text-align: right;">Total CA</th>
                <th style="width: 7.5%; text-align: center;">Points</th>
                <th style="width: 9.5%; text-align: right;">Succursale</th>
                <th style="width: 7%; text-align: right;">Cafétéria</th>
                <th style="width: 7%; text-align: right;">Max Ticket</th>
                <th style="width: 6.5%; text-align: center;">Fréq.</th>
                <th style="width: 7.5%; text-align: center;">Alerte</th>
              </tr>
            </thead>'''

if old_grossistes_table in html:
    html = html.replace(old_grossistes_table, new_grossistes_table, 1)
    print("Updated Grossistes table header in index.html")
else:
    print("WARNING: old_grossistes_table not matched directly")

# 3. Update decomp-tree-container style
html = html.replace('id="decomp-tree-container" style="overflow-x: auto; padding: 6px 0;"', 'id="decomp-tree-container" style="overflow-x: hidden; padding: 6px 0;"')

# 4. Add IDs to the 3 Inscriptions KPI badges above the chart so they can update live!
old_kpi_badge_block = '''        <!-- 3 BADGES STATS RÉCAPITULATIFS -->
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
        </div>'''

new_kpi_badge_block = '''        <!-- 3 BADGES STATS RÉCAPITULATIFS -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 16px;">
          <div style="background: rgba(142,14,20,0.04); border: 1px solid rgba(142,14,20,0.12); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Total Base CRM</div>
            <div id="badge-total-crm-count" style="font-size: 1.25rem; font-weight: 900; color: #8E0E14; margin-top: 2px;">2 715 membres</div>
          </div>
          <div style="background: rgba(217,119,6,0.06); border: 1px solid rgba(217,119,6,0.18); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Pic Campagne Lancement</div>
            <div style="font-size: 1.25rem; font-weight: 900; color: #D97706; margin-top: 2px;">1 456 inscrits (Juin 2026)</div>
          </div>
          <div style="background: rgba(16,185,129,0.06); border: 1px solid rgba(16,185,129,0.18); border-radius: 8px; padding: 10px 14px; text-align: center;">
            <div style="font-size: 0.72rem; color: #6B7280; font-weight: 700; text-transform: uppercase;">Moyenne Journalière Active</div>
            <div id="badge-moy-inscri-count" style="font-size: 1.25rem; font-weight: 900; color: #059669; margin-top: 2px;">5.25 inscrits / jour</div>
          </div>
        </div>'''

if old_kpi_badge_block in html:
    html = html.replace(old_kpi_badge_block, new_kpi_badge_block, 1)
    print("Added IDs to Inscriptions KPI badges in index.html")

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

shutil.copy('index.html', 'dashboard_bi/index.html')
print("Synced index.html to dashboard_bi/index.html")
