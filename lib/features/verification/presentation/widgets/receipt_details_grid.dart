import 'package:flutter/material.dart';
import 'package:edupay_verify/core/localization/app_strings.dart';
import 'package:edupay_verify/features/verification/models/receipt_model.dart';
import 'detail_card_widget.dart';

class ReceiptDetailsGrid extends StatelessWidget {
  final ReceiptModel receipt;

  const ReceiptDetailsGrid({
    required this.receipt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailCardWidget(details: [
          (AppStrings.program, receipt.program),
          (AppStrings.session, receipt.session),
        ]),
        const SizedBox(height: 12),
        DetailCardWidget(details: [
          (AppStrings.description, receipt.description),
          (AppStrings.paymentType, receipt.paymentType),
        ]),
        const SizedBox(height: 12),
        DetailCardWidget(details: [
          (AppStrings.amount, receipt.amount),
          (AppStrings.totalPaid, receipt.feesTotalPaid),
        ]),
        const SizedBox(height: 12),
        DetailCardWidget(details: [
          (AppStrings.outstanding, receipt.outstanding),
          (AppStrings.paymentMethod, receipt.paymentMethod),
        ]),
        const SizedBox(height: 12),
        DetailCardWidget(details: [
          (AppStrings.dateTime, receipt.dateTime),
          (AppStrings.status, receipt.status),
        ]),
      ],
    );
  }
}
