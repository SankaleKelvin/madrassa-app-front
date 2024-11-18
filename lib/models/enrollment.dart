class Enrollment {
  int id;
  DateTime enrollmentDate;
  double amountCharged;
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
        enrollmentDate: DateTime.parse(json['enrollment_date']),
        amountCharged: double.parse(json['amount_charged'].toString()),
        studentId: json['student_id'],
        courseId: json['course_id'],
        studentName: json['student_name'],
        courseName: json['course_name']);
  }
}
