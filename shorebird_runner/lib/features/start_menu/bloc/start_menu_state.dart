import 'package:equatable/equatable.dart';
import 'package:shorebird_runner/game/components/player_skin.dart';

class StartMenuState extends Equatable {
  final PlayerSkin selectedSkin;
  final bool showRulesDialog;

  const StartMenuState({
    this.selectedSkin = PlayerSkin.blueBird,
    this.showRulesDialog = false,
  });

  StartMenuState copyWith({
    PlayerSkin? selectedSkin,
    bool? showRulesDialog,
  }) {
    return StartMenuState(
      selectedSkin: selectedSkin ?? this.selectedSkin,
      showRulesDialog: showRulesDialog ?? this.showRulesDialog,
    );
  }

  @override
  List<Object?> get props => [selectedSkin, showRulesDialog];
}
