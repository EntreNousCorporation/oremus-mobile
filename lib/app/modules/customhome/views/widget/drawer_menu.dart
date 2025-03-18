import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu_item.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<DrawerMenu> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late SimpleHiddenDrawerController _controller;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _controller = SimpleHiddenDrawerController.of(context);
    _controller.addListener(() {
      if (_controller.state == MenuState.open) {
        _animationController.forward();
      }

      if (_controller.state == MenuState.closing) {
        _animationController.reverse();
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: colorGreenSemiLight,
          width: double.maxFinite,
          height: double.maxFinite,
        ),
        SafeArea(
          child: FadeTransition(
            opacity: _animationController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: (Get.height / 18), horizontal: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Menu',
                    style: TextStyles.montserratBold(
                        textSize: TextSizes.thirty_eight,
                        textColor: colorWhite),
                  ),
                  //Expanded(child: Container()),
                  SizedBox(
                    height: Get.width / 10,
                  ),
                  GetBuilder<CustomHomeController>(builder: (logic) {
                    return Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: logic.menus.length,
                          itemBuilder: (context, index) {
                            var menu = logic.menus[index];
                            menu.isSelected = (index == logic.selectedIndex.value);
                            return DrawerMenuItem(
                              menu: menu,
                              index: index,
                            );
                          }),
                    );
                  }),
                  //Expanded(child: Container()),
                  SizedBox(
                    height: Get.width / 10,
                  ),
                  isUserConnected.value == false ? Container() : GetBuilder<CustomHomeController>(builder: (logic) {
                    return TextButton(
                      onPressed: () {
                        logic.doLogout();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            Assets.imagesIconSettings,
                            height: 20,
                          ),
                          Separators.normalHorizontal(),
                          Text(
                            'Déconnexion',
                            style: TextStyles.montserratRegular(
                                textSize: TextSizes.fourteen,
                                textColor: colorWhite),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, top: Get.width / 5,),
                    child: Text(
                      'Version: $versionName''_$versionCode',
                      style: TextStyles.montserratRegular(
                        textSize: TextSizes.ten,
                        textColor: colorWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
