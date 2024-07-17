import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPrice extends StatelessWidget {
  const ShimmerPrice({Key? key, required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[200]!,
      enabled: true,
      child: GiftPlaceholder(height: height),
    );
  }
}

class GiftPlaceholder extends StatelessWidget {
  const GiftPlaceholder({Key? key, required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorBlack,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
