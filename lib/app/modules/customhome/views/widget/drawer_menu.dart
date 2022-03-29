import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu_item.dart';

class DrawerMenu extends StatefulWidget {
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
          color: colorGreyDrawer,
          width: double.maxFinite,
          height: double.maxFinite,
        ),
        SafeArea(
          child: FadeTransition(
            opacity: _animationController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: (Get.height / 15), horizontal: 15.0),
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
                  Expanded(child: Container()),
                  GetBuilder<CustomHomeController>(builder: (logic) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: logic.menus.length,
                        itemBuilder: (context, index) {
                          var menu = logic.menus.value[index];
                          menu.isSelected = (index == logic.selectedIndex.value);
                          return DrawerMenuItem(
                            menu: menu,
                            index: index,
                          );
                        });
                  }),
                  Expanded(child: Container()),
                  GetBuilder<CustomHomeController>(builder: (logic) {
                    return GestureDetector(
                      onTap: () {
                        logic.doLogout();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icon_settings.svg',
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
