import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/favorite/controller/favorite_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/paroisse_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrey4,
      body: GetX<FavoriteController>(
        builder: (_) {
          return PopScope(
            canPop: false,
            child: KeyboardDismisser(
              child: Stack(
                children: [
                  // Header gradient background
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorGreen,
                      borderRadius: const BorderRadius.only(
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
                                    Icons.arrow_back_ios_new_rounded,
                                    color: colorWhite,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _.favorites.isNotEmpty
                                        ? 'Mes favoris (${_.favorites.length})'
                                        : 'Mes favoris',
                                    style: const TextStyle(
                                      color: colorWhite,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Balance for the back button
                            ],
                          ),
                        ),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            'Retrouvez vos paroisses préférées',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Favorites list or empty state
                        Expanded(
                          child: _.favorites.isNotEmpty
                              ? _buildFavoritesList(_)
                              : _buildEmptyState(_),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(FavoriteController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeIn(
        child: AnimatedList(
          key: controller.key,
          physics: const BouncingScrollPhysics(),
          initialItemCount: controller.favorites.length,
          itemBuilder: (context, index, animation) {
            var paroisse = controller.favorites[index];
            return SizeTransition(
              key: UniqueKey(),
              sizeFactor: animation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ParoisseItem(
                    paroisse: paroisse,
                    index: index,
                    fromFavoriteUI: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(FavoriteController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorGreen1.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: colorGreenSemiLight.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Empty state text
          Text(
            'Aucun favori pour le moment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Explorez les paroisses et ajoutez-les à vos favoris pour les retrouver facilement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action button
          ElevatedButton(
            onPressed: () {
              controller.moveToHome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorGreenSemiLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 18),
                SizedBox(width: 8),
                Text(
                  'Explorer les paroisses',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
