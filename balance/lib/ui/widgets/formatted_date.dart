import 'package:balance/core/database/database.dart';
import 'package:flutter/material.dart';

class FormattedDate extends StatelessWidget {
  const FormattedDate({
    super.key,
    required this.data,
  });

  final Transaction data;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${data.createdAt.day}/${data.createdAt.month}/${data.createdAt.year}',
    );
  }
}
