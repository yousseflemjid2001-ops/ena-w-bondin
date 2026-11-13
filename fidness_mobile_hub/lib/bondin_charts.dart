import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bondin_data.dart';

// ============================================================================
// 1. COURBE + HISTOGRAMME DYNAMIQUE DES INSCRIPTIONS (chart-inscriptions-evolution)
// ============================================================================
class InscriptionsComboChart extends StatelessWidget {
  const InscriptionsComboChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      width: double.infinity,
      child: CustomPaint(
        painter: _InscriptionsComboPainter(),
      ),
    );
  }
}

class _InscriptionsComboPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = BondinDwhData.inscriptionsEvolution;
    final double chartH = size.height - 26;
    final double stepX = size.width / data.length;

    // Lignes horizontales de grille
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = chartH * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final List<Offset> linePoints = [];
    for (int i = 0; i < data.length; i++) {
      final int ins = data[i]['inscrits'] as int;
      final int cumul = data[i]['cumul'] as int;
      final String label = data[i]['label'] as String;

      final double cx = (i + 0.5) * stepX;
      final double barH = (ins / 1500.0) * (chartH - 18);
      final double barTop = chartH - barH;

      // Barre mensuelle d'inscriptions
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - 11, barTop, 22, barH),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      canvas.drawRRect(
        barRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD97706), Color(0xFF7F1017)],
          ).createShader(Rect.fromLTWH(cx - 11, barTop, 22, barH)),
      );

      // Valeur au-dessus de la barre
      final valTp = TextPainter(
        text: TextSpan(
          text: '+$ins',
          style: const TextStyle(
            color: Color(0xFFFDE68A),
            fontSize: 8.8,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(cx - valTp.width / 2, barTop - 12));

      // Label du mois en bas
      final lblTp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lblTp.paint(canvas, Offset(cx - lblTp.width / 2, chartH + 6));

      // Point de la courbe cumulative (échelle max = 3000)
      final double lineY = chartH - ((cumul / 3000.0) * (chartH - 22));
      linePoints.add(Offset(cx, lineY));
    }

    // Tracé de la courbe cumulative (Émeraude)
    final path = Path()..moveTo(linePoints.first.dx, linePoints.first.dy);
    for (int i = 1; i < linePoints.length; i++) {
      path.lineTo(linePoints[i].dx, linePoints[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    for (final pt in linePoints) {
      canvas.drawCircle(pt, 3.5, Paint()..color = const Color(0xFF10B981));
      canvas.drawCircle(pt, 1.8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 2. CARTE INTERACTIVE DE TUNISIE (map-tunisie-container + map-live-ticker)
// ============================================================================
class TunisiaInteractiveMapCard extends StatefulWidget {
  final ValueChanged<String>? onSelectRegion;

  const TunisiaInteractiveMapCard({super.key, this.onSelectRegion});

  @override
  State<TunisiaInteractiveMapCard> createState() =>
      _TunisiaInteractiveMapCardState();
}

class _TunisiaInteractiveMapCardState extends State<TunisiaInteractiveMapCard> {
  String _selectedRegion = 'Grand Tunis';

  @override
  Widget build(BuildContext context) {
    final nodes = BondinDwhData.tunisiaMapNodes;
    final activeNode = nodes.firstWhere(
      (n) => n['region'] == _selectedRegion,
      orElse: () => nodes.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bandeau Ticker Live Géospatial (map-live-ticker)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.radar_rounded, size: 14, color: Color(0xFF34D399)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'LIVE GPS TICKER : Scan #${BondinDwhData.dernierScanIdLive} • ${BondinDwhData.dernierClientLive} (${BondinDwhData.dernierMontantLive.toStringAsFixed(2)} DT) à ${BondinDwhData.dernierMagasinLive}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA7F3D0),
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
            // Carte de la Tunisie avec marqueurs cliquables
            Container(
              width: 148,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1324),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TunisiaSilhouettePainter(),
                        ),
                      ),
                      ...nodes.map((node) {
                        final String reg = node['region'] as String;
                        final bool isSel = reg == _selectedRegion;
                        final Color col = node['color'] as Color;
                        final double x = (node['dx'] as double) * box.maxWidth;
                        final double y = (node['dy'] as double) * box.maxHeight;
                        return Positioned(
                          left: x - 14,
                          top: y - 14,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedRegion = reg);
                              widget.onSelectRegion?.call(reg);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: isSel ? 28 : 22,
                              height: isSel ? 28 : 22,
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: isSel ? 0.9 : 0.65),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSel ? 2.2 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: col.withValues(alpha: 0.65),
                                    blurRadius: isSel ? 12 : 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${node['pdvCount']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
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
            // Détail du Gouvernorat sélectionné + Liste des pôles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231114),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeNode['region'] as String,
                              style: const TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${activeNode['pdvCount']} PDV',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CA : ${(activeNode['ca'] as double).toStringAsFixed(1)} DT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Flux : ${activeNode['scans']} scans QR validés',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Touchez un pôle régional :',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: nodes.map((n) {
                      final String r = n['region'] as String;
                      final bool sel = r == _selectedRegion;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRegion = r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFD97706)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r,
                            style: TextStyle(
                              color: sel ? Colors.black : Colors.white70,
                              fontSize: 9.5,
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

class _TunisiaSilhouettePainter extends CustomPainter {
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
        ..color = const Color(0xFFD97706).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. COURBE COMPARATIVE ANNÉE N (2026) VS ANNÉE N-1 (2025) (chart-comparatif-yoy)
// ============================================================================
class YoYComparativeChartCard extends StatefulWidget {
  const YoYComparativeChartCard({super.key});

  @override
  State<YoYComparativeChartCard> createState() =>
      _YoYComparativeChartCardState();
}

class _YoYComparativeChartCardState extends State<YoYComparativeChartCard> {
  bool _showScans = false;

  @override
  Widget build(BuildContext context) {
    final labels = BondinDwhData.yoyLabels;
    final seriesN =
        _showScans ? BondinDwhData.yoyScans2026 : BondinDwhData.yoyCa2026;
    final seriesN1 =
        _showScans ? BondinDwhData.yoyScans2025 : BondinDwhData.yoyCa2025;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showScans
                      ? 'Fréquentation Scans (2026 vs 2025)'
                      : 'Chiffre d\'Affaires TND (2026 vs 2025)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _showScans
                      ? 'Croissance YoY : +21,4% (${BondinDwhData.totalScansLive} vs 12 390 scans)'
                      : 'Croissance YoY : +20,4% (${(BondinDwhData.totalCaTndLive / 1000).toStringAsFixed(1)}k DT vs 147,4k DT)',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildMetricBtn('CA (DT)', !_showScans, () {
                  setState(() => _showScans = false);
                }),
                const SizedBox(width: 6),
                _buildMetricBtn('Scans', _showScans, () {
                  setState(() => _showScans = true);
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 135,
          width: double.infinity,
          child: CustomPaint(
            painter: _YoYLinePainter(
              labels: labels,
              n: seriesN,
              n1: seriesN1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendLine(const Color(0xFFF59E0B), 'Année N (2026 Live)'),
            const SizedBox(width: 16),
            _buildLegendLine(
                const Color(0xFF64748B), 'Année N-1 (2025 Référence)'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF991B1B) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFFF59E0B) : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendLine(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
        ),
      ],
    );
  }
}

class _YoYLinePainter extends CustomPainter {
  final List<String> labels;
  final List<double> n;
  final List<double> n1;

  _YoYLinePainter({
    required this.labels,
    required this.n,
    required this.n1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = n.reduce(math.max) * 1.1;
    final double chartH = size.height - 22;
    final double stepX = size.width / (labels.length - 1);

    final pathN = Path();
    final pathN1 = Path();
    final fillPathN = Path();

    for (int i = 0; i < labels.length; i++) {
      final double x = i * stepX;
      final double yN = chartH - ((n[i] / maxVal) * (chartH - 12));
      final double yN1 = chartH - ((n1[i] / maxVal) * (chartH - 12));

      if (i == 0) {
        pathN.moveTo(x, yN);
        pathN1.moveTo(x, yN1);
        fillPathN.moveTo(x, chartH);
        fillPathN.lineTo(x, yN);
      } else {
        pathN.lineTo(x, yN);
        pathN1.lineTo(x, yN1);
        fillPathN.lineTo(x, yN);
      }

      if (i == labels.length - 1) {
        fillPathN.lineTo(x, chartH);
        fillPathN.close();
      }

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((x - tp.width / 2).clamp(0.0, size.width - tp.width), chartH + 5),
      );
    }

    canvas.drawPath(
      fillPathN,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.30),
            const Color(0xFF991B1B).withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      pathN1,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    canvas.drawPath(
      pathN,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(covariant _YoYLinePainter oldDelegate) =>
      oldDelegate.n != n;
}

// ============================================================================
// 4. ARBRE DE DÉCOMPOSITION STRATÉGIQUE DU CA CLIENT (PowerBI Decomposition Tree)
// ============================================================================
class StrategicDecompositionTreeCard extends StatefulWidget {
  const StrategicDecompositionTreeCard({super.key});

  @override
  State<StrategicDecompositionTreeCard> createState() =>
      _StrategicDecompositionTreeCardState();
}

class _StrategicDecompositionTreeCardState
    extends State<StrategicDecompositionTreeCard> {
  String _selectedFormat = 'Succursales (72,6%)';

  @override
  Widget build(BuildContext context) {
    final bool isSucc = _selectedFormat.startsWith('Succursales');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Racine : CA Total
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F1017), Color(0xFF3B080C)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RACINE : CA Total ENA W BONDIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${BondinDwhData.totalCaTndLive.toStringAsFixed(2)} DT (100%)',
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Niveau 1 : Choix du Format
        Row(
          children: [
            Expanded(
              child: _buildTreeBranchButton(
                title: 'Succursales (72,9%)',
                sub: '129 389 DT • Panier 36,0 DT',
                selected: isSucc,
                onTap: () =>
                    setState(() => _selectedFormat = 'Succursales (72,9%)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTreeBranchButton(
                title: 'Cafétérias (27,1%)',
                sub: '48 100 DT • Panier 4,2 DT',
                selected: !isSucc,
                onTap: () =>
                    setState(() => _selectedFormat = 'Cafétérias (27,1%)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Niveau 2 & 3 : Décomposition par Gouvernorat & Typologie Client
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isSucc
                ? [
                    const Text(
                      '↳ Décomposition Branche SUCCURSALES (Vrac & Grains) :',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTreeLeaf('1. Grand Tunis (Menzah VI, Liberté, Ariana, Marsa)',
                        '45,0% • 58 243 DT', 0.450),
                    _buildTreeLeaf(
                        '2. Le Kef (Succursale Le Kef #1 CA)', '22,0% • 28 477 DT', 0.220),
                    _buildTreeLeaf(
                        '3. Gafsa & Gabès', '31,9% • 41 286 DT', 0.319),
                    _buildTreeLeaf(
                        '   └─ Dont Profils Grossistes B2B Suspects',
                        '77,3% du volume Succursale',
                        0.773,
                        color: const Color(0xFFEF4444)),
                  ]
                : [
                    const Text(
                      '↳ Décomposition Branche CAFÉTÉRIAS (Boissons Chaudes) :',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTreeLeaf(
                        '1. Cafétéria Gafsa Ville (#1 Trafic National)',
                        '30,0% • 3 431 scans (12 391 DT)',
                        0.300),
                    _buildTreeLeaf('2. Grand Tunis (La Marsa, Liberté, Menzah VI)',
                        '47,7% • 5 463 scans (25 291 DT)', 0.477),
                    _buildTreeLeaf(
                        '3. Cafétéria Le Kef', '15,9% • 1 815 scans (7 337 DT)', 0.159),
                    _buildTreeLeaf(
                        '   └─ Dont Consommateurs Ultra-Fréquents B2C',
                        '94,2% Particuliers Fidèles',
                        0.942,
                        color: const Color(0xFF10B981)),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreeBranchButton({
    required String title,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF991B1B) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFF59E0B) : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeLeaf(
    String label,
    String val,
    double pct, {
    Color color = const Color(0xFFD97706),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 10.5),
                ),
              ),
              Text(
                val,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. GRAPHIQUE RADAR BENCHMARK 6 AXES (chart-radar-benchmark)
// ============================================================================
class RadarBenchmarkChart extends StatelessWidget {
  const RadarBenchmarkChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendDot(const Color(0xFFA855F7), 'Succursales B2B (Gros)'),
            const SizedBox(width: 14),
            _buildLegendDot(const Color(0xFF38BDF8), 'Cafétérias B2C (Détail)'),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 195,
          width: double.infinity,
          child: CustomPaint(
            painter: _RadarPolygonPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color col, String text) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RadarPolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;

    const labels = [
      'Panier (37,6 vs 4,2 DT)',
      'Scans (2,9k vs 10,1k)',
      'CA (110k vs 42k)',
      'Points (438k vs 74k)',
      'Fréquence (5,5 vs 16,9)',
      'Clients (530 vs 598)',
    ];
    const succValues = [1.0, 0.29, 1.0, 1.0, 0.33, 0.89];
    const cafeValues = [0.18, 1.0, 0.39, 0.25, 1.0, 1.0];

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 3 anneaux hexagonaux
    for (final factor in [0.35, 0.68, 1.0]) {
      final ringPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = -math.pi / 2 + (i * 2 * math.pi / 6);
        final pt = Offset(
          center.dx + radius * factor * math.cos(angle),
          center.dy + radius * factor * math.sin(angle),
        );
        if (i == 0) {
          ringPath.moveTo(pt.dx, pt.dy);
        } else {
          ringPath.lineTo(pt.dx, pt.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // Axes et étiquettes
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 6);
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, outer, gridPaint);

      final lblPos = Offset(
        center.dx + (radius + 22) * math.cos(angle),
        center.dy + (radius + 14) * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 8.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lblPos.dx - tp.width / 2, lblPos.dy - tp.height / 2));
    }

    void drawDataset(List<double> vals, Color color) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = -math.pi / 2 + (i * 2 * math.pi / 6);
        final pt = Offset(
          center.dx + radius * vals[i] * math.cos(angle),
          center.dy + radius * vals[i] * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    drawDataset(succValues, const Color(0xFFA855F7));
    drawDataset(cafeValues, const Color(0xFF38BDF8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
