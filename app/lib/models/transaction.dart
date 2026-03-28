enum TransactionType { debit, credit }

class Transaction {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.type,
    this.note = '',
  });
}
