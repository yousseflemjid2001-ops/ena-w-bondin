import re, shutil

# ========================================================
# 1. Update style.css
# ========================================================
with open('style.css', 'r', encoding='utf-8') as f:
    css = f.read()

# Update table-responsive to completely hide horizontal scrollbar
old_table_responsive = '''.table-responsive {
  width: 100% !important;
  max-height: 275px !important;
  overflow-y: auto !important;
  overflow-x: auto !important;
  position: relative !important;
  scrollbar-width: thin;
  scrollbar-color: rgba(142, 14, 20, 0.35) rgba(0, 0, 0, 0.04);
  border-radius: 8px;
  box-shadow: inset 0 -3px 6px rgba(0, 0, 0, 0.02);
}

.table-responsive::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}'''

new_table_responsive = '''.table-responsive {
  width: 100% !important;
  max-height: 480px !important;
  overflow-y: auto !important;
  overflow-x: hidden !important;
  position: relative !important;
  scrollbar-width: thin;
  scrollbar-color: rgba(142, 14, 20, 0.35) rgba(0, 0, 0, 0.04);
  border-radius: 8px;
  box-shadow: inset 0 -3px 6px rgba(0, 0, 0, 0.02);
}

/* Suppression TOTALE et DÉFINITIVE de toute barre de défilement horizontale */
.table-responsive::-webkit-scrollbar {
  width: 6px;
  height: 0px !important;
}

.table-responsive::-webkit-scrollbar:horizontal,
.table-responsive::-webkit-scrollbar-thumb:horizontal,
.table-responsive::-webkit-scrollbar-track:horizontal,
::-webkit-scrollbar:horizontal {
  display: none !important;
  height: 0px !important;
  width: 0px !important;
  background: transparent !important;
}'''

if old_table_responsive in css:
    css = css.replace(old_table_responsive, new_table_responsive, 1)
    print("Replaced old .table-responsive in style.css")
else:
    # Do regex replace for .table-responsive
    css = re.sub(
        r'\.table-responsive\s*\{[^}]*overflow-x:[^}]*\}',
        new_table_responsive.split('\n\n/*')[0],
        css
    )
    print("Applied regex replacement for .table-responsive")

# Add fixed-table and no-horizontal-scroll utility classes to style.css if not present
util_css = '''
/* Suppression des barres de scroll horizontal sur tous les tableaux et conteneurs */
.no-horizontal-scroll,
.table-responsive {
  overflow-x: hidden !important;
}

.data-table.fixed-table {
  width: 100% !important;
  table-layout: fixed !important;
}

.data-table.fixed-table th,
.data-table.fixed-table td {
  overflow: hidden !important;
  text-overflow: ellipsis !important;
  white-space: nowrap !important;
  padding: 9px 8px !important;
}

.data-table.fixed-table td a[href^="mailto:"] {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}

#decomp-tree-container {
  overflow-x: hidden !important;
}

.decomp-tree-flex {
  min-width: 0 !important;
  width: 100% !important;
}
'''

if '.data-table.fixed-table' not in css:
    css += util_css
    print("Added util_css for fixed tables and no horizontal scroll")

with open('style.css', 'w', encoding='utf-8') as f:
    f.write(css)

shutil.copy('style.css', 'dashboard_bi/style.css')
print("Synced style.css to dashboard_bi/style.css")
