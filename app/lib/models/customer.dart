class Customer {
  final String id;
  final String name;
  final double totalDue;

  Customer({
    required this.id,
    required this.name,
    this.totalDue = 0.0,
  });

  Customer copyWith({double? totalDue}) {
    return Customer(
      id: id,
      name: name,
      totalDue: totalDue ?? this.totalDue,
    );
  }
}
