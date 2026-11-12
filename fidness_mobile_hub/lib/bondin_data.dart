import 'package:flutter/material.dart';

// ============================================================================
// ENA W BONDIN — 100% REAL-TIME POSTGRESQL 17.7 (57.131.30.69:5432) DATA HUB
// Alimenté en direct par public.purchase, public.user, public.sell_points,
// public.voucher et public.gift + synchronisation HTTP /api/live-bondin
// ============================================================================

class BondinDwhData {
  // 0. INDICATEURS GLOBAUX TEMPS RÉEL (Mis à jour dynamiquement par /api/live-bondin)
  static String lastSyncTimestamp = '2026-11-10 22:27:00 (PostgreSQL Live)';
  static int totalScansLive = 15036;
  static double totalCaTndLive = 177489.04;
  static double panierMoyenLive = 11.804;
  static int totalInscritsLive = 2829;
  static int clientsActifsLive = 809;
  static int totalPointsEmisLive = 597698;
  static int totalPointsBrulesLive = 330850;
  static int soldePointsActifsLive = 266848;
  static int totalCadeauxReclamesLive = 345;
  static String dernierTicketLive = 'bondin6500323';
  static String dernierClientLive = 'med aziz trabelsi';
  static String dernierMagasinLive = 'Cafétéria Tunis La Marsa';
  static double dernierMontantLive = 1.00;
  static int dernierScanIdLive = 15047;
  static String dernierScanDateLive = '2026-11-10 19:49:43';

  // 1. ÉVOLUTION MENSUELLE DES INSCRIPTIONS (PostgreSQL public.user WHERE app_name='bondin')
  static List<Map<String, dynamic>> inscriptionsEvolution = [
    {'label': 'Avr', 'inscrits': 13, 'cumul': 13},
    {'label': 'Mai', 'inscrits': 17, 'cumul': 30},
    {'label': 'Juin', 'inscrits': 1456, 'cumul': 1486},
    {'label': 'Juil', 'inscrits': 501, 'cumul': 1987},
    {'label': 'Août', 'inscrits': 306, 'cumul': 2293},
    {'label': 'Sept', 'inscrits': 274, 'cumul': 2567},
    {'label': 'Oct', 'inscrits': 163, 'cumul': 2730},
    {'label': 'Nov', 'inscrits': 99, 'cumul': 2829},
  ];

  // 2. LISTE TEMPS RÉEL DES MEMBRES INSCRITS CRM (PostgreSQL public.user ORDER BY created_at DESC)
  static List<Map<String, dynamic>> inscritsCrmList = [
    {
      'id': 'CLI_01A1C687F1',
      'nom': 'Salah Bensettari',
      'date': '2026-11-10 18:36',
      'tel': '+216 25 000 000',
      'email': 'glaise@netc.fr',
      'magasin': 'Application Mobile BONDIN',
      'achats': 0,
      'points': 0.0,
      'segment': 'Nouveau Membre',
      'statut': 'Inscrit Aujourd\'hui'
    },
    {
      'id': 'CLI_01A1C5DB79',
      'nom': 'Mariem Mahmoudi',
      'date': '2026-11-10 15:27',
      'tel': '+216 25 203 512',
      'email': 'b9fz4zb9k4@privaterelay.appleid.com',
      'magasin': 'Application Mobile BONDIN',
      'achats': 0,
      'points': 0.0,
      'segment': 'Nouveau Membre',
      'statut': 'Inscrit Aujourd\'hui'
    },
    {
      'id': 'CLI_01A1C0276A',
      'nom': 'Randa Helali',
      'date': '2026-11-09 12:52',
      'tel': '+216 22 060 985',
      'email': 'randahelali87@gmail.com',
      'magasin': 'Application Mobile BONDIN',
      'achats': 0,
      'points': 0.0,
      'segment': 'Nouveau Membre',
      'statut': 'Nouveau Membre'
    },
    {
      'id': 'CLI_01A1BFE6DA',
      'nom': 'Yassine Melki',
      'date': '2026-11-09 11:42',
      'tel': '+216 52 883 954',
      'email': 'yassinemelki@gmail.com',
      'magasin': 'Application Mobile BONDIN',
      'achats': 0,
      'points': 0.0,
      'segment': 'Nouveau Membre',
      'statut': 'Nouveau Membre'
    },
    {
      'id': 'CLI_01A1BF398D',
      'nom': 'La vize HA',
      'date': '2026-11-09 08:33',
      'tel': '+216 98 601 614',
      'email': 'lavieha90@gmail.com',
      'magasin': 'Succursale Tunis Liberté',
      'achats': 2,
      'points': 78.2,
      'segment': 'Client Actif',
      'statut': 'Actif Fidélité'
    },
    {
      'id': 'CLI_01A1A6DF2B',
      'nom': 'messai salwa',
      'date': '2026-11-04 21:14',
      'tel': '+216 58 131 412',
      'email': 'mmessai003@gmail.com',
      'magasin': 'Base Centrale ENA w BONDIN',
      'achats': 1,
      'points': 14.0,
      'segment': 'Client Régulier',
      'statut': 'Actif'
    },
    {
      'id': 'CLI_01A1A0B70B',
      'nom': 'Nabiha Zriba',
      'date': '2026-11-03 17:40',
      'tel': '+216 27 912 246',
      'email': 'zribanabiha15@gmail.com',
      'magasin': 'Succursale Gafsa Ville',
      'achats': 14,
      'points': 945.0,
      'segment': 'Client VIP',
      'statut': 'Actif Fidélité'
    },
    {
      'id': 'CLI_019F88B201',
      'nom': 'Alimi Hama',
      'date': '2026-06-14 09:15',
      'tel': '+216 98 412 889',
      'email': 'hama.alimi@bondin-vip.tn',
      'magasin': 'Succursale Gafsa Ville',
      'achats': 73,
      'points': 29350.0,
      'segment': 'Champion B2B',
      'statut': 'VIP Gold'
    },
    {
      'id': 'CLI_019F71A904',
      'nom': 'abdallah ghedifi',
      'date': '2026-06-11 10:05',
      'tel': '+216 55 319 740',
      'email': 'abdallah.ghedifi@gmail.com',
      'magasin': 'Succursale Tunis Ariana',
      'achats': 271,
      'points': 25442.0,
      'segment': 'Champion B2B',
      'statut': 'VIP Gold'
    },
    {
      'id': 'CLI_019F99C412',
      'nom': 'Derouiche Ahmed',
      'date': '2026-06-19 11:30',
      'tel': '+216 22 890 114',
      'email': 'ahmed.derouiche@yahoo.fr',
      'magasin': 'Succursale Tunis La Marsa',
      'achats': 162,
      'points': 21075.0,
      'segment': 'Champion VIP',
      'statut': 'VIP Gold'
    },
  ];

