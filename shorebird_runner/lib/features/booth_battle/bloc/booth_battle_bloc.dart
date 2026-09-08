import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/features/booth_battle/bloc/booth_battle_event.dart';
import 'package:shorebird_runner/features/booth_battle/bloc/booth_battle_state.dart';

export 'booth_battle_event.dart';
export 'booth_battle_state.dart';

class BoothBattleBloc extends Bloc<BoothBattleEvent, BoothBattleState> {
  BoothBattleBloc() : super(BoothBattleState()) {
    on<UpdateP1Score>(_onUpdateP1Score);
    on<UpdateP2Score>(_onUpdateP2Score);
    on<RestartBoothBattle>(_onRestartBoothBattle);
  }

  void _onUpdateP1Score(UpdateP1Score event, Emitter<BoothBattleState> emit) {
    emit(state.copyWith(
      p1Score: event.score,
      p1Patches: event.patches,
      p1Level: event.level,
      p1Crashed: !event.isAlive,
    ));
  }

  void _onUpdateP2Score(UpdateP2Score event, Emitter<BoothBattleState> emit) {
    emit(state.copyWith(
      p2Score: event.score,
      p2Patches: event.patches,
      p2Level: event.level,
      p2Crashed: !event.isAlive,
    ));
  }

  void _onRestartBoothBattle(
      RestartBoothBattle event, Emitter<BoothBattleState> emit) {
    emit(BoothBattleState());
  }
}
