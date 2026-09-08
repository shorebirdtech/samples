import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/components/player_skin.dart';

abstract class StartMenuEvent extends Equatable {
  const StartMenuEvent();

  @override
  List<Object?> get props => [];
}

class SelectPilotSkin extends StartMenuEvent {
  final PlayerSkin skin;

  const SelectPilotSkin(this.skin);

  @override
  List<Object?> get props => [skin];
}

class ToggleRulesDialog extends StartMenuEvent {
  final bool show;

  const ToggleRulesDialog(this.show);

  @override
  List<Object?> get props => [show];
}
