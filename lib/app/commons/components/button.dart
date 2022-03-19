import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final double borderWidth;
  final Color borderColor;
  final double paddingVertical;
  final double paddingHorizontal;
  final double iconHeight;
  final double iconWidth;
  final double borderRadius;
  Color bgcolor;
  Color actionColor;
  TextAlign textAlign;
  String? icon;
  bool? isIconCustom;
  IconData? iconData;
  Function? action;
  bool? enabled;

  CustomButton({
    this.text = "",
    this.textColor = colorWhite,
    this.textSize = TextSizes.fourteen,
    this.textAlign = TextAlign.center,
    this.bgcolor = colorGreen,
    this.actionColor = colorBlue2,
    this.borderWidth = 2,
    this.borderColor = colorGreen,
    this.paddingVertical = 10.0,
    this.paddingHorizontal = 10.0,
    this.icon,
    this.iconData,
    this.isIconCustom = true,
    this.iconHeight = 20.0,
    this.iconWidth = 20.0,
    this.borderRadius = 6,
    this.action,
    this.enabled = true,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  get text => widget.text;

  get textColor => widget.textColor;

  get textSize => widget.textSize;

  get textAlign => widget.textAlign;

  get bgcolor => widget.bgcolor;

  get actionColor => widget.actionColor;

  get borderWidth => widget.borderWidth;

  get borderColor => widget.borderColor;

  get paddingVertical => widget.paddingVertical;

  get paddingHorizontal => widget.paddingHorizontal;

  get iconWidth => widget.iconWidth;

  get iconHeight => widget.iconHeight;

  get borderRadius => widget.borderRadius;

  get icon => widget.icon;
  get isIconCustom => widget.isIconCustom;
  get iconData => widget.iconData;
  get action => widget.action;
  get enabled => widget.enabled;

  bool _isPressed = false;

  late Timer _timer;

  _AnimatedButton(Function action) {
    setState(() => _isPressed = true);
    _timer = Timer(const Duration(milliseconds: 100), () {
      setState(() {
        action != null ? action.call() : _isPressed = false;
        _isPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        enabled ? _AnimatedButton(action) : null;
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        decoration: BoxDecoration(
            color: _isPressed ? actionColor : bgcolor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
                color: _isPressed ? actionColor : borderColor,
                width: borderWidth)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (text != null && text.isNotEmpty) ? Expanded(
                child: Text(text,
                    textAlign: textAlign,
                    style: TextStyles.montserratMedium(
                        textSize: textSize, textColor: textColor)),
              ) : Container(),
              if (icon != null)
                SvgPicture.asset(
                        icon,
                        height: iconHeight,
                        width: iconWidth,
                      ),
              if (iconData != null)
                Icon(
                  iconData,
                  color: Colors.black,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
