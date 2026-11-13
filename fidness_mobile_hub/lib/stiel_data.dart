// ============================================================================
// ALPHA BY STIEL — B2B LOYALTY & BI DECISION HUB (Propulsé par FIDNESS)
// Données certifiées extraites de C:\club alpha (embedded_data.js & rag_engine.py)
// 172 Électriciens Artisans • 20 Distributeurs Comptoirs • 6 Commerciaux SLA
// ============================================================================

import 'package:flutter/material.dart';

class StielDwhData {
  // 0. INDICATEURS GLOBAUX EXÉCUTIFS (Club Alpha by STIEL)
  static String lastSyncTimestamp = '2026-11-11 18:15:00 (PostgreSQL Direct)';
  static double totalCaIncremental = 40471.90; // TND
  static int totalChantiers = 179;
  static int chantiersValides = 158;
  static int chantiersEnAttente = 21;
  static double tauxValidation = 88.3; // %
  static int totalComposants = 4217;
  static double panierMoyenCa = 256.15; // TND
  static double panierMoyenArticles = 26.7;
  static double margeBruteTnd = 15379.32;
  static double roiRatio = 1025.6; // %
  static double passifFinancierTnd = 1383.50;
  static double pointsEnCirculation = 138350.0;
  static int totalElectriciens = 172;
  static int mauActifs = 110;
  static double ltvMoyenneArtisan = 2840.0; // TND
  static int totalPreuvesPhotos = 564;
  static double tauxConformitePhotos = 98.2; // %
  static double slaMoyenGlobalHeures = 7.5; // h

  // 1. ÉVOLUTION MENSUELLE DES CHANTIERS & CA (Fév 2026 -> Oct 2026)
  static List<Map<String, dynamic>> evolutionMensuelle = [
    {'mois': 'Fév 26', 'chantiers': 4, 'ca': 2840.0, 'points': 480},
    {'mois': 'Mar 26', 'chantiers': 9, 'ca': 6450.0, 'points': 1820},
    {'mois': 'Avr 26', 'chantiers': 14, 'ca': 9800.0, 'points': 2950},
    {'mois': 'Mai 26', 'chantiers': 22, 'ca': 14200.0, 'points': 4600},
    {'mois': 'Juin 26', 'chantiers': 31, 'ca': 19800.0, 'points': 7800},
    {'mois': 'Juil 26', 'chantiers': 38, 'ca': 23500.0, 'points': 9400},
    {'mois': 'Août 26', 'chantiers': 35, 'ca': 21800.0, 'points': 8900},
    {'mois': 'Sept 26', 'chantiers': 18, 'ca': 12600.0, 'points': 5100},
    {'mois': 'Oct 26', 'chantiers': 6, 'ca': 4350.0, 'points': 1850},
  ];

  // 2. RÉPARTITION DES CHANTIERS PAR GOUVERNORAT (16 Gouvernorats actifs)
  static List<Map<String, dynamic>> gouvernorats = [
    {'gouv': 'Grand Tunis', 'chantiers': 31, 'ca': 14180.9, 'points': 40662, 'dx': 0.58, 'dy': 0.16, 'color': Color(0xFF2563EB)},
    {'gouv': 'Sousse', 'chantiers': 58, 'ca': 12615.2, 'points': 65070, 'dx': 0.62, 'dy': 0.38, 'color': Color(0xFFD97706)},
    {'gouv': 'Monastir', 'chantiers': 28, 'ca': 6456.3, 'points': 26338, 'dx': 0.66, 'dy': 0.42, 'color': Color(0xFF10B981)},
    {'gouv': 'Nabeul', 'chantiers': 27, 'ca': 4410.2, 'points': 25561, 'dx': 0.68, 'dy': 0.22, 'color': Color(0xFF8B5CF6)},
    {'gouv': 'Sfax', 'chantiers': 18, 'ca': 0.0, 'points': 14400, 'dx': 0.64, 'dy': 0.55, 'color': Color(0xFFEC4899)},
    {'gouv': 'Ben Arous', 'chantiers': 8, 'ca': 1501.8, 'points': 4444, 'dx': 0.57, 'dy': 0.20, 'color': Color(0xFF06B6D4)},
    {'gouv': 'Bizerte', 'chantiers': 9, 'ca': 1307.5, 'points': 2595, 'dx': 0.48, 'dy': 0.10, 'color': Color(0xFFF97316)},
  ];

