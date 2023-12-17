import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/widgets/formatted_date.dart';
import 'package:balance/ui/widgets/formatted_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        // stream that watch the balance of the group
        StreamBuilder(
          stream: _transactionsDao.groupTransactionTotalAmount(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            return Text(snapshot.data.toString());
          },
        ),
        StreamBuilder(
          stream: _transactionsDao.watchGroupTransactions(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }

            /// Sorts the data in the snapshot based on the createdAt property in descending order
            snapshot.requireData!.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Container(
              margin: EdgeInsets.all(15.sp),
              padding: EdgeInsets.all(5.sp),
              height: .5.sh,
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
                        return Card(
                          child: ListTile(
                            dense: true,
                            title: Text('Amount: \$ ${data.amount}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FormattedDate(data: data),
                                FormattedTime(data: data),
                              ],
                            ),
                            leading: Text(
                              '\$ ${data.amount}',
                              style: TextStyle(
                                color: data.amount > 0 ? Colors.green : Colors.red,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
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
                                        title: const Text("Edit transaction"),
                                        content: TextField(
                                          controller: transactionUpdateVal,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
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
        ),
      ],
    );
  }
}
