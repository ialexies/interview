import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            StreamBuilder(
              stream: _groupsDao.watchGroup(widget.groupId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("Loading...");
                }
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(snapshot.data?.name ?? ""),
                    Text(snapshot.data?.balance.toString() ?? ""),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _incomeController,
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
                            final amount = int.parse(_incomeController.text);
                            final balance = snapshot.data?.balance ?? 0;
                            _groupsDao.adjustBalance(balance + amount, widget.groupId);
                            _incomeController.text = "";
                          },
                          child: Text("Add income")),
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
                                int.parse(_expenseController.text),
                              );
                              print(_transactionsDao.getAllTransactions().toString());
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
            const Text('Transactions'),
            // Todo: Separate this stream so that we can dispose properly and handle
            // Todo: Return Transaction for specific group only
            // Todo: Refactor and put in a separate widget
            // Todo: Update the total balance of group when adding transaction
            StreamBuilder(
              stream: _transactionsDao.watch(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Loading...");
                }
                return Container(
                  //decoration with border and amber background
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.amber[100],
                  ),
                  height: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.requireData.length,
                          itemBuilder: (context, index) {
                            snapshot.requireData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                            return ListTile(
                              title: Text(snapshot.requireData[index].amount.toString()),
                              subtitle: Text(snapshot.requireData[index].createdAt.toString()),
                              onTap: () {
                                // GoRouterHelper(context).push("/groups/${snapshot.requireData[index].id}");
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
}
