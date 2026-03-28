import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drift_database.dart';
import 'daos/customers_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/transactions_dao.dart';
import '../auth/auth_provider.dart';
import '../../services/sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final customersDaoProvider = Provider<CustomersDao>((ref) {
  return ref.watch(databaseProvider).customersDao;
});

final inventoryDaoProvider = Provider<InventoryDao>((ref) {
  return ref.watch(databaseProvider).inventoryDao;
});

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return ref.watch(databaseProvider).transactionsDao;
});

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customersDaoProvider).watchAllCustomers();
});

final customerProvider = StreamProvider.family<Customer?, int>((ref, id) {
  return ref.watch(customersDaoProvider).watchCustomerById(id);
});

final inventoryStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllItems();
});

final inventorySearchQueryProvider = StateProvider<String>((ref) => "");
final inventoryPageProvider = StateProvider<int>((ref) => 0);
const int inventoryPageSize = 20;

final paginatedInventoryProvider = StreamProvider<List<UnifiedInventoryItem>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();
  final userId = user.id;
  
  final query = ref.watch(inventorySearchQueryProvider);
  final page = ref.watch(inventoryPageProvider);
  
  return ref.watch(inventoryDaoProvider).watchUnifiedInventory(
    userId,
    query: query,
    limit: inventoryPageSize,
    offset: page * inventoryPageSize,
  );
});

final historyPageProvider = StateProvider<int>((ref) => 0);
const int historyPageSize = 50;

final historyWeekOffsetProvider = StateProvider<int>((ref) => 0);

enum TransactionFilter { all, payment, purchase }
final historyFilterProvider = StateProvider<TransactionFilter>((ref) => TransactionFilter.all);

final transactionsStreamProvider = StreamProvider<List<TransactionWithCustomer>>((ref) {
  final weekOffset = ref.watch(historyWeekOffsetProvider);
  
  final now = DateTime.now();
  final currentMonday = now.subtract(Duration(days: now.weekday - 1));
  final startOfCurrentMonday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
  
  final startOfTargetWeek = startOfCurrentMonday.subtract(Duration(days: 7 * weekOffset));
  final endOfTargetWeek = weekOffset == 0 
      ? DateTime(now.year, now.month, now.day, 23, 59, 59)
      : startOfTargetWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  return ref.watch(transactionsDaoProvider).watchAllTransactionsWithCustomer(
    from: startOfTargetWeek,
    to: endOfTargetWeek,
  );
});

final allTransactionsStreamProvider = StreamProvider<List<TransactionWithCustomer>>((ref) {
  return ref.watch(transactionsDaoProvider).watchAllTransactionsWithCustomer(limit: 50);
});

final customerTransactionsProvider = StreamProvider.family<List<Transaction>, int>((ref, customerId) {
  return ref.watch(transactionsDaoProvider).watchTransactionsForCustomer(customerId);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    db: ref.watch(databaseProvider),
    supabase: ref.watch(supabaseClientProvider),
  );
});

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
