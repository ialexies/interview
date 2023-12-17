import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/ui/group/group_transaction_page.dart';
import 'package:balance/ui/widgets/formatted_date.dart';
import 'package:balance/ui/widgets/formatted_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionListPerType extends StatelessWidget {
  const TransactionListPerType({
    super.key,
    required TransactionssDao transactionsDao,
    required this.widget,
    required this.transactionUpdateVal,
  }) : _transactionsDao = transactionsDao;

  final TransactionssDao _transactionsDao;
  final GroupTransaction widget;
  final TextEditingController transactionUpdateVal;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _transactionsDao.watchGroupTransactions(
        widget.groupId,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        }

        /// Sorts the data in the snapshot based on the createdAt property in descending order
        snapshot.requireData!.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Container(
          margin: EdgeInsets.all(15.sp),
          padding: EdgeInsets.all(5.sp),
          height: .4.sh,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                  itemCount: snapshot.requireData!.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.requireData![index];
                    final transactionType = data.transactionType.name;
                    return Card(
                      child: ListTile(
                        dense: true,
                        title: Text(
                          transactionType,
                          style: TextStyle(
                            color: data.transactionType == TransactionType.expense ? Colors.red : Colors.green,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormattedDate(data: data),
                            FormattedTime(data: data),
                          ],
                        ),
                        leading: SizedBox(
                          width: 50.sp,
                          child: Text(
                            '\$ ${data.amount}',
                            style: TextStyle(
                              color: data.amount > 0 ? Colors.green : Colors.red,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                transactionUpdateVal.text = data.amount.toString();
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      "Edit transaction",
                                    ),
                                    content: TextField(
                                      controller: transactionUpdateVal,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          if (transactionUpdateVal.text.isEmpty) return;
                                          final text = transactionUpdateVal.text;
                                          await _transactionsDao.updateTransaction(
                                            data.id,
                                            int.parse(text),
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              onPressed: () async {
                                await _transactionsDao.deleteTransaction(snapshot.requireData![index].id);
                              },
                              icon: const Icon(Icons.delete),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    );
                  })),
        );
      },
    );
  }
}
