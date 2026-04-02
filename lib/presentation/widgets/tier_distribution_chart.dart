import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Donut chart showing customer tier distribution.
/// Maps to the spending categories donut chart in the reference (3rd screen).
class TierDistributionChart extends StatelessWidget {
  const TierDistributionChart({
    super.key,
    required this.bronzeCount,
    required this.silverCount,
    required this.goldCount,
    required this.platinumCount,
  });

  final int bronzeCount;
  final int silverCount;
  final int goldCount;
  final int platinumCount;

  int get _total => bronzeCount + silverCount + goldCount + platinumCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: _total == 0
              ? Center(
                  child: Text(
                    'No customers yet',
                    style: GoogleFonts.inter(color: AppColors.textTertiary),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _buildSections(),
                        centerSpaceRadius: 52,
                        sectionsSpace: 3,
                        startDegreeOffset: -90,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_total',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Customers',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = <_TierEntry>[
      _TierEntry('Platinum', platinumCount, AppColors.platinum),
      _TierEntry('Gold', goldCount, AppColors.gold),
      _TierEntry('Silver', silverCount, AppColors.silver),
      _TierEntry('Bronze', bronzeCount, AppColors.bronze),
    ].where((e) => e.count > 0).toList();

    return entries.map((entry) {
      final pct = entry.count / _total * 100;
      return PieChartSectionData(
        color: entry.color,
        value: entry.count.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        radius: 28,
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  Widget _buildLegend() {
    final entries = <_TierEntry>[
      _TierEntry('Platinum', platinumCount, AppColors.platinum),
      _TierEntry('Gold', goldCount, AppColors.gold),
      _TierEntry('Silver', silverCount, AppColors.silver),
      _TierEntry('Bronze', bronzeCount, AppColors.bronze),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: e.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${e.name} (${e.count})',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _TierEntry {
  const _TierEntry(this.name, this.count, this.color);
  final String name;
  final int count;
  final Color color;
}