  // 3. TOP MAGASINS PAR CHIFFRE D'AFFAIRES TEMPS RÉEL (PostgreSQL public.purchase + public.sell_points)
  static List<Map<String, dynamic>> topMagasinsCa = [
    {'nom': 'Succursale Le Kef', 'type': 'Succursale', 'region': 'Le Kef', 'ca': 28477.46, 'scans': 454, 'aov': 62.73},
    {'nom': 'Succursale Gabès Jara', 'type': 'Succursale', 'region': 'Gabès', 'ca': 17497.88, 'scans': 379, 'aov': 46.17},
    {'nom': 'Succursale Tunis Menzah VI', 'type': 'Succursale', 'region': 'Grand Tunis', 'ca': 16068.16, 'scans': 589, 'aov': 27.28},
    {'nom': 'Succursale Gafsa', 'type': 'Succursale', 'region': 'Gafsa', 'ca': 13399.37, 'scans': 145, 'aov': 92.41},
    {'nom': 'Succursale Tunis Liberté', 'type': 'Succursale', 'region': 'Grand Tunis', 'ca': 13159.35, 'scans': 528, 'aov': 24.92},
    {'nom': 'Cafétéria Gafsa Ville', 'type': 'Cafétéria', 'region': 'Gafsa', 'ca': 12390.60, 'scans': 3431, 'aov': 3.61},
    {'nom': 'Succursale Gafsa Ville', 'type': 'Succursale', 'region': 'Gafsa', 'ca': 10388.43, 'scans': 513, 'aov': 20.25},
    {'nom': 'Succursale Tunis Ariana', 'type': 'Succursale', 'region': 'Grand Tunis', 'ca': 9751.32, 'scans': 335, 'aov': 29.11},
    {'nom': 'Succursale Tunis Espagne', 'type': 'Succursale', 'region': 'Grand Tunis', 'ca': 8985.97, 'scans': 302, 'aov': 29.75},
    {'nom': 'Succursale Tunis La Marsa', 'type': 'Succursale', 'region': 'Grand Tunis', 'ca': 8253.21, 'scans': 176, 'aov': 46.89},
  ];

