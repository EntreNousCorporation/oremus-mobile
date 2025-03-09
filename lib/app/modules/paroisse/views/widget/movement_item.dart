import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';

class MovementItem extends StatelessWidget {
  final MovementResponse movement;

  const MovementItem({Key? key, required this.movement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      elevation: 10,
      color: colorWhite,
      shadowColor: colorGrey2.withValues(alpha: 0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          _showMovementDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et nom
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icône du mouvement avec cercle de fond
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorGreen.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/movement.svg',
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                            colorGreen,
                            BlendMode.srcIn
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nom et lieu de réunion
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.name ?? 'Mouvement',
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen,
                            textColor: colorGreenSemiLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Lieu de réunion
                        if (movement.meetingPlace != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: colorBlack.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  movement.meetingPlace!,
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.twelve,
                                    textColor: colorBlack.withValues(alpha: 0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Badge avec ID
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${movement.identifier}',
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.twelve,
                        textColor: colorGreenSemiLight,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Description
              Text(
                movement.description ?? 'Description du mouvement',
                style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen,
                  textColor: colorBlack.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Horaires et Contacts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horaires
                  if (movement.openingTime != null && movement.openingTime!.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoHeader(
                            icon: Icons.access_time,
                            label: 'Horaires',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatOpeningTime(movement.openingTime!.first),
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.twelve,
                              textColor: colorBlack.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Contacts
                  if (movement.contact != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoHeader(
                            icon: Icons.phone,
                            label: 'Contact',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movement.contact!.numbers != null && movement.contact!.numbers!.isNotEmpty
                                ? movement.contact!.numbers!.first
                                : 'Non disponible',
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.twelve,
                              textColor: colorBlack.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Responsables
              Row(
                children: [
                  // Leader
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorGrey2.withValues(alpha: 0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/admin.svg',
                            height: 16,
                            colorFilter: ColorFilter.mode(
                                colorGreenSemiLight.withValues(alpha: 0.8),
                                BlendMode.srcIn
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Resp: ${movement.leader ?? "Non défini"}',
                              style: TextStyles.montserratMedium(
                                textSize: TextSizes.twelve,
                                textColor: colorGreenSemiLight.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Aumônier
                  if (movement.chaplain != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: colorGreenSemiLight.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Aum: ${movement.chaplain!.firstname} ${movement.chaplain!.lastname}',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.twelve,
                                  textColor: colorGreenSemiLight.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget d'en-tête pour les informations
  Widget _buildInfoHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: colorGreenSemiLight,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyles.montserratBold(
            textSize: TextSizes.twelve,
            textColor: colorGreenSemiLight,
          ),
        ),
      ],
    );
  }

  // Formater les horaires d'ouverture
  String _formatOpeningTime(dynamic openingTime) {
    if (openingTime == null || openingTime.slots == null || openingTime.slots.isEmpty) {
      return 'Horaires non disponibles';
    }

    final days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final dayName = days[openingTime.dayOfWeek % 7];

    final slot = openingTime.slots.first;
    final start = _formatTimeString(slot.startTime);
    final end = _formatTimeString(slot.endTime);

    return '$dayName $start - $end';
  }

  // Formater une chaîne de temps HH:MM:SS en format plus lisible
  String _formatTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      return '${timeParts[0]}h${timeParts[1]}';
    } catch (e) {
      return timeString;
    }
  }

  // Afficher les détails du mouvement
  void _showMovementDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 16,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de tirage
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorGrey2.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(width: 36),
            ),

            // Titre
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorGreen.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/movement.svg',
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                            colorGreen,
                            BlendMode.srcIn
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.name ?? 'Mouvement',
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.twenty,
                            textColor: colorGreenSemiLight,
                          ),
                        ),
                        Text(
                          'ID: ${movement.identifier}',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.twelve,
                            textColor: colorBlack.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contenu détaillé
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    _buildDetailSection(
                      title: 'Description',
                      icon: Icons.description,
                      content: movement.description ?? 'Aucune description disponible',
                    ),

                    const SizedBox(height: 16),

                    // Lieu de réunion
                    _buildDetailSection(
                      title: 'Lieu de réunion',
                      icon: Icons.location_on,
                      content: movement.meetingPlace ?? 'Non spécifié',
                    ),

                    const SizedBox(height: 16),

                    // Horaires
                    if (movement.openingTime != null && movement.openingTime!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Horaires', Icons.access_time),
                          const SizedBox(height: 8),
                          Column(
                            children: List.generate(
                              movement.openingTime!.length,
                                  (index) => _buildScheduleItem(movement.openingTime![index]),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Responsables
                    Row(
                      children: [
                        // Leader
                        Expanded(
                          child: _buildContactCard(
                            title: 'Responsable',
                            name: movement.leader ?? 'Non défini',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Aumônier
                        if (movement.chaplain != null)
                          Expanded(
                            child: _buildContactCard(
                              title: 'Aumônier',
                              name: '${movement.chaplain!.firstname} ${movement.chaplain!.lastname}',
                              secondaryInfo: movement.chaplain!.email,
                              icon: Icons.church,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Contacts
                    if (movement.contact != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Informations de contact', Icons.contact_phone),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorGrey2.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (movement.contact!.name != null)
                                  _buildContactItem(
                                    icon: Icons.person,
                                    label: movement.contact!.name!,
                                  ),

                                if (movement.contact!.numbers != null && movement.contact!.numbers!.isNotEmpty)
                                  ...(movement.contact!.numbers!.map((number) =>
                                      _buildContactItem(
                                        icon: Icons.phone,
                                        label: number,
                                        isClickable: true,
                                      )
                                  )).toList(),

                                if (movement.contact!.emails != null && movement.contact!.emails!.isNotEmpty)
                                  ...(movement.contact!.emails!.map((email) =>
                                      _buildContactItem(
                                        icon: Icons.email,
                                        label: email,
                                        isClickable: true,
                                      )
                                  )).toList(),

                                if (movement.contact!.fax != null)
                                  _buildContactItem(
                                    icon: Icons.print,
                                    label: 'Fax: ${movement.contact!.fax}',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section détaillée
  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorGrey2.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyles.montserratRegular(
              textSize: TextSizes.fourteen,
              textColor: colorBlack.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  // Titre de section
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorGreenSemiLight,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyles.montserratBold(
            textSize: TextSizes.sixteen,
            textColor: colorGreenSemiLight,
          ),
        ),
      ],
    );
  }

  // Élément d'horaire
  Widget _buildScheduleItem(dynamic openingTime) {
    if (openingTime == null || openingTime.slots == null || openingTime.slots.isEmpty) {
      return const SizedBox.shrink();
    }

    final days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    final dayName = days[openingTime.dayOfWeek % 7];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorGrey2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorGreenSemiLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                days[openingTime.dayOfWeek % 7].substring(0, 3),
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twelve,
                  textColor: colorGreenSemiLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: TextStyles.montserratBold(
                    textSize: TextSizes.fourteen,
                    textColor: colorBlack.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                ...(openingTime.slots.map<Widget>((slot) {
                  final start = _formatTimeString(slot.startTime);
                  final end = _formatTimeString(slot.endTime);
                  return Text(
                    '$start - $end',
                    style: TextStyles.montserratRegular(
                      textSize: TextSizes.fourteen,
                      textColor: colorBlack.withValues(alpha: 0.7),
                    ),
                  );
                })).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Carte de contact
  Widget _buildContactCard({
    required String title,
    required String name,
    String? secondaryInfo,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorGrey2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colorGreenSemiLight,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twelve,
                  textColor: colorGreenSemiLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyles.montserratMedium(
              textSize: TextSizes.fourteen,
              textColor: colorBlack.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (secondaryInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              secondaryInfo,
              style: TextStyles.montserratRegular(
                textSize: TextSizes.twelve,
                textColor: colorBlack.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // Élément de contact
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isClickable ? colorGreenSemiLight : colorBlack.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyles.montserratRegular(
                textSize: TextSizes.fourteen,
                textColor: isClickable ? colorGreenSemiLight : colorBlack.withValues(alpha: 0.8),
                textDecoration: isClickable ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
          if (isClickable)
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: colorGreenSemiLight.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
  }
}