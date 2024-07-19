import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class DottedVerticalline extends StatelessWidget {
  const DottedVerticalline({Key? key, this.color}) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DottedLine(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      lineLength: double.infinity,
      lineThickness: 2,
      dashLength: 5.0,
      dashColor: color ?? colorGrey1,
      dashRadius: 0.0,
      dashGapLength: 5.0,
      dashGapColor: colorTransparent,
      dashGapRadius: 0.0,
    );
  }
}
