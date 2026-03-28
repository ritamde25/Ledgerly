import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final String name;
  final double price;
  final int quantity;
  final double? baseQuantity;
  final String? quantityMetric;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
    this.baseQuantity,
    this.quantityMetric,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item copyWith({
    String? name,
    double? price,
    int? quantity,
    double? baseQuantity,
    String? quantityMetric,
  }) {
    return Item(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      quantityMetric: quantityMetric ?? this.quantityMetric,
    );
  }
}
