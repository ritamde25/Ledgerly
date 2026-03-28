// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      baseQuantity: (json['baseQuantity'] as num?)?.toDouble(),
      quantityMetric: json['quantityMetric'] as String?,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
      'baseQuantity': instance.baseQuantity,
      'quantityMetric': instance.quantityMetric,
    };
