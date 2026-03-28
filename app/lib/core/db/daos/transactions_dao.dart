import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/transactions_table.dart';
import '../tables/customers_table.dart';

part 'transactions_dao.g.dart';

class TransactionWithCustomer {
  final Transaction transaction;
  final Customer customer;

  TransactionWithCustomer(this.transaction, this.customer);
}

@DriftAccessor(tables: [Transactions, Customers])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  Stream<List<TransactionWithCustomer>> watchAllTransactionsWithCustomer({int? limit, int? offset, DateTime? from, DateTime? to}) {
    final query = select(transactions).join([
      innerJoin(customers, customers.id.equalsExp(transactions.customerId)),
    ]);

    if (from != null) {
      query.where(transactions.timestamp.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(transactions.timestamp.isSmallerOrEqualValue(to));
    }

    query.orderBy([OrderingTerm(expression: transactions.timestamp, mode: OrderingMode.desc)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCustomer(
          row.readTable(transactions),
          row.readTable(customers),
        );
      }).toList();
    });
  }

  Stream<List<Transaction>> watchTransactionsForCustomer(int customerId) {
    return (select(transactions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) => into(transactions).insert(transaction);
}
