import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';
import 'package:oremusapp/app/modules/pray/data/repository/pray_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrayController extends GetxController {
  final PrayRepository prayRepository;

  PrayController({required this.prayRepository});

  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var refreshController = RefreshController();

  var page = 0.obs;
  RxList<Prayer> prayers = RxList<Prayer>([]);

  @override
  void onInit() {
    super.onInit();
    initPullToRefresh();
  }

  @override
  void onReady() {
    getPrayers();
    //initPrayers();
    super.onReady();
  }

  //MOCK
  initPrayers() {
    prayers.value = [
      Prayer(
        code: "AIR_TRAVEL_PROTOCOL_COVID19",
        content: TranslateContent(
          fr: "Procédure pour les voyageurs à destination d'Abidjan \n\n Si vous êtes un voyageur à destination d'Abidjan, vous devez avant votre départ de l’étranger:\n\n\n\n 1. Faire votre test PCR COVID-19 avant de voyager.\n\nLe voyageur doit faire son test de dépistage PCR COVID-19 dans le pays où il se trouve. Le résultat du test sera demandé lors de l’embarquement. Seuls les voyageurs dont les résultats sont négatifs datant de moins de 2jours, sont autorisés à voyager.\n\n\n 2. FAIRE LA DECLARATION DE DÉPLACEMENT\n\n\n Le voyageur effectue (de préférence 2jours avant son voyage) sa déclaration de déplacement sur le site https://deplacement-aerien.gouv.ci/ et paye en ligne avec Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\nLe Montant à payer est de 2 000 FCFA (3,04 €).\n\n\nIMPRIMER SON REÇU ET SA DECLARATION\n\n\nImprimez votre formulaire de déclaration et votre reçu de paiement. Vous recevrez une copie de ces documents dans la boîte mail indiquée lors de la déclaration.\n\nLa fiche de déclaration de déplacement par voie aérienne (DDVA) et l’attestation COVID-19 négatif vous seront demandées avant votre embarquement.\n\n\n\n\nProcédure pour les voyageurs au départ d'Abidjan\n\n\n\nLe Voyageur Domestique\n\nSi vous êtes un passager des vols domestiques (vols à destination de l'intérieur de la Côte d'Ivoire), vous n'êtes pas soumis à la déclaration de déplacement par voie aérienne(DDVA) ni au test de dépistage de la COVID-19.\n\nLe Voyageur International\n\nSi vous êtes un voyageur au départ d’Abidjan,vous devez avant votre départ pour l’étranger :\n\n\n 1. FAIRE LA DECLARATION DE DÉPLACEMENT\n\nFaire votre déclaration de déplacement sur https://deplacement-aerien.gouv.ci/ de préférence 2jours avant votre voyage et payer en ligne votre déclaration et votre test PCR COVID-19 avec Orange Money,Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\n\nLe Montant à payer est de 25 000 FCFA (38,11 €)\n\nNB:\n\n.La déclaration est obligatoire pour tous les passagers à partir de 03 ans\n.Le test PCR COVID-19 ne concerne que les voyageurs à partir de 12 ans.\nLes voyageurs qui ont moins de 12 ans qui ne font pas de Test COVID-19 paient uniquement leur déclaration d’un montant de 2 000 FCFA (3,04 €)\n\n\n 2. IMPRIMER SON RECU ET SA DECLARATION\n\nImprimer votre formulaire de déclaration et votre reçu de paiement. Vous recevrez une copie de ces documents dans la boîte mail indiquée lors de la déclaration.\n\n\n\n 3. LE TEST COVID-19\n\nSe rendre dans un centre de prélèvement (pour le voyageur qui fait un Test PCR Covid-19) muni du reçu de paiement et de la déclaration pour faire son prélèvement. Le résultat du test PCR COVID-19 vous sera communiqué dans un délai de 48h maximum.\n\nLorsque que le test est négatif, l’attestation est disponible en ligne sur https://attestationcovid.ci\n\nLa fiche de déclaration de déplacement par voie aérienne (DDVA) et l’attestation COVID-19 négatif vous seront demandées avant votre embarquement le jour du voyage.\n\n\nInformation importante:\n\nLes passagers sont invités à s'informer sur les délais de validité de l’attestation COVID-19 en vigueur dans les pays de destination au près des compagnies/agences de voyages.\n",
          en: "Procedure for travelers to Abidjan \n\n If you are a traveler to Abidjan, you must before your departure from abroad:\n\n\n\n 1. Do your PCR test COVID- 19 before travelling.\n\nThe traveler must take their COVID-19 PCR test in the country where they are. The test result will be requested upon boarding. Only travelers whose results are negative dating back less than 2 days are authorized to travel.\n\n\n 2. MAKE THE DECLARATION OF TRAVEL\n\n\n The traveler makes (preferably 2 days before his trip) his travel declaration on the site https://deplacement-aerien.gouv.ci/ and pay online with Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\nThe amount to be paid is 2,000 FCFA (€3.04).\n\n\nPRINT YOUR RECEIPT AND DECLARATION\n\n\nPrint your declaration form and your payment receipt. You will receive a copy of these documents in the mailbox indicated during the declaration.\n\nThe travel declaration form by air (DDVA) and the negative COVID-19 certificate will be requested before your boarding.\n\n\n\n\nProcedure for travelers departing from Abidjan\n\n\n\nThe Domestic Traveler\n\nIf you are a passenger on domestic flights (flights to the interior of Côte d'Ivoire ), you are not subject to the declaration of travel by air (DDVA) or the screening test for COVID-19.\n\nLe Voyageur International\n\nIf you are a traveler departing from Abidjan, you must before your departure abroad:\n\n\n 1. MAKE THE TRAVEL DECLARATION\n\nMake your travel declaration on https://deplacement-aerien.gouv.ci/ preferably 2 days before your trip and pay your declaration and your COVID-19 PCR test online with Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\n\nLe M The amount to be paid is 25,000 FCFA (€38.11)\n\nNB:\n\n.The declaration is compulsory for all passengers from 03 years old\n.The COVID-19 PCR test only concerns travelers from 12 years old.\nTravelers who are under 12 years old and do not take a COVID-19 test only pay their declaration of 2,000 FCFA (€3.04)\n\n\n 2 PRINT YOUR RECEIPT AND DECLARATION\n\nPrint your declaration form and your payment receipt. You will receive a copy of these documents in the mailbox indicated during the declaration.\n\n\n\n 3. THE COVID-19 TEST\n\nGo to a collection center (for the traveler who takes a test PCR Covid-19) with the payment receipt and the declaration to take the sample. The result of the COVID-19 PCR test will be communicated to you within 48 hours maximum.\n\nWhen the test is negative, the certificate is available online at https://attestationcovid.ci\n\nThe declaration form of travel by air (DDVA) and the negative COVID-19 certificate will be requested from you before your boarding on the day of the trip.\n\n\nImportant information:\n\nPassengers are invited to inquire about the delays validity of the COVID-19 certificate in force in the countries of destination with the companies / travel agencies.\n",
        ),
        title: TranslateContent(
            fr: "Protocole voyage aérien-covid19",
            en: "Air travel protocol-covid19"),
      ),
      Prayer(
        code: "AIR_TRAVEL_PROTOCOL_COVID19",
        content: TranslateContent(
          fr: "Procédure pour les voyageurs à destination d'Abidjan \n\n Si vous êtes un voyageur à destination d'Abidjan, vous devez avant votre départ de l’étranger:\n\n\n\n 1. Faire votre test PCR COVID-19 avant de voyager.\n\nLe voyageur doit faire son test de dépistage PCR COVID-19 dans le pays où il se trouve. Le résultat du test sera demandé lors de l’embarquement. Seuls les voyageurs dont les résultats sont négatifs datant de moins de 2jours, sont autorisés à voyager.\n\n\n 2. FAIRE LA DECLARATION DE DÉPLACEMENT\n\n\n Le voyageur effectue (de préférence 2jours avant son voyage) sa déclaration de déplacement sur le site https://deplacement-aerien.gouv.ci/ et paye en ligne avec Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\nLe Montant à payer est de 2 000 FCFA (3,04 €).\n\n\nIMPRIMER SON REÇU ET SA DECLARATION\n\n\nImprimez votre formulaire de déclaration et votre reçu de paiement. Vous recevrez une copie de ces documents dans la boîte mail indiquée lors de la déclaration.\n\nLa fiche de déclaration de déplacement par voie aérienne (DDVA) et l’attestation COVID-19 négatif vous seront demandées avant votre embarquement.\n\n\n\n\nProcédure pour les voyageurs au départ d'Abidjan\n\n\n\nLe Voyageur Domestique\n\nSi vous êtes un passager des vols domestiques (vols à destination de l'intérieur de la Côte d'Ivoire), vous n'êtes pas soumis à la déclaration de déplacement par voie aérienne(DDVA) ni au test de dépistage de la COVID-19.\n\nLe Voyageur International\n\nSi vous êtes un voyageur au départ d’Abidjan,vous devez avant votre départ pour l’étranger :\n\n\n 1. FAIRE LA DECLARATION DE DÉPLACEMENT\n\nFaire votre déclaration de déplacement sur https://deplacement-aerien.gouv.ci/ de préférence 2jours avant votre voyage et payer en ligne votre déclaration et votre test PCR COVID-19 avec Orange Money,Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\n\nLe Montant à payer est de 25 000 FCFA (38,11 €)\n\nNB:\n\n.La déclaration est obligatoire pour tous les passagers à partir de 03 ans\n.Le test PCR COVID-19 ne concerne que les voyageurs à partir de 12 ans.\nLes voyageurs qui ont moins de 12 ans qui ne font pas de Test COVID-19 paient uniquement leur déclaration d’un montant de 2 000 FCFA (3,04 €)\n\n\n 2. IMPRIMER SON RECU ET SA DECLARATION\n\nImprimer votre formulaire de déclaration et votre reçu de paiement. Vous recevrez une copie de ces documents dans la boîte mail indiquée lors de la déclaration.\n\n\n\n 3. LE TEST COVID-19\n\nSe rendre dans un centre de prélèvement (pour le voyageur qui fait un Test PCR Covid-19) muni du reçu de paiement et de la déclaration pour faire son prélèvement. Le résultat du test PCR COVID-19 vous sera communiqué dans un délai de 48h maximum.\n\nLorsque que le test est négatif, l’attestation est disponible en ligne sur https://attestationcovid.ci\n\nLa fiche de déclaration de déplacement par voie aérienne (DDVA) et l’attestation COVID-19 négatif vous seront demandées avant votre embarquement le jour du voyage.\n\n\nInformation importante:\n\nLes passagers sont invités à s'informer sur les délais de validité de l’attestation COVID-19 en vigueur dans les pays de destination au près des compagnies/agences de voyages.\n",
          en: "Procedure for travelers to Abidjan \n\n If you are a traveler to Abidjan, you must before your departure from abroad:\n\n\n\n 1. Do your PCR test COVID- 19 before travelling.\n\nThe traveler must take their COVID-19 PCR test in the country where they are. The test result will be requested upon boarding. Only travelers whose results are negative dating back less than 2 days are authorized to travel.\n\n\n 2. MAKE THE DECLARATION OF TRAVEL\n\n\n The traveler makes (preferably 2 days before his trip) his travel declaration on the site https://deplacement-aerien.gouv.ci/ and pay online with Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\nThe amount to be paid is 2,000 FCFA (€3.04).\n\n\nPRINT YOUR RECEIPT AND DECLARATION\n\n\nPrint your declaration form and your payment receipt. You will receive a copy of these documents in the mailbox indicated during the declaration.\n\nThe travel declaration form by air (DDVA) and the negative COVID-19 certificate will be requested before your boarding.\n\n\n\n\nProcedure for travelers departing from Abidjan\n\n\n\nThe Domestic Traveler\n\nIf you are a passenger on domestic flights (flights to the interior of Côte d'Ivoire ), you are not subject to the declaration of travel by air (DDVA) or the screening test for COVID-19.\n\nLe Voyageur International\n\nIf you are a traveler departing from Abidjan, you must before your departure abroad:\n\n\n 1. MAKE THE TRAVEL DECLARATION\n\nMake your travel declaration on https://deplacement-aerien.gouv.ci/ preferably 2 days before your trip and pay your declaration and your COVID-19 PCR test online with Orange Money, Moov Money, MTN Mobile Money, Visa, Mastercard, Yup, EcobankPay.\n\nLe M The amount to be paid is 25,000 FCFA (€38.11)\n\nNB:\n\n.The declaration is compulsory for all passengers from 03 years old\n.The COVID-19 PCR test only concerns travelers from 12 years old.\nTravelers who are under 12 years old and do not take a COVID-19 test only pay their declaration of 2,000 FCFA (€3.04)\n\n\n 2 PRINT YOUR RECEIPT AND DECLARATION\n\nPrint your declaration form and your payment receipt. You will receive a copy of these documents in the mailbox indicated during the declaration.\n\n\n\n 3. THE COVID-19 TEST\n\nGo to a collection center (for the traveler who takes a test PCR Covid-19) with the payment receipt and the declaration to take the sample. The result of the COVID-19 PCR test will be communicated to you within 48 hours maximum.\n\nWhen the test is negative, the certificate is available online at https://attestationcovid.ci\n\nThe declaration form of travel by air (DDVA) and the negative COVID-19 certificate will be requested from you before your boarding on the day of the trip.\n\n\nImportant information:\n\nPassengers are invited to inquire about the delays validity of the COVID-19 certificate in force in the countries of destination with the companies / travel agencies.\n",
        ),
        title: TranslateContent(
            fr: "Protocole voyage aérien-covid19",
            en: "Air travel protocol-covid19"),
      ),
    ];
  }

  initPullToRefresh() {
    refreshController = RefreshController(initialRefresh: false);
  }

  ///Chargement initial des paroisses
  getPrayers() {
    hideKeyboard();
    isDataProcessing(true);

    log('request getPrayers');

    prayRepository.getPrayers(page: page.value).then((value) {
      isDataProcessing(false);
      prayers.value = value;
      if (prayers.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
      /*if (value.last == false) {
            page.value += 1;
          } else {
            refreshController.loadNoData();
          }*/
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      log("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des prières (desactiver pour l'instant)
  onRefresh() {
    log('request onRefresh');

    resetSearch();
    prayRepository.getPrayers().then((value) {
      refreshController.refreshCompleted();
      prayers.value = value;
      /*if (value.last == false) {
            page.value += 1;
          } else {
            refreshController.loadNoData();
          }*/
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      log("error => ${error.toString()}");
    });
  }

  ///Pagination des prières (desactiver pour l'instant)
  onLoading() {
    hideKeyboard();

    log('request onLoading');

    prayRepository.getPrayers(page: page.value).then((value) {
      prayers.addAll(value);
      prayers.refresh();
      refreshController.loadComplete();
      log('${prayers.length}');
      /*if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }*/
    }, onError: (error) {
      refreshController.loadFailed();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      log("error => ${error.toString()}");
    });
  }

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    page.value = 0;
    hideKeyboard();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
