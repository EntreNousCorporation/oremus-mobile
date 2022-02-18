import 'package:flutter/material.dart';
import "package:flutter_svg/flutter_svg.dart";
import 'package:oremusapp/app/commons/theme/app_colors.dart';

//AssetImage imgLogo = AssetImage("assets/splash/img_logo.png");
//AssetImage imgLogo = AssetImage("assets/splash/img_logo.png");

class IconSVG {
  static icon(
    String name,{double size=20}
  ) => SvgPicture.asset(name,width: size,height:size);

  static iconWithTint( String name,{
  Color? tint= colorGreen3,double size=20
  }) => SvgPicture.asset(name,width: size,height:size,
          color: tint);

  static iconWithTintAndSemantics( String name,{double size=20,
  Color? tint = colorWhite, String semanticsLabel='Image',
  }) => SvgPicture.asset(name,width: size,height:size,
          color: tint, semanticsLabel: semanticsLabel);
}
