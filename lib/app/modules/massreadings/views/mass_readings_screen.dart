import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massreadings/controller/mass_readings_controller.dart';
import 'package:oremusapp/app/modules/massreadings/data/model/mass_readings.dart';

/// Ecran de consultation des lectures de la messe du jour.
/// Onglets par type de lecture (trait de surbrillance), swipe horizontal.
class MassReadingsScreen extends StatelessWidget {
  const MassReadingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: SafeArea(
        bottom: false,
        child: GetX<MassReadingsController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: colorGreen),
              );
            }
            if (controller.hasError.value) {
              return _stateMessage(
                icon: Icons.wifi_off_rounded,
                message:
                    "Les lectures du jour ne sont pas disponibles pour le moment.",
                onRetry: controller.loadToday,
              );
            }
            final data = controller.massReadings.value;
            if (data == null || data.readings.isEmpty) {
              return _stateMessage(
                icon: Icons.menu_book_rounded,
                message: "Aucune lecture disponible pour aujourd'hui.",
                onRetry: controller.loadToday,
              );
            }
            return _ReadingsPager(data: data);
          },
        ),
      ),
    );
  }

  Widget _stateMessage({
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorGrey1),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.montserratRegular(
                textSize: TextSizes.fifteen,
                textColor: colorGrey1,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: colorGreen),
              label: Text(
                'Réessayer',
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.fourteen,
                  textColor: colorGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lectures en onglets : un onglet par type, trait sous l'onglet actif,
/// contenu swipable (TabBarView). Montre d'emblée toutes les lectures.
class _ReadingsPager extends StatefulWidget {
  final MassReadings data;

  const _ReadingsPager({required this.data});

  @override
  State<_ReadingsPager> createState() => _ReadingsPagerState();
}

class _ReadingsPagerState extends State<_ReadingsPager>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.data.readings.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _accent => _liturgicalColor(widget.data.couleur);

  @override
  Widget build(BuildContext context) {
    final readings = widget.data.readings;
    return Column(
      children: [
        _header(),
        // Onglets par type de lecture : trait sous l'onglet actif.
        Material(
          color: colorWhite,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            // Onglets groupés à gauche (marge de début), espacés par la droite ;
            // scroll horizontal si les libellés dépassent la largeur.
            padding: const EdgeInsets.only(left: 16),
            labelPadding: const EdgeInsets.only(right: 24),
            indicatorColor: _accent,
            indicatorWeight: 3,
            dividerColor: colorGrey2,
            labelColor: _accent,
            unselectedLabelColor: colorGrey1,
            labelStyle: TextStyles.montserratBold(
              textSize: TextSizes.fourteen,
              textColor: _accent,
            ),
            unselectedLabelStyle: TextStyles.montserratMedium(
              textSize: TextSizes.fourteen,
              textColor: colorGrey1,
            ),
            tabs: readings
                .map((r) => Tab(text: _typeTabLabel(r.type)))
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: readings.map(_readingContent).toList(),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    final data = widget.data;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: colorBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_rounded, color: _accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data.jourLiturgique?.isNotEmpty == true)
                      ? data.jourLiturgique!
                      : 'Messe du jour',
                  style: TextStyles.montserratBold(
                    textSize: TextSizes.sixteen,
                    textColor: colorGreenSemiLight,
                  ),
                ),
                if (data.degre?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.degre!,
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.thirteen,
                      textColor: _accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingContent(Reading reading) {
    // Avec intro lue (évangile, 1re lecture) : l'intro se fige en haut au scroll.
    if (reading.introLue?.isNotEmpty == true) {
      return _readingWithStickyIntro(reading);
    }
    return _readingSimple(reading);
  }

  /// Lecture avec introduction lue figée (sticky) pendant le scroll du texte.
  Widget _readingWithStickyIntro(Reading reading) {
    return CustomScrollView(
      slivers: [
        // Défile : titre puis verset d'acclamation (évangile).
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reading.titre?.isNotEmpty == true) ...[
                  Text(
                    reading.titre!,
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.sixteen,
                      textColor: colorGreenSemiLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (reading.versetEvangile?.isNotEmpty == true) ...[
                  _highlightBlock(reading.versetEvangile!),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        // Intro lue : se colle en haut au scroll, reprend sa place au retour.
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyIntroDelegate(
            html: reading.introLue!,
          ),
        ),
        // Défile sous l'intro : référence puis texte.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reading.reference?.isNotEmpty == true) ...[
                  Text(
                    reading.reference!,
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.fourteen,
                      textColor: colorGrey1,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _bodyHtml(reading.contenu),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Lecture sans intro (psaume…) : scroll simple, refrain en évidence.
  Widget _readingSimple(Reading reading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reading.titre?.isNotEmpty == true) ...[
            Text(
              reading.titre!,
              style: TextStyles.montserratBold(
                textSize: TextSizes.sixteen,
                textColor: colorGreenSemiLight,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reading.refrainPsalmique?.isNotEmpty == true) ...[
                    _highlightBlock(reading.refrainPsalmique!),
                    const SizedBox(height: 12),
                  ],
                  if (reading.reference?.isNotEmpty == true) ...[
                    Text(
                      reading.reference!,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.fourteen,
                        textColor: colorGrey1,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _bodyHtml(reading.contenu),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyHtml(String? html) {
    return Html(
      data: html ?? '',
      style: {
        '#': Style(
          fontFamily: 'montserrat_regular',
          fontSize: FontSize(TextSizes.fifteen),
          lineHeight: LineHeight.number(1.5),
          margin: Margins.zero,
        ),
      },
    );
  }

  /// Bloc HTML mis en évidence (refrain psalmique, verset d'évangile).
  Widget _highlightBlock(String html) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _accent, width: 3)),
      ),
      child: Html(
        data: html,
        style: {
          '#': Style(
            fontFamily: 'montserrat_bold',
            fontSize: FontSize(TextSizes.fifteen),
            color: _accent,
            margin: Margins.zero,
          ),
        },
      ),
    );
  }

  /// Libelle du type de lecture pour les onglets.
  String _typeTabLabel(String? type) {
    switch (type) {
      case 'lecture_1':
        return 'Première lecture';
      case 'lecture_2':
        return 'Deuxième lecture';
      case 'lecture_3':
        return 'Troisième lecture';
      case 'psaume':
        return 'Psaume';
      case 'cantique':
        return 'Cantique';
      case 'epitre':
        return 'Épître';
      case 'sequence':
        return 'Séquence';
      case 'acclamation':
        return 'Acclamation';
      case 'evangile':
        return 'Évangile';
      default:
        return 'Lecture';
    }
  }

  /// Mappe la couleur liturgique AELF vers une couleur d'accent.
  Color _liturgicalColor(String? couleur) {
    switch (couleur?.toLowerCase()) {
      case 'rouge':
        return colorRed;
      case 'blanc':
        return colorGrey1;
      case 'violet':
        return const Color(0xFF6A4C93);
      case 'rose':
        return const Color(0xFFD16BA5);
      case 'vert':
      default:
        return colorGreenSemiLight;
    }
  }
}

/// En-tête persistant (pinné) affichant l'introduction lue : reste visible en
/// haut pendant le scroll du texte, et reprend sa place au défilement inverse.
class _StickyIntroDelegate extends SliverPersistentHeaderDelegate {
  final String html;
  static const double _height = 62;

  _StickyIntroDelegate({required this.html});

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: colorWhite,
        border: Border(bottom: BorderSide(color: colorGrey2)),
      ),
      child: ClipRect(
        child: Html(
          data: html,
          style: {
            '#': Style(
              fontFamily: 'montserrat_bold',
              fontSize: FontSize(TextSizes.fifteen),
              fontStyle: FontStyle.italic,
              color: colorGreenSemiLight,
              margin: Margins.zero,
            ),
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyIntroDelegate oldDelegate) =>
      oldDelegate.html != html;
}
