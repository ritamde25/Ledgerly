// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalDueMeta =
      const VerificationMeta('totalDue');
  @override
  late final GeneratedColumn<double> totalDue = GeneratedColumn<double>(
      'total_due', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: Constant(0));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, totalDue, userId, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('total_due')) {
      context.handle(_totalDueMeta,
          totalDue.isAcceptableOrUnknown(data['total_due']!, _totalDueMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      totalDue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_due'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;
  final String phone;
  final double totalDue;
  final String? userId;
  final bool isSynced;
  const Customer(
      {required this.id,
      required this.name,
      required this.phone,
      required this.totalDue,
      this.userId,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['total_due'] = Variable<double>(totalDue);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      totalDue: Value(totalDue),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      isSynced: Value(isSynced),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      totalDue: serializer.fromJson<double>(json['totalDue']),
      userId: serializer.fromJson<String?>(json['userId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'totalDue': serializer.toJson<double>(totalDue),
      'userId': serializer.toJson<String?>(userId),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Customer copyWith(
          {int? id,
          String? name,
          String? phone,
          double? totalDue,
          Value<String?> userId = const Value.absent(),
          bool? isSynced}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        totalDue: totalDue ?? this.totalDue,
        userId: userId.present ? userId.value : this.userId,
        isSynced: isSynced ?? this.isSynced,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      totalDue: data.totalDue.present ? data.totalDue.value : this.totalDue,
      userId: data.userId.present ? data.userId.value : this.userId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('totalDue: $totalDue, ')
          ..write('userId: $userId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, totalDue, userId, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.totalDue == this.totalDue &&
          other.userId == this.userId &&
          other.isSynced == this.isSynced);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<double> totalDue;
  final Value<String?> userId;
  final Value<bool> isSynced;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.totalDue = const Value.absent(),
    this.userId = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.totalDue = const Value.absent(),
    this.userId = const Value.absent(),
    this.isSynced = const Value.absent(),
  })  : name = Value(name),
        phone = Value(phone);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<double>? totalDue,
    Expression<String>? userId,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (totalDue != null) 'total_due': totalDue,
      if (userId != null) 'user_id': userId,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  CustomersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<double>? totalDue,
      Value<String?>? userId,
      Value<bool>? isSynced}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalDue: totalDue ?? this.totalDue,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (totalDue.present) {
      map['total_due'] = Variable<double>(totalDue.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('totalDue: $totalDue, ')
          ..write('userId: $userId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $BaseInventoryItemsTable extends BaseInventoryItems
    with TableInfo<$BaseInventoryItemsTable, BaseInventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaseInventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultPriceMeta =
      const VerificationMeta('defaultPrice');
  @override
  late final GeneratedColumn<double> defaultPrice = GeneratedColumn<double>(
      'default_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _yoloLabelMeta =
      const VerificationMeta('yoloLabel');
  @override
  late final GeneratedColumn<String> yoloLabel = GeneratedColumn<String>(
      'yolo_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseQuantityMeta =
      const VerificationMeta('baseQuantity');
  @override
  late final GeneratedColumn<double> baseQuantity = GeneratedColumn<double>(
      'base_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _quantityMetricMeta =
      const VerificationMeta('quantityMetric');
  @override
  late final GeneratedColumn<String> quantityMetric = GeneratedColumn<String>(
      'quantity_metric', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pcs'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        defaultPrice,
        yoloLabel,
        baseQuantity,
        quantityMetric,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'base_inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<BaseInventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_price')) {
      context.handle(
          _defaultPriceMeta,
          defaultPrice.isAcceptableOrUnknown(
              data['default_price']!, _defaultPriceMeta));
    } else if (isInserting) {
      context.missing(_defaultPriceMeta);
    }
    if (data.containsKey('yolo_label')) {
      context.handle(_yoloLabelMeta,
          yoloLabel.isAcceptableOrUnknown(data['yolo_label']!, _yoloLabelMeta));
    } else if (isInserting) {
      context.missing(_yoloLabelMeta);
    }
    if (data.containsKey('base_quantity')) {
      context.handle(
          _baseQuantityMeta,
          baseQuantity.isAcceptableOrUnknown(
              data['base_quantity']!, _baseQuantityMeta));
    }
    if (data.containsKey('quantity_metric')) {
      context.handle(
          _quantityMetricMeta,
          quantityMetric.isAcceptableOrUnknown(
              data['quantity_metric']!, _quantityMetricMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BaseInventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaseInventoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      defaultPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}default_price'])!,
      yoloLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}yolo_label'])!,
      baseQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_quantity'])!,
      quantityMetric: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}quantity_metric'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $BaseInventoryItemsTable createAlias(String alias) {
    return $BaseInventoryItemsTable(attachedDatabase, alias);
  }
}

class BaseInventoryItem extends DataClass
    implements Insertable<BaseInventoryItem> {
  final int id;
  final String name;
  final double defaultPrice;
  final String yoloLabel;
  final double baseQuantity;
  final String quantityMetric;
  final DateTime? updatedAt;
  const BaseInventoryItem(
      {required this.id,
      required this.name,
      required this.defaultPrice,
      required this.yoloLabel,
      required this.baseQuantity,
      required this.quantityMetric,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['default_price'] = Variable<double>(defaultPrice);
    map['yolo_label'] = Variable<String>(yoloLabel);
    map['base_quantity'] = Variable<double>(baseQuantity);
    map['quantity_metric'] = Variable<String>(quantityMetric);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  BaseInventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return BaseInventoryItemsCompanion(
      id: Value(id),
      name: Value(name),
      defaultPrice: Value(defaultPrice),
      yoloLabel: Value(yoloLabel),
      baseQuantity: Value(baseQuantity),
      quantityMetric: Value(quantityMetric),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BaseInventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaseInventoryItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultPrice: serializer.fromJson<double>(json['defaultPrice']),
      yoloLabel: serializer.fromJson<String>(json['yoloLabel']),
      baseQuantity: serializer.fromJson<double>(json['baseQuantity']),
      quantityMetric: serializer.fromJson<String>(json['quantityMetric']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'defaultPrice': serializer.toJson<double>(defaultPrice),
      'yoloLabel': serializer.toJson<String>(yoloLabel),
      'baseQuantity': serializer.toJson<double>(baseQuantity),
      'quantityMetric': serializer.toJson<String>(quantityMetric),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  BaseInventoryItem copyWith(
          {int? id,
          String? name,
          double? defaultPrice,
          String? yoloLabel,
          double? baseQuantity,
          String? quantityMetric,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      BaseInventoryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        defaultPrice: defaultPrice ?? this.defaultPrice,
        yoloLabel: yoloLabel ?? this.yoloLabel,
        baseQuantity: baseQuantity ?? this.baseQuantity,
        quantityMetric: quantityMetric ?? this.quantityMetric,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  BaseInventoryItem copyWithCompanion(BaseInventoryItemsCompanion data) {
    return BaseInventoryItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultPrice: data.defaultPrice.present
          ? data.defaultPrice.value
          : this.defaultPrice,
      yoloLabel: data.yoloLabel.present ? data.yoloLabel.value : this.yoloLabel,
      baseQuantity: data.baseQuantity.present
          ? data.baseQuantity.value
          : this.baseQuantity,
      quantityMetric: data.quantityMetric.present
          ? data.quantityMetric.value
          : this.quantityMetric,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaseInventoryItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('yoloLabel: $yoloLabel, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('quantityMetric: $quantityMetric, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, defaultPrice, yoloLabel,
      baseQuantity, quantityMetric, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaseInventoryItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultPrice == this.defaultPrice &&
          other.yoloLabel == this.yoloLabel &&
          other.baseQuantity == this.baseQuantity &&
          other.quantityMetric == this.quantityMetric &&
          other.updatedAt == this.updatedAt);
}

class BaseInventoryItemsCompanion extends UpdateCompanion<BaseInventoryItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> defaultPrice;
  final Value<String> yoloLabel;
  final Value<double> baseQuantity;
  final Value<String> quantityMetric;
  final Value<DateTime?> updatedAt;
  const BaseInventoryItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.yoloLabel = const Value.absent(),
    this.baseQuantity = const Value.absent(),
    this.quantityMetric = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BaseInventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double defaultPrice,
    required String yoloLabel,
    this.baseQuantity = const Value.absent(),
    this.quantityMetric = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        defaultPrice = Value(defaultPrice),
        yoloLabel = Value(yoloLabel);
  static Insertable<BaseInventoryItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? defaultPrice,
    Expression<String>? yoloLabel,
    Expression<double>? baseQuantity,
    Expression<String>? quantityMetric,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultPrice != null) 'default_price': defaultPrice,
      if (yoloLabel != null) 'yolo_label': yoloLabel,
      if (baseQuantity != null) 'base_quantity': baseQuantity,
      if (quantityMetric != null) 'quantity_metric': quantityMetric,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BaseInventoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? defaultPrice,
      Value<String>? yoloLabel,
      Value<double>? baseQuantity,
      Value<String>? quantityMetric,
      Value<DateTime?>? updatedAt}) {
    return BaseInventoryItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      yoloLabel: yoloLabel ?? this.yoloLabel,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      quantityMetric: quantityMetric ?? this.quantityMetric,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultPrice.present) {
      map['default_price'] = Variable<double>(defaultPrice.value);
    }
    if (yoloLabel.present) {
      map['yolo_label'] = Variable<String>(yoloLabel.value);
    }
    if (baseQuantity.present) {
      map['base_quantity'] = Variable<double>(baseQuantity.value);
    }
    if (quantityMetric.present) {
      map['quantity_metric'] = Variable<String>(quantityMetric.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaseInventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('yoloLabel: $yoloLabel, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('quantityMetric: $quantityMetric, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _yoloLabelMeta =
      const VerificationMeta('yoloLabel');
  @override
  late final GeneratedColumn<String> yoloLabel = GeneratedColumn<String>(
      'yolo_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseItemIdMeta =
      const VerificationMeta('baseItemId');
  @override
  late final GeneratedColumn<int> baseItemId = GeneratedColumn<int>(
      'base_item_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES base_inventory_items (id)'));
  static const VerificationMeta _isOverrideMeta =
      const VerificationMeta('isOverride');
  @override
  late final GeneratedColumn<bool> isOverride = GeneratedColumn<bool>(
      'is_override', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_override" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _baseQuantityMeta =
      const VerificationMeta('baseQuantity');
  @override
  late final GeneratedColumn<double> baseQuantity = GeneratedColumn<double>(
      'base_quantity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _quantityMetricMeta =
      const VerificationMeta('quantityMetric');
  @override
  late final GeneratedColumn<String> quantityMetric = GeneratedColumn<String>(
      'quantity_metric', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        price,
        yoloLabel,
        userId,
        baseItemId,
        isOverride,
        baseQuantity,
        quantityMetric,
        isSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('yolo_label')) {
      context.handle(_yoloLabelMeta,
          yoloLabel.isAcceptableOrUnknown(data['yolo_label']!, _yoloLabelMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('base_item_id')) {
      context.handle(
          _baseItemIdMeta,
          baseItemId.isAcceptableOrUnknown(
              data['base_item_id']!, _baseItemIdMeta));
    }
    if (data.containsKey('is_override')) {
      context.handle(
          _isOverrideMeta,
          isOverride.isAcceptableOrUnknown(
              data['is_override']!, _isOverrideMeta));
    }
    if (data.containsKey('base_quantity')) {
      context.handle(
          _baseQuantityMeta,
          baseQuantity.isAcceptableOrUnknown(
              data['base_quantity']!, _baseQuantityMeta));
    }
    if (data.containsKey('quantity_metric')) {
      context.handle(
          _quantityMetricMeta,
          quantityMetric.isAcceptableOrUnknown(
              data['quantity_metric']!, _quantityMetricMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price']),
      yoloLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}yolo_label']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      baseItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}base_item_id']),
      isOverride: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_override'])!,
      baseQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_quantity']),
      quantityMetric: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity_metric']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final int id;
  final String? name;
  final double? price;
  final String? yoloLabel;
  final String userId;
  final int? baseItemId;
  final bool isOverride;
  final double? baseQuantity;
  final String? quantityMetric;
  final bool isSynced;
  const InventoryItem(
      {required this.id,
      this.name,
      this.price,
      this.yoloLabel,
      required this.userId,
      this.baseItemId,
      required this.isOverride,
      this.baseQuantity,
      this.quantityMetric,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || yoloLabel != null) {
      map['yolo_label'] = Variable<String>(yoloLabel);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || baseItemId != null) {
      map['base_item_id'] = Variable<int>(baseItemId);
    }
    map['is_override'] = Variable<bool>(isOverride);
    if (!nullToAbsent || baseQuantity != null) {
      map['base_quantity'] = Variable<double>(baseQuantity);
    }
    if (!nullToAbsent || quantityMetric != null) {
      map['quantity_metric'] = Variable<String>(quantityMetric);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      price:
          price == null && nullToAbsent ? const Value.absent() : Value(price),
      yoloLabel: yoloLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(yoloLabel),
      userId: Value(userId),
      baseItemId: baseItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(baseItemId),
      isOverride: Value(isOverride),
      baseQuantity: baseQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(baseQuantity),
      quantityMetric: quantityMetric == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityMetric),
      isSynced: Value(isSynced),
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      price: serializer.fromJson<double?>(json['price']),
      yoloLabel: serializer.fromJson<String?>(json['yoloLabel']),
      userId: serializer.fromJson<String>(json['userId']),
      baseItemId: serializer.fromJson<int?>(json['baseItemId']),
      isOverride: serializer.fromJson<bool>(json['isOverride']),
      baseQuantity: serializer.fromJson<double?>(json['baseQuantity']),
      quantityMetric: serializer.fromJson<String?>(json['quantityMetric']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'price': serializer.toJson<double?>(price),
      'yoloLabel': serializer.toJson<String?>(yoloLabel),
      'userId': serializer.toJson<String>(userId),
      'baseItemId': serializer.toJson<int?>(baseItemId),
      'isOverride': serializer.toJson<bool>(isOverride),
      'baseQuantity': serializer.toJson<double?>(baseQuantity),
      'quantityMetric': serializer.toJson<String?>(quantityMetric),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  InventoryItem copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<double?> price = const Value.absent(),
          Value<String?> yoloLabel = const Value.absent(),
          String? userId,
          Value<int?> baseItemId = const Value.absent(),
          bool? isOverride,
          Value<double?> baseQuantity = const Value.absent(),
          Value<String?> quantityMetric = const Value.absent(),
          bool? isSynced}) =>
      InventoryItem(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        price: price.present ? price.value : this.price,
        yoloLabel: yoloLabel.present ? yoloLabel.value : this.yoloLabel,
        userId: userId ?? this.userId,
        baseItemId: baseItemId.present ? baseItemId.value : this.baseItemId,
        isOverride: isOverride ?? this.isOverride,
        baseQuantity:
            baseQuantity.present ? baseQuantity.value : this.baseQuantity,
        quantityMetric:
            quantityMetric.present ? quantityMetric.value : this.quantityMetric,
        isSynced: isSynced ?? this.isSynced,
      );
  InventoryItem copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      yoloLabel: data.yoloLabel.present ? data.yoloLabel.value : this.yoloLabel,
      userId: data.userId.present ? data.userId.value : this.userId,
      baseItemId:
          data.baseItemId.present ? data.baseItemId.value : this.baseItemId,
      isOverride:
          data.isOverride.present ? data.isOverride.value : this.isOverride,
      baseQuantity: data.baseQuantity.present
          ? data.baseQuantity.value
          : this.baseQuantity,
      quantityMetric: data.quantityMetric.present
          ? data.quantityMetric.value
          : this.quantityMetric,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('yoloLabel: $yoloLabel, ')
          ..write('userId: $userId, ')
          ..write('baseItemId: $baseItemId, ')
          ..write('isOverride: $isOverride, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('quantityMetric: $quantityMetric, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, price, yoloLabel, userId,
      baseItemId, isOverride, baseQuantity, quantityMetric, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.yoloLabel == this.yoloLabel &&
          other.userId == this.userId &&
          other.baseItemId == this.baseItemId &&
          other.isOverride == this.isOverride &&
          other.baseQuantity == this.baseQuantity &&
          other.quantityMetric == this.quantityMetric &&
          other.isSynced == this.isSynced);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItem> {
  final Value<int> id;
  final Value<String?> name;
  final Value<double?> price;
  final Value<String?> yoloLabel;
  final Value<String> userId;
  final Value<int?> baseItemId;
  final Value<bool> isOverride;
  final Value<double?> baseQuantity;
  final Value<String?> quantityMetric;
  final Value<bool> isSynced;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.yoloLabel = const Value.absent(),
    this.userId = const Value.absent(),
    this.baseItemId = const Value.absent(),
    this.isOverride = const Value.absent(),
    this.baseQuantity = const Value.absent(),
    this.quantityMetric = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.yoloLabel = const Value.absent(),
    required String userId,
    this.baseItemId = const Value.absent(),
    this.isOverride = const Value.absent(),
    this.baseQuantity = const Value.absent(),
    this.quantityMetric = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<InventoryItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<String>? yoloLabel,
    Expression<String>? userId,
    Expression<int>? baseItemId,
    Expression<bool>? isOverride,
    Expression<double>? baseQuantity,
    Expression<String>? quantityMetric,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (yoloLabel != null) 'yolo_label': yoloLabel,
      if (userId != null) 'user_id': userId,
      if (baseItemId != null) 'base_item_id': baseItemId,
      if (isOverride != null) 'is_override': isOverride,
      if (baseQuantity != null) 'base_quantity': baseQuantity,
      if (quantityMetric != null) 'quantity_metric': quantityMetric,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  InventoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? name,
      Value<double?>? price,
      Value<String?>? yoloLabel,
      Value<String>? userId,
      Value<int?>? baseItemId,
      Value<bool>? isOverride,
      Value<double?>? baseQuantity,
      Value<String?>? quantityMetric,
      Value<bool>? isSynced}) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      yoloLabel: yoloLabel ?? this.yoloLabel,
      userId: userId ?? this.userId,
      baseItemId: baseItemId ?? this.baseItemId,
      isOverride: isOverride ?? this.isOverride,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      quantityMetric: quantityMetric ?? this.quantityMetric,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (yoloLabel.present) {
      map['yolo_label'] = Variable<String>(yoloLabel.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (baseItemId.present) {
      map['base_item_id'] = Variable<int>(baseItemId.value);
    }
    if (isOverride.present) {
      map['is_override'] = Variable<bool>(isOverride.value);
    }
    if (baseQuantity.present) {
      map['base_quantity'] = Variable<double>(baseQuantity.value);
    }
    if (quantityMetric.present) {
      map['quantity_metric'] = Variable<String>(quantityMetric.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('yoloLabel: $yoloLabel, ')
          ..write('userId: $userId, ')
          ..write('baseItemId: $baseItemId, ')
          ..write('isOverride: $isOverride, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('quantityMetric: $quantityMetric, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _itemsJsonMeta =
      const VerificationMeta('itemsJson');
  @override
  late final GeneratedColumnWithTypeConverter<List<Item>, String> itemsJson =
      GeneratedColumn<String>('items_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Item>>($TransactionsTable.$converteritemsJson);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, customerId, itemsJson, totalAmount, timestamp, userId, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    context.handle(_itemsJsonMeta, const VerificationResult.success());
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      itemsJson: $TransactionsTable.$converteritemsJson.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items_json'])!),
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<Item>, String> $converteritemsJson =
      const ItemsConverter();
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int customerId;
  final List<Item> itemsJson;
  final double totalAmount;
  final DateTime timestamp;
  final String? userId;
  final bool isSynced;
  const Transaction(
      {required this.id,
      required this.customerId,
      required this.itemsJson,
      required this.totalAmount,
      required this.timestamp,
      this.userId,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    {
      map['items_json'] = Variable<String>(
          $TransactionsTable.$converteritemsJson.toSql(itemsJson));
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      itemsJson: Value(itemsJson),
      totalAmount: Value(totalAmount),
      timestamp: Value(timestamp),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      isSynced: Value(isSynced),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      itemsJson: serializer.fromJson<List<Item>>(json['itemsJson']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      userId: serializer.fromJson<String?>(json['userId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'itemsJson': serializer.toJson<List<Item>>(itemsJson),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'userId': serializer.toJson<String?>(userId),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Transaction copyWith(
          {int? id,
          int? customerId,
          List<Item>? itemsJson,
          double? totalAmount,
          DateTime? timestamp,
          Value<String?> userId = const Value.absent(),
          bool? isSynced}) =>
      Transaction(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        itemsJson: itemsJson ?? this.itemsJson,
        totalAmount: totalAmount ?? this.totalAmount,
        timestamp: timestamp ?? this.timestamp,
        userId: userId.present ? userId.value : this.userId,
        isSynced: isSynced ?? this.isSynced,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      userId: data.userId.present ? data.userId.value : this.userId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, customerId, itemsJson, totalAmount, timestamp, userId, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.itemsJson == this.itemsJson &&
          other.totalAmount == this.totalAmount &&
          other.timestamp == this.timestamp &&
          other.userId == this.userId &&
          other.isSynced == this.isSynced);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<List<Item>> itemsJson;
  final Value<double> totalAmount;
  final Value<DateTime> timestamp;
  final Value<String?> userId;
  final Value<bool> isSynced;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.userId = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required List<Item> itemsJson,
    required double totalAmount,
    this.timestamp = const Value.absent(),
    this.userId = const Value.absent(),
    this.isSynced = const Value.absent(),
  })  : customerId = Value(customerId),
        itemsJson = Value(itemsJson),
        totalAmount = Value(totalAmount);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? itemsJson,
    Expression<double>? totalAmount,
    Expression<DateTime>? timestamp,
    Expression<String>? userId,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (itemsJson != null) 'items_json': itemsJson,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (timestamp != null) 'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? customerId,
      Value<List<Item>>? itemsJson,
      Value<double>? totalAmount,
      Value<DateTime>? timestamp,
      Value<String?>? userId,
      Value<bool>? isSynced}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      itemsJson: itemsJson ?? this.itemsJson,
      totalAmount: totalAmount ?? this.totalAmount,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(
          $TransactionsTable.$converteritemsJson.toSql(itemsJson.value));
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $BaseInventoryItemsTable baseInventoryItems =
      $BaseInventoryItemsTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final CustomersDao customersDao = CustomersDao(this as AppDatabase);
  late final InventoryDao inventoryDao = InventoryDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [customers, baseInventoryItems, inventoryItems, transactions];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  required String name,
  required String phone,
  Value<double> totalDue,
  Value<String?> userId,
  Value<bool> isSynced,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<double> totalDue,
  Value<String?> userId,
  Value<bool> isSynced,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.customers.id, db.transactions.customerId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.customerId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalDue => $composableBuilder(
      column: $table.totalDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalDue => $composableBuilder(
      column: $table.totalDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get totalDue =>
      $composableBuilder(column: $table.totalDue, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function({bool transactionsRefs})> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<double> totalDue = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            totalDue: totalDue,
            userId: userId,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String phone,
            Value<double> totalDue = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            totalDue: totalDue,
            userId: userId,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CustomersTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.customerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function({bool transactionsRefs})>;
typedef $$BaseInventoryItemsTableCreateCompanionBuilder
    = BaseInventoryItemsCompanion Function({
  Value<int> id,
  required String name,
  required double defaultPrice,
  required String yoloLabel,
  Value<double> baseQuantity,
  Value<String> quantityMetric,
  Value<DateTime?> updatedAt,
});
typedef $$BaseInventoryItemsTableUpdateCompanionBuilder
    = BaseInventoryItemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> defaultPrice,
  Value<String> yoloLabel,
  Value<double> baseQuantity,
  Value<String> quantityMetric,
  Value<DateTime?> updatedAt,
});

final class $$BaseInventoryItemsTableReferences extends BaseReferences<
    _$AppDatabase, $BaseInventoryItemsTable, BaseInventoryItem> {
  $$BaseInventoryItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InventoryItemsTable, List<InventoryItem>>
      _inventoryItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryItems,
              aliasName: $_aliasNameGenerator(
                  db.baseInventoryItems.id, db.inventoryItems.baseItemId));

  $$InventoryItemsTableProcessedTableManager get inventoryItemsRefs {
    final manager = $$InventoryItemsTableTableManager($_db, $_db.inventoryItems)
        .filter((f) => f.baseItemId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_inventoryItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BaseInventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $BaseInventoryItemsTable> {
  $$BaseInventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultPrice => $composableBuilder(
      column: $table.defaultPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yoloLabel => $composableBuilder(
      column: $table.yoloLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> inventoryItemsRefs(
      Expression<bool> Function($$InventoryItemsTableFilterComposer f) f) {
    final $$InventoryItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryItems,
        getReferencedColumn: (t) => t.baseItemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryItemsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BaseInventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $BaseInventoryItemsTable> {
  $$BaseInventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultPrice => $composableBuilder(
      column: $table.defaultPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yoloLabel => $composableBuilder(
      column: $table.yoloLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BaseInventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaseInventoryItemsTable> {
  $$BaseInventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get defaultPrice => $composableBuilder(
      column: $table.defaultPrice, builder: (column) => column);

  GeneratedColumn<String> get yoloLabel =>
      $composableBuilder(column: $table.yoloLabel, builder: (column) => column);

  GeneratedColumn<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity, builder: (column) => column);

  GeneratedColumn<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> inventoryItemsRefs<T extends Object>(
      Expression<T> Function($$InventoryItemsTableAnnotationComposer a) f) {
    final $$InventoryItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryItems,
        getReferencedColumn: (t) => t.baseItemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.inventoryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BaseInventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BaseInventoryItemsTable,
    BaseInventoryItem,
    $$BaseInventoryItemsTableFilterComposer,
    $$BaseInventoryItemsTableOrderingComposer,
    $$BaseInventoryItemsTableAnnotationComposer,
    $$BaseInventoryItemsTableCreateCompanionBuilder,
    $$BaseInventoryItemsTableUpdateCompanionBuilder,
    (BaseInventoryItem, $$BaseInventoryItemsTableReferences),
    BaseInventoryItem,
    PrefetchHooks Function({bool inventoryItemsRefs})> {
  $$BaseInventoryItemsTableTableManager(
      _$AppDatabase db, $BaseInventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaseInventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaseInventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaseInventoryItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> defaultPrice = const Value.absent(),
            Value<String> yoloLabel = const Value.absent(),
            Value<double> baseQuantity = const Value.absent(),
            Value<String> quantityMetric = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              BaseInventoryItemsCompanion(
            id: id,
            name: name,
            defaultPrice: defaultPrice,
            yoloLabel: yoloLabel,
            baseQuantity: baseQuantity,
            quantityMetric: quantityMetric,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double defaultPrice,
            required String yoloLabel,
            Value<double> baseQuantity = const Value.absent(),
            Value<String> quantityMetric = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              BaseInventoryItemsCompanion.insert(
            id: id,
            name: name,
            defaultPrice: defaultPrice,
            yoloLabel: yoloLabel,
            baseQuantity: baseQuantity,
            quantityMetric: quantityMetric,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BaseInventoryItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({inventoryItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (inventoryItemsRefs) db.inventoryItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inventoryItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BaseInventoryItemsTableReferences
                            ._inventoryItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BaseInventoryItemsTableReferences(db, table, p0)
                                .inventoryItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.baseItemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BaseInventoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BaseInventoryItemsTable,
    BaseInventoryItem,
    $$BaseInventoryItemsTableFilterComposer,
    $$BaseInventoryItemsTableOrderingComposer,
    $$BaseInventoryItemsTableAnnotationComposer,
    $$BaseInventoryItemsTableCreateCompanionBuilder,
    $$BaseInventoryItemsTableUpdateCompanionBuilder,
    (BaseInventoryItem, $$BaseInventoryItemsTableReferences),
    BaseInventoryItem,
    PrefetchHooks Function({bool inventoryItemsRefs})>;
typedef $$InventoryItemsTableCreateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  Value<String?> name,
  Value<double?> price,
  Value<String?> yoloLabel,
  required String userId,
  Value<int?> baseItemId,
  Value<bool> isOverride,
  Value<double?> baseQuantity,
  Value<String?> quantityMetric,
  Value<bool> isSynced,
});
typedef $$InventoryItemsTableUpdateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  Value<String?> name,
  Value<double?> price,
  Value<String?> yoloLabel,
  Value<String> userId,
  Value<int?> baseItemId,
  Value<bool> isOverride,
  Value<double?> baseQuantity,
  Value<String?> quantityMetric,
  Value<bool> isSynced,
});

final class $$InventoryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem> {
  $$InventoryItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BaseInventoryItemsTable _baseItemIdTable(_$AppDatabase db) =>
      db.baseInventoryItems.createAlias($_aliasNameGenerator(
          db.inventoryItems.baseItemId, db.baseInventoryItems.id));

  $$BaseInventoryItemsTableProcessedTableManager? get baseItemId {
    if ($_item.baseItemId == null) return null;
    final manager =
        $$BaseInventoryItemsTableTableManager($_db, $_db.baseInventoryItems)
            .filter((f) => f.id($_item.baseItemId!));
    final item = $_typedResult.readTableOrNull(_baseItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yoloLabel => $composableBuilder(
      column: $table.yoloLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOverride => $composableBuilder(
      column: $table.isOverride, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  $$BaseInventoryItemsTableFilterComposer get baseItemId {
    final $$BaseInventoryItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.baseItemId,
        referencedTable: $db.baseInventoryItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BaseInventoryItemsTableFilterComposer(
              $db: $db,
              $table: $db.baseInventoryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yoloLabel => $composableBuilder(
      column: $table.yoloLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOverride => $composableBuilder(
      column: $table.isOverride, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  $$BaseInventoryItemsTableOrderingComposer get baseItemId {
    final $$BaseInventoryItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.baseItemId,
        referencedTable: $db.baseInventoryItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BaseInventoryItemsTableOrderingComposer(
              $db: $db,
              $table: $db.baseInventoryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get yoloLabel =>
      $composableBuilder(column: $table.yoloLabel, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isOverride => $composableBuilder(
      column: $table.isOverride, builder: (column) => column);

  GeneratedColumn<double> get baseQuantity => $composableBuilder(
      column: $table.baseQuantity, builder: (column) => column);

  GeneratedColumn<String> get quantityMetric => $composableBuilder(
      column: $table.quantityMetric, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$BaseInventoryItemsTableAnnotationComposer get baseItemId {
    final $$BaseInventoryItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.baseItemId,
            referencedTable: $db.baseInventoryItems,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BaseInventoryItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.baseInventoryItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (InventoryItem, $$InventoryItemsTableReferences),
    InventoryItem,
    PrefetchHooks Function({bool baseItemId})> {
  $$InventoryItemsTableTableManager(
      _$AppDatabase db, $InventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<String?> yoloLabel = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int?> baseItemId = const Value.absent(),
            Value<bool> isOverride = const Value.absent(),
            Value<double?> baseQuantity = const Value.absent(),
            Value<String?> quantityMetric = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              InventoryItemsCompanion(
            id: id,
            name: name,
            price: price,
            yoloLabel: yoloLabel,
            userId: userId,
            baseItemId: baseItemId,
            isOverride: isOverride,
            baseQuantity: baseQuantity,
            quantityMetric: quantityMetric,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<String?> yoloLabel = const Value.absent(),
            required String userId,
            Value<int?> baseItemId = const Value.absent(),
            Value<bool> isOverride = const Value.absent(),
            Value<double?> baseQuantity = const Value.absent(),
            Value<String?> quantityMetric = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              InventoryItemsCompanion.insert(
            id: id,
            name: name,
            price: price,
            yoloLabel: yoloLabel,
            userId: userId,
            baseItemId: baseItemId,
            isOverride: isOverride,
            baseQuantity: baseQuantity,
            quantityMetric: quantityMetric,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({baseItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (baseItemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.baseItemId,
                    referencedTable:
                        $$InventoryItemsTableReferences._baseItemIdTable(db),
                    referencedColumn:
                        $$InventoryItemsTableReferences._baseItemIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (InventoryItem, $$InventoryItemsTableReferences),
    InventoryItem,
    PrefetchHooks Function({bool baseItemId})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required int customerId,
  required List<Item> itemsJson,
  required double totalAmount,
  Value<DateTime> timestamp,
  Value<String?> userId,
  Value<bool> isSynced,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int> customerId,
  Value<List<Item>> itemsJson,
  Value<double> totalAmount,
  Value<DateTime> timestamp,
  Value<String?> userId,
  Value<bool> isSynced,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
          $_aliasNameGenerator(db.transactions.customerId, db.customers.id));

  $$CustomersTableProcessedTableManager get customerId {
    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id($_item.customerId));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<Item>, List<Item>, String>
      get itemsJson => $composableBuilder(
          column: $table.itemsJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemsJson => $composableBuilder(
      column: $table.itemsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Item>, String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool customerId})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<List<Item>> itemsJson = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            customerId: customerId,
            itemsJson: itemsJson,
            totalAmount: totalAmount,
            timestamp: timestamp,
            userId: userId,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int customerId,
            required List<Item> itemsJson,
            required double totalAmount,
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            customerId: customerId,
            itemsJson: itemsJson,
            totalAmount: totalAmount,
            timestamp: timestamp,
            userId: userId,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$TransactionsTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._customerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool customerId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$BaseInventoryItemsTableTableManager get baseInventoryItems =>
      $$BaseInventoryItemsTableTableManager(_db, _db.baseInventoryItems);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
