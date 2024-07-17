class PaymentStatusData {
  String? transactionId;
  String? paymentStatus;

  PaymentStatusData({
    this.transactionId,
    this.paymentStatus,
  });

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionId'] = transactionId;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}
