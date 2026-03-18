import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class InfoSection extends StatelessWidget {
  InfoSection({
    super.key,
    required this.label,
    required this.value,
    required this.isFirst,
    this.icon,
    this.padding,
  });

  String label;
  String value;
  IconData? icon;
  bool isFirst;
  EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icône
          icon != null ? Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorGreen, size: 24),
          ) : const SizedBox.shrink(),
          const SizedBox(width: 16),

          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Libellé
                Text(
                  label,
                  style: TextStyles.montserratRegular(
                    textSize: TextSizes.thirteen,
                    textColor: Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 4),

                // Valeur
                Text(
                  value,
                  style: TextStyles.montserratSemiBold(
                    textSize: TextSizes.fifteen,
                    textColor: colorBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
