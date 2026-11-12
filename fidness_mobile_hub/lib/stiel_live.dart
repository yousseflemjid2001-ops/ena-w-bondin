// ============================================================================
// ALPHA BY STIEL — COUCHE DONNÉES TEMPS RÉEL (stiel_live.dart)
// Branche l'app mobile sur l'API du dashboard web Club Alpha (via le proxy
// /api/stiel/* du serveur mobile, port 8090 -> serveur Alpha, port 8086).
// En cas d'indisponibilité : repli silencieux sur le snapshot embarqué.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'stiel_data.dart';

double sD(dynamic v, [double def = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.').replaceAll('%', '').trim()) ?? def;
  return def;
}

int sI(dynamic v, [int def = 0]) => sD(v, def.toDouble()).round();

String sS(dynamic v, [String def = '']) => v == null ? def : v.toString();

List<Map<String, dynamic>> sList(dynamic v) {
  if (v is List) {
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return <Map<String, dynamic>>[];
}

Map<String, dynamic> sMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

String fmtNum(num v, [int dec = 0]) {
  final neg = v < 0;
  final fixed = v.abs().toStringAsFixed(dec);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
    buf.write(intPart[i]);
  }
  final dp = parts.length > 1 ? ',${parts[1]}' : '';
  return '${neg ? '-' : ''}$buf$dp';
}

class StielLive extends ChangeNotifier {
  StielLive._();
  static final StielLive instance = StielLive._();

  Map<String, dynamic> general = {};
  Map<String, dynamic> commercials = {};
  Map<String, dynamic> loyalty = {};
  Map<String, dynamic> churn = {};
  Map<String, dynamic> agentChurn = {};
  Map<String, dynamic> trial = {};
  List<Map<String, dynamic>> users = [];

  bool online = false;
  bool loading = false;
  DateTime? lastSync;
  String? lastError;
  Timer? _timer;

  bool get hasData => general.isNotEmpty;

  Map<String, dynamic> get kpis => sMap(general['kpis']);
  Map<String, dynamic> get cKpis => sMap(commercials['kpis']);
  Map<String, dynamic> get lKpis => sMap(loyalty['kpis']);
  Map<String, dynamic> get agentSummary => sMap(agentChurn['summary']);
  Map<String, dynamic> get churnSummary => sMap(churn['summary']);
  List<Map<String, dynamic>> get agentArtisans => sList(agentChurn['artisans']);
  List<Map<String, dynamic>> get gammesErosion => sList(agentChurn['gammes_erosion']);

  void start() {
    refresh();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Uri _uri(String path) => Uri.base.resolve('api/stiel/$path');

  Future<Map<String, dynamic>?> getJson(String path) async {
    try {
      final r = await http.get(_uri(path)).timeout(const Duration(seconds: 40));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(r.bodyBytes));
      return d is Map ? Map<String, dynamic>.from(d) : {'_list': d};
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> postJson(String path, Map<String, dynamic> body,
      {int timeoutSec = 60}) async {
    try {
      final r = await http
          .post(_uri(path),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(Duration(seconds: timeoutSec));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(r.bodyBytes));
      return d is Map ? Map<String, dynamic>.from(d) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    try {
      final res = await Future.wait([
        getJson('kpis/general'),
        getJson('kpis/commercials'),
        getJson('kpis/loyalty'),
        getJson('churn'),
        getJson('agent-ia/churn'),
        getJson('agent-ia/trial'),
        getJson('users'),
      ]);
      if (res[0] == null) {
        online = false;
        lastError = 'Serveur Alpha injoignable (port 8086)';
      } else {
        general = res[0]!;
        commercials = res[1] ?? commercials;
        loyalty = res[2] ?? loyalty;
        churn = res[3] ?? churn;
        agentChurn = res[4] ?? agentChurn;
        trial = res[5] ?? trial;
        if (res[6] != null) {
          final raw = res[6]!['users'] ?? res[6]!['_list'];
          users = sList(raw);
        }
        _applyToStatic();
        online = true;
        lastError = null;
        lastSync = DateTime.now();
      }
    } catch (e) {
      online = false;
      lastError = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Recopie des données live dans StielDwhData (utilisé par les widgets existants)
  // --------------------------------------------------------------------------
  static const Map<String, List<double>> _geo = {
    'Grand Tunis': [0.58, 0.16],
    'Tunis': [0.58, 0.16],
    'Ariana': [0.56, 0.14],
    'Ben Arous': [0.57, 0.20],
    'Manouba': [0.54, 0.17],
    'Nabeul': [0.68, 0.22],
    'Bizerte': [0.48, 0.10],
    'Béja': [0.38, 0.17],
    'Jendouba': [0.30, 0.18],
    'Le Kef': [0.30, 0.30],
    'Zaghouan': [0.55, 0.27],
    'Siliana': [0.40, 0.30],
    'Sousse': [0.62, 0.38],
    'Monastir': [0.66, 0.42],
    'Mahdia': [0.66, 0.48],
    'Kairouan': [0.50, 0.42],
    'Kasserine': [0.34, 0.48],
    'Sidi Bouzid': [0.44, 0.55],
    'Sfax': [0.64, 0.55],
    'Gafsa': [0.30, 0.64],
    'Gabès': [0.48, 0.74],
    'Médenine': [0.60, 0.84],
    'Tozeur': [0.20, 0.74],
    'Kébili': [0.30, 0.78],
    'Tataouine': [0.54, 0.92],
  };

  static const List<Color> _palette = [
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF84CC16),
  ];

  static String tierOf(num points) {
    if (points >= 4000) return 'PLATINE';
    if (points >= 2000) return 'OR';
    if (points >= 1000) return 'ARGENT';
    return 'BRONZE';
  }

  void _applyToStatic() {
    final k = kpis;
    if (k.isNotEmpty) {
      StielDwhData.totalCaIncremental = sD(k['total_ca_incremental'], StielDwhData.totalCaIncremental);
      StielDwhData.totalChantiers = sI(k['chantiers_total'], StielDwhData.totalChantiers);
      StielDwhData.chantiersValides = sI(k['chantiers_valides'], StielDwhData.chantiersValides);
      StielDwhData.chantiersEnAttente = sI(k['chantiers_en_attente'], StielDwhData.chantiersEnAttente);
      StielDwhData.tauxValidation = sD(k['taux_validation'], StielDwhData.tauxValidation);
      StielDwhData.totalComposants = sI(k['volume_composants'], StielDwhData.totalComposants);
      StielDwhData.panierMoyenCa = sD(k['panier_moyen_ca'], StielDwhData.panierMoyenCa);
      StielDwhData.panierMoyenArticles = sD(k['panier_moyen_articles'], StielDwhData.panierMoyenArticles);
      StielDwhData.margeBruteTnd = sD(k['marge_brute_tnd'], StielDwhData.margeBruteTnd);
      StielDwhData.roiRatio = sD(k['roi_ratio'], StielDwhData.roiRatio);
    }
    final lk = lKpis;
    if (lk.isNotEmpty) {
      StielDwhData.passifFinancierTnd = sD(lk['passif_financier_tnd'], StielDwhData.passifFinancierTnd);
      StielDwhData.pointsEnCirculation = sD(lk['total_points_circulation'], StielDwhData.pointsEnCirculation);
      StielDwhData.totalElectriciens = sI(lk['total_electriciens'], StielDwhData.totalElectriciens);
      StielDwhData.mauActifs = sI(lk['mau_actifs'], StielDwhData.mauActifs);
      StielDwhData.ltvMoyenneArtisan = sD(lk['ltv_moyenne_artisan_tnd'], StielDwhData.ltvMoyenneArtisan);
    }
    final ck = cKpis;
    if (ck.isNotEmpty) {
      StielDwhData.totalPreuvesPhotos = sI(ck['total_preuves_photos'], StielDwhData.totalPreuvesPhotos);
      StielDwhData.tauxConformitePhotos = sD(ck['taux_conformite_photos'], StielDwhData.tauxConformitePhotos);
      StielDwhData.slaMoyenGlobalHeures = sD(ck['sla_moyen_global_h'], StielDwhData.slaMoyenGlobalHeures);
    }
    StielDwhData.lastSyncTimestamp =
        '${DateTime.now().toString().substring(0, 19)} (DWH Alpha en direct)';

    // Évolution mensuelle
    final evo = sList(general['evolution_mensuelle']);
    if (evo.isNotEmpty) {
      StielDwhData.evolutionMensuelle = evo
          .map((e) => {
                'mois': sS(e['mois']).replaceAll(' 20', ' '),
                'chantiers': sI(e['chantiers']),
                'ca': sD(e['ca']),
                'points': sI(e['points']),
              })
          .toList();
    }

    // Gouvernorats (carte)
    final gov = sList(general['gouvernorats']);
    if (gov.isNotEmpty) {
      int i = 0;
      StielDwhData.gouvernorats = gov.map((g) {
        final name = sS(g['gouvernorat']);
        final geo = _geo[name];
        final lat = sD(g['lat'], 34);
        final lon = sD(g['lon'], 9.5);
        final dx = geo?[0] ?? ((lon - 7.8) / 4.0).clamp(0.08, 0.92);
        final dy = geo?[1] ?? ((37.4 - lat) / 7.5).clamp(0.06, 0.94);
        final m = {
          'gouv': name,
          'chantiers': sI(g['nb_chantiers']),
          'ca': sD(g['ca']),
          'points': sI(g['points']),
          'dx': dx.toDouble(),
          'dy': dy.toDouble(),
          'color': _palette[i % _palette.length],
        };
        i++;
        return m;
      }).toList();
    }

    // Top articles
    final arts = sList(general['top_articles']);
    if (arts.isNotEmpty) {
      final totalCa = arts.fold<double>(0, (a, e) => a + sD(e['ca_total']));
      StielDwhData.topArticles = arts
          .map((a) => {
                'ref': sS(a['nom'], sS(a['reference'])),
                'gamme': sS(a['gamme']),
                'vol': sI(a['volume_total']),
                'ca': sD(a['ca_total']),
                'chantiers': sI(a['nb_chantiers']),
                'share': totalCa > 0
                    ? '${(sD(a['ca_total']) / totalCa * 100).toStringAsFixed(1)}%'
                    : '',
                'classe': sS(a['classe'], 'C'),
              })
          .toList();
    }

    // Commerciaux
    final com = sList(commercials['commerciaux']);
    if (com.isNotEmpty) {
      StielDwhData.palmaresCommerciaux = com.map((c) {
        final ph = sS(c['phone']);
        return {
          'nom': sS(c['nom']),
          'region': sS(c['region']),
          'phone': ph.startsWith('+') ? ph : '+216 $ph',
          'chantiers': sI(c['chantiers_audites']),
          'valides': sI(c['chantiers_valides']),
          'insitu': sD(c['taux_insitu']),
          'conformite': sD(c['taux_conformite_photos']),
          'sla': sD(c['sla_moyen_h']),
          'points': sI(c['total_points']),
          'alertes': sI(c['chantiers_alerte']),
          'status': '${sS(c['badge'])} (${fmtNum(sD(c['total_points']))} pts)',
        };
      }).toList();
    }

    // Alertes GPS / SLA
    final al = sList(commercials['alertes']);
    StielDwhData.alertesChantiers = al.map((a) {
      final type = sS(a['type_alerte']);
      final crit = type.toLowerCase().contains('sla') || type.contains('48');
      return {
        'id': sI(a['chantier_id']),
        'artisan': sS(a['electricien']),
        'gouv': sS(a['gouvernorat']),
        'type': type,
        'valeur': sS(a['valeur']),
        'commercial': sS(a['commercial']),
        'gravite': crit ? 'critique' : 'moyenne',
        'titre': sS(a['titre']),
      };
    }).toList();

    // Funnel audit
    final fun = sList(commercials['funnel_audit']);
    if (fun.isNotEmpty) {
      StielDwhData.funnelAudit = fun
          .map((f) => {
                'etape': sS(f['etape']),
                'valeur': sI(f['valeur']),
                'taux': sS(f['taux']),
              })
          .toList();
    }

    // Électriciens (palmarès live)
    if (users.isNotEmpty) {
      final churnById = <String, Map<String, dynamic>>{};
      for (final a in sList(churn['artisans'])) {
        churnById[sS(a['id'])] = a;
      }
      final elec = users.where((u) {
        final t = sS(u['type']).toLowerCase();
        return t.isEmpty || t.contains('lectric');
      }).toList();
      elec.sort((a, b) {
        final c = sI(b['chantiers_count']).compareTo(sI(a['chantiers_count']));
        return c != 0 ? c : sD(b['total_earned']).compareTo(sD(a['total_earned']));
      });
      int rank = 0;
      StielDwhData.palmaresElectriciens = elec.map((u) {
        rank++;
        final id = sS(u['id']);
        final chs = sList(u['chantiers']);
        final region = chs.isNotEmpty ? sS(chs.first['gouvernorat'], 'Tunisie') : 'Tunisie';
        final pts = sD(u['total_points']);
        final ch = churnById[id];
        final score = sI(ch?['score_churn'], 0);
        final status = ch != null
            ? sS(ch['segment'], 'Actif')
            : (sI(u['chantiers_count']) == 0 ? 'Inscrit' : 'Actif');
        return {
          'rank': rank,
          'id': id,
          'nom': sS(u['full_name'], 'Électricien'),
          'code': 'EL-${id.replaceAll('-', '').substring(0, id.replaceAll('-', '').length < 6 ? id.replaceAll('-', '').length : 6).toUpperCase()}',
          'region': region,
          'tier': tierOf(pts),
          'chantiers': sI(u['chantiers_count']),
          'ca': 0,
          'points': pts.round(),
          'earned': sD(u['total_earned']).round(),
          'burned': sD(u['total_burned']).round(),
          'phone': sS(u['phone']),
          'parrain': sS(u['parrain']),
          'churn': score,
          'status': status,
        };
      }).toList();
    }

    // Agent IA churn (24 artisans prioritaires)
    final ac = agentArtisans;
    if (ac.isNotEmpty) {
      StielDwhData.churnArtisans = ac.map((a) {
        final sc = sI(a['score_risque']);
        final status = sc >= 70
            ? 'Risque Critique 🔴'
            : sc >= 50
                ? 'Risque Élevé 🟠'
                : 'Risque Modéré 🟡';
        final id = sS(a['id']).replaceAll('-', '');
        return {
          'id': sS(a['id']),
          'nom': sS(a['nom']),
          'code': 'EL-${id.substring(0, id.length < 6 ? id.length : 6).toUpperCase()}',
          'gouv': sS(a['gouvernorat']),
          'score': sc,
          'inactifJours': sI(a['days_since_last']),
          'points': sI(a['points']),
          'cause': '${sS(a['diagnostic'])} (chute ${sI(a['chute_pct'])}%)',
          'action': sS(a['recommandation']),
          'status': status,
          'phone': sS(a['phone']),
          'wa': sS(a['wa']),
          'ca_menace': sD(a['ca_menace']),
          'gamme': sS(a['gamme_abandonnee']),
          'cross': sS(a['cross_sell_cible']),
          'offre': sS(a['offre_anti_erosion']),
          'fenetre': sS(a['fenetre_action']),
          'p48': sI(a['prob_reactivation_48h']),
          'p15': sI(a['prob_reactivation_15j']),
          'reactLabel': sS(a['reactivation_label']),
          'tier': sS(a['reactivation_tier']),
          'skus': (a['top_skus_abandonnes'] is List)
              ? (a['top_skus_abandonnes'] as List).map((e) => e.toString()).toList()
              : <String>[],
        };
      }).toList();
    }

    // Cadeaux convoités (live) fusionnés en tête du catalogue
    final cad = sList(loyalty['top_cadeaux']);
    if (cad.isNotEmpty) {
      StielDwhData.cadeauxLive = cad;
    }
  }
}
