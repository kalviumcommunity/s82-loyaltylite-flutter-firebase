import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../widgets/stat_card.dart';

class AnalyticsSummary extends StatelessWidget {
  const AnalyticsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AnalyticsProvider, _AnalyticsView>(
      selector: (_, provider) => _AnalyticsView(
        status: provider.status,
        totalCustomers: provider.data?.totalCustomers ?? 0,
        totalPoints: provider.data?.totalPoints ?? 0,
        goldOrAbove: provider.data?.goldOrAbove ?? 0,
      ),
      builder: (context, view, _) {
        switch (view.status) {
          case AnalyticsStatus.loading:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          case AnalyticsStatus.error:
            return Center(
              child: Text(
                'Failed to load analytics',
                style: GoogleFonts.inter(color: AppColors.error),
              ),
            );
          default:
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Customers',
                    value: view.totalCustomers.toString(),
                    icon: Icons.people_alt_rounded,
                    gradient: AppGradients.purpleCard,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Points',
                    value: view.totalPoints.toString(),
                    icon: Icons.stars_rounded,
                    gradient: AppGradients.goldCard,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Gold+',
                    value: view.goldOrAbove.toString(),
                    icon: Icons.diamond_rounded,
                    gradient: AppGradients.greenCard,
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

class _AnalyticsView {
  _AnalyticsView({
    required this.status,
    required this.totalCustomers,
    required this.totalPoints,
    required this.goldOrAbove,
  });

  final AnalyticsStatus status;
  final int totalCustomers;
  final int totalPoints;
  final int goldOrAbove;
}
