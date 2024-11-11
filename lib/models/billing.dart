import 'dart:ffi';

class Billing {
  int id;
  DateTime billingDate;
  int studentCourseId;
  int invoiceNumber;
  Double amountCharged;
  String studentName;
  String courseName;

  Billing(
      {required this.id,
      required this.billingDate,
      required this.studentCourseId,
      required this.amountCharged,
      required this.invoiceNumber,
      required this.studentName,
      required this.courseName});

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
        id: json['id'],
        billingDate: json['billing_date'],
        studentCourseId: json['student_course_id'],
        invoiceNumber: json['invoice_number'],
        amountCharged: json['amount_charged'],
        studentName: json['student_name'],
        courseName: json['course_name']);
  }
}
