import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    Key? key,
    this.color = colorGreen3,
    this.size = 20.0,
  }) : super(key: key);

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SpinKitCubeGrid(
      color: color,
      size: size,
    );
  }
}
