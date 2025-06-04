import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';

class TimeSlotsGrid extends StatelessWidget {
  final List<TimeSlot> slots;
  final bool showActions;
  final Function(int)? onEdit;
  final Function(int)? onDelete;

  const TimeSlotsGrid({
    Key? key,
    required this.slots,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Text(
          'Aucun créneau défini',
          style: TextStyles.montserratRegular(
            textColor: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Container(
          decoration: BoxDecoration(
            color: colorGreenSemiLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorGreenSemiLight.withOpacity(0.3),
            ),
          ),
          child: showActions
              ? Stack(
            children: [
              Center(
                child: Text(
                  slot.getFormattedTime(),
                  style: TextStyles.montserratMedium(
                    textSize: TextSizes.fourteen,
                    textColor: colorGreenSemiLight,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () => onDelete?.call(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
              : Center(
            child: Text(
              slot.getFormattedTime(),
              style: TextStyles.montserratMedium(
                textSize: TextSizes.fourteen,
                textColor: colorGreenSemiLight,
              ),
            ),
          ),
        );
      },
    );
  }
}
