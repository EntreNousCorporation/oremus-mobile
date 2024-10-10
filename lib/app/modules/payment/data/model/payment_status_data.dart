class PaymentStatusData {
  dynamic id;
  String? transactionId;
  String? paymentStatus;

  PaymentStatusData({
    this.id,
    this.transactionId,
    this.paymentStatus,
  });

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transactionId'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transactionId'] = transactionId;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}
