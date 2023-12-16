import 'package:balance/core/database/database.dart';
import 'package:flutter/material.dart';

class FormattedTime extends StatelessWidget {
  const FormattedTime({
    super.key,
    required this.data,
  });

  final Transaction data;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${data.createdAt.hour}:${data.createdAt.minute} ${data.createdAt.hour > 12 ? 'PM' : 'AM'}',
    );
  }
}
