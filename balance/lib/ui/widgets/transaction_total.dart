import 'dart:async';

import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionTotal extends StatefulWidget {
  const TransactionTotal({
    super.key,
    required TransactionssDao transactionsDao,
    // required this.widget,
    required this.transactionUpdateVal,
    required this.groupId,
  }) : _transactionsDao = transactionsDao;

  final TransactionssDao _transactionsDao;
  // final GroupTransaction widget;
  final TextEditingController transactionUpdateVal;
  final String groupId;

  @override
  State<TransactionTotal> createState() => _TransactionTotalState();
}

class _TransactionTotalState extends State<TransactionTotal> {
  Stream<int>? groupTransactionTotal;
  int? _incomeTotal;
  int? _expenseTotal;
  int? _balance = -30;

  @override
  Widget build(BuildContext context) {
    // valuue subscription  widget._transactionsDao.groupTransactionTotal(widget.groupId, TransactionType.Income);
    StreamSubscription<int?> subscriptionTotalIncome =
        widget._transactionsDao.groupTransactionTotal(widget.groupId, TransactionType.Income).listen((incomeTotal) {
      // Update widget with 'incomeTotal' value
      if (mounted) {
        setState(() {
          _incomeTotal = incomeTotal;
        });
      }
    });

    // expenses subscription
    StreamSubscription<int?> subscriptionTotalExpenses =
        widget._transactionsDao.groupTransactionTotal(widget.groupId, TransactionType.Expense).listen((expenseTotal) {
      // Update widget with 'expenseTotal' value
      if (mounted) {
        setState(() {
          _expenseTotal = expenseTotal;
        });
      }
    });

    @override
    void dispose() {
      subscriptionTotalIncome.cancel();
      subscriptionTotalExpenses.cancel();
      super.dispose();
    }

    return Container(
      padding: EdgeInsets.all(15.sp),
      width: double.maxFinite,
      margin: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataRowBuilder(
            name: 'Balance',
            val: int.parse(_incomeTotal.toString()) - int.parse(_expenseTotal.toString()) < 0
                ? '-\$${(_incomeTotal! - _expenseTotal!).abs()}'
                : '\$${(_incomeTotal! - _expenseTotal!).abs()}',
          ),
          DataRowBuilder(
            name: 'Income',
            val: (_incomeTotal!).toString(),
          ),
          DataRowBuilder(
            name: 'Expenses',
            val: (_expenseTotal!).toString(),
          ),
        ],
      ),
    );
  }
}

class DataRowBuilder extends StatelessWidget {
  const DataRowBuilder({
    super.key,
    required String name,
    required String val,
  })  : _name = name,
        _val = val;

  final String _name;
  final String _val;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_name),
        Text(_val),
      ],
    );
  }
}
