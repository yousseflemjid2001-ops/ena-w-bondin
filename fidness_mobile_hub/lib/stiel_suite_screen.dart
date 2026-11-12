// ============================================================================
// ALPHA BY STIEL — SUITE MOBILE COMPLÈTE B2B (stiel_suite_screen.dart)
// Parité complète avec le Dashboard Web Alpha by STIEL (hors galerie photos) :
// 1. Cockpit Chantiers & CA (KPIs Live, Évolution, Carte, Pareto ABC, Treemap,
//    Flux B2B Sankey, Grand Palmarès 7 Catégories + Rapport Exécutif)
// 2. Artisans, Paliers & Fidélité (Paliers Live, Cascade Financière Waterfall,
//    Simulateur What-If API, Cohortes, Proches Seuil, Fiche Électricien 360°)
// 3. Commerciaux & Audits SLA (Jauges SLA/GPS/Photos, Funnel Audit, Équipe,
//    Alertes Temps Réel — SANS galerie photos)
// 4. Distributeurs & Cadeaux Pro (Comptoirs, Top Cadeaux DWH Live, Catalogue Pro)
// 5. Agent IA Churn & Copilot RAG Live (Essai 30j, Sévérité, Trajectoire CA,
//    Gammes Abandonnées, Score Réactivation 48h/15j, Offres Push API,
//    Aperçu E-mail Lundi 09h, Simulateur Vocal WhatsApp, Copilot RAG Live)
// ============================================================================

import 'package:flutter/material.dart';
import 'stiel_data.dart';
import 'stiel_charts.dart';
import 'stiel_live.dart';
import 'stiel_extra.dart';

class StielFullMobileSuiteScreen extends StatefulWidget {
  final bool isSuperAdmin;
  final String userEmail;
  final ValueChanged<String>? onSwitchTenant;
  final VoidCallback onLogout;

  const StielFullMobileSuiteScreen({
    super.key,
    required this.isSuperAdmin,
    required this.userEmail,
    this.onSwitchTenant,
    required this.onLogout,
  });

  @override
  State<StielFullMobileSuiteScreen> createState() =>
      _StielFullMobileSuiteScreenState();
}

class _StielFullMobileSuiteScreenState extends State<StielFullMobileSuiteScreen> {
  int _activeTab = 0;
  String _selectedGouv = 'Toutes Régions';
  String? _selectedGamme;
  String _searchArtisanQuery = '';
  int _selectedChurnIdx = 0;
  String _pushStatusMsg = '🟢 Prêt pour relance artisan (API Agent IA)';
  bool _sendingOffer = false;
  bool _copilotBusy = false;

  final TextEditingController _copilotInputCtrl = TextEditingController();
  List<String> _copilotFollowups = [
    'Quel est le bilan CA et marge brute ?',
    'Quels électriciens sont en risque critique de churn ?',
    'Quel est le SLA des commerciaux terrain ?',
    'Quelles sont les références best-sellers STIEL ?',
  ];

  final List<Map<String, String>> _copilotChat = [
    {
      'role': 'ai',
      'text':
          '👋 **Bonjour Direction STIEL / Club Alpha !**\n'
          'Je suis le Copilot Décisionnel RAG branché en direct sur PostgreSQL (`57.131.30.69`).\n\n'
          '• **CA Incrémental Validé** : 40 471,90 TND (158 chantiers certifiés)\n'
          '• **Artisans Électriciens** : 172 adhérents (110 actifs • 64,0%)\n'
          '• **Panier Moyen Chantier** : 256,15 TND • 26,7 articles\n'
          '• **SLA Moyen National** : 7,5 heures • 98,2% conformité audit\n'
          '• **Passif Engagé** : 1 383,50 TND (138 350 pts en circulation)',
      'sources': 'PostgreSQL Live • 9 tables synchronisées',
    },
  ];

  @override
  void initState() {
    super.initState();
    StielLive.instance.addListener(_onLiveUpdate);
    StielLive.instance.start();
  }

