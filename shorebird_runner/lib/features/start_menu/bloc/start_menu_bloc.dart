import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/start_menu/bloc/start_menu_event.dart';
import 'package:shorebird_runner/features/start_menu/bloc/start_menu_state.dart';

export 'start_menu_event.dart';
export 'start_menu_state.dart';

class StartMenuBloc extends Bloc<StartMenuEvent, StartMenuState> {
  StartMenuBloc() : super(const StartMenuState()) {
    on<SelectPilotSkin>(_onSelectPilotSkin);
    on<ToggleRulesDialog>(_onToggleRulesDialog);
  }

  void _onSelectPilotSkin(SelectPilotSkin event, Emitter<StartMenuState> emit) {
    emit(state.copyWith(selectedSkin: event.skin));
  }

  void _onToggleRulesDialog(
      ToggleRulesDialog event, Emitter<StartMenuState> emit) {
    emit(state.copyWith(showRulesDialog: event.show));
  }
}
