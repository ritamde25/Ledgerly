import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../models/transaction.dart';

class AppState extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(id: '1', name: 'John Doe', totalDue: 150.0),
    Customer(id: '2', name: 'Jane Smith', totalDue: 50.0),
    Customer(id: '3', name: 'Bob Johnson', totalDue: 0.0),
  ];

  final List<Transaction> _transactions = [];

  List<Customer> get customers => _customers;
  List<Transaction> get transactions => _transactions;

  double get totalDueAmount {
    return _customers
        .where((c) => c.totalDue > 0)
        .fold(0.0, (sum, c) => sum + c.totalDue);
  }

  Customer addCustomer(String name) {
    final customer = Customer(
      id: DateTime.now().toString(),
      name: name,
    );
    _customers.add(customer);
    notifyListeners();
    return customer;
  }

  void addTransaction(Customer customer, double amount, String note, TransactionType type) {
    final transaction = Transaction(
      id: DateTime.now().toString(),
      customerId: customer.id,
      customerName: customer.name,
      amount: amount,
      date: DateTime.now(),
      note: note,
      type: type,
    );

    _transactions.insert(0, transaction);

    // Update customer total due
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      // Debit (billing) increases due, Credit (payment) decreases due
      final balanceChange = type == TransactionType.debit ? amount : -amount;
      _customers[index] = _customers[index].copyWith(
        totalDue: _customers[index].totalDue + balanceChange,
      );
    }

    notifyListeners();
  }
}
