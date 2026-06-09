class TransaksiModel {
  final String? id;
  final String title;
  final String date; // Bisa menggunakan DateTime atau String format untuk UI
  final int amount;
  final String type; // 'in' untuk pemasukan, 'out' untuk pengeluaran

  TransaksiModel({
    this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransaksiModel(
      id: documentId,
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount'] ?? 0,
      type: map['type'] ?? 'in',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'amount': amount,
      'type': type,
    };
  }
}