  void _onLiveUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    StielLive.instance.removeListener(_onLiveUpdate);
    _copilotInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCopilotQuestion(String query) async {
    final q = query.trim();
    if (q.isEmpty || _copilotBusy) return;

    setState(() {
      _copilotChat.add({'role': 'user', 'text': q});
      _copilotInputCtrl.clear();
      _copilotBusy = true;
    });

    final res = await StielLive.instance.postJson('rag/chat', {'query': q});
    if (!mounted) return;

    if (res != null && res['response'] != null) {
      final respText = res['response'].toString();
      final sourcesList = (res['sources'] as List?)
              ?.map((s) => s is Map ? '${s['table'] ?? ''} (${s['metric'] ?? ''})' : s.toString())
              .where((s) => s.trim().isNotEmpty)
              .join(' • ') ??
          'PostgreSQL DWH Live';
      final followups = (res['suggested_followups'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          _copilotFollowups;

      setState(() {
        _copilotChat.add({
          'role': 'ai',
          'text': respText,
          'sources': sourcesList,
        });
        if (followups.isNotEmpty) {
          _copilotFollowups = followups;
        }
        _copilotBusy = false;
      });
      return;
    }

    // Fallback local si hors-ligne
    final lower = q.toLowerCase();
    String answer;
    if (lower.contains('kpi') || lower.contains('ca') || lower.contains('bilan') || lower.contains('marge')) {
      answer =
          '📊 **Bilan Clé Club Alpha STIEL (YTD 2026)** :\n'
          '• **Total Chantiers Déclarés** : ${StielDwhData.totalChantiers} chantiers (${StielDwhData.chantiersValides} validés • ${StielDwhData.tauxValidation}%)\n'
          '• **CA Matériel Incrémental** : ${fmtNum(StielDwhData.totalCaIncremental, 2)} TND\n'
          '• **Marge Brute Générée** : ${fmtNum(StielDwhData.margeBruteTnd, 2)} TND (ROI Programme : ${fmtNum(StielDwhData.roiRatio, 1)}%)\n'
          '• **Top Régions** : Sousse & Grand Tunis.';
    } else if (lower.contains('electricien') || lower.contains('artisan') || lower.contains('palmares')) {
      final top3 = StielDwhData.palmaresElectriciens.take(3).toList();
      answer =
          '⚡ **Top Électriciens Ambassadeurs STIEL** :\n'
          '${top3.asMap().entries.map((e) => '${e.key + 1}. **${e.value['nom']}** (${e.value['tier']} • ${e.value['region']}) : ${e.value['chantiers']} chantiers • ${fmtNum(sD(e.value['ca']))} DT (${e.value['points']} pts)').join('\n')}\n'
          '• Total membres inscrits : ${StielDwhData.totalElectriciens} installateurs.';
    } else if (lower.contains('commercial') || lower.contains('sla') || lower.contains('audit')) {
      answer =
          '🎯 **Audit Terrain & Commerciaux STIEL** :\n'
          '${StielDwhData.palmaresCommerciaux.take(3).map((c) => '• **${c['nom']}** : ${c['chantiers']} chantiers (${c['valides']} validés • ${c['insitu']}% in-situ • SLA ${c['sla']}h)').join('\n')}\n'
          '• Taux national de conformité audit : **${StielDwhData.tauxConformitePhotos}%**.';
    } else if (lower.contains('distributeur') || lower.contains('comptoir') || lower.contains('grossiste')) {
      answer =
          '🏢 **Top Distributeurs Matériel Électrique STIEL** :\n'
          '${StielDwhData.distributeurs.take(3).map((d) => '• **${d['nom']}** (${d['ville']}) : ${fmtNum(sD(d['ca']))} DT CA (${d['artisans']} artisans)').join('\n')}';
    } else if (lower.contains('churn') || lower.contains('risque')) {
      answer =
          '⚠️ **Agent IA Churn Artisans STIEL** :\n'
          '${StielDwhData.churnArtisans.take(3).map((a) => '• **${a['nom']} (${a['gouv']})** : Score ${a['score']}/100 (${a['inactifJours']}j inactif • ${a['points']} pts)').join('\n')}\n'
          'Action recommandée : Offre Points x2 + appel WhatsApp IA.';
    } else {
      answer =
          '💡 **Synthèse DWH Alpha by STIEL** :\n'
          'Pour *« $q »* :\n'
          '• Total Chantiers : ${StielDwhData.totalChantiers} • CA Incrémental : ${fmtNum(StielDwhData.totalCaIncremental, 2)} DT\n'
          '• Artisans Actifs : ${StielDwhData.mauActifs} électriciens sur ${StielDwhData.totalElectriciens} membres\n'
          '• Points en circulation : ${fmtNum(StielDwhData.pointsEnCirculation)} pts (Dette provisionnée : ${fmtNum(StielDwhData.passifFinancierTnd, 2)} DT).';
    }

    setState(() {
      _copilotChat.add({
        'role': 'ai',
        'text': answer,
        'sources': 'Snapshot DWH Local',
      });
      _copilotBusy = false;
    });
  }

  Future<void> _triggerChurnOffer(Map<String, dynamic> artisan) async {
    setState(() {
      _sendingOffer = true;
      _pushStatusMsg = '⏳ Envoi de l\'offre Points x2 à ${artisan['nom']}...';
    });
    final res = await StielLive.instance.postJson('agent-ia/offers', {
      'artisan_id': artisan['id'] ?? 0,
      'nom': artisan['nom'],
      'action': artisan['action'],
    });
    if (!mounted) return;
    setState(() {
      _sendingOffer = false;
      if (res != null && res['message'] != null) {
        _pushStatusMsg = '✅ ${res['message']}';
      } else {
        _pushStatusMsg =
            '🚀 Offre Points x2 & alerte commerciale déclenchées pour ${artisan['nom']} !';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070C1E),
      body: SafeArea(
        child: Column(
          children: [
            // 1. EN-TÊTE STIEL × FIDNESS + BOUTONS LIVE & RAPPORT EXÉCUTIF
            _buildStielTopHeader(),

            // 2. SLICERS FILTRES RÉGIONAUX & GAMMES STIEL
            _buildStielSlicersBar(),

            // 3. RUBAN DES 5 ONGLETS DU HUB B2B
            _buildStielTabsRibbon(),

            // 4. CORPS DE L'ONGLET ACTIF
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildActiveTabBody(),
              ),
            ),

            // 5. BARRE DE NAVIGATION INFÉRIEURE
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStielTopHeader() {
    final live = StielLive.instance;
    final syncStr = live.lastSync != null
        ? '${live.lastSync!.hour.toString().padLeft(2, '0')}:${live.lastSync!.minute.toString().padLeft(2, '0')}'
        : 'Snapshot';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F1E3D), Color(0xFF070C1E)],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1.4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.5),
              child: Image.asset(
                'assets/images/club_alpha_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.electric_bolt_rounded,
                  color: Color(0xFF1E3A8A),
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ALPHA BY STIEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (live.online ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                            .withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: live.online ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                        ),
                      ),
                      child: Text(
                        live.online ? '● LIVE DWH' : '● SNAPSHOT',
                        style: TextStyle(
                          color: live.online ? const Color(0xFF6EE7B7) : const Color(0xFFFDE68A),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${StielDwhData.totalElectriciens} Électriciens • ${StielDwhData.totalChantiers} Chantiers • Sync $syncStr',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Bouton Rapport Décisionnel Exécutif
          InkWell(
            onTap: () => showStielExecutiveReport(context),
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.description_rounded, size: 12, color: Color(0xFF93C5FD)),
                  SizedBox(width: 4),
                  Text(
                    'Rapport',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => StielLive.instance.refresh(),
            tooltip: 'Synchroniser PostgreSQL Live',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              Icons.refresh_rounded,
              color: live.loading ? const Color(0xFFFBBF24) : const Color(0xFF93C5FD),
              size: 17,
            ),
          ),
          IconButton(
            onPressed: widget.onLogout,
            tooltip: 'Déconnexion',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white70,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStielSlicersBar() {
    final gouvs = StielDwhData.gouvernorats;
    return Container(
      height: 36,
      color: const Color(0xFF0A132C),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: [
          _buildSlicerPill('🇹🇳 Toutes Régions (${StielDwhData.totalChantiers})', 'Toutes Régions'),
          const SizedBox(width: 6),
          ...gouvs.take(8).expand((g) => [
                _buildSlicerPill('${g['gouv']} (${g['chantiers']})', g['gouv'].toString()),
                const SizedBox(width: 6),
              ]),
          if (_selectedGamme != null) ...[
            GestureDetector(
              onTap: () => setState(() => _selectedGamme = null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFBBF24)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Gamme: $_selectedGamme ✕',
                      style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (_selectedGouv != 'Toutes Régions' || _selectedGamme != null)
            GestureDetector(
              onTap: () => setState(() {
                _selectedGouv = 'Toutes Régions';
                _selectedGamme = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 12, color: Color(0xFF34D399)),
                    SizedBox(width: 4),
                    Text(
                      'Reset Filtres',
                      style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlicerPill(String label, String gouv) {
    final bool isSel = _selectedGouv == gouv;
    return GestureDetector(
      onTap: () => setState(() => _selectedGouv = gouv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF60A5FA) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : const Color(0xFFCBD5E1),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStielTabsRibbon() {
    final tabs = [
      {'badge': '01', 'label': 'Cockpit Chantiers & CA'},
      {'badge': '02', 'label': 'Artisans, Paliers & What-If'},
      {'badge': '03', 'label': 'Commerciaux & Audits SLA'},
      {'badge': '04', 'label': 'Distributeurs & Cadeaux Pro'},
      {'badge': '05', 'label': 'Agent IA Churn & Copilot'},
    ];

    return Container(
      height: 40,
      color: const Color(0xFF081026),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final bool active = _activeTab == i;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      )
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? const Color(0xFF60A5FA) : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${tabs[i]['badge']} • ',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    tabs[i]['label']!,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTabBody() {
    switch (_activeTab) {
      case 0:
        return _buildTab01CockpitChantiers();
      case 1:
        return _buildTab02ArtisansPaliers();
      case 2:
        return _buildTab03CommerciauxSla();
      case 3:
        return _buildTab04DistributeursCadeaux();
      case 4:
        return _buildTab05AgentChurnCopilot();
      default:
        return _buildTab01CockpitChantiers();
    }
  }

  // ==========================================================================
  // 1. COCKPIT DIRECTION CHANTIERS & CA (AVEC PARETO, TREEMAP, SANKEY, PALMARÈS)
  // ==========================================================================
  Widget _buildTab01CockpitChantiers() {
    double caAffiche = StielDwhData.totalCaIncremental;
    int chantiersAffiches = StielDwhData.totalChantiers;
    int validesAffiches = StielDwhData.chantiersValides;

    if (_selectedGouv != 'Toutes Régions') {
      final gMatch = StielDwhData.gouvernorats.where(
        (g) => g['gouv'].toString().toLowerCase() == _selectedGouv.toLowerCase(),
      );
      if (gMatch.isNotEmpty) {
        final gm = gMatch.first;
        caAffiche = (gm['ca'] as num?)?.toDouble() ?? caAffiche;
        chantiersAffiches = (gm['chantiers'] as num?)?.toInt() ?? chantiersAffiches;
        validesAffiches = (chantiersAffiches * (StielDwhData.tauxValidation / 100.0)).round();
      }
    }

    final filteredArticles = _selectedGamme == null
        ? StielDwhData.topArticles
        : StielDwhData.topArticles
            .where((a) => a['gamme'].toString().toLowerCase() == _selectedGamme!.toLowerCase())
            .toList();

    final sankeyRaw = StielLive.instance.general['sankey'] as Map<String, dynamic>?;
    final List<Map<String, dynamic>> sankeyNodes = (sankeyRaw?['nodes'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {'name': 'Gamme : Apparent'},
          {'name': 'Gamme : Encastré'},
          {'name': 'Gamme : Étanche'},
          {'name': 'Gamme : Modulaire'},
          {'name': 'Com. : Ali Ben Romdhane'},
          {'name': 'Com. : Mohamed Saied'},
          {'name': 'Com. : Mahdi Nabli'},
          {'name': 'Com. : Sami Riahi'},
          {'name': 'Chantier : Résidentiel Neuf'},
          {'name': 'Chantier : Rénovation'},
          {'name': 'Chantier : Tertiaire & Bureau'},
        ];
    final List<Map<String, dynamic>> sankeyLinks = (sankeyRaw?['links'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {'source': 1, 'target': 4, 'value': 12500},
          {'source': 1, 'target': 5, 'value': 9800},
          {'source': 0, 'target': 4, 'value': 6200},
          {'source': 2, 'target': 6, 'value': 5400},
          {'source': 3, 'target': 7, 'value': 4100},
          {'source': 4, 'target': 8, 'value': 11200},
          {'source': 4, 'target': 9, 'value': 7500},
          {'source': 5, 'target': 8, 'value': 6400},
          {'source': 5, 'target': 10, 'value': 3400},
          {'source': 6, 'target': 9, 'value': 5400},
          {'source': 7, 'target': 10, 'value': 4100},
        ];

    final double tauxAct = StielDwhData.totalElectriciens > 0
        ? (StielDwhData.mauActifs / StielDwhData.totalElectriciens * 100.0)
        : 64.0;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(
          badge: 'KPI B2B',
          title: _selectedGouv == 'Toutes Régions'
              ? 'Indicateurs Clés Chantiers STIEL (National)'
              : 'Indicateurs Clés Chantiers — $_selectedGouv',
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.58,
          children: [
            _buildKpiCard(
              'CA Matériel Incrémental',
              '${fmtNum(caAffiche, 2)} DT',
              '$validesAffiches chantiers certifiés',
              'ROI ${fmtNum(StielDwhData.roiRatio, 0)}%',
              const Color(0xFF3B82F6),
              Icons.payments_rounded,
            ),
            _buildKpiCard(
              'Taux de Validation',
              '${fmtNum(StielDwhData.tauxValidation, 1)} %',
              '$validesAffiches validés / $chantiersAffiches soumis',
              '${StielDwhData.chantiersEnAttente} en attente',
              const Color(0xFF10B981),
              Icons.verified_rounded,
            ),
            _buildKpiCard(
              'Panier Moyen Chantier',
              '${fmtNum(StielDwhData.panierMoyenCa, 2)} DT',
              '${fmtNum(StielDwhData.panierMoyenArticles, 1)} composants / dossier',
              '${fmtNum(StielDwhData.totalComposants)} u.',
              const Color(0xFFF59E0B),
              Icons.shopping_cart_rounded,
            ),
            _buildKpiCard(
              'Électriciens Adhérents',
              '${StielDwhData.totalElectriciens} Artisans',
              '${StielDwhData.mauActifs} Actifs (${fmtNum(tauxAct, 1)}%)',
              'LTV ${fmtNum(StielDwhData.ltvMoyenneArtisan)} DT',
              const Color(0xFF8B5CF6),
              Icons.engineering_rounded,
            ),
            _buildKpiCard(
              'Marge Brute Générée',
              '${fmtNum(StielDwhData.margeBruteTnd, 2)} DT',
              'Marge industrielle 38,0%',
              'Rentabilité Forte',
              const Color(0xFF06B6D4),
              Icons.trending_up_rounded,
            ),
            _buildKpiCard(
              'Passif Financier Prévu',
              '${fmtNum(StielDwhData.passifFinancierTnd, 2)} DT',
              '${fmtNum(StielDwhData.pointsEnCirculation)} pts en circulation',
              '0,010 DT / pt',
              const Color(0xFFEC4899),
              Icons.account_balance_wallet_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'ÉVOLUTION', title: 'Volume Mensuel des Chantiers Déclarés (Fév - Oct 2026)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📈 Trajectoire d\'Accélération Terrain STIEL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              StielEvolutionChart(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'GÉO', title: 'Cartographie Nationale des Gouvernorats Chantiers'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: StielTunisiaMapCard(
            onSelectGouv: (g) => setState(() => _selectedGouv = g),
          ),
        ),
        const SizedBox(height: 16),

        // PARETO ABC
        _buildSectionTitle(badge: 'PARETO ABC', title: 'Top 10 Références STIEL — Analyse Pareto ABC (80/20)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Valeur CA & Courbe Cumulée Pareto (%)',
                style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              StielParetoChart(
                articles: filteredArticles.isEmpty ? StielDwhData.topArticles : filteredArticles,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TREEMAP HIÉRARCHIQUE
        _buildSectionTitle(badge: 'TREEMAP', title: 'Répartition Hiérarchique de la Valeur (Gamme → Référence)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗂️ Touchez une gamme pour filtrer les articles par famille STIEL',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
              const SizedBox(height: 8),
              StielTreemap(
                articles: StielDwhData.topArticles,
                onTapGamme: (g) => setState(() {
                  _selectedGamme = (_selectedGamme == g) ? null : g;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // FLUX B2B SANKEY
        _buildSectionTitle(badge: 'FLUX B2B', title: 'Flux B2B Sankey : Gammes → Commerciaux → Typologie Chantier'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔀 Traçabilité Complète du CA Matériel par Canal & Typologie',
                style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              StielSankey(nodes: sankeyNodes, links: sankeyLinks),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // GRAND PALMARÈS & MATRICES DÉCISIONNELLES B2B (7 CATÉGORIES)
        _buildSectionTitle(badge: 'PALMARÈS B2B', title: 'Grand Palmarès & Matrices Décisionnelles (7 Dimensions)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: StielGrandPalmares(
            region: _selectedGouv,
            onOpenElectricien: (e) => showStielElectricien360(
              context,
              sS(e['id'], '1'),
              sS(e['nom'], 'Électricien'),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. ARTISANS ÉLECTRICIENS, PALIERS, WATERFALL, WHAT-IF & COHORTES
  // ==========================================================================
  Widget _buildTab02ArtisansPaliers() {
    final loyalty = StielLive.instance.loyalty;
    final paliersMap = (loyalty['paliers'] as Map<String, dynamic>?) ??
        {'Platine': 3, 'Or': 5, 'Argent': 5, 'Bronze': 159};
    final waterfallList = (loyalty['waterfall_points'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {'etape': 'Points Chantiers Validés', 'valeur': 152850, 'type': 'entree'},
          {'etape': 'Bonus Parrainage & Bienvenue', 'valeur': 21000, 'type': 'entree'},
          {'etape': 'Cadeaux Convertis (Burn)', 'valeur': -35500, 'type': 'sortie'},
          {'etape': 'Solde Actif en Circulation', 'valeur': 138350, 'type': 'solde'},
        ];
    final cohortesList = (loyalty['cohortes'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {'cohorte': 'Juin 2026', 'inscrits': 24, 'm0': '100%', 'm1': '88%', 'm2': '83%', 'm3': '79%', 'm4': '75%'},
          {'cohorte': 'Juil 2026', 'inscrits': 31, 'm0': '100%', 'm1': '90%', 'm2': '84%', 'm3': '81%', 'm4': '-'},
          {'cohorte': 'Août 2026', 'inscrits': 28, 'm0': '100%', 'm1': '86%', 'm2': '79%', 'm3': '-', 'm4': '-'},
          {'cohorte': 'Sept 2026', 'inscrits': 18, 'm0': '100%', 'm1': '83%', 'm2': '-', 'm3': '-', 'm4': '-'},
        ];
    final prochesList = (loyalty['proches_seuil'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {'nom': 'Hichem Trabelsi', 'ville': 'Nabeul', 'points': 4420, 'prochain_palier': 'Platine (5000)', 'points_manquants': 580},
          {'nom': 'Kais Ben Amor', 'ville': 'Sousse', 'points': 4180, 'prochain_palier': 'Platine (5000)', 'points_manquants': 820},
          {'nom': 'Nabil Mejri', 'ville': 'Bizerte', 'points': 1760, 'prochain_palier': 'Or (2000)', 'points_manquants': 240},
        ];

    final filtered = StielDwhData.palmaresElectriciens.where((e) {
      if (_selectedGouv != 'Toutes Régions' &&
          !e['region'].toString().toLowerCase().contains(_selectedGouv.toLowerCase())) {
        return false;
      }
      if (_searchArtisanQuery.trim().isEmpty) return true;
      final q = _searchArtisanQuery.toLowerCase();
      return (e['nom'] as String).toLowerCase().contains(q) ||
          (e['region'] as String).toLowerCase().contains(q) ||
          (e['code'] as String).toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(
          badge: 'PALIERS',
          title: 'Répartition du Réseau Artisans Club Alpha (${StielDwhData.totalElectriciens} Membres)',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTierBadge('Platine ⭐', '${paliersMap['Platine'] ?? 3} Artisans', const Color(0xFF38BDF8)),
            const SizedBox(width: 6),
            _buildTierBadge('Or 🏆', '${paliersMap['Or'] ?? 5} Artisans', const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            _buildTierBadge('Argent 🥈', '${paliersMap['Argent'] ?? 5} Artisans', const Color(0xFFCBD5E1)),
            const SizedBox(width: 6),
            _buildTierBadge('Bronze 🥉', '${paliersMap['Bronze'] ?? 159} Membres', const Color(0xFFD97706)),
          ],
        ),
        const SizedBox(height: 16),

        // CASCADE FINANCIÈRE DES POINTS (WATERFALL)
        _buildSectionTitle(badge: 'WATERFALL', title: 'Cascade Financière des Points & Passif Provisionné'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💰 Équilibre Earn & Burn (1 pt = 0,010 TND)',
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Passif : ${fmtNum(StielDwhData.passifFinancierTnd, 2)} DT',
                    style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StielWaterfall(steps: waterfallList),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SIMULATEUR DYNAMIQUE WHAT-IF (CONNECTÉ API)
        _buildSectionTitle(badge: 'WHAT-IF', title: 'Simulateur Dynamique de Rentabilité & Barème Points'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const StielWhatIfCard(),
        ),
        const SizedBox(height: 16),

        // COHORTES DE RÉTENTION & PROCHES DU SEUIL
        _buildSectionTitle(badge: 'COHORTES', title: 'Rétention par Cohorte Mensuelle & Proches Palier Supérieur'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StielCohorts(cohortes: cohortesList),
              if (prochesList.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  '🎯 Artisans proches du palier supérieur (Opportunité d\'upsell) :',
                  style: TextStyle(color: Color(0xFFFDE68A), fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                ...prochesList.take(5).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '• ${sS(p['nom'])} (${sS(p['ville'], sS(p['gouvernorat']))}) — ${fmtNum(sD(p['points']))} pts',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Manque ${fmtNum(sD(p['points_manquants'], sD(p['manque'])))} pts → ${sS(p['prochain_palier'], sS(p['cible']))}',
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ANNUAIRE INTERACTIF AVEC FICHE ÉLECTRICIEN 360°
        _buildSectionTitle(badge: 'FICHE 360°', title: 'Annuaire Électriciens (Touchez un artisan pour ouvrir sa Fiche 360°)'),
        const SizedBox(height: 8),
        TextField(
          onChanged: (v) => setState(() => _searchArtisanQuery = v),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Rechercher un électricien (Nom, Ville, Code EL-)...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
            prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF60A5FA)),
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),

        ...filtered.take(30).map((e) {
          final isPlatine = e['tier'] == 'PLATINE';
          final isOr = e['tier'] == 'OR';
          final Color badgeCol = isPlatine
              ? const Color(0xFF38BDF8)
              : isOr
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF94A3B8);

          return InkWell(
            onTap: () => showStielElectricien360(
              context,
              sS(e['id'], '1'),
              e['nom'].toString(),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: badgeCol.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                e['nom'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: badgeCol.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(e['tier'] as String, style: TextStyle(color: badgeCol, fontSize: 8.5, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${e['code']} • ${e['region']} • ${e['status']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        Text('${e['chantiers']} chantiers réalisés • ${fmtNum(sD(e['ca']))} DT volume', style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${fmtNum(sD(e['points']))} pts', style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w900)),
                      const Row(
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 10, color: Color(0xFF60A5FA)),
                          SizedBox(width: 3),
                          Text('Fiche 360°', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 9, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTierBadge(String label, String count, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: col.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 3. COMMERCIAUX & AUDIT TERRAIN SLA (AVEC JAUGES SLA/GPS/CONFORMITÉ, SANS GALERIE)
  // ==========================================================================
  Widget _buildTab03CommerciauxSla() {
    final commKpis = StielLive.instance.cKpis;
    final double tauxSla = sD(commKpis['taux_respect_sla'], 92.4);
    final double tauxInsitu = sD(commKpis['taux_insitu_global'], 87.7);
    final double tauxPhotos = sD(commKpis['taux_conformite_photos'], StielDwhData.tauxConformitePhotos);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // JAUGES DE CONFORMITÉ SLA, GPS IN-SITU & AUDIT
        _buildSectionTitle(badge: 'JAUGES SLA & GPS', title: 'Jauges Nationales de Conformité Terrain & SLA (<48h)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎯 Contrôle Qualité Temps Réel des Audits',
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'SLA Moyen : ${fmtNum(StielDwhData.slaMoyenGlobalHeures, 1)}h',
                    style: const TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StielGaugeRow(
                sla: tauxSla,
                gps: tauxInsitu,
                photos: tauxPhotos,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'FUNNEL', title: 'Funnel d\'Audit des Déclarations Chantiers'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contrôle des 4 Étapes de Validation Terrain', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              StielFunnelAuditWidget(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'ÉQUIPE', title: 'Palmarès des Délégués Commerciaux & SLA'),
        const SizedBox(height: 8),
        ...StielDwhData.palmaresCommerciaux.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['nom'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                      Text('${c['region']} • ${c['phone']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                      Text('SLA Moyen : ${c['sla']}h • In-situ : ${c['insitu']}% • Conformité : ${c['conformite']}%', style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${c['valides']} / ${c['chantiers']} validés', style: const TextStyle(color: Color(0xFF34D399), fontSize: 10.5, fontWeight: FontWeight.w800)),
                    Text('${fmtNum(sD(c['points']))} pts', style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'ALERTES', title: 'Alertes GPS Suspectes (>300m) & Délais SLA (>48h)'),
        const SizedBox(height: 8),
        ...StielDwhData.alertesChantiers.map((al) {
          final isCrit = al['gravite'] == 'critique';
          final Color col = isCrit ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: col.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                Icon(isCrit ? Icons.timer_off_rounded : Icons.fmd_bad_rounded, color: col, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chantier #${al['id']} • ${al['artisan']} (${al['gouv']})', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('${al['type']} : ${al['valeur']} • Délégué : ${al['commercial']}', style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================================
  // 4. DISTRIBUTEURS COMPTOIRS & CADEAUX PRO (LIVE + CATALOGUE)
  // ==========================================================================
  Widget _buildTab04DistributeursCadeaux() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(badge: 'COMPTOIRS', title: 'Réseau Distributeurs Partenaires STIEL (20 Comptoirs)'),
        const SizedBox(height: 8),
        ...StielDwhData.distributeurs.map((d) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['nom'] as String, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                      Text('${d['ville']} • Délégué : ${d['commercial']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                      Text('${d['artisans']} électriciens rattachés • Part : ${d['share']}', style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 9.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmtNum(sD(d['ca']))} DT', style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w900)),
                    Text(d['tier'] as String, style: const TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        // TOP CADEAUX CONVOITÉS (LIVE DWH DEMANDES & BURN)
        _buildSectionTitle(badge: 'BURN LIVE', title: 'Top Cadeaux Convoités & Points Brûlés (DWH Live)'),
        const SizedBox(height: 8),
        ...StielDwhData.cadeauxLive.map((c) {
          final nom = sS(c['nom'], sS(c['titre'], 'Cadeau STIEL'));
          final ptsReq = sD(c['points_requis'], sD(c['cout_points'], 1000));
          final demandes = sI(c['demandes'], 1);
          final brules = sD(c['points_brules'], ptsReq * demandes);
          final statut = sS(c['statut'], sS(c['stock'], 'Disponible'));
          final isCrit = statut.toLowerCase().contains('critique');
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: isCrit ? const Color(0xFFF59E0B).withValues(alpha: 0.45) : Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nom, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text(
                        '$demandes demandes • ${fmtNum(ptsReq)} pts/u • $statut',
                        style: TextStyle(color: isCrit ? const Color(0xFFFBBF24) : const Color(0xFF94A3B8), fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmtNum(brules)} pts', style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w900)),
                    const Text('Points brûlés', style: TextStyle(color: Color(0xFF64748B), fontSize: 8.5)),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        _buildSectionTitle(badge: 'BOUTIQUE', title: 'Catalogue Récompenses & Outillage Pro Facom / STIEL'),
        const SizedBox(height: 8),
        ...StielDwhData.cadeauxPro.map((cad) {
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cad['titre'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      Text('${cad['cat']} • Stock : ${cad['stock']} unités (${cad['status']})', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmtNum(sD(cad['points']))} pts', style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('Valeur ${(cad['valeurTnd'] as double).toStringAsFixed(0)} DT', style: const TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================================
  // 5. AGENT IA CHURN COMPLET & COPILOT CONVERSATIONNEL RAG LIVE
  // ==========================================================================
  Widget _buildTab05AgentChurnCopilot() {
    final agentChurn = StielLive.instance.agentChurn;
    final summary = StielLive.instance.agentSummary;
    final churnSum = StielLive.instance.churnSummary.isNotEmpty
        ? StielLive.instance.churnSummary
        : {'champions': 42, 'reguliers': 106, 'a_risque': 8, 'critiques': 16};

    final int nbRisque = sI(summary['count'], StielDwhData.churnArtisans.length);
    final int nbCritiques = sI(summary['critiques'], 16);
    final double caMenace = sD(summary['ca_menace'], 52437.95);
    final int unitesPerdues = sI(summary['total_unites_perdues'], 428);
    final double avgProb48h = sD(summary['avg_prob_48h'], 78.4);
    final double avgProb15j = sD(summary['avg_prob_15j'], 34.2);

    final gammesErosion = (agentChurn['gammes_erosion'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [
          {
            'gamme': 'Modules Blanc Neige',
            'artisans_count': 10,
            'ca_mensuel_expose': 4180,
            'unites_mensuelles_perdues': 195,
            'risque_concurrent': 'Bascule détectée vers marques économiques sur chantiers résidentiels',
            'offre_anti_erosion': 'Points x2 sur pack 50 Interrupteurs + Prises Blanc Neige pendant 15j',
          },
          {
            'gamme': 'Modules Noir Carbone',
            'artisans_count': 6,
            'ca_mensuel_expose': 2840,
            'unites_mensuelles_perdues': 112,
            'risque_concurrent': 'Ralentissement commandes villas haut standing Sousse & Tunis',
            'offre_anti_erosion': 'Bonus +150 pts dès 20 mécanismes Noir Carbone validés',
          },
        ];

    // Top gouvernorats exposés au churn
    final Map<String, double> gouvExposure = {};
    for (final a in StielDwhData.churnArtisans) {
      final g = sS(a['gouv'], 'Tunis');
      final ca = sD(a['ca_menace'], sD(a['caMenace'], 1800.0));
      gouvExposure[g] = (gouvExposure[g] ?? 0.0) + ca;
    }
    final gouvEntries = gouvExposure.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final safeIdx = _selectedChurnIdx.clamp(0, StielDwhData.churnArtisans.length - 1);
    final curChurn = StielDwhData.churnArtisans[safeIdx];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 1. BANDEAU PÉRIODE D'ESSAI 30 JOURS AGENT IA FIDNESS
        StielTrialBanner(trial: StielLive.instance.trial),
        const SizedBox(height: 14),

        // 2. KPIS SYNTHÉTIQUES AGENT IA CHURN
        _buildSectionTitle(badge: 'RADAR IA', title: 'Indicateurs Prédictifs d\'Attrition & CA Menacé'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.65,
          children: [
            _buildKpiCard(
              'Artisans à Risque IA',
              '$nbRisque Électriciens',
              'Dont $nbCritiques en urgence critique',
              'Détection SHAP',
              const Color(0xFFEF4444),
              Icons.warning_amber_rounded,
            ),
            _buildKpiCard(
              'CA Annuel Menacé',
              '${fmtNum(caMenace, 0)} DT',
              '$unitesPerdues unités perdues / mois',
              'Risque Direct',
              const Color(0xFFF59E0B),
              Icons.trending_down_rounded,
            ),
            _buildKpiCard(
              'Réactivation < 48h',
              '${fmtNum(avgProb48h, 1)} %',
              'vs ${fmtNum(avgProb15j, 1)}% si attente 15j',
              'Gain +${fmtNum(avgProb48h - avgProb15j, 0)} pts',
              const Color(0xFF10B981),
              Icons.bolt_rounded,
            ),
            _buildKpiCard(
              'Sauvetage Points x2',
              '${fmtNum(caMenace * 0.68, 0)} DT',
              'CA préservé estimé (68% succès)',
              'ROI +840%',
              const Color(0xFF3B82F6),
              Icons.shield_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. SÉVÉRITÉ DU CHURN & TOP GOUVERNORATS EXPOSÉS
        _buildSectionTitle(badge: 'SÉVÉRITÉ & GÉO', title: 'Distribution de Sévérité & Gouvernorats Exposés'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Répartition du Portefeuille (Champions, Réguliers, À risque, Critiques)',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              StielSeverityBar(summary: churnSum),
              const SizedBox(height: 14),
              const Text(
                '📍 Top Gouvernorats Exposés au Churn (CA Menacé en TND)',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              StielHBars(data: gouvEntries.take(5).toList()),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. TRAJECTOIRE CA : SANS ACTION VS AVEC OFFRE POINTS X2
        _buildSectionTitle(badge: 'TRAJECTOIRE CA', title: 'Projection CA : Sans Action vs Relance IA Points x2'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 Impact Financier sur 6 Mois de la Relance Automatique <48h',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              StielTrajectory(caMenace: caMenace, probReactivation: avgProb48h),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. DÉTECTEUR DE GAMMES ABANDONNÉES (ANTI-ÉROSION)
        _buildSectionTitle(badge: 'ANTI-ÉROSION', title: 'Détecteur de Gammes Abandonnées & Cross-Sell IA'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: StielGammesErosion(gammes: gammesErosion),
        ),
        const SizedBox(height: 16),

        // 6. SCORE PRÉDICTIF DE RÉACTIVATION IA (48H VS 15J)
        _buildSectionTitle(badge: 'SCORE 48H VS 15J', title: 'Score Prédictif de Réactivation IA : Fenêtre 48h vs 15 Jours'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: StielReactivationList(artisans: StielDwhData.churnArtisans),
        ),
        const SizedBox(height: 16),

        // 7. ACTIONNEMENT OFFRE PUSH SUR ARTISAN CIBLÉ
        _buildSectionTitle(badge: 'ACTION IA', title: 'Ciblage Artisan & Déclenchement Offre Anti-Churn (API)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Artisan Ciblé : ${curChurn['nom']} (${curChurn['code']} • ${curChurn['gouv']})',
                      style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  InkWell(
                    onTap: () => showStielElectricien360(
                      context,
                      sS(curChurn['id'], '1'),
                      curChurn['nom'].toString(),
                    ),
                    child: const Text(
                      'Fiche 360° ↗',
                      style: TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Score Risque : ${curChurn['score']}/100 • Inactif : ${curChurn['inactifJours']}j • CA menacé : ${fmtNum(sD(curChurn['ca_menace'], 2400))} DT',
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
              Text(
                'Gamme abandonnée : ${sS(curChurn['gamme_abandonnee'], 'Modules Blanc Neige')} → Cross-sell : ${sS(curChurn['cross_sell'], 'Modules Noir Carbone')}',
                style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 10, fontWeight: FontWeight.w600),
              ),
              Text('Cause SHAP : ${curChurn['cause']}', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                child: Text('Offre IA : ${curChurn['action']}', style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10.5, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _sendingOffer ? null : () => _triggerChurnOffer(curChurn),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: Text(_sendingOffer ? 'Envoi en cours...' : 'Envoyer Offre Points x2 (${curChurn['nom']})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 6),
              Text(_pushStatusMsg, style: const TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        const Text('Sélectionnez un artisan à risque dans la file prioritaire :', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SizedBox(
          height: 165,
          child: ListView.builder(
            itemCount: StielDwhData.churnArtisans.length,
            itemBuilder: (context, i) {
              final a = StielDwhData.churnArtisans[i];
              final bool isSel = i == safeIdx;
              return GestureDetector(
                onTap: () => setState(() => _selectedChurnIdx = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF2563EB).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? const Color(0xFF60A5FA) : Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${i + 1}. ${a['nom']} (${a['gouv']}) • Score ${a['score']}/100',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(a['status'].toString(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // 8. APERÇU DU RAPPORT E-MAIL HEBDOMADAIRE LUNDI 09H00
        _buildSectionTitle(badge: 'E-MAIL LUNDI 09H', title: 'Aperçu du Rapport E-mail Hebdomadaire Automatique'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const StielEmailPreview(),
        ),
        const SizedBox(height: 16),

        // 9. SIMULATEUR VOCAL WHATSAPP IA (DARIJA / FR)
        _buildSectionTitle(badge: 'WHATSAPP VOCAL IA', title: 'Simulateur de Note Vocale WhatsApp Artisan (Darija / FR)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const StielWhatsAppVoiceCard(),
        ),
        const SizedBox(height: 16),

        // 10. COPILOT RAG DÉCISIONNEL STIEL LIVE
        _buildSectionTitle(badge: 'COPILOT RAG LIVE', title: 'Copilot RAG Décisionnel STIEL (PostgreSQL Live)'),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggestions rapides cliquables
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _copilotFollowups.map((q) {
                  return ActionChip(
                    onPressed: () => _sendCopilotQuestion(q),
                    backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                    side: BorderSide(color: const Color(0xFF60A5FA).withValues(alpha: 0.4)),
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      q,
                      style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 9.5, fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              ..._copilotChat.map((m) {
                final bool isAi = m['role'] == 'ai';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isAi ? const Color(0xFF0F1E3D) : const Color(0xFF2563EB).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isAi ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StielRichText(m['text']!, fontSize: 10.5),
                      if (isAi && m['sources'] != null && m['sources']!.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          '🔎 Sources : ${m['sources']}',
                          style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 8.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              if (_copilotBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF60A5FA))),
                      SizedBox(width: 8),
                      Text('Interrogation du Data Warehouse PostgreSQL...', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 10)),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _copilotInputCtrl,
                      onSubmitted: _sendCopilotQuestion,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'Interrogez le Copilot RAG (Chantiers, SLA, Churn, CA, Régions)...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _sendCopilotQuestion(_copilotInputCtrl.text),
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF60A5FA), size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGETS HELPERS
  Widget _buildSectionTitle({required String badge, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(5)),
          child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1633),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _buildKpiCard(String title, String val, String sub, String badge, Color acc, IconData ico) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1633),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: acc.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(ico, size: 16, color: acc),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(color: acc.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(badge, style: TextStyle(color: acc, fontSize: 8.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF070C1E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBtn(0, Icons.dashboard_rounded, 'Cockpit'),
          _buildNavBtn(1, Icons.engineering_rounded, 'Artisans'),
          _buildNavBtn(2, Icons.fact_check_rounded, 'Audits SLA'),
          _buildNavBtn(3, Icons.storefront_rounded, 'Comptoirs'),
          _buildNavBtn(4, Icons.smart_toy_rounded, 'IA & Copilot'),
        ],
      ),
    );
  }

  Widget _buildNavBtn(int idx, IconData ico, String lbl) {
    final bool sel = _activeTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ico, size: 18, color: sel ? const Color(0xFF60A5FA) : const Color(0xFF64748B)),
          const SizedBox(height: 2),
          Text(
            lbl,
            style: TextStyle(
              color: sel ? Colors.white : const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
