import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/about/views/about_screen.dart';
import 'package:oremusapp/app/modules/contact/views/contact_screen.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu.dart';
import 'package:oremusapp/app/modules/donation/views/donation_menu_screen.dart';
import 'package:oremusapp/app/modules/faq/views/faq_screen.dart';
import 'package:oremusapp/app/modules/massrequest/views/mass_request_menu_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';
import 'package:oremusapp/app/modules/pray/views/pray_screen.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:oremusapp/app/modules/profile/views/profile_screen.dart';
import 'package:oremusapp/app/modules/promos/views/promo_screen.dart';
import 'package:oremusapp/app/modules/settings/views/settings_screen.dart';
import 'package:oremusapp/main.dart';

class CustomHomeNewScreen extends StatelessWidget {
  const CustomHomeNewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: GetBuilder<CustomHomeController>(builder: (logic) {
        return SimpleHiddenDrawer(
          menu: const DrawerMenu(),
          withShadow: false,
          slidePercent: 70, // en %
          screenSelectedBuilder: (position, controller) {
            logic.drawerController = controller;
            Widget? screenCurrent;
            switch (logic.menus[position].code) {
              case AppConstants.HOME:
                logic.title.value = 'Oremus';
                screenCurrent = const ParoisseScreen();
                break;
              case AppConstants.PROFILE:
                logic.title.value = logic.menus[position].libelle ?? 'Mon Profil';
                screenCurrent = const ProfileScreen();
                break;
              case AppConstants.PRAY:
                logic.title.value = logic.menus[position].libelle ?? 'Mini Missel';
                screenCurrent = const PrayScreen();
                break;
              case AppConstants.REQUEST_MASS_WITHOUT_WORSHIP:
                logic.title.value = logic.menus[position].libelle ?? 'Demande de messe';
                screenCurrent = const MassRequestMenuScreen();
                break;
              case AppConstants.DONATION_WITHOUT_WORSHIP:
                logic.title.value = logic.menus[position].libelle ?? 'Faire un don';
                screenCurrent = const DonationMenuScreen();
                break;
              case AppConstants.PROMO:
                logic.title.value = logic.menus[position].libelle ?? 'Codes promo';
                screenCurrent = const PromoScreen();
                break;
              case AppConstants.FAQ:
                logic.title.value = logic.menus[position].libelle ?? 'F.A.Q';
                screenCurrent = const FaqScreen();
                break;
              case AppConstants.CONTACTS:
                logic.title.value = logic.menus[position].libelle ?? 'Contacts';
                screenCurrent = const ContactScreen();
                break;
              case AppConstants.ABOUT:
                logic.title.value = logic.menus[position].libelle ?? 'A propos';
                screenCurrent = const AboutScreen();
                break;
              case AppConstants.SETTINGS:
                logic.title.value = logic.menus[position].libelle ?? 'Paramètres';
                screenCurrent = const SettingsScreen();
                break;
            }

            // L'écran est-il la page d'accueil principale?
            final bool isHomePage = logic.menus[position].code == AppConstants.HOME;

            return Scaffold(
              backgroundColor: colorGrey4,
              body: Stack(
                children: [
                  // Header gradient background
                  Container(
                    height: isHomePage ? 260 : 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: colorGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Custom app bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    color: colorWhite,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    controller.toggle();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    logic.title.value,
                                    style: TextStyles.montserratBold(
                                      textColor: colorWhite,
                                      textSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // Action buttons
                              if (isUserConnected.value &&
                                  logic.menus[logic.selectedIndex.value].code == AppConstants.PROFILE &&
                                  logic.userCanUpdateProfile())
                                GetBuilder<ProfileController>(
                                    builder: (profileLogic) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit_rounded,
                                            color: colorWhite,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            profileLogic.goToEditProfile();
                                          },
                                        ),
                                      );
                                    }
                                ),
                              if (logic.menus[logic.selectedIndex.value].code == AppConstants.HOME)
                                GetBuilder<CustomHomeController>(
                                    builder: (homeLogic) {
                                      return Bounce(
                                        key: homeLogic.basicIconAnimation,
                                        preferences: AnimationPreferences(
                                          offset: const Duration(seconds: 3),
                                          autoPlay: homeLogic.applyAnimation(),
                                          magnitude: 0.3,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.favorite_border_outlined,
                                              color: colorWhite,
                                              size: 22,
                                            ),
                                            onPressed: () {
                                              homeLogic.goToFavorites();
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                ),
                            ],
                          ),
                        ),

                        // Welcome section for home page only
                        //if (isHomePage) _buildWelcomeSection(),

                        // Content area
                        Expanded(
                          child: screenCurrent!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // App Logo
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 40,
            ),
          ),
        ),

        // Welcome text
        const Text(
          'Bienvenue sur Oremus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorWhite,
          ),
        ),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Text(
            'Trouvez facilement des informations sur vos paroisses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),

        //const SizedBox(height: 16),
      ],
    );
  }
}

// Suggestion for the ParoisseScreen redesign
class ModernParoisseScreen extends StatelessWidget {
  const ModernParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une paroisse...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: colorGreenSemiLight,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Categories section
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 8),
            child: Text(
              'Catégories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryChip('Toutes', isSelected: true),
                _buildCategoryChip('À proximité'),
                _buildCategoryChip('Populaires'),
                _buildCategoryChip('Récentes'),
                _buildCategoryChip('Favorites'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Paroisses list section
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paroisses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorGreenSemiLight,
                  ),
                ),
              ],
            ),
          ),

          // ParoisseScreen content will be injected here
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        selectedColor: colorGreenSemiLight,
        onSelected: (bool selected) {
          // Handle category selection
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
