import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/core/widgets/widgets.dart';
import 'package:plume/l10n/l10n.dart';

/// Plays the brand intro once, then lets the router move on.
class SplashPage extends StatefulWidget {
  const SplashPage({required this.onFinished, super.key});

  /// Called once the intro has played.
  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      // Deferred: completing navigates, which can't happen mid-build.
      if (status == AnimationStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      if (Motion.reduced(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.elasticOut),
    );
    final word = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.8, curve: Motion.emphasized),
    );
    final name = context.l10n.appName;
    return Scaffold(
      body: AuroraBackground(
        colors: const [Palette.ink, Palette.violet, Color(0xFF1E3A8A)],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: logo,
                child: RotationTransition(
                  turns: Tween<double>(begin: -0.08, end: 0).animate(logo),
                  child: const PlumeLogo(size: 96),
                ),
              ),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: word,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < name.length; i++)
                      _Letter(
                        letter: name[i],
                        progress: ((word.value * (name.length + 2)) - i).clamp(
                          0,
                          1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({required this.letter, required this.progress});

  final String letter;
  final double progress;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: progress,
    child: Transform.translate(
      offset: Offset(0, 18 * (1 - progress)),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.displaySmall
            ?.copyWith(color: Colors.white, letterSpacing: 2),
      ),
    ),
  );
}
