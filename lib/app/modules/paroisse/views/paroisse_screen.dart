import 'package:badges/badges.dart' as b;
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/paroisse_item.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseScreen extends StatefulWidget {
  const ParoisseScreen({Key? key}) : super(key: key);

  @override
  State<ParoisseScreen> createState() => _ParoisseScreenState();
}

class _ParoisseScreenState extends State<ParoisseScreen> with TickerProviderStateMixin {
  late Worker _extendedWorker;
  Offset? _fabPosition; // Position du FAB
  double fabSize = 250.0; // Taille par défaut du FAB
  bool _isSubMenuOpen = false;

  // Animation pour le sous-menu
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // Animation pour la transition entre compact et étendu
  late AnimationController _sizeAnimationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialisation de l'animation pour le sous-menu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialisation des animations pour la transition entre compact et étendu
    _sizeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _widthAnimation = Tween<double>(begin: 75.0, end: 250.0).animate(
      CurvedAnimation(
        parent: _sizeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sizeAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _sizeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialiser l'écouteur après un court délai pour s'assurer que le contrôleur est prêt
    Future.delayed(Duration.zero, () {
      final controller = Get.find<ParoisseController>();

      // Stockez la référence à l'écouteur pour pouvoir l'annuler plus tard
      _extendedWorker = ever(controller.isExtended, (value) {
        // Vérifiez si le widget est toujours monté avant d'utiliser les contrôleurs d'animation
        if (mounted) {
          if (value == true) {
            _sizeAnimationController.forward();
          } else {
            _sizeAnimationController.reverse();
          }
        }
      });

      // Initialiser l'état de l'animation en fonction de l'état actuel
      if (controller.isExtended.isTrue) {
        _sizeAnimationController.value = 1.0;
      } else {
        _sizeAnimationController.value = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _extendedWorker.dispose();
    _animationController.dispose();
    _sizeAnimationController.dispose();
    super.dispose();
  }

  void _toggleSubMenu() {
    setState(() {
      _isSubMenuOpen = !_isSubMenuOpen;
      if (_isSubMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si la position initiale n'est pas encore définie, la définir en bas à droite
    _fabPosition ??= Offset(
      Get.width - fabSize - 16.0, // 16.0 pour une petite marge du bord
      Get.height - 150 - 16.0 - kToolbarHeight - MediaQuery.of(context).padding.top, // Compense la AppBar et la barre de statut
    );

    return Container(
      color: colorGreen,
      child: GetX<ParoisseController>(builder: (_) {
        return PopScope(
          canPop: false,
          child: KeyboardDismisser(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Stack(
                children: [
                  Container(
                    color: colorGrey4,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 0,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _.doLaunchSimpleSearch();
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(10.0),
                                  elevation: 10,
                                  color: colorWhite,
                                  shadowColor: colorGrey2.withValues(alpha: 0.5),
                                  child: SizedBox(
                                    height: (Get.width / 9),
                                    width: (Get.width / 9),
                                    child: const Icon(
                                      Icons.search_rounded,
                                      color: colorPurpleLight,
                                    ),
                                  ),
                                ),
                              ),
                              Separators.normalHorizontal(),
                              Expanded(
                                child: SizedBox(
                                  height: (Get.width / 9),
                                  child: const SearchWidget(),
                                ),
                              ),
                              Separators.normalHorizontal(),
                              GestureDetector(
                                onTap: () {
                                  _.goToAdvancedSearch();
                                },
                                child: Material(
                                    borderRadius: BorderRadius.circular(10.0),
                                    elevation: 10,
                                    color: colorWhite,
                                    shadowColor: colorGrey2.withValues(alpha: 0.5),
                                    child: b.Badge(
                                      showBadge: (_.searchCriteria.value
                                          .isCriteriaEmpty ==
                                          false)
                                          ? true
                                          : false,
                                      position: b.BadgePosition.topEnd(
                                          top: -10, end: -5),
                                      badgeContent: Text(
                                        '${_.searchCriteria.value.countCriteria}',
                                        style: TextStyles.montserratRegular(
                                            textColor: colorWhite,
                                            textSize: TextSizes.thirteen),
                                      ),
                                      child: SizedBox(
                                        height: (Get.width / 9),
                                        width: (Get.width / 9),
                                        child: const Icon(
                                          Icons.filter_list_rounded,
                                          color: colorPurpleLight,
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Separators.minimunVertical(),
                        _.isDataProcessing.isTrue
                            ? Expanded(
                          child: Center(
                            child: LottieLoadingView(
                              size: Get.width / 4,
                            ),
                          ),
                        )
                            : _.hasData.isTrue
                            ? Expanded(
                          child: FadeIn(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 0,
                                bottom: 0,
                                left: 16,
                                right: 16,
                              ),
                              child: NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (notification) {
                                  notification.disallowIndicator();
                                  return false;
                                },
                                child: SmartRefresher(
                                  scrollController: _.scrollController,
                                  enablePullDown: true,
                                  enablePullUp: true,
                                  onRefresh: _.onRefresh,
                                  onLoading: _.onLoading,
                                  header: const CustomClassicHeader(),
                                  footer: CustomFooter(
                                    builder: (BuildContext context,
                                        LoadStatus? mode) {
                                      Widget body;
                                      if (mode == LoadStatus.idle) {
                                        body = Container();
                                      } else if (mode ==
                                          LoadStatus.loading) {
                                        body = LottieLoadingView();
                                      } else if (mode ==
                                          LoadStatus.failed) {
                                        body = Text(
                                          "Une erreur est survenue lors du chargement",
                                          style: TextStyles
                                              .montserratBold(
                                              textSize:
                                              TextSizes
                                                  .thirteen,
                                              textColor:
                                              colorBlack),
                                        );
                                      } else if (mode ==
                                          LoadStatus.canLoading) {
                                        body = Text(
                                          "Relacher pour charger plus de paroisses",
                                          style: TextStyles
                                              .montserratBold(
                                              textSize:
                                              TextSizes
                                                  .thirteen,
                                              textColor:
                                              colorBlack),
                                        );
                                      } else {
                                        body = Visibility(
                                          visible: false,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width:
                                                Get.width / 1.7,
                                                height: 4,
                                                child: Container(
                                                  decoration:
                                                  BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10),
                                                    gradient:
                                                    const LinearGradient(
                                                      begin: Alignment
                                                          .topRight,
                                                      end: Alignment
                                                          .bottomLeft,
                                                      colors: [
                                                        colorGreen,
                                                        colorGreenSemiLight,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Separators
                                                  .minimunVertical(),
                                              Text(
                                                "Aucune donnée à charger",
                                                style: TextStyles
                                                    .montserratBold(
                                                    textSize:
                                                    TextSizes
                                                        .thirteen,
                                                    textColor:
                                                    colorBlack),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 55.0,
                                        child: Center(child: body),
                                      );
                                    },
                                  ),
                                  controller: _.refreshController,
                                  physics:
                                  const BouncingScrollPhysics(),
                                  child: ListView.separated(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 16),
                                    shrinkWrap: false,
                                    itemCount: _.paroisses.length,
                                    itemBuilder: (builder, index) {
                                      var paroisse = _.paroisses[index];
                                      return ParoisseItem(
                                        paroisse: paroisse,
                                        index: index,
                                        key: ValueKey(paroisse?.identifier),
                                      );
                                    },
                                    separatorBuilder: (builder, index) {
                                      return Separators.maximum1Vertical();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                            : Expanded(
                          child: NotFoundScreen(
                            message: "Aucune paroisse trouvée !",
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Widget de menu flottant avec sous-menu
                  Positioned(
                    left: _fabPosition!.dx,
                    top: _fabPosition!.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        // Si le sous-menu est ouvert, on ne déplace pas le bouton
                        if (!_isSubMenuOpen) {
                          setState(() {
                            double newX = _fabPosition!.dx + details.delta.dx;
                            double newY = _fabPosition!.dy + details.delta.dy;

                            // Limiter la position à l'intérieur des bords de l'écran
                            if (_.isExtended.isTrue) {
                              newX = newX.clamp(0.0, Get.width - 250);
                              newY = newY.clamp(0.0, Get.height - 150 - kToolbarHeight - MediaQuery.of(context).padding.top);
                            } else {
                              newX = newX.clamp(0.0, Get.width - 70);
                              newY = newY.clamp(0.0, Get.height - 150 - kToolbarHeight - MediaQuery.of(context).padding.top);
                            }

                            _fabPosition = Offset(newX, newY);
                          });
                        }
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Sous-menu
                            SizeTransition(
                              sizeFactor: _expandAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black26,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 250.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: colorGreen.withValues(alpha: 0.9),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Option Demande de messe
                                          InkWell(
                                            onTap: () {
                                              _toggleSubMenu(); // Ferme le sous-menu
                                              _.doMoveRequestMass(); // Fonction existante
                                            },
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 16.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    Assets.imagesMesse,
                                                    height: 24,
                                                    colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "Demande de messe",
                                                    style: TextStyles.montserratSemiBold(
                                                      textSize: TextSizes.fifteen,
                                                      textColor: colorWhite,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Séparateur
                                          Container(
                                            height: 1,
                                            color: Colors.white.withValues(alpha: 0.3),
                                            margin: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          // Option Faire un don
                                          InkWell(
                                            onTap: () {
                                              _toggleSubMenu(); // Ferme le sous-menu
                                              _.doMakeDonation();
                                            },
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 16.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    Assets.imagesVolunteer,
                                                    height: 24,
                                                    colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "Faire un don",
                                                    style: TextStyles.montserratSemiBold(
                                                      textSize: TextSizes.fifteen,
                                                      textColor: colorWhite,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            // Bouton principal avec animation fluide
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutBack,
                              width: _.isExtended.isTrue ? 250.0 : 75.0,
                              height: 75.0,
                              child: Material(
                                color: _isSubMenuOpen ? colorGreen.withValues(alpha: 0.8) : colorGreen,
                                elevation: 6.0,
                                shadowColor: colorGreen,
                                shape: const StadiumBorder(),
                                child: InkWell(
                                  onTap: _toggleSubMenu,
                                  customBorder: const StadiumBorder(),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: _.isExtended.isTrue ? 16.0 : 0.0),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _.isExtended.isTrue
                                          ? Row(
                                        key: const ValueKey('extended'),
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SvgPicture.asset(
                                            Assets.imagesMesse,
                                            height: 35,
                                            colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Menu paroissial",
                                              style: TextStyles.montserratSemiBold(
                                                textSize: TextSizes.fifteen,
                                                textColor: colorWhite,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          AnimatedRotation(
                                            turns: _isSubMenuOpen ? 0.5 : 0.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: colorWhite,
                                            ),
                                          ),
                                        ],
                                      )
                                          : Stack(
                                        key: const ValueKey('compact'),
                                        clipBehavior: Clip.none,
                                        children: [
                                          SvgPicture.asset(
                                            Assets.imagesMesse,
                                            height: 35,
                                            colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                          ),
                                          Positioned(
                                            right: -10,
                                            bottom: -5,
                                            child: AnimatedRotation(
                                              turns: _isSubMenuOpen ? 0.5 : 0.0,
                                              duration: const Duration(milliseconds: 200),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: colorGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: colorWhite,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}