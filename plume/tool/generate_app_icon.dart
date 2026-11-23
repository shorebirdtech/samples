// Renders the launcher icon artwork from the same painter as the in-app logo.
//
// Run from the package root, then regenerate the platform icons:
//
//   flutter test tool/generate_app_icon.dart
//   dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/plume_logo.dart';

const _size = 1024.0;

void main() {
  testWidgets('generate app icon', (tester) async {
    tester.view
      ..physicalSize = const Size(_size, _size)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // iOS and legacy Android: full bleed, the OS rounds the corners.
    await _render(
      tester,
      'assets/icon/icon.png',
      const _Icon(background: true, featherScale: 1),
    );
    // Android adaptive icon: flutter_launcher_icons insets the foreground
    // 16% to keep it inside the safe zone launchers crop to.
    await _render(
      tester,
      'assets/icon/icon_foreground.png',
      const _Icon(background: false, featherScale: 1),
    );
    await _render(
      tester,
      'assets/icon/icon_background.png',
      const _Icon(background: true, featherScale: 0),
    );
  });
}

Future<void> _render(WidgetTester tester, String path, Widget icon) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        key: key,
        child: SizedBox.square(dimension: _size, child: icon),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

class _Icon extends StatelessWidget {
  const _Icon({required this.background, required this.featherScale});

  final bool background;
  final double featherScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: background ? Palette.brandGradient : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (featherScale > 0)
            Center(
              child: FractionallySizedBox(
                widthFactor: featherScale,
                heightFactor: featherScale,
                child: const CustomPaint(painter: PlumeFeatherPainter()),
              ),
            ),
        ],
      ),
    );
  }
}
