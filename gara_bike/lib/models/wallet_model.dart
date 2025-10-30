// lib/models/wallet_model.dart

class Transaction {
  final int id;
  final double amount;
  final String transactionType;
  final String timestamp;
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.timestamp,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      transactionType: json['transaction_type'],
      timestamp: json['timestamp'],
      description: json['description'] ?? '',
    );
  }
}

class Wallet {
  final int id;
  final double balance;
  final List<Transaction> transactions;

  Wallet({
    required this.id,
    required this.balance,
    required this.transactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    var transactionList = json['transactions'] as List;
    List<Transaction> transactions = transactionList.map((i) => Transaction.fromJson(i)).toList();

    return Wallet(
      id: json['id'],
      balance: double.parse(json['balance'].toString()),
      transactions: transactions,
    );
  }
}
