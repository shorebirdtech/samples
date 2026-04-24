import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/core/app_theme.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_bloc.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_event.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_state.dart';
import 'package:intl/intl.dart';

class TransferPreviewScreen extends StatelessWidget {
  final double amount;
  final double fee;
  final double total;
  final bool isInternal;

  const TransferPreviewScreen({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
    required this.isInternal,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is TransferSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.transactionSuccess),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is TransferFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransferLoading;

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.preview)),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                _SummaryCard(
                  amountLabel: AppStrings.amount,
                  amountValue: currencyFormat.format(amount),
                  feeLabel: AppStrings.fee,
                  feeValue: currencyFormat.format(fee),
                  totalLabel: AppStrings.total,
                  totalValue: currencyFormat.format(total),
                ),
                const SizedBox(height: 32),
                if (isInternal)
                  const _Badge(
                    label: AppStrings.internalTransfer,
                    color: AppTheme.successColor,
                  )
                else
                  const _Badge(
                    label: AppStrings.standardTransfer,
                    color: AppTheme.accentColor,
                  ),
                const Spacer(),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransferBloc>().add(
                        ConfirmTransfer(
                          amount: amount,
                          fee: fee,
                          isInternal: isInternal,
                        ),
                      );
                    },
                    child: const Text(AppStrings.confirmTransfer),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String amountLabel;
  final String amountValue;
  final String feeLabel;
  final String feeValue;
  final String totalLabel;
  final String totalValue;

  const _SummaryCard({
    required this.amountLabel,
    required this.amountValue,
    required this.feeLabel,
    required this.feeValue,
    required this.totalLabel,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            _Row(label: amountLabel, value: amountValue),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppTheme.backgroundColor),
            ),
            _Row(
              label: feeLabel,
              value: feeValue,
              valueColor: AppTheme.errorColor,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppTheme.backgroundColor),
            ),
            _Row(label: totalLabel, value: totalValue, isLarge: true),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLarge;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textColor,
            fontSize: isLarge ? 24 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
