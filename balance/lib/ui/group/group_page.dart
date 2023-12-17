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
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();
  late final TransactionssDao _transactionsDao = getIt.get<TransactionssDao>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  bool isGroupPageLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group details"),
      ),
      body: Stack(
        children: [
          Column(
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
                        _groupAction(context, type: TransactionType.income),
                        SizedBox(
                          height: 10.sp,
                        ),
                        _groupAction(context, type: TransactionType.expense),
                      ],
                    );
                  },
                ),
              ),
              GroupTransaction(groupId: widget.groupId),
            ],
          ),
          if (isGroupPageLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Row _groupAction(BuildContext context, {required TransactionType type}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150.sp,
          child: Expanded(
            child: TextFormField(
              controller: type == TransactionType.income ? _incomeController : _expenseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
              decoration: txtFieldDecor(),
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final controller = type == TransactionType.income ? _incomeController : _expenseController;
            final value = controller.text;

            // prevent empty values
            if (value.isEmpty) return;

            // prevent multiple clicks
            if (isGroupPageLoading) return;
            setState(() {
              isGroupPageLoading = true;
            });

            try {
              _transactionsDao.insert(
                widget.groupId,
                int.parse(value),
                type,
              );

              await _updateGroupBalance();

              controller.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction added'),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              );
              // close keyboard
              FocusScope.of(context).unfocus();
            } catch (e) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: Text(e.toString()),
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
            setState(() {
              isGroupPageLoading = false;
            });
          },
          child: Text("Add ${type == TransactionType.income ? 'Income' : 'Expense'}"),
        ),
      ],
    );
  }

  Future<void> _updateGroupBalance() async {
    int totalBalance = await _transactionsDao.getBalance(groupId: widget.groupId);
    _groupsDao.adjustBalance(totalBalance, widget.groupId);
  }

  InputDecoration txtFieldDecor() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      prefixText: "\$  ",
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }
}
