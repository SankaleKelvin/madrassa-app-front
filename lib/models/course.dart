
class Course {
  int id;
  String courseName;
  String description;
  double charges;
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
        courseName: json['course_name'],
        description: json['description'],
        charges: json['charges'].toDouble(),
        madrassaId: json['madrassa_id'],
        madrassaName: json['madrassa_name']);
  }
}
