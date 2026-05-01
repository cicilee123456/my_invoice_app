class Invoice {
  final String invoiceNumber;
  final String period;
  final int amount;
  final String invoiceDate;
  final String? prizeLevel; // 新增：獎級（對獎結果用）

  Invoice({
    required this.invoiceNumber,
    required this.period,
    required this.amount,
    required this.invoiceDate,
    this.prizeLevel,
  });

  
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoice_number'] ?? '',
      period: json['period'] ?? '115年03-04月',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      invoiceDate: json['invoice_date'] ?? '',
      prizeLevel: json['prize_level'], // 新增：可選字段
    );
  }
}