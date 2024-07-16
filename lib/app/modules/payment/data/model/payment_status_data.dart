class PaymentStatusData {
  String? status;
  String? amount;
  String? currency;
  String? operatorId;

  PaymentStatusData({
    this.status,
    this.amount,
    this.currency,
    this.operatorId,
  });

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    amount = json['amount'];
    currency = json['currency'];
    operatorId = json['operatorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['amount'] = amount;
    data['currency'] = currency;
    data['operatorId'] = operatorId;
    return data;
  }
}
