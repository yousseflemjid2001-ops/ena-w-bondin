import shutil, re

# ========================================================
# 1. Update style.css for date-filter-group
# ========================================================
with open('style.css', 'r', encoding='utf-8') as f:
    css = f.read()

# Update date-filter-group styles
old_date_group_css = '''.pro-filter-group.date-filter-group {
  min-width: 255px !important;
  flex: 1.5 1 0 !important;
}'''

new_date_group_css = '''.pro-filter-group.date-filter-group {
  min-width: 310px !important;
  flex: 2 0 auto !important;
  max-width: 360px !important;
  box-sizing: border-box !important;
}'''

if old_date_group_css in css:
    css = css.replace(old_date_group_css, new_date_group_css, 1)
    print("Updated .pro-filter-group.date-filter-group in style.css")
else:
    css = re.sub(
        r'\.pro-filter-group\.date-filter-group\s*\{[^}]*\}',
        new_date_group_css,
        css
    )
    print("Regex updated .pro-filter-group.date-filter-group in style.css")

# Update pro-date-picker-wrap and pro-date-field styles
old_date_wrap_css = '''.pro-date-picker-wrap {
  display: flex !important;
  align-items: center !important;
  justify-content: space-between !important;
  background-color: #F9FAFB !important;
  border: 1.5px solid #D1D5DB !important;
  border-radius: 12px !important;
  padding: 4px 10px !important;
  height: 42px !important;
  box-sizing: border-box !important;
  width: 100% !important;
}'''

new_date_wrap_css = '''.pro-date-picker-wrap {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  background-color: #F9FAFB !important;
  border: 1.5px solid #D1D5DB !important;
  border-radius: 12px !important;
  padding: 4px 8px !important;
  height: 42px !important;
  box-sizing: border-box !important;
  width: 100% !important;
  max-width: 100% !important;
  gap: 4px !important;
}'''

if old_date_wrap_css in css:
    css = css.replace(old_date_wrap_css, new_date_wrap_css, 1)
    print("Updated .pro-date-picker-wrap in style.css")

old_date_field_css = '''.pro-date-field {
  background: transparent !important;
  border: none !important;
  color: #111827 !important;
  font-family: 'JetBrains Mono', monospace !important;
  font-size: 0.82rem !important;
  font-weight: 800 !important;
  padding: 0 2px !important;
  width: 112px !important;
  outline: none !important;
  cursor: pointer !important;
}'''

new_date_field_css = '''.pro-date-field {
  background: transparent !important;
  border: none !important;
  color: #111827 !important;
  font-family: 'JetBrains Mono', monospace !important;
  font-size: 0.78rem !important;
  font-weight: 800 !important;
  padding: 0 1px !important;
  width: auto !important;
  flex: 1 1 0 !important;
  min-width: 105px !important;
  max-width: 130px !important;
  outline: none !important;
  cursor: pointer !important;
  box-sizing: border-box !important;
}'''

if old_date_field_css in css:
    css = css.replace(old_date_field_css, new_date_field_css, 1)
    print("Updated .pro-date-field in style.css")

with open('style.css', 'w', encoding='utf-8') as f:
    f.write(css)

shutil.copy('style.css', 'dashboard_bi/style.css')
print("Synced style.css to dashboard_bi/style.css")


# ========================================================
# 2. Update index.html for date picker inline & section reordering
# ========================================================
with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Update date picker container in index.html
old_date_picker_html = '''    <!-- Calendrier : Plage de dates personnalisées -->
    <div class="pro-filter-group date-filter-group" id="group-filter-date">
      <label class="pro-filter-label" for="filter-date-start">
        <i data-lucide="calendar" class="w-3.5 h-3.5 text-[#8E0E14]"></i>
        <span>Plage Personnalisée</span>
      </label>
      <div class="pro-date-picker-wrap">
        <input type="date" id="filter-date-start" class="pro-date-field" value="2026-04-01" min="2026-01-01" max="2026-12-31" title="Date début" onchange="window.handleManualDateChange()">
        <span class="date-arrow">&rarr;</span>
        <input type="date" id="filter-date-end" class="pro-date-field" value="2026-10-20" min="2026-01-01" max="2026-12-31" title="Date fin" onchange="window.handleManualDateChange()">
      </div>
    </div>'''

new_date_picker_html = '''    <!-- Calendrier : Plage de dates personnalisées (Format Conforme sans Débordement) -->
    <div class="pro-filter-group date-filter-group" id="group-filter-date" style="min-width: 310px; flex: 2 0 auto; box-sizing: border-box;">
      <label class="pro-filter-label" for="filter-date-start">
        <i data-lucide="calendar" class="w-3.5 h-3.5 text-[#8E0E14]"></i>
        <span>Plage Personnalisée</span>
      </label>
      <div class="pro-date-picker-wrap" style="width: 100%; box-sizing: border-box;">
        <input type="date" id="filter-date-start" class="pro-date-field" value="2026-04-01" min="2026-01-01" max="2026-12-31" title="Date début" onchange="window.handleManualDateChange()">
        <span class="date-arrow">&rarr;</span>
        <input type="date" id="filter-date-end" class="pro-date-field" value="2026-10-20" min="2026-01-01" max="2026-12-31" title="Date fin" onchange="window.handleManualDateChange()">
      </div>
    </div>'''

