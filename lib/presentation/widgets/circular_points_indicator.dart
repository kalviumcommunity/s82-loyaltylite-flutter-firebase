import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Circular ring chart showing total loyalty points, inspired by the
/// reference budget indicator. Segments represent tier distribution.
class CircularPointsIndicator extends StatefulWidget {
  const CircularPointsIndicator({
    super.key,
    required this.totalPoints,
    required this.goldCount,
    required this.silverCount,
    required this.bronzeCount,
    required this.totalCustomers,
  });

  final int totalPoints;
  final int goldCount;
  final int silverCount;
  final int bronzeCount;
  final int totalCustomers;

  @override
  State<CircularPointsIndicator> createState() => _CircularPointsIndicatorState();
}

class _CircularPointsIndicatorState extends State<CircularPointsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.goldCount + widget.silverCount + widget.bronzeCount;
    final platinumCount = widget.totalCustomers - total;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _animation.value,
              gold: widget.goldCount,
              silver: widget.silverCount,
              bronze: widget.bronzeCount,
              platinum: platinumCount > 0 ? platinumCount : 0,
              total: widget.totalCustomers,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    '${(widget.totalPoints * _animation.value).toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Points',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.platinum,
    required this.total,
  });

  final double progress;
  final int gold;
  final int silver;
  final int bronze;
  final int platinum;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (total == 0) return;

    final segments = <_Segment>[
      _Segment(bronze, AppColors.bronze),
      _Segment(silver, AppColors.silver),
      _Segment(gold, AppColors.gold),
      _Segment(platinum, AppColors.platinum),
    ].where((s) => s.count > 0).toList();

    double startAngle = -pi / 2;
    const gap = 0.04; // gap between segments

    for (final segment in segments) {
      final sweepAngle = (segment.count / total) * 2 * pi * progress - gap;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Segment {
  const _Segment(this.count, this.color);
  final int count;
  final Color color;
}
