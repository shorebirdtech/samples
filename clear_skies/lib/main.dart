import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/data/repositories/repositories.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';
import 'package:clear_skies/presentation/screens/screens.dart';

void main() {
  runApp(const ClearSkiesApp());
}

class ClearSkiesApp extends StatelessWidget {
  const ClearSkiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WeatherRepository(),
      child: BlocProvider(
        create: (context) =>
            WeatherBloc(weatherRepository: context.read<WeatherRepository>()),
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
