import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/features/features.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationAndFetchWeather();
    });
  }

  Future<void> _requestLocationAndFetchWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      String resolvedCityName = "Current Location";
      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final possibleName =
              p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              "";
          if (possibleName.isNotEmpty) {
            resolvedCityName = possibleName;
          }
        }
      } catch (_) {
        // Fallback to "Current Location" if reverse geocoding fails
      }

      if (mounted) {
        context.read<WeatherBloc>().add(
          WeatherLocationRequested(
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: resolvedCityName,
          ),
        );
      }
    } catch (e) {
      // Ignored
    }
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
          if (state.status == WeatherStatus.loaded && state.weather != null) {
            isDay = state.weather!.isDay;
          } else if (state.status == WeatherStatus.error) {
            isDay = false; // Just to show dark theme on error
          }
          final currentGradient = isDay
              ? AppColors.dayGradient
              : AppColors.nightGradient;

          return AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, _bgController.value * 0.2 + 0.4, 1.0],
                    colors: currentGradient,
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
                  Expanded(child: _buildContent(state, isDay)),
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

    if (state.status == WeatherStatus.initial) {
      return BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, favState) {
          if (favState.status == FavoritesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          } else if (favState.status == FavoritesStatus.loaded &&
              favState.favorites.isNotEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: favState.favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final favWeather = favState.favorites[index];
                return GestureDetector(
                  onTap: () {
                    context.read<WeatherBloc>().add(
                      WeatherRequested(favWeather.cityName),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favWeather.cityName,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                WeatherHelper.getWeatherDescription(
                                  favWeather.weatherCode,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: textColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${favWeather.temperature.round()}°',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              WeatherHelper.getWeatherIcon(
                                favWeather.weatherCode,
                              ),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return WelcomeHeroWidget(
            textColor: textColor,
            onCityTapped: (city) {
              context.read<WeatherBloc>().add(WeatherRequested(city));
            },
          );
        },
      );
    } else if (state.status == WeatherStatus.loading) {
      return Center(child: CreativeLoadingWidget(textColor: textColor));
    } else if (state.status == WeatherStatus.loaded && state.weather != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            WeatherDisplay(weather: state.weather!),
            const SizedBox(height: 16),
            ForecastListWidget(
              forecast: state.weather!.forecast,
              textColor: textColor,
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    } else if (state.status == WeatherStatus.error) {
      return Center(
        child: Padding(
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
                state.errorMessage ?? 'An error occurred',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
