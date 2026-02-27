import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analytics_provider.dart';

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
            return const LinearProgressIndicator(minHeight: 3);
          case AnalyticsStatus.error:
            return const Text('Failed to load analytics');
          default:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(label: 'Customers', value: view.totalCustomers.toString()),
                _StatCard(label: 'Points', value: view.totalPoints.toString()),
                _StatCard(label: 'Gold+', value: view.goldOrAbove.toString()),
              ],
            );
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
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
