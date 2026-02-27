class Analytics {
  const Analytics({
    required this.totalCustomers,
    required this.totalPoints,
    required this.goldOrAbove,
    required this.updatedAt,
  });

  final int totalCustomers;
  final int totalPoints;
  final int goldOrAbove;
  final DateTime updatedAt;
}
