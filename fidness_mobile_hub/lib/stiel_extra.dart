// ============================================================================
// ALPHA BY STIEL — WIDGETS DÉCISIONNELS AVANCÉS MOBILE (stiel_extra.dart)
// Pareto ABC • Treemap valeur • Sankey B2B • Jauges SLA/GPS • Waterfall points
// What-If • Trajectoire churn • Sévérité • Gammes abandonnées • Réactivation IA
// Cohortes • Grand Palmarès • Fiche Électricien 360° • Essai 30j • WhatsApp vocal
// (La galerie photos du dashboard web n'est volontairement PAS reprise.)
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'stiel_data.dart';
import 'stiel_live.dart';

const Color kCardBg = Color(0xFF0C1633);
const Color kBlue = Color(0xFF2563EB);
const Color kBlueLight = Color(0xFF60A5FA);
const Color kGold = Color(0xFFFDE68A);
const Color kGreen = Color(0xFF34D399);
const Color kRed = Color(0xFFF87171);
const Color kMuted = Color(0xFF94A3B8);

// ---------------------------------------------------------------------------
// Texte riche minimal : **gras** et *italique* (réponses Copilot / WhatsApp)
// ---------------------------------------------------------------------------
class StielRichText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  const StielRichText(this.text,
      {super.key, this.fontSize = 10.5, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
          text: m.group(1),
          style: const TextStyle(fontWeight: FontWeight.w900, color: kGold)));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: TextStyle(color: color, fontSize: fontSize, height: 1.4),
      ),
    );
  }
}

Widget stielCard({required Widget child, EdgeInsets? padding, Color? border}) {
  return Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: (border ?? kBlue).withValues(alpha: 0.3)),
    ),
    child: child,
  );
}

Widget stielTitle(String badge, String title, {Color color = kBlue}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Text(badge,
            style: const TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}

void _paintText(Canvas c, String t, Offset o,
    {double size = 9,
    Color color = kMuted,
    FontWeight w = FontWeight.w600,
    double maxW = 120,
    bool center = false,
    bool right = false}) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: TextStyle(color: color, fontSize: size, fontWeight: w)),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxW);
  var dx = o.dx;
  if (center) dx -= tp.width / 2;
  if (right) dx -= tp.width;
  tp.paint(c, Offset(dx, o.dy));
}

// ---------------------------------------------------------------------------
// 1. PARETO ABC
// ---------------------------------------------------------------------------
class StielParetoChart extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  const StielParetoChart({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    final list = [...articles]..sort((a, b) => sD(b['ca']).compareTo(sD(a['ca'])));
    final top = list.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 178,
          width: double.infinity,
          child: CustomPaint(painter: _ParetoPainter(top)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children: const [
            _Legend(Color(0xFF3B82F6), 'Classe A'),
            _Legend(Color(0xFFF59E0B), 'Classe B'),
            _Legend(Color(0xFF64748B), 'Classe C'),
            _Legend(Color(0xFFF87171), 'Cumul % CA'),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(top.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '${i + 1}. ${top[i]['ref']} — ${fmtNum(sD(top[i]['ca']), 0)} DT (${top[i]['classe']})',
              style: const TextStyle(color: kMuted, fontSize: 9.5),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: kMuted, fontSize: 9)),
        ],
      );
}

