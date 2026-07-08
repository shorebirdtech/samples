import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clear_skies/core/core.dart';
import 'package:clear_skies/logic/bloc/bloc.dart';
import 'package:clear_skies/data/repositories/repositories.dart';
import 'package:clear_skies/data/models/models.dart';

class SearchBarWidget extends StatefulWidget {
  final bool isDay;
  const SearchBarWidget({super.key, required this.isDay});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isDay ? Colors.black54 : Colors.white70;
    final textColor = widget.isDay ? Colors.black87 : Colors.white;
    final hintColor = widget.isDay ? Colors.black38 : Colors.white54;
    final bgColor = widget.isDay
        ? Colors.black.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.1);

    return Autocomplete<CitySuggestion>(
      displayStringForOption: (CitySuggestion option) => option.displayName,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<CitySuggestion>.empty();
        }
        try {
          final repo = context.read<WeatherRepository>();
          return await repo.searchCities(textEditingValue.text);
        } catch (_) {
          return const Iterable<CitySuggestion>.empty();
        }
      },
      onSelected: (CitySuggestion selection) {
        context.read<WeatherBloc>().add(
          WeatherLocationRequested(
            latitude: selection.latitude,
            longitude: selection.longitude,
            cityName: selection.name,
          ),
        );
        FocusManager.instance.primaryFocus?.unfocus();
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: GoogleFonts.inter(color: hintColor),
                  prefixIcon: Icon(Icons.search, color: iconColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<WeatherBloc>().add(
                      WeatherRequested(value.trim()),
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(15),
              clipBehavior: Clip.antiAlias,
              color: widget.isDay ? Colors.white : AppColors.backgroundNight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CitySuggestion option = options.elementAt(index);
                    return ListTile(
                      title: Text(
                        option.displayName,
                        style: GoogleFonts.inter(
                          color: widget.isDay ? Colors.black87 : Colors.white,
                        ),
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
