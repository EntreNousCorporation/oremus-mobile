import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageDisplayer extends StatelessWidget {
  const ImageDisplayer({Key? key,
    required this.icon,
    this.width,
    this.height,
    this.scale,
    this.color,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final String icon;
  final double? width;
  final double? height;
  final double? scale;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final extension = icon.toLowerCase();

    if (extension.endsWith('.svg') || extension.endsWith('.svgz')) {
      return SvgPicture.asset(
        icon,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }

    if (extension.endsWith('.png') || extension.endsWith('.gif')) {
      return Image.asset(
        icon,
        width: width,
        height: height,
        scale: scale,
        color: color,
        fit: fit,
      );
    }

    return const SizedBox.shrink();
  }
}
