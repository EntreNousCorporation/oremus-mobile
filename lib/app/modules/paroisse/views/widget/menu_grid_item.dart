import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';

class MenuGridItem extends StatefulWidget {
  const MenuGridItem({Key? key, required this.item}) : super(key: key);

  final TypeMenu item;

  @override
  _MenuGridItemState createState() => _MenuGridItemState();
}

class _MenuGridItemState extends State<MenuGridItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  get item => widget.item;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _animatedButton(Function destination) {
    if (!mounted) return;
    setState(() => _isPressed = true);
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            destination.call();
            _isPressed = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: item.goToPage != null
                ? () {
              _animatedButton(item.goToPage);
            }
                : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                borderRadius: BorderRadius.circular(16.0),
                color: _isPressed ? item.bgColor.withValues(alpha: 0.9) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: item.bgColor.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: item.isPngImage
                              ? Image.asset(
                            item.icon,
                            height: 30,
                            color: item.activeTint,
                          )
                              : SvgPicture.asset(
                            item.icon,
                            height: 28,
                            colorFilter: ColorFilter.mode(item.activeTint, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Titre
                      Hero(
                        tag: item.code,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.fourteen,
                            textColor: _isPressed ? colorBlue : colorBlack,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
