import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';

class CreativeLoadingWidget extends StatefulWidget {
  final Color textColor;
  const CreativeLoadingWidget({super.key, required this.textColor});

  @override
  State<CreativeLoadingWidget> createState() => _CreativeLoadingWidgetState();
}

class _CreativeLoadingWidgetState extends State<CreativeLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: child,
            );
          },
          child: const Text(
            '☁️',
            style: TextStyle(fontSize: 60),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.loadingMessage,
          style: GoogleFonts.outfit(
            fontSize: 20,
            color: widget.textColor,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
