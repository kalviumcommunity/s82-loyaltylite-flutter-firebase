class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    required this.points,
    required this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final int points;
  final String tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer copyWith({
    String? name,
    String? phone,
    int? points,
    String? tier,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      tier: tier ?? this.tier,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
