import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transactions])
class TransactionssDao extends DatabaseAccessor<Database> with _$TransactionssDaoMixin {
  TransactionssDao(super.db);

  Future insert(String groupId, int amount, TransactionType transactionType) {
    return into(transactions).insert(
      TransactionsCompanion.insert(
        id: const Uuid().v1(),
        createdAt: DateTime.now(),
        transactionType: Value(transactionType),
        amount: Value(amount),
        groupId: groupId,
      ),
    );
  }

  // Function to return list of transactions
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  // Function to return Stream list of transactions
  Stream<List<Transaction>> watch() => select(transactions).watch();

  // Function to return Stream list of transactions for a group
  Stream<List<Transaction>?> watchGroupTransactions(String groupId) {
    // return where groupId is groupId and transactionType are same
    return (select(transactions)
          ..where(
            (tbl) => tbl.groupId.equals(groupId),
          ))
        .watch();
  }

  // Function to delete a transaction in a group
  Future deleteTransaction(String transactionId) {
    return (delete(transactions)
          ..where(
            (tbl) => tbl.id.equals(transactionId),
          ))
        .go();
  }

  // Function to update a transaction in a group
  updateTransaction(String id, int parse) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        amount: Value(parse),
      ),
    );
  }

  // Function to return sum of all amount of transactions in a group
  Stream<int> groupTransactionTotal(String groupId, TransactionType transactionType) {
    return (select(transactions)
          ..where(
            (tbl) => tbl.groupId.equals(groupId),
          )
          ..where(
            (tbl) => tbl.transactionType.equals(transactionType.index),
          ))
        .watch()
        .map((event) => event.map((e) => e.amount).toList())
        .map((event) => event.fold<int>(0, (previousValue, element) => previousValue + element));
  }

  Future<int> getBalance({required String groupId}) async {
    final List<Transaction> totIncome = await (select(transactions)
          ..where(
            (tbl) => tbl.groupId.equals(groupId),
          )
          ..where(
            (tbl) => tbl.transactionType.equals(TransactionType.income.index),
          ))
        .get();
    final List<Transaction> totExpenses = await (select(transactions)
          ..where(
            (tbl) => tbl.groupId.equals(groupId),
          )
          ..where(
            (tbl) => tbl.transactionType.equals(TransactionType.expense.index),
          ))
        .get();

    int totalIncome = totIncome.fold<int>(0, (previousValue, element) => previousValue + element.amount);
    int totalExpenses = totExpenses.fold<int>(0, (previousValue, element) => previousValue + element.amount);

    final totalBalance = totalIncome - totalExpenses;

    // print(totIncome);
    return totalBalance;
  }
}
