import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_worship_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/filter_search_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FilterWorshipScreen extends StatelessWidget {
  const FilterWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        bottom: false,
        child: GetX<FilterWorshipController>(builder: (_) {
          return PopScope(
            canPop: false,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                  color: colorGrey4,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec fond vert et contenu
                      Container(
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        decoration: const BoxDecoration(
                          color: colorGreen,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bouton retour et titre
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        _.goBackToMassRequest();
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: colorWhite,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _.title.value,
                                    style: TextStyles.montserratBold(
                                      textColor: colorWhite,
                                      textSize: TextSizes.twenty,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Titre principal
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Choisir une paroisse',
                                style: TextStyles.montserratBold(
                                  textColor: colorWhite,
                                  textSize: TextSizes.thirty_eight,
                                ),
                              ),
                            ),

                            // Barre de recherche
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                left: 16,
                                right: 16,
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(
                                      Icons.search_rounded,
                                      color: colorGreenSemiLight,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: Center(
                                          child: FilterSearchWidget(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contenu principal (liste des paroisses)
                      Expanded(
                        child: _.isDataProcessing.isTrue
                            ? Center(
                          child: LottieLoadingView(
                            size: Get.width / 4,
                          ),
                        )
                            : _.hasData.isTrue
                            ? FadeIn(
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification: (notification) {
                              notification.disallowIndicator();
                              return false;
                            },
                            child: SmartRefresher(
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
                                  } else if (mode == LoadStatus.loading) {
                                    body = LottieLoadingView();
                                  } else if (mode == LoadStatus.failed) {
                                    body = Text(
                                      "Une erreur est survenue",
                                      style: TextStyles.montserratRegular(
                                          textSize: TextSizes.thirteen,
                                          textColor: colorBlack),
                                    );
                                  } else if (mode == LoadStatus.canLoading) {
                                    body = Text(
                                      "Relâcher pour charger plus",
                                      style: TextStyles.montserratRegular(
                                          textSize: TextSizes.thirteen,
                                          textColor: colorBlack),
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
                              physics: const BouncingScrollPhysics(),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 16,
                                ),
                                itemCount: _.paroisses.length,
                                itemBuilder: (context, index) {
                                  var paroisse = _.paroisses[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        _.worshipSelected.value = paroisse;
                                        _.goBackToMassRequest();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Image de la paroisse
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                bottomLeft: Radius.circular(16),
                                              ),
                                              child: SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: (paroisse?.coverImage?.link?.isNotEmpty == true)
                                                    ? CachedNetworkImage(
                                                  imageUrl: paroisse?.coverImage?.link ?? '',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Center(
                                                    child: LottieLoadingView(size: 30),
                                                  ),
                                                  errorWidget: (context, url, error) =>
                                                  const Icon(Icons.church_outlined,
                                                      size: 40,
                                                      color: colorGreenSemiLight),
                                                )
                                                    : Image.asset(
                                                  'assets/images/bg_login.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                            // Informations sur la paroisse
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Nom de la paroisse
                                                    Text(
                                                      '${paroisse?.name}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyles.montserratSemiBold(
                                                        textSize: TextSizes.fifteen,
                                                        textColor: colorBlack,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),

                                                    // Nom du diocèse
                                                    Text(
                                                      '${paroisse?.diocese?.name}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyles.montserratRegular(
                                                        textSize: TextSizes.thirteen,
                                                        textColor: Colors.grey[700]!,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // Localisation
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.location_on_outlined,
                                                          size: 14,
                                                          color: colorGreenSemiLight,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            paroisse?.address?.municipality ?? 'N/A',
                                                            style: TextStyles.montserratRegular(
                                                              textSize: TextSizes.twelve,
                                                              textColor: colorGreenSemiLight,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Indicateur de sélection
                                            Padding(
                                              padding: const EdgeInsets.only(right: 12),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 16,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                            : _.hasError.isTrue
                            ? NotFoundScreen(
                          message: _.errorMessage.value,
                        )
                            : NotFoundScreen(
                          message: "Aucune paroisse trouvée",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
