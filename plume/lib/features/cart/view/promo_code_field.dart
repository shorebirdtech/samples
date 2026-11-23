import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:plume/core/theme/motion.dart';
import 'package:plume/core/theme/palette.dart';
import 'package:plume/data/repositories/promotion_repository.dart';
import 'package:plume/features/cart/cubit/cart_cubit.dart';
import 'package:plume/l10n/l10n.dart';

class PromoCodeField extends StatefulWidget {
  const PromoCodeField({super.key});

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    FocusScope.of(context).unfocus();
    final applied = await context.read<CartCubit>().applyPromo(
      _controller.text,
    );
    if (applied) {
      unawaited(HapticFeedback.mediumImpact());
      _controller.clear();
    } else {
      unawaited(HapticFeedback.heavyImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final summary = cart.summary;
    final promotion = cart.promotion;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.medium),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: promotion != null
          ? Container(
              key: ValueKey(promotion.code),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                color: Palette.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Palette.success.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Palette.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.code,
                          style: theme.textTheme.titleSmall?.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          summary.promoShortfall != null
                              ? l10n.promoShortfall(
                                  summary.promoShortfall!.format(locale),
                                )
                              : promotion.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: summary.promoShortfall != null
                                ? Palette.amber
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.removePromo,
                    onPressed: () =>
                        unawaited(context.read<CartCubit>().removePromo()),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            )
          : Column(
              key: const ValueKey('entry'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => unawaited(_apply()),
                  decoration: InputDecoration(
                    hintText: l10n.promoHint,
                    prefixIcon: const Icon(Icons.local_offer_outlined),
                    errorText: switch (cart.promoError) {
                      PromoError.notFound => l10n.promoInvalid,
                      PromoError.network => l10n.errorMessage,
                      null => null,
                    },
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(6),
                      child: cart.promoStatus == PromoStatus.applying
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(72, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => unawaited(_apply()),
                              child: Text(l10n.apply),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
