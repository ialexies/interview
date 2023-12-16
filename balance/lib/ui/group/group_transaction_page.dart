import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupTransaction extends StatefulWidget {
  final String groupId;
  const GroupTransaction({super.key, required this.groupId});

  @override
  State<GroupTransaction> createState() => _GroupTransactionState();
}

class _GroupTransactionState extends State<GroupTransaction> {
  late final TransactionssDao _transactionsDao = getIt.get<TransactionssDao>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: _transactionsDao.watch(),
      stream: _transactionsDao.watchGroupTransactions(widget.groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        }

        // sort data by date
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
                itemBuilder: (context, index) => Card(
                      child: ListTile(
                        dense: true,
                        title: Text('Amount: \$ ${snapshot.requireData![index].amount}'),
                        subtitle: Text(snapshot.requireData![index].createdAt.toString()),
                        leading: Text(
                          '\$ ${snapshot.requireData![index].amount}',
                          style: TextStyle(
                            color: snapshot.requireData![index].amount > 0 ? Colors.green : Colors.red,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {},
                              icon: const Icon(Icons.edit),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              onPressed: () async {},
                              icon: const Icon(Icons.delete),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    )),
          ),
        );
      },
    );
  }
}
