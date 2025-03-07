import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';

abstract class IDonationRepository {
  //For API
  Future<DonationResponse> sendDonation({required DonationData request});
  Future<DonationResponse> donationRetryPayment({required PaymentStatusData request});
}
