/// ConditionMeter — the app's signature element.
///
/// A dual-arc radial gauge showing:
///   - outer arc: condition grade (0.0–1.0)
///   - inner arc: battery health (0.0–1.0)
///
/// Use [ConditionMeter] for large detail views and
/// [ConditionMeterCompact] for product cards.
library condition_meter;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

// ── Large meter (product detail) ──────────────────────────────────────────────

class ConditionMeter extends StatefulWidget {
  const ConditionMeter({
    super.key,
    required this.grade,
    required this.batteryHealth,
    this.size = 96,
    this.animate = true,
  });

  final ConditionGrade grade;

  /// 0.0–1.0. Pass null to hide the inner arc.
  final double? batteryHealth;

  final double size;
  final bool animate;

  @override
  State<ConditionMeter> createState() => _ConditionMeterState();
}

class _ConditionMeterState extends State<ConditionMeter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = widget.grade.color;
    const batteryColor = AppColors.secondary;

    return Semantics(
      label:
          'Condition: ${widget.grade.label}'
          '${widget.batteryHealth != null ? ', Battery: ${(widget.batteryHealth! * 100).round()}%' : ''}',
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _MeterPainter(
                conditionValue: widget.grade.meterValue * _progress.value,
                batteryValue: (widget.batteryHealth ?? 0) * _progress.value,
                showBattery: widget.batteryHealth != null,
                gradeColor: gradeColor,
                batteryColor: batteryColor,
                trackColor: AppColors.divider,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.grade.label,
                      style: TextStyle(
                        fontSize: widget.size * 0.145,
                        fontWeight: FontWeight.w700,
                        color: gradeColor,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.batteryHealth != null)
                      Text(
                        '${(widget.batteryHealth! * 100).round()}%',
                        style: TextStyle(
                          fontSize: widget.size * 0.115,
                          fontWeight: FontWeight.w600,
                          color: batteryColor,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Compact meter (product card) ──────────────────────────────────────────────

class ConditionMeterCompact extends StatelessWidget {
  const ConditionMeterCompact({
    super.key,
    required this.grade,
    this.batteryHealth,
    this.size = 48,
  });

  final ConditionGrade grade;
  final double? batteryHealth;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ConditionMeter(
      grade: grade,
      batteryHealth: batteryHealth,
      size: size,
      animate: false,
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _MeterPainter extends CustomPainter {
  _MeterPainter({
    required this.conditionValue,
    required this.batteryValue,
    required this.showBattery,
    required this.gradeColor,
    required this.batteryColor,
    required this.trackColor,
  });

  final double conditionValue; // 0–1
  final double batteryValue;   // 0–1
  final bool showBattery;
  final Color gradeColor;
  final Color batteryColor;
  final Color trackColor;

  static const double _startAngle = math.pi * 0.75;    // 135°
  static const double _sweepRange = math.pi * 1.5;     // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeOuter = size.width * 0.085;
    final strokeInner = showBattery ? size.width * 0.065 : 0.0;
    final gap = size.width * 0.05;

    final radiusOuter = (size.width / 2) - strokeOuter / 2;
    final radiusInner = showBattery
        ? radiusOuter - strokeOuter / 2 - gap - strokeInner / 2
        : 0.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeOuter;

    final conditionPaint = Paint()
      ..color = gradeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeOuter;

    // ── Outer track ──────────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radiusOuter),
      _startAngle,
      _sweepRange,
      false,
      trackPaint,
    );

    // ── Outer condition arc ──────────────────────────────────────────────────
    if (conditionValue > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radiusOuter),
        _startAngle,
        _sweepRange * conditionValue,
        false,
        conditionPaint,
      );
    }

    if (!showBattery || radiusInner <= 0) return;

    final batteryTrackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeInner;

    final batteryPaint = Paint()
      ..color = batteryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeInner;

    // ── Inner battery track ──────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radiusInner),
      _startAngle,
      _sweepRange,
      false,
      batteryTrackPaint,
    );

    // ── Inner battery arc ────────────────────────────────────────────────────
    if (batteryValue > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radiusInner),
        _startAngle,
        _sweepRange * batteryValue,
        false,
        batteryPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MeterPainter old) =>
      old.conditionValue != conditionValue ||
      old.batteryValue   != batteryValue;
}