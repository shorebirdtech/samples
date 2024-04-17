import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:super_dash_counter/game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SuperDashCounterApp());
}

class SuperDashCounterApp extends StatelessWidget {
  const SuperDashCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Dash Counter',
      theme: flutterNesTheme(),
      home: const GamePage(),
    );
  }
}
