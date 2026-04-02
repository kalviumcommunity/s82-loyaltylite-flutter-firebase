import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/customer.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/circular_points_indicator.dart';
import '../widgets/customer_form_modal.dart';
import '../widgets/customer_list.dart';
import '../widgets/glass_card.dart';
import '../widgets/points_trend_chart.dart';
import '../widgets/search_bar.dart' as widgets;
import '../widgets/stat_card.dart';
import '../widgets/tier_distribution_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0; // 0 = Overview, 1 = Trends, 2 = Customers

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().refresh();
    });
  }

  void _openAddCustomer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerFormModal(),
    );
  }

  void _increment(Customer customer) {
    context.read<CustomerProvider>().updatePoints(customer: customer, delta: 10);
  }

  void _decrement(Customer customer) {
    context.read<CustomerProvider>().updatePoints(customer: customer, delta: -10);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final analytics = context.watch<AnalyticsProvider>();
    final now = DateTime.now();
    final monthYear = DateFormat('MMM yyyy').format(now);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddCustomer,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Customer'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ─── Purple Header ───
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                  decoration: BoxDecoration(
                    gradient: AppGradients.header,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LoyaltyLite',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.user?.displayName ?? auth.user?.email ?? 'Merchant',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Month selector chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              monthYear,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Logout
                      InkWell(
                        onTap: () => context.read<AuthProvider>().signOut(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Tab Selector ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TabSelector(
                    selectedIndex: _selectedTab,
                    onChanged: (idx) => setState(() => _selectedTab = idx),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ─── Tab Content ───
              if (_selectedTab == 0) ..._buildOverviewTab(analytics),
              if (_selectedTab == 1) ..._buildTrendsTab(analytics),
              if (_selectedTab == 2) ..._buildCustomersTab(customerProvider),

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════
  // Overview Tab
  // ═══════════════════════════════════
  List<Widget> _buildOverviewTab(AnalyticsProvider analytics) {
    final data = analytics.data;
    final totalCustomers = data?.totalCustomers ?? 0;
    final totalPoints = data?.totalPoints ?? 0;
    final goldOrAbove = data?.goldOrAbove ?? 0;
    final bronzeCount = (totalCustomers - goldOrAbove).clamp(0, totalCustomers);
    final silverCount = (goldOrAbove * 0.4).round();
    final goldCount = goldOrAbove - silverCount;

    return [
      // Circular indicator + stat cards
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircularPointsIndicator(
                  totalPoints: totalPoints,
                  goldCount: goldCount,
                  silverCount: silverCount,
                  bronzeCount: bronzeCount,
                  totalCustomers: totalCustomers,
                ),
                const SizedBox(height: 20),
                // Stat cards row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Customers',
                        value: totalCustomers.toString(),
                        icon: Icons.people_alt_rounded,
                        gradient: AppGradients.purpleCard,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Total Points',
                        value: totalPoints.toString(),
                        icon: Icons.stars_rounded,
                        gradient: AppGradients.goldCard,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Gold+',
                        value: goldOrAbove.toString(),
                        icon: Icons.diamond_rounded,
                        gradient: AppGradients.greenCard,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Loyalty Overview section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loyalty Overview',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _OverviewRow(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.gold,
                  label: 'Gold Members',
                  value: goldCount.toString(),
                  subtitle: 'High-value customers',
                ),
                const Divider(height: 20),
                _OverviewRow(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.silver,
                  label: 'Silver Members',
                  value: silverCount.toString(),
                  subtitle: 'Growing engagement',
                ),
                const Divider(height: 20),
                _OverviewRow(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.bronze,
                  label: 'Bronze Members',
                  value: bronzeCount.toString(),
                  subtitle: 'New customers',
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  // ═══════════════════════════════════
  // Trends Tab
  // ═══════════════════════════════════
  List<Widget> _buildTrendsTab(AnalyticsProvider analytics) {
    final data = analytics.data;
    final totalCustomers = data?.totalCustomers ?? 0;
    final goldOrAbove = data?.goldOrAbove ?? 0;
    final bronzeCount = (totalCustomers - goldOrAbove).clamp(0, totalCustomers);
    final silverCount = (goldOrAbove * 0.4).round();
    final goldCount = goldOrAbove - silverCount;
    final platinumCount = 0;

    return [
      // Points Trend Chart
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points Activity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const PointsTrendChart(),
              ],
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Tier Distribution
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tier Distribution',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TierDistributionChart(
                  bronzeCount: bronzeCount,
                  silverCount: silverCount,
                  goldCount: goldCount,
                  platinumCount: platinumCount,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  // ═══════════════════════════════════
  // Customers Tab
  // ═══════════════════════════════════
  List<Widget> _buildCustomersTab(CustomerProvider customerProvider) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgets.SearchBar(
                  onChanged: customerProvider.setSearchQuery,
                  hintText: 'Search customers',
                ),
                const SizedBox(height: 12),
                Text(
                  'Recent Customers',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 400,
              child: CustomerList(
                stream: customerProvider.customersStream(),
                onIncrement: _increment,
                onDecrement: _decrement,
                onDelete: (id) => customerProvider.deleteCustomer(id),
                onEndReached: () {
                  customerProvider
                      .setLimit(customerProvider.limit + AppConstants.defaultPageSize);
                },
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

// ─── Tab Selector Widget ───
class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selectedIndex, required this.onChanged});
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Overview', 'Trends', 'Customers'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Overview Row ───
class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
