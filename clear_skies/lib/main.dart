import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  runApp(const ClearSkiesApp());
}

class ClearSkiesApp extends StatelessWidget {
  final WeatherRepository? weatherRepository;
  final FavoritesRepository? favoritesRepository;

  const ClearSkiesApp({
    super.key,
    this.weatherRepository,
    this.favoritesRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => weatherRepository ?? WeatherRepository()),
        RepositoryProvider(create: (context) => favoritesRepository ?? FavoritesRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WeatherBloc(
              weatherRepository: context.read<WeatherRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(
              weatherRepository: context.read<WeatherRepository>(),
              favoritesRepository: context.read<FavoritesRepository>(),
            )..add(LoadFavorites()),
          ),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
            useMaterial3: true,
          ),
          home: const WeatherScreen(),
        ),
      ),
    );
  }
}