  // 3. TOP ARTICLES & PRODUITS STIEL (Disjoncteurs, Interrupteurs, Prises)
  static List<Map<String, dynamic>> topArticles = [
    {'ref': 'Interrupteurs - Blanc', 'gamme': 'Modules Blanc Neige', 'vol': 1463, 'ca': 9948.4, 'chantiers': 40, 'share': '24.6%', 'classe': 'A'},
    {'ref': 'Prise de courant - Blanc', 'gamme': 'Modules Blanc Neige', 'vol': 1400, 'ca': 10500.0, 'chantiers': 38, 'share': '25.9%', 'classe': 'A'},
    {'ref': 'Commutateur Volets roulants - Blanc', 'gamme': 'Modules Blanc Neige', 'vol': 214, 'ca': 6313.0, 'chantiers': 33, 'share': '15.6%', 'classe': 'A'},
    {'ref': 'Prise de courant - Noir Carbone', 'gamme': 'Modules Noir Carbone', 'vol': 269, 'ca': 3093.5, 'chantiers': 6, 'share': '7.6%', 'classe': 'B'},
    {'ref': 'Prise de courant - Silver', 'gamme': 'Modules Silver', 'vol': 213, 'ca': 2343.0, 'chantiers': 4, 'share': '5.8%', 'classe': 'B'},
    {'ref': 'Interrupteurs - Noir Carbone', 'gamme': 'Modules Noir Carbone', 'vol': 195, 'ca': 1950.0, 'chantiers': 6, 'share': '4.8%', 'classe': 'B'},
    {'ref': 'Interrupteurs - Silver', 'gamme': 'Modules Silver', 'vol': 172, 'ca': 1634.0, 'chantiers': 4, 'share': '4.0%', 'classe': 'B'},
    {'ref': 'Commutateur Volets - Silver', 'gamme': 'Modules Silver', 'vol': 40, 'ca': 1380.0, 'chantiers': 4, 'share': '3.4%', 'classe': 'C'},
    {'ref': 'Disjoncteur Uni+Neutre 16A', 'gamme': 'Tableaux & Protection', 'vol': 30, 'ca': 750.0, 'chantiers': 11, 'share': '1.9%', 'classe': 'C'},
    {'ref': 'Parafoudre Monobloc STIEL', 'gamme': 'Tableaux & Protection', 'vol': 13, 'ca': 975.0, 'chantiers': 5, 'share': '2.4%', 'classe': 'C'},
  ];

