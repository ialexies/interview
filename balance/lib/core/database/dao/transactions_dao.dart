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

  Future insert(String groupId, int amount) {
    // return into(transactions).insert(TransactionsCompanion.insert(id: const Uuid().v1(), id: 'test'));
    return into(transactions).insert(
      TransactionsCompanion.insert(
        id: const Uuid().v1(),
        createdAt: DateTime.now(),
        amount: Value(amount),
        groupId: groupId,
      ),
    );
  }

  // Function to return list of transactions
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<Transaction>> watch() => select(transactions).watch();

  Stream<List<Transaction>?> watchGroupTransactions(String groupId) {
    return (select(transactions)..where((tbl) => tbl.groupId.equals(groupId))).watch();
    // return all transactions which is equal to trnsactionId
    // return (select(transactions)..where((tbl) => tbl.groupId.equals(groupId))).get();

    // return (select(transactions)..where((tbl) => tbl.id.equals(transactionId))).watchSingleOrNull();

    // return transactions sort by date
    // return (select(transactions)
    //       ..where((tbl) => tbl.id.equals(transactionId))
    //       ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
    //     .watchSingleOrNull();
  }
}
