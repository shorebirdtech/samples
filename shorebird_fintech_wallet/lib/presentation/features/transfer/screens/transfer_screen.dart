import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_fintech_wallet/core/app_strings.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_bloc.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_event.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_state.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/screens/transfer_preview_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isInternal = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPreview(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    context.read<TransferBloc>().add(
      UpdateTransferValues(amount: amount, isInternal: _isInternal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransferBloc>(),
      child: BlocListener<TransferBloc, TransferState>(
        listener: (context, state) {
          if (state is TransferPreview) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider.value(
                  value: context.read<TransferBloc>(),
                  child: TransferPreviewScreen(
                    amount: state.amount,
                    fee: state.fee,
                    total: state.total,
                    isInternal: _isInternal,
                  ),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text(AppStrings.transfer)),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.amount,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.attach_money_rounded),
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text(AppStrings.internalTransfer),
                  subtitle: const Text('Transfer to friends or family'),
                  value: _isInternal,
                  onChanged: (val) {
                    setState(() {
                      _isInternal = val;
                    });
                  },
                ),
                const Spacer(),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => _onPreview(context),
                      child: const Text(AppStrings.preview),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Note: Using setState here for a local UI toggle (internal check) which is acceptable per user rule "it's a very small change".
