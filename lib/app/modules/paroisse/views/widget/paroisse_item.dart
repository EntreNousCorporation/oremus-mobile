import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';

class ParoisseItem extends StatelessWidget {
  const ParoisseItem({Key? key, required this.paroisse}) : super(key: key);

  final ContentPlace paroisse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 32.0,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 0,
        color: colorWhite,
        shadowColor: colorGrey2.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: SizedBox(
                    height: Get.width / 2.8,
                    width: double.infinity,
                    child: (paroisse.coverImage?.link?.isNotEmpty == true)
                        ? CachedNetworkImage(
                            imageUrl: paroisse.coverImage?.link ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const LottieLoadingView(size: 10),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : Image.asset(
                            'assets/images/bg_login.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Container(
                  width: Get.width,
                  height: Get.width / 2.8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width / 10),
                    child: Text(
                      '${paroisse.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                          textSize: TextSizes.twenty_four,
                          textColor: colorWhite),
                    ),
                  ),
                ),
              ],
            ),
            Separators.minimunVertical(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${paroisse.diocese?.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyles.montserratBold(
                        textSize: TextSizes.twelve, textColor: colorBlack),
                  ),
                ),
                Separators.minimunHorizontal(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: colorGreen,
                      ),
                      child: Text(
                        'Informations',
                        style: TextStyles.montserratBold(
                            textSize: TextSizes.eleven, textColor: colorWhite),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
