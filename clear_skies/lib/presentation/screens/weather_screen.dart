import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';
import 'package:clear_skies/presentation/widgets/widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          bool isDay = true;
          if (state is WeatherLoaded) {
            isDay = state.weather.isDay;
          } else if (state is WeatherError) {
            isDay = false; // Just to show dark theme on error
          }
          final bgColor = isDay
              ? AppColors.backgroundDay
              : AppColors.backgroundNight;
          final altColor = isDay
              ? const Color(0xFFB2EBF2)
              : const Color(0xFF0D1B2A); // Slightly different shade

          return AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, _bgController.value * 0.5 + 0.5],
                    colors: [bgColor, altColor],
                  ),
                ),
                child: child,
              );
            },
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBarWidget(isDay: isDay),
                  ),
                  Expanded(child: Center(child: _buildContent(state, isDay))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(WeatherState state, bool isDay) {
    final textColor = isDay ? AppColors.textDay : AppColors.textNight;

    if (state is WeatherInitial) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 80,
            color: textColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.initialSearchPrompt,
            style: GoogleFonts.outfit(
              fontSize: 24,
              color: textColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      );
    } else if (state is WeatherLoading) {
      return CreativeLoadingWidget(textColor: textColor);
    } else if (state is WeatherLoaded) {
      return WeatherDisplay(weather: state.weather);
    } else if (state is WeatherError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
