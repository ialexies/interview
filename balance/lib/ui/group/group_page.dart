import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/group/group_transaction_page.dart';
import 'package:balance/ui/widgets/transaction_total.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();
  late final TransactionssDao _transactionsDao = getIt.get<TransactionssDao>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  //final _transactionController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Group details"),
        ),
        body: Column(
          children: [
            TransactionTotal(
              groupId: widget.groupId,
              transactionsDao: _transactionsDao,
              transactionUpdateVal: _incomeController,
            ),
            Container(
              margin: EdgeInsets.all(15.sp),
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
              height: .16.sh,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: StreamBuilder(
                stream: _groupsDao.watchGroup(widget.groupId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("Loading...");
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Row(children: [
                      //   Expanded(
                      //     child: TextFormField(
                      //       controller: _incomeController,
                      //       keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      //       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                      //       decoration: const InputDecoration(
                      //         contentPadding: EdgeInsets.symmetric(vertical: 10),
                      //         suffixText: "\$",
                      //       ),
                      //     ),
                      //   ),
                      //   TextButton(
                      //       onPressed: () {
                      //         final amount = int.parse(_incomeController.text);
                      //         final balance = snapshot.data?.balance ?? 0;
                      //         _groupsDao.adjustBalance(balance + amount, widget.groupId);
                      //         _incomeController.text = "";
                      //       },
                      //       child: Text("Add income")),
                      // ]),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expenseController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                              suffixText: "\$",
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              try {
                                _transactionsDao.insert(
                                  widget.groupId,
                                  int.parse(_expenseController.text),
                                  TransactionType.Income,
                                );
                                _incomeController.clear();
                                // print(_transactionsDao.getAllTransactions().toString());
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Wrong input"),
                                      content: const Text("Please enter a valid amount"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("Add Income")),
                      ]),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expenseController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                              suffixText: "\$",
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              try {
                                _transactionsDao.insert(
                                  widget.groupId,
                                  int.parse(
                                    _expenseController.text,
                                  ),
                                  TransactionType.Expense,
                                );
                                _expenseController.clear();
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Wrong input"),
                                      content: const Text("Please enter a valid amount"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("Add expense")),
                      ]),
                    ],
                  );
                },
              ),
            ),
            GroupTransaction(groupId: widget.groupId),
          ],
        ),
      );
}
