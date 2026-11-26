import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/colors.dart';

class MarikinaMapCanvas extends StatelessWidget {
  final List<FloodZone> zones;
  final String? selectedZoneId;
  final bool isLiveRiskMode;
  final Function(FloodZone)? onZoneTap;
  final bool showSavedHomePin;
  final bool showPendingPin;
  final bool showUserLocation;
  final String? customPinLabel;
  final VoidCallback? onRecenter;

  const MarikinaMapCanvas({
    super.key,
    required this.zones,
    this.selectedZoneId,
    required this.isLiveRiskMode,
    this.onZoneTap,
    this.showSavedHomePin = true,
    this.showPendingPin = false,
    this.showUserLocation = true,
    this.customPinLabel,
    this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Base Canvas Map
          CustomPaint(
            size: Size.infinite,
            painter: _MarikinaMapPainter(
              zones: zones,
              selectedZoneId: selectedZoneId,
              isLiveRiskMode: isLiveRiskMode,
            ),
          ),

          // Clickable hotspots over zones
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // Tumana hotspot
                    Positioned(
                      left: w * 0.32,
                      top: h * 0.20,
                      width: w * 0.34,
                      height: h * 0.26,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final z = zones.firstWhere((x) => x.id == 'tumana', orElse: () => zones[0]);
                          onZoneTap?.call(z);
                        },
                      ),
                    ),

                    // Concepcion Uno hotspot
                    Positioned(
                      left: w * 0.58,
                      top: h * 0.46,
                      width: w * 0.38,
                      height: h * 0.28,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final z = zones.firstWhere((x) => x.id == 'concepcion', orElse: () => zones[0]);
                          onZoneTap?.call(z);
                        },
                      ),
                    ),

                    // Sto. Nino hotspot
                    Positioned(
                      left: w * 0.26,
                      top: h * 0.60,
                      width: w * 0.30,
                      height: h * 0.24,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final z = zones.firstWhere((x) => x.id == 'sto_nino', orElse: () => zones[0]);
                          onZoneTap?.call(z);
                        },
                      ),
                    ),

                    // Saved Home Pin in Tumana
                    if (showSavedHomePin && !showPendingPin && customPinLabel == null)
                      Positioned(
                        left: w * 0.44,
                        top: h * 0.29,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(Icons.home, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Pending Pin in Tumana
                    if (showPendingPin)
                      Positioned(
                        left: w * 0.44,
                        top: h * 0.28,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.pendingText,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(Icons.access_time_filled, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pendingText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Custom/Report Pin
                    if (customPinLabel != null)
                      Positioned(
                        left: w * 0.44,
                        top: h * 0.28,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              customPinLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // User live position pulse dot
                    if (showUserLocation)
                      Positioned(
                        left: w * 0.65,
                        top: h * 0.42,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Scale indicator bottom-left
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Text(
                          'Illustrative map · 200 m',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    // Re-center Floating button bottom-right
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: InkWell(
                        onTap: onRecenter,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: AppColors.primaryTeal,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MarikinaMapPainter extends CustomPainter {
  final List<FloodZone> zones;
  final String? selectedZoneId;
  final bool isLiveRiskMode;

  _MarikinaMapPainter({
    required this.zones,
    required this.selectedZoneId,
    required this.isLiveRiskMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background Map Canvas (Light grey/green land)
    final bgPaint = Paint()..color = const Color(0xFFEFF5F1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw Marikina River
    final riverPaint = Paint()
      ..color = const Color(0xFFB3D9EA)
      ..strokeWidth = size.width * 0.16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(size.width * 0.35, -20);
    riverPath.cubicTo(
      size.width * 0.22,
      size.height * 0.20,
      size.width * 0.15,
      size.height * 0.50,
      size.width * 0.18,
      size.height + 20,
    );
    canvas.drawPath(riverPath, riverPaint);

    // River label
    _drawAngledText(
      canvas,
      'Marikina River',
      Offset(size.width * 0.11, size.height * 0.30),
      -0.65,
      const TextStyle(fontSize: 10, color: Color(0xFF6B8A99), fontStyle: FontStyle.italic),
    );

    // 3. Draw Road Network (Light white / cream grid lines)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.32), Offset(size.width, size.height * 0.38), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.54), Offset(size.width, size.height * 0.52), roadPaint);

    // Vertical / diagonal roads
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.32, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.58, 0), Offset(size.width * 0.52, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.72, 0), Offset(size.width * 0.68, size.height), roadPaint);

    // Road text labels
    _drawAngledText(
      canvas,
      'J. P. Rizal St.',
      Offset(size.width * 0.66, size.height * 0.30),
      0.0,
      const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
    );

    _drawAngledText(
      canvas,
      'Bayan-Bayanan Ave.',
      Offset(size.width * 0.65, size.height * 0.80),
      0.0,
      const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
    );

    // 4. Draw Polygons for each zone
    for (final zone in zones) {
      if (zone.polygonPoints.isEmpty) continue;

      final path = Path();
      for (int i = 0; i < zone.polygonPoints.length; i++) {
        final pt = zone.polygonPoints[i];
        final dx = pt[0] * size.width;
        final dy = pt[1] * size.height;
        if (i == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      path.close();

      // Determine level based on mode
      final level = isLiveRiskMode ? zone.liveRiskLevel : zone.hazardLevel;

      Color fillColor;
      Color strokeColor;

      switch (level) {
        case RiskLevel.high:
          fillColor = AppColors.riskHighFill;
          strokeColor = const Color(0xFFC62828);
          break;
        case RiskLevel.medium:
          fillColor = AppColors.riskMediumFill;
          strokeColor = const Color(0xFFC66900);
          break;
        case RiskLevel.low:
          fillColor = AppColors.riskLowFill;
          strokeColor = const Color(0xFF2E7D32);
          break;
      }

      // Fill polygon
      final polyFillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, polyFillPaint);

      // Stroke polygon (dashed in hazard mode, solid in live mode)
      final polyStrokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = (zone.id == selectedZoneId) ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      if (!isLiveRiskMode) {
        // Dashed boundary for long-term hazard
        _drawDashedPath(canvas, path, polyStrokePaint, dashWidth: 5, dashSpace: 4);
      } else {
        canvas.drawPath(path, polyStrokePaint);
      }

      // Draw Zone Name Label in center
      _drawZoneCenterLabel(canvas, zone, size);
    }
  }

  void _drawZoneCenterLabel(Canvas canvas, FloodZone zone, Size size) {
    double cx = 0;
    double cy = 0;
    switch (zone.id) {
      case 'tumana':
        cx = size.width * 0.48;
        cy = size.height * 0.28;
        break;
      case 'concepcion':
        cx = size.width * 0.75;
        cy = size.height * 0.56;
        break;
      case 'sto_nino':
        cx = size.width * 0.40;
        cy = size.height * 0.72;
        break;
      default:
        cx = size.width * 0.5;
        cy = size.height * 0.5;
    }

    final textSpan = TextSpan(
      text: zone.shortName,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  void _drawAngledText(
      Canvas canvas, String text, Offset offset, double angle, TextStyle style) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, {required double dashWidth, required double dashSpace}) {
    for (final metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        final end = start + dashWidth;
        final extractPath = metric.extractPath(start, end.clamp(0.0, metric.length));
        canvas.drawPath(extractPath, paint);
        start = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarikinaMapPainter oldDelegate) {
    return oldDelegate.selectedZoneId != selectedZoneId ||
        oldDelegate.isLiveRiskMode != isLiveRiskMode ||
        oldDelegate.zones != zones;
  }
}
