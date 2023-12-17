// group_business_logic.dart

import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';

/// A class containing business logic functions related to managing transactions in a group.
class GroupBusinessLogic {
  late final TransactionssDao _transactionsDao = getIt.get<TransactionssDao>();

  /// Adds a new transaction to the specified group with the given amount and type.
  /// Throws an error if the amount is invalid or the operation fails.
  Future<void> addTransaction(
    String groupId,
    int amount,
    TransactionType type,
  ) async {
    if (amount == 0) {
      throw Exception('Transaction amount cannot be zero.');
    }

    try {
      await _transactionsDao.insert(groupId, amount, type);
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  /// Handles an error that occurred during transaction addition.
  /// Shows a snackbar message to the user about the error.
  void handleTransactionError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