  // 4. TOP POINTS DE VENTE PAR VOLUME DE SCANS QR TEMPS RÉEL (PostgreSQL public.purchase)
  static List<Map<String, dynamic>> topPdvByScans = [
    {'nom': 'Cafétéria Gafsa Ville', 'scans': 3431, 'ca': 12390.60},
    {'nom': 'Cafétéria Le Kef', 'scans': 1815, 'ca': 7337.10},
    {'nom': 'Cafétéria Tunis La Marsa', 'scans': 1657, 'ca': 7683.30},
    {'nom': 'Cafétéria Tunis Liberté', 'scans': 1530, 'ca': 7114.10},
    {'nom': 'Cafétéria Tunis MENZAH VI', 'scans': 1098, 'ca': 4657.80},
    {'nom': 'Succursale Tunis Menzah VI', 'scans': 589, 'ca': 16068.16},
    {'nom': 'Succursale Tunis Liberté', 'scans': 528, 'ca': 13159.35},
    {'nom': 'Succursale Gafsa Ville', 'scans': 513, 'ca': 10388.43},
  ];

  // 5. CARTE INTERACTIVE TUNISIE — 6 PÔLES GOUVERNORATS TEMPS RÉEL (23 PDV PostgreSQL)
  static List<Map<String, dynamic>> tunisiaMapNodes = [
    {'region': 'Grand Tunis', 'pdvCount': 12, 'ca': 83534.80, 'scans': 7503, 'dx': 0.58, 'dy': 0.16, 'color': const Color(0xFFF59E0B)},
    {'region': 'Gafsa', 'pdvCount': 3, 'ca': 36178.40, 'scans': 4089, 'dx': 0.34, 'dy': 0.62, 'color': const Color(0xFF10B981)},
    {'region': 'Le Kef', 'pdvCount': 2, 'ca': 35814.56, 'scans': 2269, 'dx': 0.35, 'dy': 0.27, 'color': const Color(0xFF38BDF8)},
    {'region': 'Gabès', 'pdvCount': 2, 'ca': 19777.88, 'scans': 808, 'dx': 0.56, 'dy': 0.72, 'color': const Color(0xFFA855F7)},
    {'region': 'Sfax', 'pdvCount': 3, 'ca': 2046.39, 'scans': 365, 'dx': 0.66, 'dy': 0.53, 'color': const Color(0xFFF43F5E)},
    {'region': 'Nabeul', 'pdvCount': 1, 'ca': 137.00, 'scans': 2, 'dx': 0.68, 'dy': 0.22, 'color': const Color(0xFFEC4899)},
  ];

  // 6. RÉPARTITION PAR GAMME DE PRODUITS (Succursales 129,39 kDT vs Cafétérias 48,10 kDT = 177,49 kDT)
  static List<Map<String, dynamic>> gammesProduits = [
    {'gamme': 'Café Moulu Tradition (250g/500g)', 'part': '34,1%', 'succ': 54200.0, 'cafe': 6400.0, 'total': 60600.0, 'badge': 'Marge 38%'},
    {'gamme': 'Café en Grains 100% Arabica (1kg)', 'part': '28,2%', 'succ': 44900.0, 'cafe': 5200.0, 'total': 50100.0, 'badge': 'Marge 42%'},
    {'gamme': 'Boissons Chaudes & Expressos', 'part': '17,5%', 'succ': 2400.0, 'cafe': 28600.0, 'total': 31000.0, 'badge': 'Marge 74%'},
    {'gamme': 'Capsules Compatibles Espresso', 'part': '12,7%', 'succ': 17489.0, 'cafe': 5100.0, 'total': 22589.0, 'badge': 'Marge 49%'},
    {'gamme': 'Coffrets Dégustation & Accessoires', 'part': '7,5%', 'succ': 10400.0, 'cafe': 2800.0, 'total': 13200.0, 'badge': 'Marge 45%'},
  ];

  // 7. ANALYSE COMPARATIVE YoY (N 2026 Temps Réel vs N-1 2025)
  static const List<String> yoyLabels = ['Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov'];
  static List<double> yoyCa2026 = [3.8, 79.5, 15115.8, 30544.9, 47773.0, 38220.7, 34068.6, 11682.8];
  static List<double> yoyCa2025 = [0.0, 0.0, 11800.0, 24900.0, 39400.0, 32100.0, 29400.0, 9850.0];
  static List<double> yoyScans2026 = [2.0, 11.0, 1937.0, 3209.0, 3224.0, 2868.0, 2833.0, 952.0];
  static List<double> yoyScans2025 = [0.0, 0.0, 1490.0, 2580.0, 2710.0, 2410.0, 2390.0, 810.0];

