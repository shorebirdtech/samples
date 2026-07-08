import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/features/features.dart';

void main() {
  runApp(const ClearSkiesApp());
}

class ClearSkiesApp extends StatelessWidget {
  const ClearSkiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => WeatherRepository()),
        RepositoryProvider(create: (context) => FavoritesRepository()),
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
