import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';

class ActivityItem extends StatelessWidget {
  ActivityItem({Key? key, required this.activity}) : super(key: key);

  ActivityResponse activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        //color: _isPressed ? colorGreen.withOpacity(0.5) : colorWhite,
        shadowColor: colorGrey2.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/downtime.svg', height: 40, colorBlendMode: BlendMode.plus),
              Separators.normalHorizontal(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activity.name}',
                      style: TextStyles.montserratBold(
                        textSize: TextSizes.sixteen,
                        textColor: colorGreen,
                      ),
                    ),
                    Text(
                      '${activity.description}',
                      style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen,
                        textColor: colorBlack.withOpacity(0.5),
                      ),
                    ),
                    Separators.minimunVertical(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/images/admin.svg',
                          height: 20,
                          color: colorBlack.withOpacity(0.8),
                        ),
                        Separators.minimunHorizontal(),
                        Text(
                          '${activity.organizer}',
                          style: TextStyles.montserratMediumItalic(
                            textSize: TextSizes.fourteen,
                            textColor: colorBlack.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
