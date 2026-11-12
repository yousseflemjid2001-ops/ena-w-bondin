// ============================================================================
// ALPHA BY STIEL — GRAPHIQUES VECTORIELS NATIFS FLUTTER (stiel_charts.dart)
// Carte des Chantiers en Tunisie • Funnel d'Audit Terrain • Waterfall Points
// ============================================================================

import 'package:flutter/material.dart';
import 'stiel_data.dart';

// 1. CARTE INTERACTIVE DES CHANTIERS DE TUNISIE (STIEL B2B)
class StielTunisiaMapCard extends StatefulWidget {
  final ValueChanged<String>? onSelectGouv;
  const StielTunisiaMapCard({super.key, this.onSelectGouv});

  @override
  State<StielTunisiaMapCard> createState() => _StielTunisiaMapCardState();
}

class _StielTunisiaMapCardState extends State<StielTunisiaMapCard> {
  String _selectedGouv = 'Grand Tunis';

  @override
  Widget build(BuildContext context) {
    final nodes = StielDwhData.gouvernorats;
    final activeNode = nodes.firstWhere(
      (n) => n['gouv'] == _selectedGouv,
      orElse: () => nodes.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ticker GPS Chantiers Live
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_searching_rounded, size: 14, color: Color(0xFF60A5FA)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'GPS CHANTIERS : Dernier audit in-situ validé (Ali Ben Romdhane • 48m)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Silhouette vectorielle de la Tunisie avec marqueurs chantiers
            Container(
              width: 148,
              height: 185,
              decoration: BoxDecoration(
                color: const Color(0xFF070F21),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _StielMapSilhouettePainter(),
                        ),
                      ),
                      ...nodes.map((n) {
                        final String g = n['gouv'] as String;
                        final bool isSel = g == _selectedGouv;
                        final Color col = n['color'] as Color;
                        final double x = (n['dx'] as double) * box.maxWidth;
                        final double y = (n['dy'] as double) * box.maxHeight;

                        return Positioned(
                          left: x - 13,
                          top: y - 13,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedGouv = g);
                              widget.onSelectGouv?.call(g);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSel ? 26 : 20,
                              height: isSel ? 26 : 20,
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: isSel ? 0.95 : 0.7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: isSel ? 2 : 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: col.withValues(alpha: 0.6),
                                    blurRadius: isSel ? 10 : 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${n['chantiers']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Détails du pôle régional sélectionné
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1E3D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeNode['gouv'] as String,
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${activeNode['chantiers']} Chantiers',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'CA Incrémental : ${(activeNode['ca'] as double).toStringAsFixed(1)} DT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Points Émis : ${activeNode['points']} pts',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pôles régionaux : ',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: nodes.map((n) {
                      final String g = n['gouv'] as String;
                      final bool sel = g == _selectedGouv;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGouv = g),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            g,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StielMapSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mapPath = Path()
      ..moveTo(w * 0.42, h * 0.08)
      ..lineTo(w * 0.64, h * 0.09)
      ..lineTo(w * 0.74, h * 0.19)
      ..lineTo(w * 0.65, h * 0.30)
      ..lineTo(w * 0.68, h * 0.48)
      ..lineTo(w * 0.56, h * 0.64)
      ..lineTo(w * 0.70, h * 0.76)
      ..lineTo(w * 0.54, h * 0.92)
      ..lineTo(w * 0.35, h * 0.80)
      ..lineTo(w * 0.24, h * 0.62)
      ..lineTo(w * 0.30, h * 0.42)
      ..lineTo(w * 0.28, h * 0.22)
      ..close();

    canvas.drawPath(
      mapPath,
      Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.75)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      mapPath,
      Paint()
        ..color = const Color(0xFF3B82F6).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. FUNNEL D'AUDIT TERRAIN (Soumission -> Audit in-situ -> Validation -> Crédit)
class StielFunnelAuditWidget extends StatelessWidget {
  const StielFunnelAuditWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = StielDwhData.funnelAudit;

    return Column(
      children: stages.map((s) {
        final double ratio = (s['valeur'] as int) / 179.0;
        final bool isLast = s['etape'].toString().startsWith('4');

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isLast ? const Color(0xFF10B981).withValues(alpha: 0.5) : Colors.white12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s['etape'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${s['valeur']} (${s['taux']})',
                    style: TextStyle(
                      color: isLast ? const Color(0xFF34D399) : const Color(0xFFFDE68A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 5.5,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLast ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// 3. COURBE D'ÉVOLUTION MENSUELLE DES CHANTIERS STIEL
class StielEvolutionChart extends StatelessWidget {
  const StielEvolutionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(
        painter: _StielEvolutionPainter(),
      ),
    );
  }
}

class _StielEvolutionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = StielDwhData.evolutionMensuelle;
    final double chartH = size.height - 24;
    final double stepX = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final double cx = (i + 0.5) * stepX;
      final int chantiers = data[i]['chantiers'] as int;
      final String mois = data[i]['mois'] as String;

      final double barH = (chantiers / 42.0) * (chartH - 15);
      final double barTop = chartH - barH;

      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - 9, barTop, 18, barH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      canvas.drawRRect(
        barRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          ).createShader(Rect.fromLTWH(cx - 9, barTop, 18, barH)),
      );

      final valTp = TextPainter(
        text: TextSpan(
          text: '$chantiers',
          style: const TextStyle(
            color: Color(0xFF93C5FD),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(cx - valTp.width / 2, barTop - 11));

      final lblTp = TextPainter(
        text: TextSpan(
          text: mois.replaceAll(' 26', ''),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lblTp.paint(canvas, Offset(cx - lblTp.width / 2, chartH + 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
