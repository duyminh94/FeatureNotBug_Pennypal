class ReceiptScanResult {
  final bool hasText;
  final double? amount;
  final String? description;
  final DateTime date;
  final bool isDateFromReceipt;
  final String? categoryId;
  final String? imagePath;

  const ReceiptScanResult({
    required this.hasText,
    this.amount,
    this.description,
    required this.date,
    this.isDateFromReceipt = false,
    this.categoryId,
    this.imagePath,
  });

  ReceiptScanResult withImagePath(String path) {
    return ReceiptScanResult(
      hasText: hasText,
      amount: amount,
      description: description,
      date: date,
      isDateFromReceipt: isDateFromReceipt,
      categoryId: categoryId,
      imagePath: path,
    );
  }
}