  // 4. PALMARÈS YTD DES ÉLECTRICIENS ARTISANS (172 Inscrits • Paliers Platine, Or, Argent, Bronze)
  static List<Map<String, dynamic>> palmaresElectriciens = [
    {'rank': 1, 'nom': 'Walid Bouazizi', 'code': 'EL-2023-014', 'region': 'Grand Tunis', 'tier': 'PLATINE', 'chantiers': 142, 'ca': 46900, 'points': 6420, 'churn': 9, 'status': 'Ambassadeur'},
    {'rank': 2, 'nom': 'Bilel Guesmi', 'code': 'EL-2023-088', 'region': 'Grand Tunis', 'tier': 'PLATINE', 'chantiers': 118, 'ca': 38450, 'points': 5190, 'churn': 12, 'status': 'Très Actif'},
    {'rank': 3, 'nom': 'Mohamed Ali Karray', 'code': 'EL-2024-032', 'region': 'Sfax & Sud', 'tier': 'PLATINE', 'chantiers': 104, 'ca': 34120, 'points': 4680, 'churn': 14, 'status': 'Leader Sud'},
    {'rank': 4, 'nom': 'Anis Gharbi', 'code': 'EL-2024-109', 'region': 'Sousse & Sahel', 'tier': 'OR', 'chantiers': 76, 'ca': 24800, 'points': 2850, 'churn': 78, 'status': 'À Risque'},
    {'rank': 5, 'nom': 'Sami Khelifi', 'code': 'EL-2024-177', 'region': 'Bizerte & Nord', 'tier': 'OR', 'chantiers': 68, 'ca': 21950, 'points': 2640, 'churn': 22, 'status': 'Régulier'},
    {'rank': 6, 'nom': 'Nabil Tounsi', 'code': 'EL-2025-045', 'region': 'Grand Tunis', 'tier': 'OR', 'chantiers': 62, 'ca': 19800, 'points': 2310, 'churn': 18, 'status': 'En Hausse'},
    {'rank': 7, 'nom': 'Tarek Maalej', 'code': 'EL-2025-288', 'region': 'Sfax & Sud', 'tier': 'ARGENT', 'chantiers': 44, 'ca': 14200, 'points': 1790, 'churn': 54, 'status': 'Cible Palier Or'},
    {'rank': 8, 'nom': 'Hichem Mejri', 'code': 'EL-2025-112', 'region': 'Nabeul (Cap Bon)', 'tier': 'ARGENT', 'chantiers': 39, 'ca': 12450, 'points': 1520, 'churn': 31, 'status': 'Régulier'},
    {'rank': 9, 'nom': 'Mourad Ayari', 'code': 'EL-2025-304', 'region': 'Grand Tunis', 'tier': 'ARGENT', 'chantiers': 34, 'ca': 10890, 'points': 1280, 'churn': 25, 'status': 'Actif'},
    {'rank': 10, 'nom': 'Lotfi Ben Amor', 'code': 'EL-2026-019', 'region': 'Sousse & Sahel', 'tier': 'ARGENT', 'chantiers': 28, 'ca': 9240, 'points': 1050, 'churn': 42, 'status': 'Nouveau'},
    {'rank': 11, 'nom': 'Sofiane Trabelsi', 'code': 'EL-2024-055', 'region': 'Grand Tunis', 'tier': 'OR', 'chantiers': 58, 'ca': 18600, 'points': 2240, 'churn': 16, 'status': 'Très Actif'},
    {'rank': 12, 'nom': 'Karim Chaabane', 'code': 'EL-2024-092', 'region': 'Sousse & Sahel', 'tier': 'OR', 'chantiers': 54, 'ca': 17400, 'points': 2120, 'churn': 24, 'status': 'Régulier'},
  ];

  // 5. PALMARÈS DES DÉLÉGUÉS COMMERCIAUX & AUDIT TERRAIN SLA
  static List<Map<String, dynamic>> palmaresCommerciaux = [
    {
      'nom': 'Ali Ben Romdhane',
      'region': 'Grand Tunis & Monastir',
      'phone': '+216 98 345 612',
      'chantiers': 72,
      'valides': 65,
      'insitu': 87.5,
      'conformite': 98.5,
      'sla': 3.5,
      'points': 70430,
      'alertes': 5,
      'status': 'Leader National (70 430 pts)'
    },
    {
      'nom': 'Mohamed Saied',
      'region': 'Bizerte & Nord',
      'phone': '+216 97 112 458',
      'chantiers': 56,
      'valides': 48,
      'insitu': 85.7,
      'conformite': 98.5,
      'sla': 19.3,
      'points': 64431,
      'alertes': 4,
      'status': 'Excellence (64 431 pts)'
    },
    {
      'nom': 'Mahdi Nabli',
      'region': 'Nabeul & Cap Bon',
      'phone': '+216 55 684 920',
      'chantiers': 31,
      'valides': 26,
      'insitu': 93.5,
      'conformite': 98.5,
      'sla': 0.1,
      'points': 28738,
      'alertes': 1,
      'status': 'SLA Ultra-Rapide (28 738 pts)'
    },
    {
      'nom': 'Zied Mzid',
      'region': 'Sousse & Sahel',
      'phone': '+216 22 415 789',
      'chantiers': 18,
      'valides': 18,
      'insitu': 88.9,
      'conformite': 98.5,
      'sla': 0.1,
      'points': 14400,
      'alertes': 0,
      'status': 'Zéro Alerte (14 400 pts)'
    },
    {
      'nom': 'Atef Berdaoui',
      'region': 'Sfax & Sud',
      'phone': '+216 24 890 123',
      'chantiers': 1,
      'valides': 0,
      'insitu': 100.0,
      'conformite': 98.5,
      'sla': 0.1,
      'points': 697,
      'alertes': 0,
      'status': 'En Déploiement'
    },
    {
      'nom': 'Nizar Bentanfous',
      'region': 'Direction Nationale',
      'phone': '+216 93 554 201',
      'chantiers': 1,
      'valides': 1,
      'insitu': 0.0,
      'conformite': 98.5,
      'sla': 0.1,
      'points': 374,
      'alertes': 0,
      'status': 'Supervision Nationale'
    },
  ];