class _ParetoPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  _ParetoPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final total = items.fold<double>(0, (a, e) => a + sD(e['ca']));
    if (total <= 0) return;
    final maxCa = items.map((e) => sD(e['ca'])).reduce(math.max);
    const left = 4.0, bottom = 18.0, top = 14.0, right = 4.0;
    final w = size.width - left - right;
    final h = size.height - bottom - top;
    final step = w / items.length;

    // ligne 80 %
    final y80 = top + h * (1 - 0.8);
    canvas.drawLine(Offset(left, y80), Offset(size.width - right, y80),
        Paint()..color = kRed.withValues(alpha: 0.35)..strokeWidth = 1);
    _paintText(canvas, '80 %', Offset(size.width - right, y80 - 11), color: kRed, size: 8, right: true);

    double cum = 0;
    final pts = <Offset>[];
    for (int i = 0; i < items.length; i++) {
      final ca = sD(items[i]['ca']);
      final cx = left + step * (i + 0.5);
      final bh = maxCa > 0 ? ca / maxCa * h : 0.0;
      final cls = sS(items[i]['classe']);
      final col = cls == 'A'
          ? const Color(0xFF3B82F6)
          : cls == 'B'
              ? const Color(0xFFF59E0B)
              : const Color(0xFF64748B);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - step * 0.32, top + h - bh, step * 0.64, bh),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()..color = col,
      );
      cum += ca;
      pts.add(Offset(cx, top + h * (1 - cum / total)));
      _paintText(canvas, '${i + 1}', Offset(cx, top + h + 3), center: true, size: 8.5);
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, Paint()..color = kRed..style = PaintingStyle.stroke..strokeWidth = 2);
    for (final p in pts) {
      canvas.drawCircle(p, 2.6, Paint()..color = kRed);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ---------------------------------------------------------------------------
// 2. TREEMAP VALEUR HIÉRARCHIQUE (Gamme -> Référence)
// ---------------------------------------------------------------------------
class StielTreemap extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final ValueChanged<String>? onTapGamme;
  const StielTreemap({super.key, required this.articles, this.onTapGamme});

  static const _cols = [
    Color(0xFF1D4ED8),
    Color(0xFFB45309),
    Color(0xFF047857),
    Color(0xFF6D28D9),
    Color(0xFFBE185D),
    Color(0xFF0E7490),
  ];

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final a in articles) {
      groups.putIfAbsent(sS(a['gamme'], 'Autres'), () => []).add(a);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => _sum(b.value).compareTo(_sum(a.value)));
    if (entries.isEmpty) return const SizedBox.shrink();
    final total = entries.fold<double>(0, (a, e) => a + _sum(e.value));

    return SizedBox(
      height: 210,
      child: Row(
        children: List.generate(entries.length, (gi) {
          final e = entries[gi];
          final col = _cols[gi % _cols.length];
          final refs = [...e.value]..sort((a, b) => sD(b['ca']).compareTo(sD(a['ca'])));
          return Expanded(
            flex: math.max(1, (_sum(e.value) / math.max(1, total) * 1000).round()),
            child: GestureDetector(
              onTap: () => onTapGamme?.call(e.key),
              child: Container(
                margin: const EdgeInsets.all(1.5),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: col.withValues(alpha: 0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                    Text('${fmtNum(_sum(e.value))} DT',
                        style: const TextStyle(color: kGold, fontSize: 8, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Expanded(
                      child: Column(
                        children: refs.map((r) {
                          return Expanded(
                            flex: math.max(1, (sD(r['ca']) / math.max(1, _sum(e.value)) * 100).round()),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                sS(r['ref']).replaceAll('- ', '').replaceAll(' - ', ' '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  double _sum(List<Map<String, dynamic>> l) => l.fold<double>(0, (a, e) => a + sD(e['ca']));
}

// ---------------------------------------------------------------------------
// 3. SANKEY FLUX B2B (Gammes -> Commerciaux -> Typologie chantier)
// ---------------------------------------------------------------------------
class StielSankey extends StatelessWidget {
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> links;
  const StielSankey({super.key, required this.nodes, required this.links});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty || links.isEmpty) {
      return const Text('Flux B2B indisponible.', style: TextStyle(color: kMuted, fontSize: 10));
    }
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: CustomPaint(painter: _SankeyPainter(nodes, links)),
    );
  }
}

class _SankeyPainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> links;
  _SankeyPainter(this.nodes, this.links);

  static const _pal = [
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF94A3B8),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF84CC16),
    Color(0xFFA78BFA),
    Color(0xFFFB7185),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final n = nodes.length;
    final level = List<int>.filled(n, 0);
    for (int pass = 0; pass < n; pass++) {
      for (final l in links) {
        final s = sI(l['source']), t = sI(l['target']);
        if (s < n && t < n && level[t] <= level[s]) level[t] = level[s] + 1;
      }
    }
    final maxLevel = level.reduce(math.max);
    final inV = List<double>.filled(n, 0), outV = List<double>.filled(n, 0);
    for (final l in links) {
      final s = sI(l['source']), t = sI(l['target']);
      if (s >= n || t >= n) continue;
      outV[s] += sD(l['value']);
      inV[t] += sD(l['value']);
    }
    final nodeVal = List<double>.generate(n, (i) => math.max(inV[i], outV[i]));

    const nodeW = 10.0;
    const gap = 8.0;
    final colX = (size.width - nodeW - 6) / math.max(1, maxLevel);
    // échelle verticale commune
    double scale = double.infinity;
    for (int lv = 0; lv <= maxLevel; lv++) {
      final idx = [for (int i = 0; i < n; i++) if (level[i] == lv) i];
      final sum = idx.fold<double>(0, (a, i) => a + nodeVal[i]);
      final avail = size.height - gap * (idx.length - 1) - 4;
      if (sum > 0) scale = math.min(scale, avail / sum);
    }
    if (!scale.isFinite) return;

    final rect = List<Rect>.filled(n, Rect.zero);
    for (int lv = 0; lv <= maxLevel; lv++) {
      final idx = [for (int i = 0; i < n; i++) if (level[i] == lv) i];
      final used = idx.fold<double>(0, (a, i) => a + nodeVal[i] * scale) + gap * (idx.length - 1);
      double y = (size.height - used) / 2;
      for (final i in idx) {
        final h = math.max(3.0, nodeVal[i] * scale);
        rect[i] = Rect.fromLTWH(3 + colX * lv, y, nodeW, h);
        y += h + gap;
      }
    }

    final outOff = List<double>.filled(n, 0), inOff = List<double>.filled(n, 0);
    for (final l in links) {
      final s = sI(l['source']), t = sI(l['target']);
      if (s >= n || t >= n) continue;
      final v = sD(l['value']) * scale;
      final x0 = rect[s].right, x1 = rect[t].left;
      final y0 = rect[s].top + outOff[s] + v / 2;
      final y1 = rect[t].top + inOff[t] + v / 2;
      outOff[s] += v;
      inOff[t] += v;
      final path = Path()
        ..moveTo(x0, y0)
        ..cubicTo((x0 + x1) / 2, y0, (x0 + x1) / 2, y1, x1, y1);
      canvas.drawPath(
        path,
        Paint()
          ..color = _pal[s % _pal.length].withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, v),
      );
    }
    for (int i = 0; i < n; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect[i], const Radius.circular(2)),
          Paint()..color = _pal[i % _pal.length]);
      final name = sS(nodes[i]['name']);
      final isLast = level[i] == maxLevel && maxLevel > 0;
      if (isLast) {
        _paintText(canvas, name, Offset(rect[i].left - 4, rect[i].center.dy - 5),
            right: true, color: Colors.white, size: 8.5, w: FontWeight.w800, maxW: 100);
      } else {
        _paintText(canvas, name, Offset(rect[i].right + 4, rect[i].center.dy - 5),
            color: Colors.white, size: 8.5, w: FontWeight.w800, maxW: 100);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ---------------------------------------------------------------------------
// 4. JAUGES SLA / GPS / PHOTOS
// ---------------------------------------------------------------------------
class StielGaugeRow extends StatelessWidget {
  final double sla;
  final double gps;
  final double photos;
  const StielGaugeRow({super.key, required this.sla, required this.gps, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Gauge(value: sla, label: 'SLA < 48h', color: const Color(0xFF10B981))),
        Expanded(child: _Gauge(value: gps, label: 'GPS in-situ < 150m', color: const Color(0xFF3B82F6))),
        Expanded(child: _Gauge(value: photos, label: 'Conformité photos', color: const Color(0xFFF59E0B))),
      ],
    );
  }
}

class _Gauge extends StatelessWidget {
  final double value;
  final String label;
  final Color color;
  const _Gauge({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 86,
          height: 62,
          child: CustomPaint(painter: _GaugePainter(value, color)),
        ),
        Text('${value.toStringAsFixed(1)} %',
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMuted, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double v;
  final Color color;
  _GaugePainter(this.v, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height - 4);
    final r = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(rect, math.pi, math.pi, false,
        Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = 9..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, math.pi, math.pi * (v.clamp(0, 100) / 100), false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 9..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ---------------------------------------------------------------------------
// 5. WATERFALL POINTS
// ---------------------------------------------------------------------------
class StielWaterfall extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  const StielWaterfall({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    final maxV = steps.map((s) => sD(s['valeur']).abs()).reduce(math.max);
    return Column(
      children: steps.map((s) {
        final v = sD(s['valeur']);
        final type = sS(s['type']);
        final col = type == 'entree'
            ? const Color(0xFF10B981)
            : type == 'solde'
                ? const Color(0xFF3B82F6)
                : type == 'perte'
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFF59E0B);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(sS(s['etape']),
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('${v >= 0 ? '+' : ''}${fmtNum(v)} pts',
                      style: TextStyle(color: col, fontSize: 10.5, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxV > 0 ? v.abs() / maxV : 0,
                  minHeight: 7,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(col),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. SIMULATEUR WHAT-IF (appelle /api/simulate-whatif, repli local)
// ---------------------------------------------------------------------------
class StielWhatIfCard extends StatefulWidget {
  const StielWhatIfCard({super.key});
  @override
  State<StielWhatIfCard> createState() => _StielWhatIfCardState();
}

class _StielWhatIfCardState extends State<StielWhatIfCard> {
  double bareme = 1.0, prix = 1.0, marge = 0.38;
  Map<String, dynamic>? sim;
  bool busy = false;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final my = ++_seq;
    setState(() => busy = true);
    final r = await StielLive.instance.getJson(
        'simulate-whatif?bareme_factor=${bareme.toStringAsFixed(2)}&prix_factor=${prix.toStringAsFixed(2)}&marge_rate=${marge.toStringAsFixed(2)}');
    if (!mounted || my != _seq) return;
    Map<String, dynamic> s;
    if (r != null && r['simulation'] is Map) {
      s = sMap(r['simulation']);
    } else {
      final ca = StielDwhData.totalCaIncremental * prix;
      final pts = StielDwhData.pointsEnCirculation * bareme;
      final cout = pts * 0.010;
      final mg = ca * marge;
      s = {
        'ca_simule_tnd': ca,
        'marge_brute_tnd': mg,
        'points_distribues': pts,
        'cout_recompenses_tnd': cout,
        'roi_simule_ratio': cout > 0 ? mg / cout * 100 : 0,
      };
    }
    setState(() {
      sim = s;
      busy = false;
    });
  }

  Widget _slider(String label, double v, double min, double max, String txt, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
            Text(txt, style: const TextStyle(color: kGold, fontSize: 10.5, fontWeight: FontWeight.w900)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
          child: Slider(
            value: v,
            min: min,
            max: max,
            activeColor: kBlue,
            onChanged: (x) => setState(() => on(x)),
            onChangeEnd: (_) => _run(),
          ),
        ),
      ],
    );
  }

  Widget _res(String l, String v, Color c) => Expanded(
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withValues(alpha: 0.4))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l, style: const TextStyle(color: kMuted, fontSize: 8.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(v, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = sim ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _slider('Barème de points (x)', bareme, 0.5, 3.0, '${bareme.toStringAsFixed(2)}x', (x) => bareme = x),
        _slider('Prix moyen matériel (x)', prix, 0.8, 1.3, '${prix.toStringAsFixed(2)}x', (x) => prix = x),
        _slider('Taux de marge brute', marge, 0.2, 0.6, '${(marge * 100).toStringAsFixed(0)} %', (x) => marge = x),
        const SizedBox(height: 4),
        Row(children: [
          _res('CA SIMULÉ', '${fmtNum(sD(s['ca_simule_tnd']), 0)} DT', kBlueLight),
          _res('MARGE BRUTE', '${fmtNum(sD(s['marge_brute_tnd']), 0)} DT', kGreen),
        ]),
        Row(children: [
          _res('POINTS DISTRIBUÉS', fmtNum(sD(s['points_distribues'])), kGold),
          _res('COÛT RÉCOMPENSES', '${fmtNum(sD(s['cout_recompenses_tnd']), 0)} DT', kRed),
        ]),
        Row(children: [
          _res('ROI SIMULÉ', '${fmtNum(sD(s['roi_simule_ratio']), 1)} %', const Color(0xFFA78BFA)),
          _res('ÉCART ROI', s['ecart_roi'] == null ? '—' : '${sD(s['ecart_roi']) >= 0 ? '+' : ''}${fmtNum(sD(s['ecart_roi']), 1)} pts', const Color(0xFF22D3EE)),
        ]),
        if (busy) const Padding(padding: EdgeInsets.only(top: 4), child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 7. TRAJECTOIRE CA : SANS ACTION vs POINTS x2 (projection)
// ---------------------------------------------------------------------------
class StielTrajectory extends StatelessWidget {
  final double caMenace;
  final double probReactivation; // 0-100
  const StielTrajectory({super.key, required this.caMenace, required this.probReactivation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(painter: _TrajPainter(caMenace, probReactivation)),
        ),
        const SizedBox(height: 4),
        const Wrap(spacing: 12, children: [
          _Legend(Color(0xFFEF4444), 'Sans action'),
          _Legend(Color(0xFF10B981), 'Avec offre Points x2'),
        ]),
        const SizedBox(height: 2),
        const Text('Projection modélisée sur 6 mois (CA mensuel du portefeuille d\'artisans à risque).',
            style: TextStyle(color: kMuted, fontSize: 8.5)),
      ],
    );
  }
}

class _TrajPainter extends CustomPainter {
  final double ca;
  final double prob;
  _TrajPainter(this.ca, this.prob);
  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 16.0, top = 6.0;
    final w = size.width - left - 4, h = size.height - bottom - top;
    final base = math.max(1.0, ca / 6.0);
    final rec = (0.35 + prob / 100 * 0.6).clamp(0.3, 0.95);
    final sans = <double>[], avec = <double>[];
    for (int m = 0; m <= 6; m++) {
      sans.add(base * math.pow(0.82, m).toDouble());
      avec.add(m == 0 ? base : base * (math.pow(0.82, 1).toDouble() + (1 - math.pow(0.82, 1).toDouble()) * rec * math.min(1.0, m / 3.0)));
    }
    final maxV = base * 1.05;
    Offset pt(int m, double v) => Offset(left + w * m / 6, top + h * (1 - v / maxV));
    for (int g = 0; g <= 3; g++) {
      final y = top + h * g / 3;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), Paint()..color = Colors.white10);
      _paintText(canvas, fmtNum(maxV * (1 - g / 3)), Offset(left - 4, y - 5), right: true, size: 8);
    }
    for (int m = 0; m <= 6; m++) {
      _paintText(canvas, m == 0 ? 'M0' : 'M+$m', Offset(left + w * m / 6, top + h + 3), center: true, size: 8);
    }
    void draw(List<double> s, Color c) {
      final p = Path()..moveTo(pt(0, s[0]).dx, pt(0, s[0]).dy);
      for (int m = 1; m < s.length; m++) {
        p.lineTo(pt(m, s[m]).dx, pt(m, s[m]).dy);
      }
      final fill = Path.from(p)
        ..lineTo(pt(6, 0).dx, pt(6, 0).dy)
        ..lineTo(pt(0, 0).dx, pt(0, 0).dy)
        ..close();
      canvas.drawPath(fill, Paint()..color = c.withValues(alpha: 0.12));
      canvas.drawPath(p, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 2.2);
    }

    draw(sans, const Color(0xFFEF4444));
    draw(avec, const Color(0xFF10B981));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ---------------------------------------------------------------------------
// 8. SÉVÉRITÉ CHURN (barre empilée)
// ---------------------------------------------------------------------------
class StielSeverityBar extends StatelessWidget {
  final Map<String, dynamic> summary;
  const StielSeverityBar({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['Champions', sI(summary['champions']), const Color(0xFF10B981)],
      ['Réguliers', sI(summary['reguliers']), const Color(0xFF3B82F6)],
      ['À risque', sI(summary['a_risque']), const Color(0xFFF59E0B)],
      ['Critiques', sI(summary['critiques']), const Color(0xFFEF4444)],
    ];
    final total = items.fold<int>(0, (a, e) => a + (e[1] as int));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 16,
            child: Row(
              children: items.map((e) {
                final v = e[1] as int;
                if (v == 0) return const SizedBox.shrink();
                return Expanded(flex: v, child: Container(color: e[2] as Color));
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: items.map((e) {
            final v = e[1] as int;
            final pct = total > 0 ? (v / total * 100).toStringAsFixed(0) : '0';
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: e[2] as Color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('${e[0]} : $v ($pct %)', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ]);
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 9. BARRES HORIZONTALES (gouvernorats exposés, etc.)
// ---------------------------------------------------------------------------
class StielHBars extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final String unit;
  final Color color;
  const StielHBars({super.key, required this.data, this.unit = 'DT', this.color = const Color(0xFFEF4444)});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text('Aucune donnée.', style: TextStyle(color: kMuted, fontSize: 10));
    final maxV = data.map((e) => e.value).reduce(math.max);
    return Column(
      children: data.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxV > 0 ? e.value / maxV : 0,
                    minHeight: 9,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text('${fmtNum(e.value)} $unit', textAlign: TextAlign.right, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. GAMMES ABANDONNÉES
// ---------------------------------------------------------------------------
class StielGammesErosion extends StatelessWidget {
  final List<Map<String, dynamic>> gammes;
  const StielGammesErosion({super.key, required this.gammes});

  @override
  Widget build(BuildContext context) {
    if (gammes.isEmpty) return const Text('Aucune gamme en érosion détectée.', style: TextStyle(color: kMuted, fontSize: 10));
    return Column(
      children: gammes.map((g) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${sS(g['gamme'])}', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900))),
                  Text('${fmtNum(sD(g['ca_mensuel_expose']))} DT/mois', style: const TextStyle(color: kRed, fontSize: 10.5, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 3),
              Text('${sI(g['artisans_count'])} artisans • ${fmtNum(sD(g['unites_mensuelles_perdues']))} unités perdues / mois',
                  style: const TextStyle(color: kMuted, fontSize: 10)),
              Text('${sS(g['risque_concurrent'])}', style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 10)),
              const SizedBox(height: 3),
              Text('${sS(g['offre_anti_erosion'])}', style: const TextStyle(color: kGreen, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// 11. SCORE PRÉDICTIF DE RÉACTIVATION
// ---------------------------------------------------------------------------
class StielReactivationList extends StatelessWidget {
  final List<Map<String, dynamic>> artisans;
  const StielReactivationList({super.key, required this.artisans});

  @override
  Widget build(BuildContext context) {
    final list = [...artisans]..sort((a, b) => sI(b['p48']).compareTo(sI(a['p48'])));
    if (list.isEmpty) return const Text('Aucun artisan à scorer.', style: TextStyle(color: kMuted, fontSize: 10));
    return Column(
      children: list.take(8).map((a) {
        final p48 = sI(a['p48']);
        final p15 = sI(a['p15']);
        final col = p48 >= 70 ? kGreen : p48 >= 40 ? const Color(0xFFFBBF24) : kRed;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${sS(a['nom'])} • ${sS(a['gouv'])}', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                  Text(sS(a['reactLabel']), style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 3),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: p48 / 100, minHeight: 7, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(col)),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$p48 % si relance < 48h', style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.w900)),
              ]),
              Text('Sans relance rapide : $p15 % à 15 jours', style: const TextStyle(color: kMuted, fontSize: 9)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// 12. COHORTES DE RÉTENTION
// ---------------------------------------------------------------------------
class StielCohorts extends StatelessWidget {
  final List<Map<String, dynamic>> cohortes;
  const StielCohorts({super.key, required this.cohortes});

  Color _c(String v) {
    final n = sD(v, -1);
    if (n < 0) return Colors.white10;
    if (n >= 85) return const Color(0xFF10B981);
    if (n >= 75) return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    if (cohortes.isEmpty) return const Text('Aucune cohorte disponible.', style: TextStyle(color: kMuted, fontSize: 10));
    Widget cell(String t, {Color? bg, bool head = false, double flex = 1}) => Expanded(
          flex: (flex * 10).round(),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: bg ?? Colors.transparent, borderRadius: BorderRadius.circular(5)),
            child: Text(t, textAlign: TextAlign.center, style: TextStyle(color: head ? kMuted : Colors.white, fontSize: 9.5, fontWeight: head ? FontWeight.w800 : FontWeight.w900)),
          ),
        );
    return Column(
      children: [
        Row(children: [cell('Cohorte', head: true, flex: 1.8), cell('Inscrits', head: true), cell('M0', head: true), cell('M1', head: true), cell('M2', head: true), cell('M3', head: true), cell('M4', head: true)]),
        ...cohortes.map((c) => Row(children: [
              cell(sS(c['cohorte']), flex: 1.8),
              cell('${sI(c['inscrits'])}'),
              for (final k in ['m0', 'm1', 'm2', 'm3', 'm4']) cell(sS(c[k], '-'), bg: _c(sS(c[k])).withValues(alpha: 0.55)),
            ])),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 13. GRAND PALMARÈS & MATRICES DÉCISIONNELLES B2B
// ---------------------------------------------------------------------------
class StielGrandPalmares extends StatefulWidget {
  final String region; // 'Toutes Régions' ou nom du gouvernorat
  final void Function(Map<String, dynamic> electricien)? onOpenElectricien;
  const StielGrandPalmares({super.key, required this.region, this.onOpenElectricien});
  @override
  State<StielGrandPalmares> createState() => _StielGrandPalmaresState();
}

class _StielGrandPalmaresState extends State<StielGrandPalmares> {
  int _cat = 0;
  int _top = 10;

  static const _cats = [
    'Électriciens',
    'Grossistes',
    'Best-Sellers',
    'Commerciaux SLA',
    'Régions Leaders',
    'Risque Churn IA',
    'Cadeaux Convoités',
  ];

  bool _inRegion(String r) {
    if (widget.region == 'Toutes Régions') return true;
    return r.toLowerCase().contains(widget.region.toLowerCase());
  }

  List<Map<String, dynamic>> _rows() {
    final out = <Map<String, dynamic>>[];
    switch (_cat) {
      case 0:
        for (final e in StielDwhData.palmaresElectriciens.where((e) => _inRegion(sS(e['region'])))) {
          out.add({'t': sS(e['nom']), 's': '${e['region']} • ${e['tier']}', 'v': '${fmtNum(sD(e['points']))} pts', 'v2': '${e['chantiers']} chantiers', 'e': e});
        }
        break;
      case 1:
        for (final d in StielDwhData.distributeurs.where((d) => _inRegion(sS(d['ville'])))) {
          out.add({'t': sS(d['nom']), 's': '${d['ville']} • ${d['tier']}', 'v': '${fmtNum(sD(d['ca']))} DT', 'v2': '${d['artisans']} artisans'});
        }
        break;
      case 2:
        for (final a in StielDwhData.topArticles) {
          out.add({'t': sS(a['ref']), 's': '${a['gamme']} • Classe ${a['classe']}', 'v': '${fmtNum(sD(a['ca']), 0)} DT', 'v2': '${fmtNum(sD(a['vol']))} unités'});
        }
        break;
      case 3:
        final c = [...StielDwhData.palmaresCommerciaux]..sort((a, b) => sI(b['valides']).compareTo(sI(a['valides'])));
        for (final x in c) {
          out.add({'t': sS(x['nom']), 's': '${x['region']} • SLA ${x['sla']}h', 'v': '${x['valides']}/${x['chantiers']} validés', 'v2': '${x['insitu']}% in-situ'});
        }
        break;
      case 4:
        final g = [...StielDwhData.gouvernorats]..sort((a, b) => sD(b['ca']).compareTo(sD(a['ca'])));
        for (final x in g.where((x) => _inRegion(sS(x['gouv'])))) {
          out.add({'t': sS(x['gouv']), 's': '${x['chantiers']} chantiers', 'v': '${fmtNum(sD(x['ca']), 0)} DT', 'v2': '${fmtNum(sD(x['points']))} pts'});
        }
        break;
      case 5:
        final c = [...StielDwhData.churnArtisans]..sort((a, b) => sI(b['score']).compareTo(sI(a['score'])));
        for (final x in c.where((x) => _inRegion(sS(x['gouv'])))) {
          out.add({'t': sS(x['nom']), 's': '${x['gouv']} • ${x['inactifJours']}j inactif', 'v': 'Score ${x['score']}/100', 'v2': '${fmtNum(sD(x['ca_menace']))} DT menacés'});
        }
        break;
      case 6:
        final c = [...StielDwhData.cadeauxLive]..sort((a, b) => sI(b['demandes']).compareTo(sI(a['demandes'])));
        for (final x in c) {
          out.add({'t': sS(x['titre']), 's': '${fmtNum(sD(x['cout_points']))} pts • ${x['stock']}', 'v': '${x['demandes']} demandes', 'v2': ''});
        }
        break;
    }
    return out;
  }

  String _csv(List<Map<String, dynamic>> rows) {
    final b = StringBuffer('Rang;Libellé;Détail;Valeur;Complément\n');
    for (int i = 0; i < rows.length; i++) {
      b.writeln('${i + 1};${rows[i]['t']};${rows[i]['s']};${rows[i]['v']};${rows[i]['v2']}');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final all = _rows();
    final rows = all.take(_top).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(_cats[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _cat == i ? Colors.white : kMuted)),
              selected: _cat == i,
              selectedColor: kBlue,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              visualDensity: VisualDensity.compact,
              onSelected: (_) => setState(() => _cat = i),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Afficher :', style: TextStyle(color: kMuted, fontSize: 10)),
            const SizedBox(width: 6),
            for (final n in [10, 20, 50, 9999])
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () => setState(() => _top = n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _top == n ? kBlue : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(n == 9999 ? 'Tous' : 'Top $n', style: TextStyle(color: _top == n ? Colors.white : kMuted, fontSize: 9.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _csv(rows)));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Palmarès copié (format CSV)')));
              },
              child: const Row(children: [
                Icon(Icons.copy_rounded, size: 12, color: kBlueLight),
                SizedBox(width: 3),
                Text('CSV', style: TextStyle(color: kBlueLight, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text('Aucun résultat pour ce filtre.', style: TextStyle(color: kMuted, fontSize: 10.5)),
          ),
        ...List.generate(rows.length, (i) {
          final r = rows[i];
          final medal = i == 0 ? '' : i == 1 ? '' : i == 2 ? '' : '${i + 1}';
          return GestureDetector(
            onTap: r['e'] != null ? () => widget.onOpenElectricien?.call(r['e'] as Map<String, dynamic>) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  SizedBox(width: 26, child: Text(medal, style: const TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.w900))),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sS(r['t']), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                        Text(sS(r['s']), style: const TextStyle(color: kMuted, fontSize: 9.5), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(sS(r['v']), style: const TextStyle(color: kGold, fontSize: 10.5, fontWeight: FontWeight.w900)),
                      if (sS(r['v2']).isNotEmpty) Text(sS(r['v2']), style: const TextStyle(color: kBlueLight, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        Text('${rows.length} affichés sur ${all.length}', style: const TextStyle(color: kMuted, fontSize: 9)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 14. FICHE ÉLECTRICIEN 360° (bottom sheet, sans galerie photos)
// ---------------------------------------------------------------------------
Future<void> showStielElectricien360(BuildContext context, String id, String nom) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF070C1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => _Electricien360Sheet(id: id, nom: nom),
  );
}

class _Electricien360Sheet extends StatefulWidget {
  final String id;
  final String nom;
  const _Electricien360Sheet({required this.id, required this.nom});
  @override
  State<_Electricien360Sheet> createState() => _Electricien360SheetState();
}

class _Electricien360SheetState extends State<_Electricien360Sheet> {
  Map<String, dynamic>? data;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    StielLive.instance.getJson('electricien/360/${widget.id}').then((r) {
      if (!mounted) return;
      setState(() {
        data = r;
        failed = r == null;
      });
    });
  }

  Widget _stat(String l, String v, Color c) => Expanded(
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withValues(alpha: 0.4))),
          child: Column(children: [
            Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w900)),
            Text(l, textAlign: TextAlign.center, style: const TextStyle(color: kMuted, fontSize: 8.5, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.85;
    return SizedBox(
      height: h,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: data == null && !failed
            ? const Center(child: CircularProgressIndicator())
            : failed
                ? Center(child: Text('Fiche 360° indisponible pour ${widget.nom}.', style: const TextStyle(color: kMuted)))
                : _body(),
      ),
    );
  }

  Widget _body() {
    final d = data!;
    final p = sMap(d['profile']);
    final st = sMap(d['statistiques']);
    final favs = sList(d['articles_favoris']);
    final chs = sList(d['chantiers']);
    return ListView(
      children: [
        Row(children: [
          const Icon(Icons.engineering_rounded, color: kBlueLight),
          const SizedBox(width: 8),
          Expanded(child: Text('Fiche 360° • ${sS(p['full_name'], widget.nom)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: kMuted)),
        ]),
        Text('${sS(p['phone'])} • ${sS(p['email'])}', style: const TextStyle(color: kMuted, fontSize: 10.5)),
        if (sS(p['parrain']).isNotEmpty) Text('Parrain : ${sS(p['parrain'])}', style: const TextStyle(color: kMuted, fontSize: 10.5)),
        Text('Commercial référent : ${sS(d['commercial_referent'])}', style: const TextStyle(color: kGold, fontSize: 10.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(children: [
          _stat('Chantiers', '${sI(st['total_chantiers'])}', kBlueLight),
          _stat('Validés', '${sI(st['chantiers_valides'])}', kGreen),
          _stat('Points cumulés', fmtNum(sD(st['total_points_cumules'])), kGold),
        ]),
        Row(children: [
          _stat('Composants posés', fmtNum(sD(st['total_composants_poses'])), const Color(0xFFA78BFA)),
          _stat('Preuves photos', '${sI(st['total_photos_fournies'])}', const Color(0xFF22D3EE)),
          _stat('Solde actuel', fmtNum(sD(p['total_points'])), kGreen),
        ]),
        const SizedBox(height: 10),
        const Text('Articles favoris', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        StielHBars(
          data: favs.map((f) => MapEntry(sS(f['article']), sD(f['quantite']))).toList(),
          unit: 'u.',
          color: kBlueLight,
        ),
        const SizedBox(height: 10),
        const Text('Historique des chantiers', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        ...chs.take(12).map((c) => Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('#${sS(c['id'])} • ${sS(c['title'], sS(c['titre'], 'Chantier'))}\n${sS(c['gouvernorat'])} • ${sS(c['created_at']).split('T').first}',
                        style: const TextStyle(color: Colors.white, fontSize: 10.5)),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${fmtNum(sD(c['total_points']))} pts', style: const TextStyle(color: kGold, fontSize: 10.5, fontWeight: FontWeight.w900)),
                    Text(sS(c['status'], sS(c['status_raw'])), style: const TextStyle(color: kGreen, fontSize: 9)),
                  ]),
                ],
              ),
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 15. ESSAI GRATUIT 30 JOURS
// ---------------------------------------------------------------------------
class StielTrialBanner extends StatelessWidget {
  final Map<String, dynamic> trial;
  const StielTrialBanner({super.key, required this.trial});

  @override
  Widget build(BuildContext context) {
    if (trial.isEmpty) return const SizedBox.shrink();
    final left = sI(trial['days_left']);
    final expired = trial['expired'] == true;
    final pct = (sD(trial['progress_pct']) / 100).clamp(0.0, 1.0);
    final col = expired ? kRed : left <= 7 ? const Color(0xFFFBBF24) : kGreen;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expired ? '⏳ Période d\'essai de 30 jours terminée' : '⏳ Essai gratuit : $left jours restants (fin le ${sS(trial['end_date'])})',
              style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(col)),
          ),
          const SizedBox(height: 4),
          Text('Jour ${sI(trial['days_elapsed'])} / ${sI(trial['days_total'], 30)} • Contact : ${sS(trial['contact'])}',
              style: const TextStyle(color: kMuted, fontSize: 9.5)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 16. APERÇU RAPPORT E-MAIL HEBDOMADAIRE (Lundi 09h00) — lecture seule
// ---------------------------------------------------------------------------
class StielEmailPreview extends StatelessWidget {
  const StielEmailPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final l = StielLive.instance;
    final s = l.agentSummary;
    final top = l.agentArtisans.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 10.5, height: 1.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Objet : Rapport hebdomadaire Club Alpha by STIEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
            const Text('Envoi : chaque lundi à 09h00 • Destinataires : Nizar & Ahmed', style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
            const Divider(),
            Text('• CA matériel incrémental : ${fmtNum(StielDwhData.totalCaIncremental, 0)} DT'),
            Text('• Chantiers : ${StielDwhData.totalChantiers} (${StielDwhData.chantiersValides} validés — ${StielDwhData.tauxValidation} %)'),
            Text('• Électriciens à risque : ${sI(s['count'])} dont ${sI(s['critiques'])} critiques'),
            Text('• CA menacé : ${fmtNum(sD(s['ca_menace']))} DT • Unités perdues / mois : ${fmtNum(sD(s['total_unites_perdues']))}'),
            const SizedBox(height: 4),
            const Text('Top 3 à relancer cette semaine :', style: TextStyle(fontWeight: FontWeight.w900)),
            ...top.map((a) => Text('  ${sI(a['score_risque'])}/100 — ${sS(a['nom'])} (${sS(a['gouvernorat'])}) : ${sS(a['offre_anti_erosion'])}')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 17. WHATSAPP VOCAL (simulation du webhook : question -> script vocal)
// ---------------------------------------------------------------------------
class StielWhatsAppVoiceCard extends StatefulWidget {
  const StielWhatsAppVoiceCard({super.key});
  @override
  State<StielWhatsAppVoiceCard> createState() => _StielWhatsAppVoiceCardState();
}

class _StielWhatsAppVoiceCardState extends State<StielWhatsAppVoiceCard> {
  final _ctrl = TextEditingController(text: 'Donne-moi le bilan des électriciens en risque critique de churn et les offres WhatsApp Points x2.');
  Map<String, dynamic>? res;
  bool busy = false;
  bool failed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    setState(() {
      busy = true;
      failed = false;
    });
    final r = await StielLive.instance.postJson('whatsapp/voice-simulate', {'query': _ctrl.text.trim()}, timeoutSec: 90);
    if (!mounted) return;
    setState(() {
      res = r;
      failed = r == null;
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          maxLines: 2,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black26,
            hintText: 'Message vocal WhatsApp (transcription)…',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          onPressed: busy ? null : _go,
          icon: busy
              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.mic_rounded, size: 14),
          label: const Text('Simuler la réponse vocale WhatsApp'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
        ),
        if (failed) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Serveur Alpha indisponible.', style: TextStyle(color: kRed, fontSize: 10))),
        if (res != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: const Color(0xFF064E3B).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(' Script vocal (${sS(res!['persona'])} • ${sS(res!['timestamp'])})', style: const TextStyle(color: kGreen, fontSize: 10, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                StielRichText(sS(res!['voice_script'], sS(res!['full_markdown']))),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 18. RAPPORT EXÉCUTIF (texte copiable)
// ---------------------------------------------------------------------------
String buildStielExecutiveReport() {
  final l = StielLive.instance;
  final k = l.kpis;
  final lk = l.lKpis;
  final ck = l.cKpis;
  final s = l.agentSummary;
  final b = StringBuffer();
  b.writeln('RAPPORT DÉCISIONNEL EXÉCUTIF — CLUB ALPHA BY STIEL');
  b.writeln('Généré le ${DateTime.now().toString().substring(0, 16)} (DWH ${l.online ? 'en direct' : 'snapshot'})');
  b.writeln('');
  b.writeln('1. DIRECTION & VENTES');
  b.writeln('• CA matériel incrémental : ${fmtNum(sD(k['total_ca_incremental'], StielDwhData.totalCaIncremental), 2)} DT');
  b.writeln('• Chantiers : ${sI(k['chantiers_total'], StielDwhData.totalChantiers)} (validés ${sI(k['chantiers_valides'], StielDwhData.chantiersValides)}, en attente ${sI(k['chantiers_en_attente'], StielDwhData.chantiersEnAttente)}) — taux ${sD(k['taux_validation'], StielDwhData.tauxValidation)} %');
  b.writeln('• Panier moyen : ${fmtNum(sD(k['panier_moyen_ca'], StielDwhData.panierMoyenCa), 2)} DT');
  b.writeln('• Marge brute : ${fmtNum(sD(k['marge_brute_tnd'], StielDwhData.margeBruteTnd), 2)} DT — ROI programme ${sD(k['roi_ratio'], StielDwhData.roiRatio)} %');
  b.writeln('• Best-seller : ${sS(k['best_seller_nom'])} (${sI(k['best_seller_volume'])} unités)');
  b.writeln('');
  b.writeln('2. AUDITS & TERRAIN');
  b.writeln('• SLA moyen : ${sD(ck['sla_moyen_global_h'], StielDwhData.slaMoyenGlobalHeures)} h — respect SLA ${sD(ck['taux_respect_sla'])} %');
  b.writeln('• GPS in-situ : ${sD(ck['taux_insitu_global'])} % — conformité photos ${sD(ck['taux_conformite_photos'], StielDwhData.tauxConformitePhotos)} %');
  b.writeln('• Alertes actives : GPS ${sI(ck['alertes_gps_actives'])} / SLA ${sI(ck['alertes_sla_actives'])}');
  b.writeln('');
  b.writeln('3. RÉSEAU & FIDÉLITÉ');
  b.writeln('• Électriciens : ${sI(lk['total_electriciens'], StielDwhData.totalElectriciens)} (actifs ${sI(lk['mau_actifs'], StielDwhData.mauActifs)}, activation ${sD(lk['taux_activation'])} %)');
  b.writeln('• Points en circulation : ${fmtNum(sD(lk['total_points_circulation'], StielDwhData.pointsEnCirculation))} — passif ${fmtNum(sD(lk['passif_financier_tnd'], StielDwhData.passifFinancierTnd), 2)} DT');
  b.writeln('');
  b.writeln('4. AGENT IA CHURN');
  b.writeln('• Artisans à risque : ${sI(s['count'])} (critiques ${sI(s['critiques'])}) — CA menacé ${fmtNum(sD(s['ca_menace']))} DT');
  for (final a in l.agentArtisans.take(5)) {
    b.writeln('   - ${sS(a['nom'])} (${sS(a['gouvernorat'])}) : score ${sI(a['score_risque'])}/100 — ${sS(a['offre_anti_erosion'])}');
  }
  return b.toString();
}

Future<void> showStielExecutiveReport(BuildContext context) async {
  final txt = buildStielExecutiveReport();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF070C1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.82,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(children: [
              const Expanded(child: Text(' Rapport Décisionnel Exécutif', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txt));
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Rapport copié dans le presse-papiers')));
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copier'),
              ),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: kMuted)),
            ]),
            Expanded(child: SingleChildScrollView(child: SelectableText(txt, style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.5)))),
          ],
        ),
      ),
    ),
  );
}
