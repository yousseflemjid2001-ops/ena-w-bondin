import json, shutil

grossistes_updated = [
    { 'id': 'CLI_0580F7CD5E', 'nom': 'Sté Distribution Ben Salem (Mohamed)', 'tel': '+216 98 412 850', 'email': 'contact@bensalem-distrib.tn', 'points': 3585, 'succ': 354.330, 'cafe': 4.200, 'total': 358.530, 'max_succ': 223.60, 'freq_sem': 5.5, 'status': 'Alerte Grossiste B2B' },
    { 'id': 'CLI_91A2DBA24D', 'nom': 'Café & Comptoir El Andalous (Karim T.)', 'tel': '+216 22 654 980', 'email': 'k.andalous@topnet.tn', 'points': 2989, 'succ': 284.100, 'cafe': 14.800, 'total': 298.900, 'max_succ': 145.00, 'freq_sem': 4.2, 'status': 'Alerte Grossiste B2B' },
    { 'id': 'CLI_6694456D51', 'nom': 'Établissements Khelifi & Frères (Sami)', 'tel': '+216 55 321 789', 'email': 'sami.khelifi@ets-khelifi.com', 'points': 2658, 'succ': 257.188, 'cafe': 8.600, 'total': 265.788, 'max_succ': 195.00, 'freq_sem': 3.8, 'status': 'Alerte Grossiste B2B' },
    { 'id': 'CLI_3595C46849', 'nom': 'Cafétéria Prestige & Dérivés (Tarek M.)', 'tel': '+216 98 789 123', 'email': 'prestige.cafe@planet.tn', 'points': 1169, 'succ': 102.326, 'cafe': 14.600, 'total': 116.926, 'max_succ': 85.00, 'freq_sem': 5.5, 'status': 'Alerte Churn & Gros' },
    { 'id': 'CLI_06C9F42F20', 'nom': 'Hôtel & Salon Le Diplomate (Belgacem)', 'tel': '+216 71 890 234', 'email': 'direction@hotel-diplomate.tn', 'points': 1049, 'succ': 102.500, 'cafe': 2.400, 'total': 104.900, 'max_succ': 51.25, 'freq_sem': 2.1, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_050C1C5789', 'nom': 'Comptoir Central Bourguiba (Hassen)', 'tel': '+216 24 567 890', 'email': 'hassen.bourguiba@comptoir-central.tn', 'points': 859, 'succ': 79.019, 'cafe': 6.900, 'total': 85.919, 'max_succ': 45.00, 'freq_sem': 3.2, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_011A5AE03B', 'nom': 'Superette Moderne La Marsa (Moncef)', 'tel': '+216 97 123 456', 'email': 'moncef.marsa@superette.tn', 'points': 809, 'succ': 75.744, 'cafe': 5.200, 'total': 80.944, 'max_succ': 38.00, 'freq_sem': 3.0, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_0B823FE6C6', 'nom': 'Salon de Thé & Torréfaction Gafsa (Tahar)', 'tel': '+216 26 345 678', 'email': 'tahar.gafsa@torrefaction.tn', 'points': 696, 'succ': 63.000, 'cafe': 6.600, 'total': 69.600, 'max_succ': 42.00, 'freq_sem': 2.4, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_7A28F10D12', 'nom': 'Comptoir Torréfaction Nabeul (Zied B.)', 'tel': '+216 50 234 567', 'email': 'zied.b@nabeul-torrefaction.com', 'points': 643, 'succ': 59.800, 'cafe': 4.450, 'total': 64.250, 'max_succ': 32.50, 'freq_sem': 2.8, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_4C991E334F', 'nom': 'Ets Ben Abdallah & Cie (Mounir)', 'tel': '+216 98 678 901', 'email': 'mounir@benabdallah.tn', 'points': 587, 'succ': 54.200, 'cafe': 4.500, 'total': 58.700, 'max_succ': 29.00, 'freq_sem': 2.5, 'status': 'Grossiste Régulier' },
    { 'id': 'CLI_8E31AA0288', 'nom': 'Café Lounge Les Berges (Mehdi)', 'tel': '+216 29 456 789', 'email': 'mehdi.lounge@bergesdulac.tn', 'points': 523, 'succ': 48.100, 'cafe': 4.240, 'total': 52.340, 'max_succ': 26.50, 'freq_sem': 2.2, 'status': 'Grossiste Régulier' },
    { 'id': 'CLI_12F009BA57', 'nom': 'Distribution Boissons Sousse (Anouar)', 'tel': '+216 21 890 123', 'email': 'anouar@boissons-sousse.tn', 'points': 498, 'succ': 46.300, 'cafe': 3.500, 'total': 49.800, 'max_succ': 25.00, 'freq_sem': 2.0, 'status': 'Grossiste Régulier' },
    { 'id': 'CLI_99E10C7A14', 'nom': 'Hôtel Rosa Rivage B2B (Foued M.)', 'tel': '+216 73 567 890', 'email': 'achats@hotelrosarivage.com', 'points': 461, 'succ': 43.500, 'cafe': 2.620, 'total': 46.120, 'max_succ': 24.00, 'freq_sem': 1.8, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_54B200DD83', 'nom': 'Alimentation Générale Bizerte (Béchir)', 'tel': '+216 52 345 678', 'email': 'bechir.bizerte@gmail.com', 'points': 426, 'succ': 39.800, 'cafe': 2.800, 'total': 42.600, 'max_succ': 22.00, 'freq_sem': 2.1, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_31A882EF19', 'nom': 'Torréfaction Artisanale Kairouan (Lotfi)', 'tel': '+216 96 123 456', 'email': 'lotfi.kairouan@artisanat.tn', 'points': 395, 'succ': 36.900, 'cafe': 2.550, 'total': 39.450, 'max_succ': 20.50, 'freq_sem': 1.9, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_62C553AA71', 'nom': 'Café des Délices Sidi Bou (Hichem)', 'tel': '+216 22 789 012', 'email': 'hichem@cafedesdelices.tn', 'points': 368, 'succ': 34.200, 'cafe': 2.600, 'total': 36.800, 'max_succ': 19.00, 'freq_sem': 2.3, 'status': 'Grossiste Suspect' },
    { 'id': 'CLI_88D919FC02', 'nom': 'Comptoir El Manar Restauration (Walid)', 'tel': '+216 98 234 567', 'email': 'walid.elmanar@resto.tn', 'points': 342, 'succ': 31.800, 'cafe': 2.400, 'total': 34.200, 'max_succ': 18.50, 'freq_sem': 1.7, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_77E0411B93', 'nom': 'Espace Pause Café Lac 2 (Farid)', 'tel': '+216 55 890 123', 'email': 'farid.lac2@pausecafe.tn', 'points': 319, 'succ': 29.700, 'cafe': 2.200, 'total': 29.500, 'max_succ': 17.00, 'freq_sem': 1.6, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_44B7629C50', 'nom': 'Grossiste Sud Épicerie (Chokri)', 'tel': '+216 27 456 789', 'email': 'chokri.sud@epicerie.tn', 'points': 295, 'succ': 27.500, 'cafe': 2.000, 'total': 29.500, 'max_succ': 16.00, 'freq_sem': 1.5, 'status': 'Compte Pro Validé' },
    { 'id': 'CLI_22A3098E64', 'nom': 'Relais Autoroute Grombalia (Kamel B.)', 'tel': '+216 99 567 890', 'email': 'kamel.grombalia@relais.tn', 'points': 278, 'succ': 25.900, 'cafe': 1.900, 'total': 27.800, 'max_succ': 15.50, 'freq_sem': 1.4, 'status': 'Compte Pro Validé' }
]

with open('inscrits_generated.json', 'r', encoding='utf-8') as f:
    inscrits_list = json.load(f)

with open('data.js', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace top_grossistes_table
start_g = content.find('top_grossistes_table: [')
end_g = content.find('  parrainage: {', start_g)
if start_g != -1 and end_g != -1:
    g_json = json.dumps(grossistes_updated, ensure_ascii=False, indent=4)
    content = content[:start_g] + 'top_grossistes_table: ' + g_json + ',\n\n  // 8. ' + content[end_g:]
    print('Updated grossistes in data.js')

# Add rapport_repartition_pdv, rapport_top_pdv_achats, rapport_top_pdv_ca and inscrits_list at the end of DASHBOARD_DATA
if 'inscrits_list:' not in content:
    idx_close = content.rfind('};')
    extra_data = [
        '  rapport_repartition_pdv: [',
        '    { pdv: "Cafétéria Le Kef", pct: 27, achats: 143, ca: 628, color: "#8E0E14" },',
        '    { pdv: "Cafétéria Tunis Liberté", pct: 17, achats: 92, ca: 424, color: "#C00E29" },',
        '    { pdv: "Cafétéria Tunis La Marsa", pct: 16, achats: 85, ca: 338, color: "#D97706" },',
        '    { pdv: "Cafétéria Tunis MENZAH VI", pct: 13, achats: 67, ca: 275, color: "#B45309" },',
        '    { pdv: "Succursale Tunis Menzah VI", pct: 5, achats: 26, ca: 499, color: "#7C3AED" },',
        '    { pdv: "Cafétéria Tunis France", pct: 5, achats: 25, ca: 180, color: "#10B981" },',
        '    { pdv: "Succursale Tunis Liberté", pct: 3, achats: 16, ca: 404, color: "#6B7280" },',
        '    { pdv: "Autres points de vente", pct: 14, achats: 73, ca: 988, color: "#9CA3AF" }',
        '  ],',
        '',
        '  rapport_top_pdv_achats: [',
        '    { pdv: "Cafétéria Le Kef", achats: 143, ca: 628, pct: 27 },',
        '    { pdv: "Cafétéria Tunis Liberté", achats: 92, ca: 424, pct: 17 },',
        '    { pdv: "Cafétéria Tunis La Marsa", achats: 85, ca: 338, pct: 16 },',
        '    { pdv: "Cafétéria Tunis MENZAH VI", achats: 67, ca: 275, pct: 13 },',
        '    { pdv: "Succursale Tunis Menzah VI", achats: 26, ca: 499, pct: 5 },',
        '    { pdv: "Cafétéria Tunis France", achats: 25, ca: 180, pct: 5 },',
        '    { pdv: "Succursale Tunis Liberté", achats: 16, ca: 404, pct: 3 },',
        '    { pdv: "Cafétéria Tunis Espagne", achats: 12, ca: 160, pct: 2 }',
        '  ],',
        '',
        '  rapport_top_pdv_ca: [',
        '    { pdv: "Cafétéria Le Kef", ca: 628, achats: 143 },',
        '    { pdv: "Succursale Tunis Menzah VI", ca: 499, achats: 26 },',
        '    { pdv: "Cafétéria Tunis Liberté", ca: 424, achats: 92 },',
        '    { pdv: "Succursale Tunis Liberté", ca: 404, achats: 16 },',
        '    { pdv: "Cafétéria Tunis La Marsa", ca: 338, achats: 85 },',
        '    { pdv: "Succursale Tunis Espagne", ca: 286, achats: 12 },',
        '    { pdv: "Cafétéria Tunis MENZAH VI", ca: 275, achats: 67 },',
        '    { pdv: "Succursale Tunis Ariana", ca: 203, achats: 8 }',
        '  ],',
        '',
        '  inscrits_list: ' + json.dumps(inscrits_list, ensure_ascii=False, indent=2)
    ]
    content = content[:idx_close] + ',\n' + '\n'.join(extra_data) + '\n};\n'
    print('Added inscrits_list & rapport PDV to data.js')

with open('data.js', 'w', encoding='utf-8') as f:
    f.write(content)

shutil.copy('data.js', 'dashboard_bi/data.js')
print('data.js written and synced to dashboard_bi/data.js')
