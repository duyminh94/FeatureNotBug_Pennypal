import '../models/transaction_record.dart';
import 'constants.dart';

class BalanceCalculator {
  static double balance(List<TransactionRecord> transactions) {
    double total = 0;
    for (final TransactionRecord transaction in transactions) {
      total += transaction.type == TransactionTypes.income ? transaction.amount : -transaction.amount;
    }
    return total;
  }
}
