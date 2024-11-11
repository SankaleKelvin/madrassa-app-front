import 'dart:ffi';

class Enrollment {
  int id;
  DateTime enrollmentDate;
  Double amountCharged;
  int studentId;
  int courseId;
  String studentName;
  String courseName;

  Enrollment({
    required this.id,
    required this.enrollmentDate,
    required this.amountCharged,
    required this.studentId,
    required this.courseId,
    required this.studentName,
    required this.courseName,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
        id: json['id'],
        enrollmentDate: json['enrollmentDate'],
        amountCharged: json['amountCharged'],
        studentId: json['studentId'],
        courseId: json['courseId'],
        studentName: json['studentName'],
        courseName: json['courseName']);
  }
}
