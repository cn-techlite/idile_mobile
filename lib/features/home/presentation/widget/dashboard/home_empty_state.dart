import 'dart:math' as math;

import 'package:idile_mobile_app/core/utils/size_config.dart';

import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:intl/intl.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    required this.name,
    required this.onRefresh,
    super.key,
    this.now,
  });

  final String name;
  final Future<void> Function() onRefresh;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.paper : AppColors.ink;
    final secondary = dark ? Colors.white60 : AppColors.muted;
    final surface = dark ? const Color(0xFF1D1A15) : AppColors.white;
    final border = dark ? Colors.white24 : AppColors.line;
    final displayName = name.trim().isEmpty
        ? 'THERE'
        : name.trim().toUpperCase();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headingSize = (constraints.maxWidth * .0825).clamp(30.0, 42.0);
          return CustomScrollView(
            key: const Key('home-empty-state'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 120),
                sliver: SliverList.list(
                  children: [
                    AppText(
                      text: 'GOOD ${_greeting(date)},\n$displayName',
                      type: AppTextType.displaySmall,
                      color: foreground,
                      fontFamily: 'Open Serif',
                      fontSize: headingSize,
                      height: .92,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.8,
                    ),
                    addVerticalSpacing(2.75),
                    AppText(
                      text: DateFormat('EEEE d MMMM').format(date),
                      type: AppTextType.titleLarge,
                      color: secondary,
                      fontSize: 20,
                    ),
                    addVerticalSpacing(2.5),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: CustomPaint(
                          foregroundPainter: _DashedRoundedBorderPainter(
                            color: border,
                            radius: 16,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(28, 54, 28, 58),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 220,
                                  height: 180,
                                  child: CustomPaint(
                                    painter: _ReadyHomePainter(
                                      lineColor: foreground,
                                    ),
                                  ),
                                ),
                                addVerticalSpacing(2.25),
                                AppText(
                                  text: 'Your space is ready when you are',
                                  type: AppTextType.headlineSmall,
                                  color: foreground,
                                  fontFamily: 'Open Serif',
                                  textAlign: TextAlign.center,
                                  fontSize: 27,
                                  height: 1.12,
                                  fontWeight: FontWeight.w900,
                                ),
                                addVerticalSpacing(2.75),
                                AppText(
                                  text: 'Add a bill, household item, or document and Ìdílé will start keeping the details together.',
                                  type: AppTextType.bodyLarge,
                                  color: secondary,
                                  textAlign: TextAlign.center,
                                  fontSize: 17,
                                  height: 1.6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _greeting(DateTime date) => date.hour < 12
    ? 'MORNING'
    : date.hour < 17
    ? 'AFTERNOON'
    : 'EVENING';

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 6, metric.length)),
          paint,
        );
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRoundedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

class _ReadyHomePainter extends CustomPainter {
  const _ReadyHomePainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final yellow = Paint()..color = AppColors.signal;
    final green = Paint()..color = AppColors.success;

    final house = Path()
      ..moveTo(size.width * .12, size.height * .48)
      ..lineTo(size.width * .5, size.height * .18)
      ..lineTo(size.width * .88, size.height * .48)
      ..moveTo(size.width * .2, size.height * .44)
      ..lineTo(size.width * .2, size.height * .84)
      ..lineTo(size.width * .8, size.height * .84)
      ..lineTo(size.width * .8, size.height * .44);
    canvas.drawPath(house, line);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .41,
        size.height * .58,
        size.width * .2,
        size.height * .26,
      ),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .31,
        size.height * .54,
        size.width * .08,
        size.height * .09,
      ),
      line,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .65,
        size.height * .54,
        size.width * .08,
        size.height * .09,
      ),
      line,
    );

    canvas.drawCircle(
      Offset(size.width * .84, size.height * .29),
      size.width * .045,
      yellow,
    );
    canvas.drawCircle(
      Offset(size.width * .93, size.height * .42),
      size.width * .022,
      Paint()..color = lineColor,
    );

    final leaf = Path()
      ..moveTo(size.width * .84, size.height * .72)
      ..quadraticBezierTo(
        size.width * .98,
        size.height * .62,
        size.width * .98,
        size.height * .5,
      )
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .54,
        size.width * .84,
        size.height * .72,
      );
    canvas.drawPath(leaf, green);

    _sparkle(canvas, Offset(size.width * .94, size.height * .18), 11, yellow);
    _sparkle(canvas, Offset(size.width * .88, size.height * .23), 6, yellow);
  }

  void _sparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final length = i.isEven ? radius : radius * .25;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * length;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ReadyHomePainter oldDelegate) =>
      lineColor != oldDelegate.lineColor;
}
