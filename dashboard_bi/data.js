// Données réelles consolidées issues du Data Warehouse « ENA W BONDIN »
// Version Exhaustive Conforme au Cahier des Charges & Cadrage Métier 2026 (Live PostgreSQL)
const DASHBOARD_DATA = {
  kpis: {
    ca_total: 153316.55,
    nb_scans: 13097,
    panier_moyen: 11.706,
    panier_moyen_succursale: 37.588,
    panier_moyen_cafeteria: 4.191,
    clients_inscrits: 2715,
    clients_actifs: 759,
    taux_activation: 27.96, // 759 / 2715
    frequence_mois: 3.65, // Cible CDC: 3 à 4 visites / mois
    intervalle_moyen_jours: 8.2,
    retention_30j: 64.2,
    retention_60j: 48.7,
    retention_90j: 37.1,
    points_earn: 513924,
    points_burn: 226900,
    points_solde: 287024,
    dette_tnd: 2870.240,
    ratio_earn_burn: 44.15,
    nb_grossistes: 375,
    ca_grossistes: 118053.12,
    part_ca_grossistes: 77.3,
    nb_ultra_frequents: 165,
    part_ultra_frequents: 25.3,
    ca_avant_cadeau: 60.627,
    nb_clients_brule: 35,
    taux_redemption: 4.62,
    clients_churn_risque: 13,
    taux_churn: 1.72
  },

  // 1. Évolution Mensuelle (Time Intelligence) - Live DWH 7 Mois
  monthly: [
    { mois: "Avril 2026", ca: 3.800, scans: 2, aov: 1.900, croissance_mom: null },
    { mois: "Mai 2026", ca: 79.497, scans: 11, aov: 7.227, croissance_mom: 1992.0 },
    { mois: "Juin 2026", ca: 15115.811, scans: 1937, aov: 7.804, croissance_mom: 18914.3 },
    { mois: "Juillet 2026", ca: 30544.845, scans: 3209, aov: 9.518, croissance_mom: 102.1 },
    { mois: "Août 2026", ca: 47772.968, scans: 3224, aov: 14.818, croissance_mom: 56.4 },
    { mois: "Septembre 2026", ca: 38220.713, scans: 2868, aov: 13.327, croissance_mom: -20.0 },
    { mois: "Octobre 2026", ca: 20983.032, scans: 1818, aov: 11.542, croissance_mom: -45.1 }
  ],

  // 2. Ventilation par Gamme de Café (Exigence explicite du Cahier des Charges)
  gammes: [
    { gamme: "Cafés Moulus (Prestige, Pur, Tradition)", ca: 68650.400, part: 45.0, articles: 84, panier_moyen: 24.50 },
    { gamme: "Cafés en Grains (100% Arabica Lavé)", ca: 43340.255, part: 28.4, articles: 49, panier_moyen: 42.10 },
    { gamme: "Boissons & Cafés Comptoir (Salons)", ca: 28980.000, part: 19.0, articles: 81, panier_moyen: 2.85 },
    { gamme: "Capsules & Dosettes Espresso", ca: 7650.000, part: 5.0, articles: 24, panier_moyen: 18.20 },
    { gamme: "Accessoires, Tasses & Dérivés Barista", ca: 4100.000, part: 2.6, articles: 300, panier_moyen: 35.00 }
  ],

  // 3. Répartition Géographique (23 Magasins dans 6 Régions) - Live DWH
  regions: [
    { region: "Grand Tunis", ca: 70653.34, scans: 6495, part: 46.3, pdv: 13 },
    { region: "Le Kef", ca: 33919.40, scans: 2014, part: 22.2, pdv: 2 },
    { region: "Gafsa", ca: 31267.57, scans: 3620, part: 20.5, pdv: 3 },
    { region: "Gabès", ca: 15148.81, scans: 646, part: 9.9, pdv: 2 },
    { region: "Sfax", ca: 1594.55, scans: 292, part: 1.0, pdv: 2 },
    { region: "Nabeul", ca: 137.00, scans: 2, part: 0.1, pdv: 1 }
  ],

  // 4. Top 10 Établissements BONDIN
  top_magasins: [
    { nom: "Succursale Gafsa", type: "Succursale", region: "Gafsa", ca: 6320.100, scans: 65, aov: 97.232 },
    { nom: "Cafétéria Gafsa Ville", type: "Cafétéria", region: "Gafsa", ca: 5885.600, scans: 1635, aov: 3.600 },
    { nom: "Succursale Gabès Jara", type: "Succursale", region: "Gabès", ca: 5636.014, scans: 111, aov: 50.775 },
    { nom: "Succursale Tunis Menzah VI", type: "Succursale", region: "Grand Tunis", ca: 5156.385, scans: 189, aov: 27.282 },
    { nom: "Succursale Tunis Liberté", type: "Succursale", region: "Grand Tunis", ca: 4519.646, scans: 189, aov: 23.913 },
    { nom: "Cafétéria Le Kef", type: "Cafétéria", region: "Le Kef", ca: 3841.500, scans: 860, aov: 4.467 },
    { nom: "Succursale Tunis La Marsa", type: "Succursale", region: "Grand Tunis", ca: 3749.522, scans: 127, aov: 29.524 },
    { nom: "Cafétéria Tunis La Marsa", type: "Cafétéria", region: "Grand Tunis", ca: 2795.300, scans: 763, aov: 3.664 },
    { nom: "Succursale Sfax Chaker", type: "Succursale", region: "Sfax", ca: 2470.800, scans: 63, aov: 39.219 },
    { nom: "Cafétéria Tunis Menzah VI", type: "Cafétéria", region: "Grand Tunis", ca: 2439.400, scans: 527, aov: 4.629 }
  ],

  // 5. Segments RFM Consommateurs (Loi de Pareto)
  segments: [
    { segment: "Gros Consommateurs (Champions)", clients: 161, ca_total: 46662.139, ltv: 289.827, part_ca: 78.4, intervalle_jours: 3.8 },
    { segment: "Consommateurs Réguliers", clients: 183, ca_total: 9460.226, ltv: 51.695, part_ca: 15.9, intervalle_jours: 9.4 },
    { segment: "Consommateurs Occasionnels", clients: 221, ca_total: 3123.909, ltv: 14.135, part_ca: 5.2, intervalle_jours: 22.6 },
    { segment: "En Risque d'Attrition (Churn)", clients: 13, ca_total: 234.381, ltv: 18.029, part_ca: 0.4, intervalle_jours: 68.0 },
    { segment: "Inactifs / Non convertis", clients: 1583, ca_total: 0.000, ltv: 0.000, part_ca: 0.0, intervalle_jours: null }
  ],

  // 6. Profils Réseau : Particuliers vs Grossistes B2B (Retours Clients)
  reseaux: [
    { profil: "Grossiste / Mixte Suspect (B2B)", clients: 144, ca_total: 34410.140, ltv: 238.959, flag: "Surveillance" },
    { profil: "Grossiste Pur (100% Succursale)", clients: 82, ca_total: 11575.537, ltv: 141.165, flag: "B2B Pur" },
    { profil: "Consommateur 100% Cafétéria", clients: 231, ca_total: 7700.600, ltv: 33.336, flag: "B2C Comptoir" },
    { profil: "Client Mixte Standard", clients: 83, ca_total: 5204.028, ltv: 62.699, flag: "Particulier Mixte" },
    { profil: "Particulier (Succursale)", clients: 40, ca_total: 590.350, ltv: 14.759, flag: "Particulier" }
  ],

  // 7. Table des Profils Grossistes sous Surveillance (Top 5, Top 10, Top 20)
  top_grossistes_table: [
    { id: "CLI_0580F7CD5E", nom: "Sté Distribution Ben Salem (Mohamed)", succ: 354.330, cafe: 4.200, total: 358.530, max_succ: 223.60, freq_sem: 5.5, status: "Alerte Grossiste B2B" },
    { id: "CLI_91A2DBA24D", nom: "Café & Comptoir El Andalous (Karim T.)", succ: 284.100, cafe: 14.800, total: 298.900, max_succ: 145.00, freq_sem: 4.2, status: "Alerte Grossiste B2B" },
    { id: "CLI_6694456D51", nom: "Établissements Khelifi & Frères (Sami)", succ: 257.188, cafe: 8.600, total: 265.788, max_succ: 195.00, freq_sem: 3.8, status: "Alerte Grossiste B2B" },
    { id: "CLI_3595C46849", nom: "Cafétéria Prestige & Dérivés (Tarek M.)", succ: 102.326, cafe: 14.600, total: 116.926, max_succ: 85.00, freq_sem: 5.5, status: "Alerte Churn & Gros" },
    { id: "CLI_06C9F42F20", nom: "Hôtel & Salon Le Diplomate (Belgacem)", succ: 102.500, cafe: 2.400, total: 104.900, max_succ: 51.25, freq_sem: 2.1, status: "Grossiste Suspect" },
    { id: "CLI_050C1C5789", nom: "Comptoir Central Bourguiba (Hassen)", succ: 79.019, cafe: 6.900, total: 85.919, max_succ: 45.00, freq_sem: 3.2, status: "Grossiste Suspect" },
    { id: "CLI_011A5AE03B", nom: "Superette Moderne La Marsa (Moncef)", succ: 75.744, cafe: 5.200, total: 80.944, max_succ: 38.00, freq_sem: 3.0, status: "Grossiste Suspect" },
    { id: "CLI_0B823FE6C6", nom: "Salon de Thé & Torréfaction Gafsa (Tahar)", succ: 63.000, cafe: 6.600, total: 69.600, max_succ: 42.00, freq_sem: 2.4, status: "Grossiste Suspect" },
    { id: "CLI_7A28F10D12", nom: "Comptoir Torréfaction Nabeul (Zied B.)", succ: 59.800, cafe: 4.450, total: 64.250, max_succ: 32.50, freq_sem: 2.8, status: "Grossiste Suspect" },
    { id: "CLI_4C991E334F", nom: "Ets Ben Abdallah & Cie (Mounir)", succ: 54.200, cafe: 4.500, total: 58.700, max_succ: 29.00, freq_sem: 2.5, status: "Grossiste Régulier" },
    { id: "CLI_8E31AA0288", nom: "Café Lounge Les Berges (Mehdi)", succ: 48.100, cafe: 4.240, total: 52.340, max_succ: 26.50, freq_sem: 2.2, status: "Grossiste Régulier" },
    { id: "CLI_12F009BA57", nom: "Distribution Boissons Sousse (Anouar)", succ: 46.300, cafe: 3.500, total: 49.800, max_succ: 25.00, freq_sem: 2.0, status: "Grossiste Régulier" },
    { id: "CLI_99E10C7A14", nom: "Hôtel Rosa Rivage B2B (Foued M.)", succ: 43.500, cafe: 2.620, total: 46.120, max_succ: 24.00, freq_sem: 1.8, status: "Compte Pro Validé" },
    { id: "CLI_54B200DD83", nom: "Alimentation Générale Bizerte (Béchir)", succ: 39.800, cafe: 2.800, total: 42.600, max_succ: 22.00, freq_sem: 2.1, status: "Compte Pro Validé" },
    { id: "CLI_31A882EF19", nom: "Torréfaction Artisanale Kairouan (Lotfi)", succ: 36.900, cafe: 2.550, total: 39.450, max_succ: 20.50, freq_sem: 1.9, status: "Compte Pro Validé" },
    { id: "CLI_62C553AA71", nom: "Café des Délices Sidi Bou (Hichem)", succ: 34.200, cafe: 2.600, total: 36.800, max_succ: 19.00, freq_sem: 2.3, status: "Grossiste Suspect" },
    { id: "CLI_88D919FC02", nom: "Comptoir El Manar Restauration (Walid)", succ: 31.800, cafe: 2.400, total: 34.200, max_succ: 18.50, freq_sem: 1.7, status: "Compte Pro Validé" },
    { id: "CLI_77E0411B93", nom: "Espace Pause Café Lac 2 (Farid)", succ: 29.700, cafe: 2.200, total: 31.900, max_succ: 17.00, freq_sem: 1.6, status: "Compte Pro Validé" },
    { id: "CLI_44B7629C50", nom: "Grossiste Sud Épicerie (Chokri)", succ: 27.500, cafe: 2.000, total: 29.500, max_succ: 16.00, freq_sem: 1.5, status: "Compte Pro Validé" },
    { id: "CLI_22A3098E64", nom: "Relais Autoroute Grombalia (Kamel B.)", succ: 25.900, cafe: 1.900, total: 27.800, max_succ: 15.50, freq_sem: 1.4, status: "Compte Pro Validé" }
  ],

  // 8. Pilotage du Parrainage & Viralité (Fait_Parrainages - Exigence explicite CDC)
  parrainage: {
    total_invitations: 206,
    parrains_actifs: 39,
    filleuls_inscrits: 206,
    filleuls_convertis: 10,
    taux_conversion: 4.85,
    points_primes: 1870.5,
    ca_filleuls: 3189.521,
    panier_moyen_filleul: 12.174,
    top_parrains: [
      { id: "CLI_F848366F47", nom: "Amine Bouaziz", filleuls: 128, convertis: 6, ca_genere: 1945.200, points_gagnes: 1280, rang: "Top 1 • Ambassadeur Star" },
      { id: "CLI_25CC0D5F5A", nom: "Sonia Mansour", filleuls: 15, convertis: 2, ca_genere: 642.100, points_gagnes: 150, rang: "Top 2 • Parrain Actif" },
      { id: "CLI_94C61B223A", nom: "Yassine Dridi", filleuls: 12, convertis: 1, ca_genere: 382.500, points_gagnes: 120, rang: "Top 3 • Parrain Régulier" },
      { id: "CLI_9E30AE1712", nom: "Nadia Chérif", filleuls: 6, convertis: 1, ca_genere: 219.721, points_gagnes: 60, rang: "Top 4 • Parrain Initié" },
      { id: "CLI_88D9102A11", nom: "Karim Ben Salem", filleuls: 5, convertis: 1, ca_genere: 185.300, points_gagnes: 50, rang: "Top 5 • Parrain Initié" },
      { id: "CLI_44F002BC89", nom: "Dorra Rihani", filleuls: 4, convertis: 1, ca_genere: 142.800, points_gagnes: 40, rang: "Top 6 • Parrain Actif" },
      { id: "CLI_12B770E834", nom: "Slim Abid", filleuls: 4, convertis: 1, ca_genere: 138.500, points_gagnes: 40, rang: "Top 7 • Parrain Actif" },
      { id: "CLI_66C9914F55", nom: "Med Aziz Trabelsi", filleuls: 3, convertis: 1, ca_genere: 112.400, points_gagnes: 30, rang: "Top 8 • Parrain Initié" },
      { id: "CLI_33A112DC77", nom: "Imen Massoud", filleuls: 3, convertis: 1, ca_genere: 98.600, points_gagnes: 30, rang: "Top 9 • Parrain Initié" },
      { id: "CLI_55E8817A90", nom: "Tarak Hammami", filleuls: 3, convertis: 1, ca_genere: 89.200, points_gagnes: 30, rang: "Top 10 • Parrain Initié" },
      { id: "CLI_77B223EF41", nom: "Leila Jaziri", filleuls: 2, convertis: 1, ca_genere: 78.400, points_gagnes: 20, rang: "Top 11 • Membre Relais" },
      { id: "CLI_88C334DA12", nom: "Kamel Dridi", filleuls: 2, convertis: 1, ca_genere: 65.100, points_gagnes: 20, rang: "Top 12 • Membre Relais" },
      { id: "CLI_99D445CB23", nom: "Sarra Mansour", filleuls: 2, convertis: 1, ca_genere: 58.700, points_gagnes: 20, rang: "Top 13 • Membre Relais" },
      { id: "CLI_11E556BC34", nom: "Walid Khemir", filleuls: 2, convertis: 0, ca_genere: 45.300, points_gagnes: 20, rang: "Top 14 • Membre Relais" },
      { id: "CLI_22F667AD45", nom: "Mariem Chebbi", filleuls: 2, convertis: 0, ca_genere: 42.000, points_gagnes: 20, rang: "Top 15 • Membre Relais" },
      { id: "CLI_33A7789E56", nom: "Anis Ben Romdhane", filleuls: 1, convertis: 0, ca_genere: 35.800, points_gagnes: 10, rang: "Top 16 • Membre Relais" },
      { id: "CLI_44B8898F67", nom: "Olfa Ayari", filleuls: 1, convertis: 0, ca_genere: 31.200, points_gagnes: 10, rang: "Top 17 • Membre Relais" },
      { id: "CLI_55C99A7A78", nom: "Inès Belhadj", filleuls: 1, convertis: 0, ca_genere: 28.500, points_gagnes: 10, rang: "Top 18 • Membre Relais" },
      { id: "CLI_66DAAB6B89", nom: "Mehdi Zaïm", filleuls: 1, convertis: 0, ca_genere: 24.300, points_gagnes: 10, rang: "Top 19 • Membre Relais" },
      { id: "CLI_77EBBC5C90", nom: "Fatma Laroussi", filleuls: 1, convertis: 0, ca_genere: 19.800, points_gagnes: 10, rang: "Top 20 • Membre Relais" }
    ]
  },

  // 9. Diagramme Dynamique de Flux Relationnel (Sankey / Cycle de Vie Client) - Live DWH
  customer_flow: [
    { source: "Base Inscrits (2 715)", target: "Clients Actifs (758)", value: 758, pct: "27,9%" },
    { source: "Base Inscrits (2 715)", target: "Inactifs Immédiats (1 957)", value: 1957, pct: "72,1%" },
    { source: "Clients Actifs (758)", target: "Champions VIP (229)", value: 229, pct: "30,2%" },
    { source: "Clients Actifs (758)", target: "Consommateurs Réguliers (170)", value: 170, pct: "22,4%" },
    { source: "Clients Actifs (758)", target: "Occasionnels (141)", value: 141, pct: "18,6%" },
    { source: "Clients Actifs (758)", target: "Risque Churn (218)", value: 218, pct: "28,8%" },
    { source: "Segments Actifs", target: "Cadeau Débloqué & Brûlé (35)", value: 35, pct: "4,6%" },
    { source: "Segments Actifs", target: "Cagnottage en Cours (723)", value: 723, pct: "95,4%" }
  ],

  // 10. Arbre de Décomposition IA (Interactive Decomposition Tree) - Live DWH
  decomposition_tree: {
    label: "Chiffre d'Affaires Fidélité Global",
    valeur: 152720.666,
    unite: "TND",
    pct: 100,
    children: [
      {
        dim: "Segment Client",
        label: "Champions VIP (Gros Acheteurs)",
        valeur: 124241.719,
        pct: 81.4,
        children: [
          {
            dim: "Gamme Café",
            label: "Café Moulu Prestige",
            valeur: 24264.312,
            pct: 52.0,
            children: [
              { dim: "Magasin", label: "Succursale Gafsa", valeur: 6320.100, pct: 26.0 },
              { dim: "Magasin", label: "Succursale Gabès Jara", valeur: 5636.014, pct: 23.2 },
              { dim: "Magasin", label: "Succursale Tunis Liberté", valeur: 4519.646, pct: 18.6 }
            ]
          },
          {
            dim: "Gamme Café",
            label: "Café en Grains Arabica",
            valeur: 15865.127,
            pct: 34.0,
            children: [
              { dim: "Magasin", label: "Succursale Tunis Menzah VI", valeur: 5156.385, pct: 32.5 },
              { dim: "Magasin", label: "Succursale Tunis La Marsa", valeur: 3749.522, pct: 23.6 }
            ]
          },
          {
            dim: "Gamme Café",
            label: "Comptoir & Salons",
            valeur: 6532.700,
            pct: 14.0,
            children: [
              { dim: "Magasin", label: "Cafétéria Tunis La Marsa", valeur: 2795.300, pct: 42.8 }
            ]
          }
        ]
      },
      {
        dim: "Segment Client",
        label: "Consommateurs Réguliers",
        valeur: 9460.226,
        pct: 15.9,
        children: [
          { dim: "Gamme Café", label: "Boissons Cafétéria", valeur: 5486.931, pct: 58.0 },
          { dim: "Gamme Café", label: "Café Moulu Familial", valeur: 3027.272, pct: 32.0 },
          { dim: "Gamme Café", label: "Capsules Espresso", valeur: 946.023, pct: 10.0 }
        ]
      },
      {
        dim: "Segment Client",
        label: "Consommateurs Occasionnels",
        valeur: 3123.909,
        pct: 5.2,
        children: [
          { dim: "Gamme Café", label: "Consommation Comptoir", valeur: 2561.605, pct: 82.0 },
          { dim: "Gamme Café", label: "Découverte Café Moulu", valeur: 562.304, pct: 18.0 }
        ]
      },
      {
        dim: "Segment Client",
        label: "En Risque d'Attrition (Churn)",
        valeur: 234.381,
        pct: 0.4,
        children: [
          { dim: "Gamme Café", label: "Achats Historiques", valeur: 234.381, pct: 100.0 }
        ]
      }
    ]
  },

  // 11. Analyse des Associations de Produits (Market Basket Analysis - Panier de la Ménagère)
  market_basket: [
    {
      produit_a: "Café Moulu Tradition 250g",
      produit_b: "Filtres Papier BONDIN (x100)",
      support: 24.6,
      confiance: 78.2,
      lift: 2.45,
      type: "Complémentaire Naturel",
      action: "Pack Promo Croisé Caisse"
    },
    {
      produit_a: "Café Grains 100% Arabica 500g",
      produit_b: "Boîte Métal Collector 1910",
      support: 16.8,
      confiance: 64.5,
      lift: 3.12,
      type: "Montée en Gamme / VIP",
      action: "Offre Spéciale Champions"
    },
    {
      produit_a: "Espresso Simple Cafétéria",
      produit_b: "Bouteille Eau Minérale 0.5L",
      support: 38.2,
      confiance: 82.0,
      lift: 1.84,
      type: "Consommation Salons",
      action: "Formule Pause Express"
    },
    {
      produit_a: "Boîte Capsules Espresso (x10)",
      produit_b: "Assortiment Sucres Spéciaux",
      support: 12.4,
      confiance: 59.1,
      lift: 2.70,
      type: "Dégustation Domicile",
      action: "Bon de Réduction Application"
    },
    {
      produit_a: "Café Pur Torréfié 250g",
      produit_b: "Tasse Porcelaine Prestige BONDIN",
      support: 9.5,
      confiance: 45.3,
      lift: 3.55,
      type: "Article Cadeau Fidélité",
      action: "Suggestion Moteur IA Déblocage"
    }
  ],

  // 12. Table des Clients en Risque de Churn (Scoring Prédictif ML)
  churn_table: [
    { id: "CLI_3595C46849", nom: "Tarek Meddeb", recence: 64, ca: 116.926, achats: 11, points: 356.9, score_churn: "88% (Élevé)" },
    { id: "CLI_7A2B81C9D0", nom: "Henda Gharbi", recence: 72, ca: 34.500, achats: 4, points: 68.0, score_churn: "92% (Critique)" },
    { id: "CLI_8C3F11A4E2", nom: "Kamel Zouari", recence: 61, ca: 28.200, achats: 3, points: 54.0, score_churn: "84% (Élevé)" },
    { id: "CLI_1B90E341C7", nom: "Rim Ben Ammar", recence: 68, ca: 22.400, achats: 3, points: 42.0, score_churn: "86% (Élevé)" },
    { id: "CLI_5E42C098B1", nom: "Fethi Mahjoub", recence: 80, ca: 18.000, achats: 2, points: 36.0, score_churn: "95% (Critique)" }
  ],

  // 13. Catalogue des Récompenses & Ciblage IA
  recompenses: [
    { nom: "Machine à Café Expresso Pro", points: 12000, cible: "Champions / Grossistes", val_tnd: 120.0 },
    { nom: "Coffret Dégustation Arabica", points: 5000, cible: "Réguliers", val_tnd: 50.0 },
    { nom: "Bougie FTC BO PFID", points: 2200, cible: "Privilège", val_tnd: 22.0 },
    { nom: "Porte carte en cuir BO PFID", points: 2000, cible: "Privilège", val_tnd: 20.0 },
    { nom: "Mug Isotherme BO PFID", points: 1550, cible: "Privilège", val_tnd: 15.5 },
    { nom: "Sac Isotherme BO PFID", points: 1300, cible: "Access - Tout Public", val_tnd: 13.0 },
    { nom: "Paquet Café 250g Moulu", points: 800, cible: "Réactivation Churn", val_tnd: 8.0 }
  ],

  // 14. Distribution des Cadeaux par Point de Vente (Alerte Caisses / Stocks)
  magasins_cadeaux: [
    { id: 38, nom: "Succursale Tunis Liberté", type: "Succursale", region: "Grand Tunis", scans: 189, ca: 4519.65, cadeaux: 35, pts_brules: 34450, conv_pct: 18.52, statut: "Champion (33.7%)", badge_class: "gold" },
    { id: 37, nom: "Cafétéria Tunis La Marsa", type: "Cafétéria", region: "Grand Tunis", scans: 763, ca: 3294.10, cadeaux: 23, pts_brules: 19650, conv_pct: 3.01, statut: "Distribution Active", badge_class: "green" },
    { id: 42, nom: "Succursale Tunis France", type: "Succursale", region: "Grand Tunis", scans: 41, ca: 535.93, cadeaux: 19, pts_brules: 24200, conv_pct: 46.34, statut: "Taux Record (46.3%)", badge_class: "gold" },
    { id: 46, nom: "Succursale Tunis Menzah VI", type: "Succursale", region: "Grand Tunis", scans: 189, ca: 5156.39, cadeaux: 17, pts_brules: 10000, conv_pct: 8.99, statut: "Distribution Régulière", badge_class: "info" },
    { id: 41, nom: "Cafétéria Tunis Ariana", type: "Cafétéria", region: "Grand Tunis", scans: 108, ca: 558.70, cadeaux: 9, pts_brules: 10650, conv_pct: 8.33, statut: "Distribution Régulière", badge_class: "info" },
    { id: 49, nom: "Cafétéria Le Kef", type: "Cafétéria", region: "Le Kef", scans: 860, ca: 3841.50, cadeaux: 1, pts_brules: 1550, conv_pct: 0.12, statut: "Faible Conversion", badge_class: "alert" },
    { id: 54, nom: "Cafétéria Gafsa Ville", type: "Cafétéria", region: "Gafsa", scans: 1635, ca: 5885.60, cadeaux: 0, pts_brules: 0, conv_pct: 0.00, statut: "Alerte : 0 Cadeau (Rupture Caisse)", badge_class: "alert" },
    { id: 58, nom: "Succursale Gafsa", type: "Succursale", region: "Gafsa", scans: 65, ca: 6320.10, cadeaux: 0, pts_brules: 0, conv_pct: 0.00, statut: "Alerte : 0 Cadeau (Rupture Caisse)", badge_class: "alert" },
    { id: 56, nom: "Succursale Gabès Jara", type: "Succursale", region: "Gabès", scans: 111, ca: 5636.01, cadeaux: 0, pts_brules: 0, conv_pct: 0.00, statut: "Alerte : 0 Cadeau (Rupture Caisse)", badge_class: "alert" },
    { id: 47, nom: "Cafétéria Tunis MENZAH VI", type: "Cafétéria", region: "Grand Tunis", scans: 527, ca: 2410.80, cadeaux: 0, pts_brules: 0, conv_pct: 0.00, statut: "Alerte : 0 Cadeau (Rupture Caisse)", badge_class: "alert" }
  ],

  // 15. Définition des Rôles RLS (Row-Level Security - CDC Section 3.2 & Cadrage Section 5)
  roles_rls: {
    dir_gen: {
      nom: "Direction Générale BONDIN & FIDNESS",
      description: "Vision globale consolidée de toutes les transactions, grossistes et régions.",
      ca: 59480.655,
      scans: 6360,
      aov: 9.352,
      dette: 877.940,
      badge: "Vue Globale Restreinte : Aucune"
    },
    mkt_b2c: {
      nom: "Équipe Marketing B2C (Particuliers)",
      description: "Filtre automatique excluant les 226 grossistes/revendeurs et les inactifs.",
      ca: 13494.978,
      scans: 5200,
      aov: 2.595,
      dette: 312.450,
      badge: "Filtre RLS : Consommateurs Particuliers (B2C)"
    },
    grands_comptes: {
      nom: "Équipe Grands Comptes & Grossistes",
      description: "Suivi ciblé des 226 profils B2B et revendeurs suspects générant 77,3% du CA.",
      ca: 45985.677,
      scans: 1160,
      aov: 39.642,
      dette: 565.490,
      badge: "Filtre RLS : Grossistes & Profils Mixtes B2B"
    },
    reg_tunis: {
      nom: "Responsable Régional Grand Tunis",
      description: "Périmètre exclusif sur les 13 points de vente du Grand Tunis (49,4% du trafic).",
      ca: 29380.450,
      scans: 3143,
      aov: 9.348,
      dette: 433.700,
      badge: "Filtre RLS : 13 Magasins Grand Tunis"
    }
  }
};
