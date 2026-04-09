// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../presentation/features/transfer/bloc/transfer_bloc.dart' as _i573;
import '../../store/wallet_store/transaction_logic.dart' as _i217;
import '../../store/wallet_store/wallet_store.dart' as _i285;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i217.TransactionLogic>(() => _i217.TransactionLogic());
    gh.lazySingleton<_i285.WalletStore>(() => _i285.WalletStore());
    gh.factory<_i573.TransferBloc>(
      () => _i573.TransferBloc(
        gh<_i217.TransactionLogic>(),
        gh<_i285.WalletStore>(),
      ),
    );
    return this;
  }
}
