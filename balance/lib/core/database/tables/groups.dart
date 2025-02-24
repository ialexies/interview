import 'package:drift/drift.dart';

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get balance => integer().withDefault(const Constant(0))();

  // one to many group to transaction

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
