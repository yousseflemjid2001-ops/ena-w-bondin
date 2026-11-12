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
    {'rank': 1, 'nom': 'Walid Bouazizi', 'code': 'EL-2023-014', 'region': 'Grand Tunis', 'tier': 'PLATINE', 'chantiers': 142, 'ca': 46900, 'points': 6420, 'churn': 9, 'status': 'Ambassadeur ⭐'},
    {'rank': 2, 'nom': 'Bilel Guesmi', 'code': 'EL-2023-088', 'region': 'Grand Tunis', 'tier': 'PLATINE', 'chantiers': 118, 'ca': 38450, 'points': 5190, 'churn': 12, 'status': 'Très Actif'},
    {'rank': 3, 'nom': 'Mohamed Ali Karray', 'code': 'EL-2024-032', 'region': 'Sfax & Sud', 'tier': 'PLATINE', 'chantiers': 104, 'ca': 34120, 'points': 4680, 'churn': 14, 'status': 'Leader Sud'},
    {'rank': 4, 'nom': 'Anis Gharbi', 'code': 'EL-2024-109', 'region': 'Sousse & Sahel', 'tier': 'OR', 'chantiers': 76, 'ca': 24800, 'points': 2850, 'churn': 78, 'status': 'À Risque ⚠️'},
    {'rank': 5, 'nom': 'Sami Khelifi', 'code': 'EL-2024-177', 'region': 'Bizerte & Nord', 'tier': 'OR', 'chantiers': 68, 'ca': 21950, 'points': 2640, 'churn': 22, 'status': 'Régulier'},
    {'rank': 6, 'nom': 'Nabil Tounsi', 'code': 'EL-2025-045', 'region': 'Grand Tunis', 'tier': 'OR', 'chantiers': 62, 'ca': 19800, 'points': 2310, 'churn': 18, 'status': 'En Hausse 📈'},
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
    {'rank': 1, 'nom': 'Comptoir Électrique du Sud (CES)', 'ville': 'Sfax (Route de Gabès)', 'ca': 384200, 'volume': 16840, 'artisans': 148, 'share': '20.8%', 'commercial': 'Sonia Gharbi', 'tier': 'Distributeur Or 🏆'},
    {'rank': 2, 'nom': 'STEQ Charguia', 'ville': 'Tunis (Charguia)', 'ca': 348900, 'volume': 14250, 'artisans': 164, 'share': '18.9%', 'commercial': 'Karim Ben Ali', 'tier': 'Distributeur Or 🏆'},
    {'rank': 3, 'nom': 'Élec-Distribution Sahel & Cie', 'ville': 'Sousse (Sahloul)', 'ca': 271400, 'volume': 11200, 'artisans': 96, 'share': '14.7%', 'commercial': 'Mehdi Trabelsi', 'tier': 'Distributeur Argent 🥈'},
    {'rank': 4, 'nom': 'Comptoir Moderne de Nabeul', 'ville': 'Nabeul (Centre)', 'ca': 218500, 'volume': 8940, 'artisans': 74, 'share': '11.8%', 'commercial': 'Mehdi Trabelsi', 'tier': 'Distributeur Argent 🥈'},
    {'rank': 5, 'nom': 'Maghreb Électrique Bizerte', 'ville': 'Bizerte (Zone Port)', 'ca': 182300, 'volume': 7650, 'artisans': 62, 'share': '9.9%', 'commercial': 'Yassine Mansour', 'tier': 'Distributeur Argent 🥈'},
    {'rank': 6, 'nom': 'Comptoir Électro-Technique Ariana', 'ville': 'Ariana (Ennasr)', 'ca': 154800, 'volume': 6420, 'artisans': 58, 'share': '8.4%', 'commercial': 'Karim Ben Ali', 'tier': 'Partenaire Certifié'},
  ];

  // 8. BOUTIQUE CADEAUX & OUTILLAGE PRO STIEL
  static List<Map<String, dynamic>> cadeauxPro = [
    {'titre': 'Veste Polaire Haute Visibilité STIEL', 'cat': 'Équipement Pro', 'points': 800, 'echanges': 48, 'stock': 12, 'valeurTnd': 45.0, 'status': 'Tension Stock ⚠️'},
    {'titre': 'Boîte à Outils Électricien Facom / STIEL', 'cat': 'Outillage Pro', 'points': 2500, 'echanges': 34, 'stock': 8, 'valeurTnd': 140.0, 'status': 'Best-Seller 🏆'},
    {'titre': 'Multimètre Numérique Digital Pro', 'cat': 'Mesure & Test', 'points': 1200, 'echanges': 29, 'stock': 15, 'valeurTnd': 68.0, 'status': 'Stock Normal'},
    {'titre': 'Visseuse Sans Fil 18V Li-Ion Pro', 'cat': 'Électroportatif', 'points': 4000, 'echanges': 22, 'stock': 5, 'valeurTnd': 220.0, 'status': 'Palier Platine ⭐'},
    {'titre': 'Casque de Chantier Ventilé STIEL', 'cat': 'EPI Sécurité', 'points': 450, 'echanges': 19, 'stock': 35, 'valeurTnd': 25.0, 'status': 'Stock Élevé'},
    {'titre': 'Pince à Dénuder Automatique Pro', 'cat': 'Outillage Pro', 'points': 650, 'echanges': 18, 'stock': 22, 'valeurTnd': 35.0, 'status': 'Stock Normal'},
    {'titre': 'Perforateur Burineur SDS-Plus 800W', 'cat': 'Électroportatif', 'points': 4500, 'echanges': 9, 'stock': 4, 'valeurTnd': 260.0, 'status': 'Palier Platine ⭐'},
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
      'status': 'Risque Critique 🔴'
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
      'status': 'Risque Élevé 🟠'
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
      'status': 'Risque Élevé 🟠'
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
      'status': 'Risque Élevé 🟠'
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
      'status': 'Risque Modéré 🟡'
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
}
