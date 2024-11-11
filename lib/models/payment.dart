import 'dart:ffi';

class Payment {
  int id;
  DateTime paymentDate;
  int studentId;
  Double amountPaid;
  String receiptNumber;
  String studentName;

  Payment(
      {required this.id,
      required this.paymentDate,
      required this.studentId,
      required this.amountPaid,
      required this.receiptNumber,
      required this.studentName});

      factory Payment.fromJson(Map<String, dynamic> json){
        return Payment(
          id: json['id'],
          paymentDate: json['payment_date'],
          studentId: json['student_id'],
          amountPaid: json['amount_paid'],
          receiptNumber: json['receipt_number'],
          studentName: json['student_name']
        );
      }
}