  // 6. ALERTES GPS SUSPECTES & DÉPASSEMENT SLA (> 48h)
  static List<Map<String, dynamic>> alertesChantiers = [
    {'id': 181, 'commercial': 'Ali Ben Romdhane', 'artisan': 'Mongi Farhat', 'gouv': 'Monastir', 'type': 'Écart GPS Suspect (> 300m)', 'valeur': '493m du chantier', 'gravite': 'haute'},
    {'id': 154, 'commercial': 'Mohamed Saied', 'artisan': 'Mohamed Messelmani', 'gouv': 'Grand Tunis', 'type': 'Écart GPS Suspect (> 300m)', 'valeur': '772m du chantier', 'gravite': 'haute'},
    {'id': 135, 'commercial': 'Mohamed Saied', 'artisan': 'haykel saada', 'gouv': 'Grand Tunis', 'type': 'Dépassement SLA (> 48h)', 'valeur': '165h écoulées', 'gravite': 'critique'},
    {'id': 132, 'commercial': 'Mohamed Saied', 'artisan': 'Mohamed Messelmani', 'gouv': 'Grand Tunis', 'type': 'Dépassement SLA (> 48h)', 'valeur': '195h écoulées', 'gravite': 'critique'},
    {'id': 108, 'commercial': 'Ali Ben Romdhane', 'artisan': 'Amara Jriri', 'gouv': 'Sousse', 'type': 'Écart GPS Suspect (> 300m)', 'valeur': '614m du chantier', 'gravite': 'haute'},
    {'id': 81, 'commercial': 'Ali Ben Romdhane', 'artisan': 'Amara Jriri', 'gouv': 'Sousse', 'type': 'Écart GPS Suspect (> 300m)', 'valeur': '443m du chantier', 'gravite': 'moyenne'},
  ];

  // 7. DISTRIBUTEURS & COMPTOIRS PARTENAIRES (20 Points de Vente B2B)
  static List<Map<String, dynamic>> distributeurs = [
    {'rank': 1, 'nom': 'Comptoir Électrique du Sud (CES)', 'ville': 'Sfax (Route de Gabès)', 'ca': 384200, 'volume': 16840, 'artisans': 148, 'share': '20.8%', 'commercial': 'Sonia Gharbi', 'tier': 'Distributeur Or'},
    {'rank': 2, 'nom': 'STEQ Charguia', 'ville': 'Tunis (Charguia)', 'ca': 348900, 'volume': 14250, 'artisans': 164, 'share': '18.9%', 'commercial': 'Karim Ben Ali', 'tier': 'Distributeur Or'},
    {'rank': 3, 'nom': 'Élec-Distribution Sahel & Cie', 'ville': 'Sousse (Sahloul)', 'ca': 271400, 'volume': 11200, 'artisans': 96, 'share': '14.7%', 'commercial': 'Mehdi Trabelsi', 'tier': 'Distributeur Argent'},
    {'rank': 4, 'nom': 'Comptoir Moderne de Nabeul', 'ville': 'Nabeul (Centre)', 'ca': 218500, 'volume': 8940, 'artisans': 74, 'share': '11.8%', 'commercial': 'Mehdi Trabelsi', 'tier': 'Distributeur Argent'},
    {'rank': 5, 'nom': 'Maghreb Électrique Bizerte', 'ville': 'Bizerte (Zone Port)', 'ca': 182300, 'volume': 7650, 'artisans': 62, 'share': '9.9%', 'commercial': 'Yassine Mansour', 'tier': 'Distributeur Argent'},
    {'rank': 6, 'nom': 'Comptoir Électro-Technique Ariana', 'ville': 'Ariana (Ennasr)', 'ca': 154800, 'volume': 6420, 'artisans': 58, 'share': '8.4%', 'commercial': 'Karim Ben Ali', 'tier': 'Partenaire Certifié'},
  ];

