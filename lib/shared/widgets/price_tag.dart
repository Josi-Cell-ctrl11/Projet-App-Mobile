import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/utils/formatters.dart";

/// Affichage prix FCFA stylé.
class PriceTag extends StatelessWidget {
  const PriceTag(this.amountFcfa, {super.key, this.style});

  final double amountFcfa;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      Formatters.fcfa(amountFcfa),
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
  }
}
