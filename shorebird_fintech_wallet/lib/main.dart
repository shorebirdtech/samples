import 'package:flutter/material.dart';
import 'package:shorebird_fintech_wallet/core/app_theme.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';
import 'package:shorebird_fintech_wallet/presentation/features/wallet/screens/wallet_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shorebird Safe-Guard',
      theme: AppTheme.darkTheme,
      home: WalletScreen(store: getIt<WalletStore>()),
    );
  }
}
