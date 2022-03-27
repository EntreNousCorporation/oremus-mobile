import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';

class MenuGridItem extends StatefulWidget {
  const MenuGridItem({Key? key, required this.item}) : super(key: key);

  final TypeMenu item;

  @override
  _MenuGridItemState createState() => _MenuGridItemState();
}

class _MenuGridItemState extends State<MenuGridItem> {
  bool _isPressed = false;
  get item => widget.item;

  _animatedButton(Function destination) {
    if (!mounted) return;
    setState(() => _isPressed = true);
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        destination.call();
        _isPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.goToPage != null ? () {
        _animatedButton(item.goToPage);
      } : () {
        _animatedButton(item.goToPage);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10,
          color: _isPressed ? colorGreen.withOpacity(0.5) : colorWhite,
          shadowColor: colorGrey2.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              item.isPngImage
                  ? Image.asset(item.icon, height: Get.width / 8)
                  : SvgPicture.asset(
                      item.icon,
                      height: Get.width / 8,
                    ),
              Separators.minimunVertical(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.montserratBold(
                    textSize: TextSizes.thirteen,
                    textColor: _isPressed ? colorWhite : colorBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
