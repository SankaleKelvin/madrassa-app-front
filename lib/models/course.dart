import 'dart:ffi';

class Course {
  int id;
  String courseName;
  String description;
  Double charges;
  int madrassaId;
  String madrassaName;

  Course({
    required this.id,
    required this.courseName,
    required this.description,
    required this.charges,
    required this.madrassaId,
    required this.madrassaName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        id: json['id'],
        courseName: json['courseName'],
        description: json['description'],
        charges: json['charges'],
        madrassaId: json['madrassaId'],
        madrassaName: json['madrassaName']);
  }
}
