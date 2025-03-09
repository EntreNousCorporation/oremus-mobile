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

class _ParoisseScreenState extends State<ParoisseScreen>
    with TickerProviderStateMixin {
  late Worker _extendedWorker;
  Offset? _fabPosition; // Position du FAB
  bool _isSubMenuOpen = false;

  // Animation pour le sous-menu
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // Animation pour la transition entre compact et étendu
  late AnimationController _sizeAnimationController;
  late Animation<double> _widthAnimation;

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
      Get.width - 250 - 16.0, // 16.0 pour une petite marge du bord
      Get.height -
          150 -
          16.0 -
          kToolbarHeight -
          MediaQuery.of(context)
              .padding
              .top, // Compense la AppBar et la barre de statut
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
                  // Header avec fond vert
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 130,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: colorGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),

                  // Contenu principal
                  Column(
                    children: [
                      // Barre de recherche
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                'Paroisses',
                                style: TextStyles.montserratBold(
                                  textColor: colorWhite,
                                  textSize: TextSizes.thirty_two,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Barre de recherche avec filtres
                              Container(
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Bouton de recherche
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: colorGreenSemiLight,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _.doLaunchSimpleSearch();
                                        },
                                        icon: const Icon(
                                          Icons.search_rounded,
                                          color: colorWhite,
                                          size: 24,
                                        ),
                                      ),
                                    ),

                                    // Champ de recherche
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: const Center(
                                          child: SearchWidget(),
                                        ),
                                      ),
                                    ),

                                    // Bouton de filtres
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: colorWhite,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _.goToAdvancedSearch();
                                        },
                                        icon: b.Badge(
                                          showBadge: (_.searchCriteria.value
                                                  .isCriteriaEmpty ==
                                              false),
                                          position: b.BadgePosition.topEnd(
                                              top: -8, end: -8),
                                          badgeColor: colorGreenSemiLight,
                                          padding: EdgeInsets.all(6),
                                          badgeContent: Text(
                                            '${_.searchCriteria.value.countCriteria}',
                                            style: TextStyles.montserratBold(
                                              textColor: colorWhite,
                                              textSize: TextSizes.eleven,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.filter_list_rounded,
                                            color: colorGreenSemiLight,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Liste des paroisses
                      Expanded(
                        child: Container(
                          color: colorGrey4,
                          child: _.isDataProcessing.isTrue
                              ? Center(
                                  child: LottieLoadingView(
                                    size: Get.width / 4,
                                  ),
                                )
                              : _.hasData.isTrue
                                  ? FadeIn(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: NotificationListener<
                                            OverscrollIndicatorNotification>(
                                          onNotification: (notification) {
                                            notification.disallowIndicator();
                                            return false;
                                          },
                                          child: SmartRefresher(
                                            scrollController:
                                                _.scrollController,
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
                                                    "Une erreur est survenue",
                                                    style: TextStyles
                                                        .montserratMedium(
                                                            textSize: TextSizes
                                                                .thirteen,
                                                            textColor:
                                                                colorBlack),
                                                  );
                                                } else if (mode ==
                                                    LoadStatus.canLoading) {
                                                  body = Text(
                                                    "Relâcher pour charger plus",
                                                    style: TextStyles
                                                        .montserratMedium(
                                                            textSize: TextSizes
                                                                .thirteen,
                                                            textColor:
                                                                colorBlack),
                                                  );
                                                } else {
                                                  body = Container();
                                                }
                                                return SizedBox(
                                                  height: 50.0,
                                                  child: Center(child: body),
                                                );
                                              },
                                            ),
                                            controller: _.refreshController,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            child: ListView.builder(
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 100),
                                              shrinkWrap: false,
                                              itemCount: _.paroisses.length,
                                              itemBuilder: (builder, index) {
                                                var paroisse =
                                                    _.paroisses[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 16),
                                                  child: ParoisseItem(
                                                    paroisse: paroisse,
                                                    index: index,
                                                    key: ValueKey(
                                                        paroisse?.identifier),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : NotFoundScreen(
                                      message: "Aucune paroisse trouvée !",
                                    ),
                        ),
                      ),
                    ],
                  ),

                  // Menu flottant avec sous-menu
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
                              newY = newY.clamp(
                                  0.0,
                                  Get.height -
                                      150 -
                                      kToolbarHeight -
                                      MediaQuery.of(context).padding.top);
                            } else {
                              newX = newX.clamp(0.0, Get.width - 70);
                              newY = newY.clamp(
                                  0.0,
                                  Get.height -
                                      150 -
                                      kToolbarHeight -
                                      MediaQuery.of(context).padding.top);
                            }

                            _fabPosition = Offset(newX, newY);
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Sous-menu avec animation
                          SizeTransition(
                            sizeFactor: _expandAnimation,
                            axisAlignment: 1.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [colorGreen, colorGreenSemiLight],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Option Demande de messe
                                      menuItem(
                                        icon: Assets.imagesMesse,
                                        title: "Demande de messe",
                                        isFirst: true,
                                        isLast: false,
                                        onTap: () {
                                          _toggleSubMenu();
                                          _.doMoveRequestMass();
                                        },
                                      ),

                                      // Séparateur
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Container(
                                          height: 1,
                                          color: Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),

                                      // Option Faire un don
                                      menuItem(
                                        icon: Assets.imagesVolunteer,
                                        title: "Faire un don",
                                        isFirst: false,
                                        isLast: true,
                                        onTap: () {
                                          _toggleSubMenu();
                                          _.doMakeDonation();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bouton principal
                          AnimatedBuilder(
                            animation: _sizeAnimationController,
                            builder: (context, child) {
                              final width = _.isExtended.isTrue ? 250.0 : 75.0;
                              return Container(
                                width: width,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [colorGreen, colorGreenSemiLight],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorGreen.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _toggleSubMenu,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: _.isExtended.isTrue
                                            ? MainAxisAlignment.spaceBetween
                                            : MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            Assets.imagesMesse,
                                            height: 28,
                                            colorFilter: const ColorFilter.mode(
                                                colorWhite, BlendMode.srcIn),
                                          ),
                                          if (_.isExtended.isTrue) ...[
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Menu paroissial",
                                                style: TextStyles
                                                    .montserratSemiBold(
                                                  textSize: TextSizes.fifteen,
                                                  textColor: colorWhite,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            AnimatedRotation(
                                              turns: _isSubMenuOpen ? 0.5 : 0.0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: const Icon(
                                                Icons.keyboard_arrow_up,
                                                color: colorWhite,
                                              ),
                                            ),
                                          ] else
                                            // Petite flèche en mode compact
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: AnimatedRotation(
                                                turns:
                                                    _isSubMenuOpen ? 0.5 : 0.0,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: const Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: colorWhite,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget menuItem({
    required String icon,
    required String title,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? 16 : 0),
        topRight: Radius.circular(isFirst ? 16 : 0),
        bottomLeft: Radius.circular(isLast ? 16 : 0),
        bottomRight: Radius.circular(isLast ? 16 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 24,
              colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyles.montserratSemiBold(
                textSize: TextSizes.fifteen,
                textColor: colorWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
