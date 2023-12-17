import 'package:drift/drift.dart';

enum TransactionType { expense, income }

class Transactions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get amount => integer().withDefault(const Constant(0))();
  TextColumn get groupId => text().customConstraint('NOT NULL REFERENCES groups(id) ON DELETE CASCADE')();

// column for transaction type enum
  IntColumn get transactionType => intEnum<TransactionType>().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
