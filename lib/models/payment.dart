
// class Payment {
//   int id;
//   DateTime paymentDate;
//   int studentId;
//   double amountPaid;
//   String receiptNumber;
//   String studentName;

//   Payment(
//       {required this.id,
//       required this.paymentDate,
//       required this.studentId,
//       required this.amountPaid,
//       required this.receiptNumber,
//       required this.studentName});

//       factory Payment.fromJson(Map<String, dynamic> json){
//         return Payment(
//           id: json['id'],
//           paymentDate: DateTime.parse(json['payment_date']),
//           studentId: json['student_id'],
//           amountPaid: double.parse(json['amount_paid']),
//           receiptNumber: json['receipt_number'],
//           studentName: json['student_name']
//         );
//       }
// }


class Payment {
  final int id;
  final DateTime paymentDate;
  final int studentId;
  final double amountPaid;
  final String receiptNumber;
  final String studentName;

  Payment({
    required this.id,
    required this.paymentDate,
    required this.studentId,
    required this.amountPaid,
    required this.receiptNumber,
    required this.studentName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      paymentDate: DateTime.parse(json['payment_date']),
      studentId: json['student_id'],
      amountPaid: (json['amount_paid'] is int) 
          ? (json['amount_paid'] as int).toDouble() 
          : json['amount_paid'],
      receiptNumber: json['receipt_number'],
      studentName: json['student_name'],
    );
  }
}