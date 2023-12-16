import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:flutter/material.dart';

class GroupTransaction extends StatelessWidget {
  const GroupTransaction({
    super.key,
    required TransactionssDao transactionsDao,
  }) : _transactionsDao = transactionsDao;

  final TransactionssDao _transactionsDao;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _transactionsDao.watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        }
        return Container(
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
    );
  }
}
