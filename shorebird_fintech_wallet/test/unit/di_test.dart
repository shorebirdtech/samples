import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/core/di/injection.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/wallet_store.dart';
import 'package:shorebird_fintech_wallet/store/wallet_store/transaction_logic.dart';
import 'package:shorebird_fintech_wallet/presentation/features/transfer/bloc/transfer_bloc.dart';

void main() {
  group('Dependency Injection Tests', () {
    setUp(() async {
      await getIt.reset();
      configureDependencies();
    });

    test('WalletStore should be registered as a singleton', () {
      expect(getIt.isRegistered<WalletStore>(), isTrue);
      final store1 = getIt<WalletStore>();
      final store2 = getIt<WalletStore>();
      expect(identical(store1, store2), isTrue);
    });

    test('TransactionLogic should be registered as a singleton', () {
      expect(getIt.isRegistered<TransactionLogic>(), isTrue);
      final logic1 = getIt<TransactionLogic>();
      final logic2 = getIt<TransactionLogic>();
      expect(identical(logic1, logic2), isTrue);
    });

    test('TransferBloc should be registered as a factory', () {
      expect(getIt.isRegistered<TransferBloc>(), isTrue);
      final bloc1 = getIt<TransferBloc>();
      final bloc2 = getIt<TransferBloc>();
      // It should be a factory, so different instances
      expect(identical(bloc1, bloc2), isFalse);
    });
  });
}
