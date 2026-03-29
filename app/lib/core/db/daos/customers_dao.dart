import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/customers_table.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomersDao extends DatabaseAccessor<AppDatabase> with _$CustomersDaoMixin {
  CustomersDao(AppDatabase db) : super(db);

  Stream<List<Customer>> watchAllCustomers() => select(customers).watch();
  Stream<Customer?> watchCustomerById(String id) => (select(customers)..where((t) => t.id.equals(id))).watchSingleOrNull();
  Future<List<Customer>> getAllCustomers() => select(customers).get();
  Future<int> insertCustomer(CustomersCompanion customer) => into(customers).insert(customer);
  Future updateCustomer(Customer customer) => update(customers).replace(customer);
  Future deleteCustomer(Customer customer) => delete(customers).delete(customer);
  
  Future<void> updateCustomerDebt(String id, double amount) async {
    final customer = await (select(customers)..where((t) => t.id.equals(id))).getSingle();
    await update(customers).replace(customer.copyWith(
      totalDue: customer.totalDue + amount,
      isSynced: false, // Reset sync flag so SyncService picks it up
    ));
  }
}