  // 8. BOUTIQUE CADEAUX & OUTILLAGE PRO STIEL
  static List<Map<String, dynamic>> cadeauxPro = [
    {'titre': 'Veste Polaire Haute Visibilité STIEL', 'cat': 'Équipement Pro', 'points': 800, 'echanges': 48, 'stock': 12, 'valeurTnd': 45.0, 'status': 'Tension Stock'},
    {'titre': 'Boîte à Outils Électricien Facom / STIEL', 'cat': 'Outillage Pro', 'points': 2500, 'echanges': 34, 'stock': 8, 'valeurTnd': 140.0, 'status': 'Best-Seller'},
    {'titre': 'Multimètre Numérique Digital Pro', 'cat': 'Mesure & Test', 'points': 1200, 'echanges': 29, 'stock': 15, 'valeurTnd': 68.0, 'status': 'Stock Normal'},
    {'titre': 'Visseuse Sans Fil 18V Li-Ion Pro', 'cat': 'Électroportatif', 'points': 4000, 'echanges': 22, 'stock': 5, 'valeurTnd': 220.0, 'status': 'Palier Platine'},
    {'titre': 'Casque de Chantier Ventilé STIEL', 'cat': 'EPI Sécurité', 'points': 450, 'echanges': 19, 'stock': 35, 'valeurTnd': 25.0, 'status': 'Stock Élevé'},
    {'titre': 'Pince à Dénuder Automatique Pro', 'cat': 'Outillage Pro', 'points': 650, 'echanges': 18, 'stock': 22, 'valeurTnd': 35.0, 'status': 'Stock Normal'},
    {'titre': 'Perforateur Burineur SDS-Plus 800W', 'cat': 'Électroportatif', 'points': 4500, 'echanges': 9, 'stock': 4, 'valeurTnd': 260.0, 'status': 'Palier Platine'},
  ];

  // 9. AGENT IA CHURN ARTISANS (Décrochage chantiers & Recommandations)
  static List<Map<String, dynamic>> churnArtisans = [
    {
      'nom': 'Anis Gharbi',
      'code': 'EL-2024-109',
      'gouv': 'Sousse',
      'score': 78,
      'inactifJours': 42,
      'points': 2850,
      'cause': 'Chute déclarations (-60% M-1)',
      'action': 'Visite commercial in-situ + Offre 100 Pts bonus',
      'status': 'Risque Critique'
    },
    {
      'nom': 'Tarek Maalej',
      'code': 'EL-2025-288',
      'gouv': 'Sfax',
      'score': 54,
      'inactifJours': 38,
      'points': 1790,
      'cause': 'Aucun chantier depuis 5 semaines',
      'action': 'Appel délégué STIEL + Échantillons Série Noire',
      'status': 'Risque Élevé'
    },
    {
      'nom': 'Mondher Zribi',
      'code': 'EL-2025-452',
      'gouv': 'Sfax',
      'score': 48,
      'inactifJours': 35,
      'points': 740,
      'cause': 'Baisse volume disjoncteurs',
      'action': 'Offre réactivation pack chantier +50 pts',
      'status': 'Risque Élevé'
    },
    {
      'nom': 'Marwen Mansouri',
      'code': 'EL-2025-139',
      'gouv': 'Bizerte',
      'score': 45,
      'inactifJours': 32,
      'points': 1260,
      'cause': 'Retard validation photo in-situ',
      'action': 'Assistance directe application Club Alpha',
      'status': 'Risque Élevé'
    },
    {
      'nom': 'Skander Triki',
      'code': 'EL-2025-572',
      'gouv': 'Sfax',
      'score': 44,
      'inactifJours': 31,
      'points': 590,
      'cause': 'Fréquence chantiers ralentie',
      'action': 'Visite de courtoisie délégué commercial',
      'status': 'Risque Modéré'
    },
  ];

  // 10. FUNNEL AUDIT CHANTIERS TERRAIN
  static List<Map<String, dynamic>> funnelAudit = [
    {'etape': '1. Chantiers Soumis avec Photos', 'valeur': 179, 'taux': '100%'},
    {'etape': '2. Audit Terrain Programmé', 'valeur': 179, 'taux': '100%'},
    {'etape': '3. Audit Validé In-Situ (< 150m)', 'valeur': 157, 'taux': '87.7%'},
    {'etape': '4. Points Crédités sur Carte', 'valeur': 158, 'taux': '88.3%'},
  ];