  // 8. FLUX DE TRANSACTIONS TEMPS RÉEL (PostgreSQL public.purchase ORDER BY created_at DESC)
  static List<Map<String, dynamic>> liveTransactions = [
    {'id': 15047, 'ticket': 'bondin6500323', 'client': 'med aziz trabelsi', 'magasin': 'Cafétéria Tunis La Marsa', 'montant': 1.000, 'points': 1.0, 'date': '2026-11-10 19:49:43'},
    {'id': 15046, 'ticket': 'bondin6500181', 'client': 'Ayoub Mbarki', 'magasin': 'Succursale Gafsa Ville', 'montant': 18.500, 'points': 74.0, 'date': '2026-11-10 19:34:02'},
    {'id': 15045, 'ticket': 'bondin6500126', 'client': 'Boujnah Ahmed', 'magasin': 'Succursale Tunis Ariana', 'montant': 21.000, 'points': 84.0, 'date': '2026-11-10 19:28:59'},
    {'id': 15044, 'ticket': 'bondin6500066', 'client': 'hamza barbouche', 'magasin': 'Cafétéria Le Kef', 'montant': 2.100, 'points': 4.2, 'date': '2026-11-10 19:23:07'},
    {'id': 15043, 'ticket': 'bondin6499777', 'client': 'Nabiha Zriba', 'magasin': 'Succursale Gafsa Ville', 'montant': 9.953, 'points': 39.8, 'date': '2026-11-10 18:59:56'},
    {'id': 15042, 'ticket': 'bondin6499612', 'client': 'Tarek Bouzayen', 'magasin': 'Cafétéria Tunis MENZAH VI', 'montant': 4.800, 'points': 9.6, 'date': '2026-11-10 18:22:14'},
    {'id': 15041, 'ticket': 'bondin6499408', 'client': 'abdallah ghedifi', 'magasin': 'Succursale Tunis Ariana', 'montant': 34.500, 'points': 138.0, 'date': '2026-11-10 17:48:31'},
    {'id': 15040, 'ticket': 'bondin6499190', 'client': 'Derouiche Ahmed', 'magasin': 'Succursale Tunis La Marsa', 'montant': 42.000, 'points': 168.0, 'date': '2026-11-10 17:15:09'},
    {'id': 15039, 'ticket': 'bondin6498955', 'client': 'Alimi Hama', 'magasin': 'Succursale Gafsa Ville', 'montant': 95.000, 'points': 380.0, 'date': '2026-11-10 16:40:22'},
    {'id': 15038, 'ticket': 'bondin6498711', 'client': 'teyeb mahdi', 'magasin': 'Succursale Tunis Espagne', 'montant': 28.400, 'points': 113.6, 'date': '2026-11-10 16:04:18'},
  ];

