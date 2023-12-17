import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/widgets/transaction_list_per_type.dart';
import 'package:balance/ui/widgets/transaction_total.dart';
import 'package:flutter/material.dart';

class GroupTransaction extends StatefulWidget {
  final String groupId;
  const GroupTransaction({super.key, required this.groupId});

  @override
  State<GroupTransaction> createState() => _GroupTransactionState();
}

class _GroupTransactionState extends State<GroupTransaction> {
  late final TransactionssDao _transactionsDao = getIt.get<TransactionssDao>();
  final transactionUpdateVal = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TransactionListPerType(
            transactionsDao: _transactionsDao, widget: widget, transactionUpdateVal: transactionUpdateVal),
      ],
    );
  }
}