  // 11. TOP CADEAUX CONVOITÉS (LIVE DWH)
  static List<Map<String, dynamic>> cadeauxLive = [
    {'id': 20, 'nom': "Bon d'achat 100 DT", 'points_requis': 1000, 'stock': 0, 'demandes': 11, 'points_brules': 11000, 'statut': 'Validé'},
    {'id': 23, 'nom': "Bon d'achat 400 DT", 'points_requis': 4000, 'stock': 0, 'demandes': 4, 'points_brules': 16000, 'statut': 'Validé'},
    {'id': 22, 'nom': 'Valise Outils Electricien Pro STIEL', 'points_requis': 2500, 'stock': 15, 'demandes': 2, 'points_brules': 5000, 'statut': 'Stock Critique'},
    {'id': 21, 'nom': 'Perforateur Sans Fil 18V', 'points_requis': 3500, 'stock': 10, 'demandes': 1, 'points_brules': 3500, 'statut': 'Stock Critique'},
  ];

  // 12. GALERIE INTERACTIVE DES PREUVES PHOTOS DE CHANTIER (Dim_Photos_Chantier • 564 Clichés HD)
  static List<Map<String, dynamic>> galeriePhotosChantiers = [
    {
      'id': 'CH-2026-184',
      'titre': 'Villa Haut Standing Ennasr 2 — Tableau 3 Rangées',
      'artisan': 'Walid Bouazizi',
      'code_elec': 'EL-2023-014',
      'gouv': 'Grand Tunis',
      'commercial': 'Ali Ben Romdhane',
      'date': '2026-11-11 14:22',
      'mode': 'insitu',
      'dist': 28,
      'coords': '36.8624° N, 10.1642° E',
      'sla': '2.4h',
      'pts': 1240,
      'ca': 1890.0,
      'statut': 'Validé In-Situ',
      'skus': '42x Interrupteurs Blanc Neige • 38x Prises 2P+T • 8x Disjoncteurs STIEL 16A',
      'photos': [
        'assets/images/site_photos/chantier_01.jpg',
        'assets/images/site_photos/chantier_02.jpg',
        'assets/images/site_photos/chantier_03.jpg',
      ],
    },
    {
      'id': 'CH-2026-181',
      'titre': 'Immeuble Résidentiel Khezama Est — 6 Appartements',
      'artisan': 'Mongi Farhat',
      'code_elec': 'EL-2024-071',
      'gouv': 'Monastir',
      'commercial': 'Ali Ben Romdhane',
      'date': '2026-11-10 17:05',
      'mode': 'alert',
      'dist': 493,
      'coords': '35.7780° N, 10.8262° E',
      'sla': '14.0h',
      'pts': 980,
      'ca': 1420.0,
      'statut': 'Anomalie GPS (>300m)',
      'skus': '30x Prises Noir Carbone • 24x Interrupteurs • 6x Commutateurs Volets',
      'photos': [
        'assets/images/site_photos/chantier_04.jpg',
        'assets/images/site_photos/chantier_05.jpg',
        'assets/images/site_photos/chantier_06.jpg',
      ],
    },
    {
      'id': 'CH-2026-179',
      'titre': 'Clinique Médicale Sahloul — Coffrets Divisionnaires',
      'artisan': 'Anis Gharbi',
      'code_elec': 'EL-2024-109',
      'gouv': 'Sousse',
      'commercial': 'Zied Mzid',
      'date': '2026-11-09 11:40',
      'mode': 'insitu',
      'dist': 42,
      'coords': '35.8342° N, 10.5924° E',
      'sla': '1.8h',
      'pts': 1650,
      'ca': 2480.0,
      'statut': 'Validé In-Situ',
      'skus': '64x Prises Blanc Neige • 50x Interrupteurs • 12x Disjoncteurs Diff 30mA',
      'photos': [
        'assets/images/site_photos/chantier_07.jpg',
        'assets/images/site_photos/chantier_08.jpg',
        'assets/images/site_photos/chantier_09.jpg',
      ],
    },
    {
      'id': 'CH-2026-176',
      'titre': 'Showroom Commercial Route de Teniour — Éclairage & Prises',
      'artisan': 'Mohamed Ali Karray',
      'code_elec': 'EL-2024-032',
      'gouv': 'Sfax',
      'commercial': 'Atef Berdaoui',
      'date': '2026-11-08 16:15',
      'mode': 'insitu',
      'dist': 64,
      'coords': '34.7615° N, 10.7481° E',
      'sla': '3.1h',
      'pts': 1120,
      'ca': 1680.0,
      'statut': 'Validé In-Situ',
      'skus': '35x Modules Silver • 28x Prises Silver • 4x Parafoudres Monobloc STIEL',
      'photos': [
        'assets/images/site_photos/chantier_10.jpg',
        'assets/images/site_photos/chantier_11.jpg',
        'assets/images/site_photos/chantier_12.jpg',
      ],
    },
    {
      'id': 'CH-2026-172',
      'titre': 'Résidence Les Jasmins Hammamet Nord — Duplex B4',
      'artisan': 'Hichem Mejri',
      'code_elec': 'EL-2025-112',
      'gouv': 'Nabeul',
      'commercial': 'Mahdi Nabli',
      'date': '2026-11-07 10:30',
      'mode': 'boutique',
      'dist': 215,
      'coords': '36.4182° N, 10.6420° E',
      'sla': '4.2h',
      'pts': 790,
      'ca': 1150.0,
      'statut': 'Déporté / Comptoir',
      'skus': '26x Interrupteurs Blanc • 22x Prises 2P+T • 8x Commutateurs Volets',
      'photos': [
        'assets/images/site_photos/chantier_02.jpg',
        'assets/images/site_photos/chantier_06.jpg',
        'assets/images/site_photos/chantier_10.jpg',
      ],
    },
    {
      'id': 'CH-2026-168',
      'titre': 'Villa Marina Bizerte Corniche — Rénovation Complète',
      'artisan': 'Sami Khelifi',
      'code_elec': 'EL-2024-177',
      'gouv': 'Bizerte',
      'commercial': 'Mohamed Saied',
      'date': '2026-11-06 15:10',
      'mode': 'insitu',
      'dist': 35,
      'coords': '37.2845° N, 9.8672° E',
      'sla': '5.6h',
      'pts': 940,
      'ca': 1390.0,
      'statut': 'Validé In-Situ',
      'skus': '32x Prises Noir Carbone • 28x Interrupteurs Noir Carbone • 6x Disjoncteurs',
      'photos': [
        'assets/images/site_photos/chantier_03.jpg',
        'assets/images/site_photos/chantier_07.jpg',
        'assets/images/site_photos/chantier_11.jpg',
      ],
    },
    {
      'id': 'CH-2026-154',
      'titre': 'Plateau Bureaux Lac 2 — Distribution Courant Fort',
      'artisan': 'Mohamed Messelmani',
      'code_elec': 'EL-2024-121',
      'gouv': 'Grand Tunis',
      'commercial': 'Mohamed Saied',
      'date': '2026-11-04 09:50',
      'mode': 'alert',
      'dist': 772,
      'coords': '36.8452° N, 10.2710° E',
      'sla': '19.3h',
      'pts': 1480,
      'ca': 2190.0,
      'statut': 'Anomalie GPS (>300m)',
      'skus': '58x Prises Blanc Neige • 40x Interrupteurs • 10x Disjoncteurs 16A',
      'photos': [
        'assets/images/site_photos/chantier_05.jpg',
        'assets/images/site_photos/chantier_09.jpg',
        'assets/images/site_photos/chantier_01.jpg',
      ],
    },
    {
      'id': 'CH-2026-149',
      'titre': 'Lotissement El Mourouj 5 — Villa R+1',
      'artisan': 'Bilel Guesmi',
      'code_elec': 'EL-2023-088',
      'gouv': 'Ben Arous',
      'commercial': 'Ali Ben Romdhane',
      'date': '2026-11-02 13:25',
      'mode': 'insitu',
      'dist': 51,
      'coords': '36.7318° N, 10.2145° E',
      'sla': '2.9h',
      'pts': 860,
      'ca': 1275.0,
      'statut': 'Validé In-Situ',
      'skus': '28x Interrupteurs Blanc • 30x Prises 2P+T • 5x Commutateurs Volets',
      'photos': [
        'assets/images/site_photos/chantier_08.jpg',
        'assets/images/site_photos/chantier_12.jpg',
        'assets/images/site_photos/chantier_04.jpg',
      ],
    },
  ];
}