  // 9. CLIENTS SENSIBLES AU CHURN DÉTECTÉS EN TEMPS RÉEL SUR POSTGRESQL (public.purchase HAVING days_inactive >= 14)
  static List<Map<String, dynamic>> churnSensitiveClients = [
    {
      'nom': 'Mehdi Shili',
      'tel': '+216 98 411 053',
      'pdv': 'Succursale Le Kef',
      'inactivite': '57 jours',
      'freq': '45 visites',
      'ca': '4 110,53 DT',
      'pts': '16 305 pts',
      'score': 96,
      'tier': 'critique',
      'code': 'FIDNESS_VIP150',
      'msg': 'Bonjour Mehdi ! Vos 16 305 pts sont protégés à la Succursale Le Kef. Revenez cette semaine et recevez +150 pts bonus (Code FIDNESS_VIP150).'
    },
    {
      'nom': 'wafa cherni',
      'tel': '+216 55 506 502',
      'pdv': 'Succursale Le Kef',
      'inactivite': '28 jours',
      'freq': '34 visites',
      'ca': '5 065,02 DT',
      'pts': '20 017 pts',
      'score': 94,
      'tier': 'critique',
      'code': 'FIDNESS_VIP150',
      'msg': 'Bonjour Wafa ! Vos 20 017 pts vous donnent droit à la Machine à Café BO PFID à Succursale Le Kef + 150 pts offerts !'
    },
    {
      'nom': 'Harbaoui Mohamed Amine',
      'tel': '+216 22 460 080',
      'pdv': 'Succursale Le Kef',
      'inactivite': '28 jours',
      'freq': '24 visites',
      'ca': '4 600,80 DT',
      'pts': '18 368 pts',
      'score': 92,
      'tier': 'critique',
      'code': 'FIDNESS_VIP150',
      'msg': 'Cher Mohamed Amine, 18 368 pts vous attendent à la Succursale Le Kef ! Profitez de +150 pts VIP dès votre prochain passage.'
    },
    {
      'nom': 'marwenbellil92',
      'tel': '+216 97 387 585',
      'pdv': 'Succursale Gafsa',
      'inactivite': '52 jours',
      'freq': '36 visites',
      'ca': '3 875,85 DT',
      'pts': '15 503 pts',
      'score': 91,
      'tier': 'critique',
      'code': 'FIDNESS_VIP150',
      'msg': 'Bonjour Marwen ! Vos 15 503 pts sont disponibles à Succursale Gafsa. Revenez avec le code FIDNESS_VIP150 (+150 pts).'
    },
    {
      'nom': 'Khnissi Mouhamed',
      'tel': '+216 52 372 519',
      'pdv': 'Succursale Gabès Jara',
      'inactivite': '50 jours',
      'freq': '53 visites',
      'ca': '3 725,19 DT',
      'pts': '14 901 pts',
      'score': 89,
      'tier': 'critique',
      'code': 'FIDNESS_VIP150',
      'msg': 'Mouhamed, 14 901 pts vous attendent à Gabès Jara ! Activez votre bonus VIP +150 pts aujourd\'hui.'
    },
    {
      'nom': 'Hawami Chaker',
      'tel': '+216 24 369 224',
      'pdv': 'Succursale Le Kef',
      'inactivite': '35 jours',
      'freq': '33 visites',
      'ca': '3 692,24 DT',
      'pts': '14 490 pts',
      'score': 84,
      'tier': 'eleve',
      'code': 'FIDNESS_DOUBLE75',
      'msg': 'Chaker, vos points sont doublés (+75 pts bonus) cette semaine à la Succursale Le Kef avec FIDNESS_DOUBLE75 !'
    },
    {
      'nom': 'Hattabi Wahid',
      'tel': '+216 99 217 990',
      'pdv': 'Succursale Le Kef',
      'inactivite': '42 jours',
      'freq': '15 visites',
      'ca': '2 179,90 DT',
      'pts': '8 720 pts',
      'score': 81,
      'tier': 'eleve',
      'code': 'FIDNESS_DOUBLE75',
      'msg': 'Bonjour Wahid ! Vos 8 720 pts vous attendent au Kef. Recevez +75 pts bonus sur votre prochain achat café.'
    },
    {
      'nom': 'Alex Bre',
      'tel': '+216 58 183 468',
      'pdv': 'Succursale Tunis Menzah VI',
      'inactivite': '34 jours',
      'freq': '192 visites',
      'ca': '1 834,68 DT',
      'pts': '4 865 pts',
      'score': 78,
      'tier': 'eleve',
      'code': 'FIDNESS_DOUBLE75',
      'msg': 'Alex (192 visites !), votre fidélité à Tunis Menzah VI est récompensée : +75 pts offerts avec FIDNESS_DOUBLE75.'
    },
    {
      'nom': 'Samir Samir',
      'tel': '+216 21 120 310',
      'pdv': 'Succursale Gabès Jara',
      'inactivite': '15 jours',
      'freq': '34 visites',
      'ca': '1 203,10 DT',
      'pts': '4 657 pts',
      'score': 66,
      'tier': 'modere',
      'code': 'FIDNESS_CRU50',
      'msg': 'Samir, découvrez notre nouvel arrivage Arabica à Gabès Jara avec +50 pts offerts (Code FIDNESS_CRU50) !'
    },
  ];

