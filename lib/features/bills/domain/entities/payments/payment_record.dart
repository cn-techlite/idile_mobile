class PaymentRecord {
  const PaymentRecord({
    required this.billId,
    required this.title,
    required this.category,
    required this.paidOn,
    required this.amount,
    required this.currencyId,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    billId: (json['billId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    category: (json['category'] ?? '').toString(),
    paidOn: (json['paidOn'] ?? '').toString(),
    amount: json['amount'] is num
        ? (json['amount'] as num).toDouble()
        : double.tryParse('${json['amount']}') ?? 0,
    currencyId: (json['currencyId'] ?? '').toString(),
  );

  final String billId;
  final String title;
  final String category;
  final String paidOn;
  final double amount;
  final String currencyId;
}