if old_date_picker_html in html:
    html = html.replace(old_date_picker_html, new_date_picker_html, 1)
    print("Updated date picker in index.html")

# REORDER SECTIONS ON PAGE 1 COCKPIT:
# Extract blocks:
s_cockpit_start = html.find('id="tab-cockpit"')
s2_header = html.find('SECTION 2 : R', s_cockpit_start)
s2_block_start = html.rfind('<!--', 0, s2_header)

s3_header = html.find('SECTION 3 : DYNAMIQUE', s_cockpit_start)
s3_block_start = html.rfind('<!--', 0, s3_header)

s4_header = html.find('SECTION 4 : D', s_cockpit_start)
s4_block_start = html.rfind('<!--', 0, s4_header)

s_decomp = html.find('<!-- Module IA CDC : Arbre de D', s_cockpit_start)

# Block A: 2x2 grid (Répartition, Carto, Classement)
block_grid_2x2 = html[s2_block_start:s3_block_start]

# Block B: Dynamique des Inscriptions & Répertoire CRM
block_inscriptions_crm = html[s3_block_start:s4_block_start]

# Block C: Détection Grossistes
block_grossistes = html[s4_block_start:s_decomp]

# Update block_inscriptions_crm header to Section 1
block_inscriptions_crm = block_inscriptions_crm.replace(
    '<!-- SECTION 3 : DYNAMIQUE DES INSCRIPTIONS & RÉPERTOIRE CRM  -->',
    '<!-- SECTION 1 : DYNAMIQUE DES INSCRIPTIONS & RÉPERTOIRE CRM (PLACÉ EN PREMIER) -->'
).replace(
    '<span class="bondin-section-badge">3</span>',
    '<span class="bondin-section-badge">1</span>'
)

# Update block_grid_2x2 badge to Section 2
block_grid_2x2 = block_grid_2x2.replace(
    '<span class="bondin-section-badge">2</span>',
    '<span class="bondin-section-badge">2</span>'
)

# Update block_grossistes badge to Section 3
block_grossistes = block_grossistes.replace(
    '<!-- SECTION 4 : DÉTECTION DES PROFILS GROSSISTES & VOLUMES B2B -->',
    '<!-- SECTION 3 : DÉTECTION DES PROFILS GROSSISTES & VOLUMES B2B -->'
).replace(
    '<span class="bondin-section-badge">4</span>',
    '<span class="bondin-section-badge">3</span>'
)

# Add section headers to Arbre de Décomposition (Section 4) and What-If (Section 5)
arbre_header_html = '''      <!-- ======================================================== -->
      <!-- SECTION 4 : ARBRE DE DÉCOMPOSITION STRATÉGIQUE DU CA      -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 22px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">4</span>
        <h2 class="bondin-section-title">Arbre de Décomposition Stratégique du CA Client</h2>
      </div>
      '''

whatif_header_html = '''      <!-- ======================================================== -->
      <!-- SECTION 5 : SIMULATEUR WHAT-IF & SENSIBILITÉ DU BARÈME    -->
      <!-- ======================================================== -->
      <div class="bondin-report-section-header" style="margin: 22px 0 16px 0;">
        <span class="bondin-section-bar"></span>
        <span class="bondin-section-badge">5</span>
        <h2 class="bondin-section-title">Simulateur Dynamique What-If : Sensibilité Barème &amp; Dette DAX</h2>
      </div>
      '''

# Check if Arbre already has section header
if 'SECTION 4 : ARBRE DE DÉCOMPOSITION' not in html:
    html = html.replace('<!-- Module IA CDC : Arbre de Décomposition IA -->', arbre_header_html + '<!-- Module IA CDC : Arbre de Décomposition IA -->', 1)

if 'SECTION 5 : SIMULATEUR WHAT-IF' not in html:
    html = html.replace('<!-- MODULE WHAT-IF SIMULATOR DAX (EXIGENCE EXPLICITE CAHIER DES CHARGES PAGE 3) -->', whatif_header_html + '<!-- MODULE WHAT-IF SIMULATOR DAX (EXIGENCE EXPLICITE CAHIER DES CHARGES PAGE 3) -->', 1)

# Now rebuild the order in tab-cockpit:
# Inscriptions CRM (Block B) FIRST, then 2x2 Grid (Block A), then Grossistes (Block C)
new_cockpit_flow = block_inscriptions_crm + '\n      ' + block_grid_2x2 + '\n      ' + block_grossistes

# Replace the region from s2_block_start to s_decomp
# Need to recalculate s_decomp in the updated html
s_decomp_new = html.find('<!-- ========================================================\n      <!-- SECTION 4 : ARBRE DE DÉCOMPOSITION')
if s_decomp_new == -1:
    s_decomp_new = html.find('<!-- Module IA CDC : Arbre de Décomposition IA -->')

# Let's perform the reassembly
html = html[:s2_block_start] + new_cockpit_flow + '\n      ' + html[s_decomp:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

shutil.copy('index.html', 'dashboard_bi/index.html')
print("Successfully reordered sections in index.html and synced to dashboard_bi/index.html")