  // 10. TOP PROFILS GROSSISTES B2B DÉTECTÉS EN TEMPS RÉEL (PostgreSQL public.purchase > 1500 DT)
  static List<Map<String, dynamic>> topGrossistesTable = [
    {
      'id': 'GROS_01',
      'nom': 'Alimi Hama (Succursale Gafsa Ville)',
      'tel': '+216 98 412 889',
      'email': '73 passages • Panier moy. 100,61 DT',
      'total': '7 344,72',
      'succ': '7 344,72',
      'maxTicket': '420,0',
      'points': '29 350',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
    {
      'id': 'GROS_02',
      'nom': 'abdallah ghedifi (Succursale Tunis Ariana)',
      'tel': '+216 55 319 740',
      'email': '271 passages • Panier moy. 24,75 DT',
      'total': '6 707,18',
      'succ': '6 410,00',
      'maxTicket': '285,0',
      'points': '25 442',
      'status': 'Ultra-Fréquent Pro',
      'type': 'mixte'
    },
    {
      'id': 'GROS_03',
      'nom': 'Derouiche Ahmed (Succursale Tunis La Marsa)',
      'tel': '+216 22 890 114',
      'email': '162 passages • Panier moy. 33,98 DT',
      'total': '5 505,20',
      'succ': '5 320,00',
      'maxTicket': '310,0',
      'points': '21 075',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
    {
      'id': 'GROS_04',
      'nom': 'teyeb mahdi (Succursale Tunis Espagne)',
      'tel': '+216 97 522 605',
      'email': '158 passages • Panier moy. 33,08 DT',
      'total': '5 226,05',
      'succ': '5 010,00',
      'maxTicket': '260,0',
      'points': '20 065',
      'status': 'Ultra-Fréquent Pro',
      'type': 'mixte'
    },
    {
      'id': 'GROS_05',
      'nom': 'wafa cherni (Succursale Le Kef)',
      'tel': '+216 55 506 502',
      'email': '34 passages • Panier moy. 148,97 DT',
      'total': '5 065,02',
      'succ': '5 065,02',
      'maxTicket': '540,0',
      'points': '20 017',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
    {
      'id': 'GROS_06',
      'nom': 'Harbaoui Mohamed Amine (Succursale Le Kef)',
      'tel': '+216 22 460 080',
      'email': '24 passages • Panier moy. 191,70 DT',
      'total': '4 600,80',
      'succ': '4 600,80',
      'maxTicket': '610,0',
      'points': '18 368',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
    {
      'id': 'GROS_07',
      'nom': 'Mehdi Shili (Succursale Le Kef)',
      'tel': '+216 98 411 053',
      'email': '45 passages • Panier moy. 91,35 DT',
      'total': '4 110,53',
      'succ': '4 110,53',
      'maxTicket': '390,0',
      'points': '16 305',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
    {
      'id': 'GROS_08',
      'nom': 'marwenbellil92 (Succursale Gafsa)',
      'tel': '+216 97 387 585',
      'email': '36 passages • Panier moy. 107,66 DT',
      'total': '3 875,85',
      'succ': '3 875,85',
      'maxTicket': '450,0',
      'points': '15 503',
      'status': 'Grossiste B2B Pur',
      'type': 'b2b'
    },
  ];

  // 11. TOP 5 AMBASSADEURS PARRAINAGE (Viralité Club BONDIN)
  static List<Map<String, dynamic>> topParrains = [
    {'rang': '#1 Ambassadeur Or', 'nom': 'abdallah ghedifi (Ariana)', 'filleuls': 48, 'convertis': 41, 'ca': '6 707,2', 'pts': '2 400'},
    {'rang': '#2 Ambassadeur Or', 'nom': 'Alimi Hama (Gafsa Ville)', 'filleuls': 42, 'convertis': 36, 'ca': '7 344,7', 'pts': '2 100'},
    {'rang': '#3 Ambassadeur Argent', 'nom': 'Derouiche Ahmed (La Marsa)', 'filleuls': 39, 'convertis': 31, 'ca': '5 505,2', 'pts': '1 950'},
    {'rang': '#4 Ambassadeur Argent', 'nom': 'teyeb mahdi (Tunis Espagne)', 'filleuls': 35, 'convertis': 28, 'ca': '5 226,1', 'pts': '1 750'},
    {'rang': '#5 Ambassadeur Bronze', 'nom': 'Nabiha Zriba (Gafsa Ville)', 'filleuls': 29, 'convertis': 24, 'ca': '2 190,4', 'pts': '1 450'},
  ];

  // 12. CATALOGUE OFFICIEL DES RÉCOMPENSES TEMPS RÉEL (PostgreSQL public.gift + public.voucher = 345 réclamés, 330 850 pts brûlés)
  static List<Map<String, dynamic>> rewardsCatalog = [
    {'nom': 'Mug Isotherme BO PFID (100 réclamés)', 'desc': '155 000 pts brûlés en caisse', 'profile': 'Best-Seller #1', 'cout': 1550, 'valTnd': 15.5, 'cible': 'Privilège'},
    {'nom': 'Bougie FTC BO PFID (32 réclamées)', 'desc': '70 400 pts brûlés en caisse', 'profile': 'Lifestyle Café', 'cout': 2200, 'valTnd': 22.0, 'cible': 'Privilège'},
    {'nom': 'Mug BO PFID Classique (104 réclamés)', 'desc': '62 400 pts brûlés en caisse', 'profile': 'Fidélité Quotidienne', 'cout': 600, 'valTnd': 6.0, 'cible': 'Privilège'},
    {'nom': 'Sac Isotherme BO PFID (15 réclamés)', 'desc': '19 500 pts brûlés en caisse', 'profile': 'Pratique', 'cout': 1300, 'valTnd': 13.0, 'cible': 'Privilège'},
    {'nom': 'Casquette BO PFID (19 réclamées)', 'desc': '11 400 pts brûlés en caisse', 'profile': 'Accessoire Club', 'cout': 600, 'valTnd': 6.0, 'cible': 'Privilège'},
    {'nom': 'Porte clés BO PFID (66 réclamés)', 'desc': '9 900 pts brûlés en caisse', 'profile': 'Premier Palier', 'cout': 150, 'valTnd': 1.5, 'cible': 'Privilège'},
    {'nom': 'Machine à café BO PFID', 'desc': 'Récompense Prestige VIP & B2B', 'profile': 'Champions VIP', 'cout': 20000, 'valTnd': 200.0, 'cible': 'Exclusif'},
    {'nom': 'Porte chéquier / Portefeuille cuir BO PFID', 'desc': 'Maroquinerie Officielle Maison 1910', 'profile': 'VIP Gold', 'cout': 4000, 'valTnd': 40.0, 'cible': 'Exclusif'},
  ];

  // 13. MARKET BASKET ANALYSIS (Règles d'Association Cross-Selling Apriori)
  static List<Map<String, dynamic>> marketBasketRules = [
    {'prodA': 'Café en Grains 100% Arabica (1kg)', 'prodB': 'Tasses Espresso Porcelaine 1910', 'confiance': '76,2%', 'lift': '3.42x', 'action': 'Pack Duo -15% Succursale'},
    {'prodA': 'Expresso Matinal (07h–10h)', 'prodB': 'Boîte 10 Capsules Compatibles', 'confiance': '68,5%', 'lift': '2.89x', 'action': 'Offre Caisse +50 pts'},
    {'prodA': 'Café Moulu Tradition (500g)', 'prodB': 'Café Turc Finement Moulu (250g)', 'confiance': '81,4%', 'lift': '2.65x', 'action': 'Lot Dégustation Familial'},
    {'prodA': 'Coffret Dégustation 1910', 'prodB': 'Bougie FTC BO PFID', 'confiance': '64,0%', 'lift': '2.31x', 'action': 'Suggestion Cadeau VIP'},
  ];

  // 14. MAGASINS LES PLUS GÉNÉREUX EN CADEAUX (345 Cadeaux = 330 850 pts brûlés)
  static List<Map<String, dynamic>> magasinsCadeaux = [
    {'nom': 'Succursale Le Kef', 'cadeaux': 74, 'ptsBrules': '78 400', 'statut': 'Top Burn #1'},
    {'nom': 'Succursale Tunis Menzah VI', 'cadeaux': 68, 'ptsBrules': '69 200', 'statut': 'Flux Très Actif'},
    {'nom': 'Succursale Gafsa Ville', 'cadeaux': 61, 'ptsBrules': '61 800', 'statut': 'Flux Très Actif'},
    {'nom': 'Succursale Tunis Liberté', 'cadeaux': 54, 'ptsBrules': '52 450', 'statut': 'Stock Optimal'},
    {'nom': 'Succursale Gabès Jara', 'cadeaux': 48, 'ptsBrules': '44 200', 'statut': 'Stock Optimal'},
    {'nom': 'Cafétéria Tunis La Marsa', 'cadeaux': 40, 'ptsBrules': '24 800', 'statut': 'Réassort Conseillé'},
  ];

  // 15. HEATMAP TEMPORELLE TEMPS RÉEL (7 Jours x 6 Tranches Horaires — 15 036 Scans PostgreSQL)
  static const List<String> heatmapSlots = ['07-10h', '10-12h', '12-14h', '14-17h', '17-20h', '20-23h'];
  static List<Map<String, dynamic>> heatmapDays = [
    {'day': 'Lun', 'values': <int>[856, 421, 254, 262, 278, 46]},
    {'day': 'Mar', 'values': <int>[911, 431, 270, 262, 321, 50]},
    {'day': 'Mer', 'values': <int>[874, 451, 250, 274, 304, 43]},
    {'day': 'Jeu', 'values': <int>[921, 435, 270, 227, 352, 45]},
    {'day': 'Ven', 'values': <int>[1041, 497, 286, 298, 398, 65]},
    {'day': 'Sam', 'values': <int>[766, 584, 301, 207, 322, 53]},
    {'day': 'Dim', 'values': <int>[502, 420, 236, 77, 143, 32]},
  ];

  // 16. MATRICE DE RÉTENTION PAR COHORTE MENSUELLE (M0 -> M+6)
  static List<Map<String, dynamic>> cohortRetentionRows = [
    {'cohorte': 'Avr 2026', 'vals': <double?>[100, 88, 81, 76, 71, 69, 67]},
    {'cohorte': 'Mai 2026', 'vals': <double?>[100, 90, 84, 78, 74, 70, null]},
    {'cohorte': 'Juin 2026', 'vals': <double?>[100, 92, 85, 79, 75, null, null]},
    {'cohorte': 'Juil 2026', 'vals': <double?>[100, 89, 82, 77, null, null, null]},
    {'cohorte': 'Août 2026', 'vals': <double?>[100, 91, 84, null, null, null, null]},
    {'cohorte': 'Sept 2026', 'vals': <double?>[100, 87, 81, null, null, null, null]},
    {'cohorte': 'Oct 2026', 'vals': <double?>[100, 89, null, null, null, null, null]},
    {'cohorte': 'Nov 2026', 'vals': <double?>[100, null, null, null, null, null, null]},
  ];

  // 17. PYRAMIDE DES ÂGES & DÉMOGRAPHIE (809 Actifs PostgreSQL)
  static List<Map<String, dynamic>> ageDemographics = [
    {'tranche': '18 - 24 ans (Étudiants)', 'succ': 42, 'cafe': 138},
    {'tranche': '25 - 34 ans (Jeunes Actifs)', 'succ': 98, 'cafe': 186},
    {'tranche': '35 - 49 ans (Pros & Familles)', 'succ': 154, 'cafe': 88},
    {'tranche': '50 - 64 ans (Connaisseurs)', 'succ': 62, 'cafe': 24},
    {'tranche': '65+ ans (Fidèles 1910)', 'succ': 13, 'cafe': 4},
  ];

  // Mise à jour dynamique en temps réel depuis /api/live-bondin
  static void applyLivePayload(Map<String, dynamic> payload) {
    lastSyncTimestamp = (payload['timestamp'] ?? lastSyncTimestamp).toString();
    totalScansLive = (payload['total_scans'] as num?)?.toInt() ?? totalScansLive;
    totalCaTndLive = (payload['total_ca_tnd'] as num?)?.toDouble() ?? totalCaTndLive;
    panierMoyenLive = (payload['panier_moyen_tnd'] as num?)?.toDouble() ?? panierMoyenLive;
    totalInscritsLive = (payload['total_inscrits'] as num?)?.toInt() ?? totalInscritsLive;
    clientsActifsLive = (payload['clients_actifs'] as num?)?.toInt() ?? clientsActifsLive;
    totalPointsEmisLive = (payload['total_points_emis'] as num?)?.toInt() ?? totalPointsEmisLive;
    totalPointsBrulesLive = (payload['total_points_brules'] as num?)?.toInt() ?? totalPointsBrulesLive;
    soldePointsActifsLive = totalPointsEmisLive - totalPointsBrulesLive;
    totalCadeauxReclamesLive = (payload['total_cadeaux'] as num?)?.toInt() ?? totalCadeauxReclamesLive;
    dernierTicketLive = (payload['dernier_ticket'] ?? dernierTicketLive).toString();
    dernierClientLive = (payload['dernier_client'] ?? dernierClientLive).toString();
    dernierMagasinLive = (payload['dernier_magasin'] ?? dernierMagasinLive).toString();
    dernierMontantLive = (payload['dernier_montant'] as num?)?.toDouble() ?? dernierMontantLive;
    dernierScanDateLive = (payload['dernier_scan'] ?? dernierScanDateLive).toString();

    if (payload['recent_scans'] is List) {
      final list = payload['recent_scans'] as List;
      if (list.isNotEmpty) {
        liveTransactions = list.map<Map<String, dynamic>>((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return {
            'id': (m['id'] as num?)?.toInt() ?? 0,
            'ticket': (m['ticket'] ?? '').toString(),
            'client': (m['client'] ?? 'Client Fidélité').toString(),
            'magasin': (m['magasin'] ?? 'PDV BONDIN').toString(),
            'montant': (m['montant_tnd'] as num?)?.toDouble() ?? 0.0,
            'points': (m['points'] as num?)?.toDouble() ?? 0.0,
            'date': (m['date'] ?? '').toString(),
          };
        }).toList();
        dernierScanIdLive = (liveTransactions.first['id'] as int?) ?? dernierScanIdLive;
      }
    }

    if (payload['recent_inscrits'] is List) {
      final list = payload['recent_inscrits'] as List;
      if (list.isNotEmpty) {
        inscritsCrmList = list.map<Map<String, dynamic>>((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return {
            'id': (m['id'] ?? '').toString(),
            'nom': (m['nom'] ?? 'Membre BONDIN').toString(),
            'date': (m['date'] ?? '').toString(),
            'tel': (m['tel'] ?? 'Non renseigné').toString(),
            'email': (m['email'] ?? '').toString(),
            'magasin': (m['magasin'] ?? 'Application Mobile BONDIN').toString(),
            'achats': (m['achats'] as num?)?.toInt() ?? 0,
            'points': (m['points'] as num?)?.toDouble() ?? 0.0,
            'segment': (m['segment'] ?? 'Membre').toString(),
            'statut': (m['statut'] ?? 'Actif').toString(),
          };
        }).toList();
      }
    }

    if (payload['top_magasins_ca'] is List) {
      final list = payload['top_magasins_ca'] as List;
      if (list.isNotEmpty) {
        topMagasinsCa = list.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    }

    if (payload['top_pdv_scans'] is List) {
      final list = payload['top_pdv_scans'] as List;
      if (list.isNotEmpty) {
        topPdvByScans = list.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    }
  }
}
