class Student {
  int id;
  String firstName;
  String lastName;
  String studentName;
  String? studentPhoto;
  int locationId;
  String locationName;
  int madrassaId;
  String madrassaName;

  Student(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.studentName,
      this.studentPhoto,
      required this.locationId,
      required this.locationName,
      required this.madrassaId,
      required this.madrassaName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        studentName: json['student_name'],
        studentPhoto: json['student_photo'],
        locationId: json['location_id'],
        locationName: json['location_name'],
        madrassaId: json['madrassa_id'],
        madrassaName: json['madrassa_name']);
  }
  String getPhotoUrl() {
    String baseUrl = "http://localhost:8000/storage/";
    return studentPhoto != null && studentPhoto!.startsWith('http')
        ? studentPhoto!
        : baseUrl + studentPhoto!;
  }

  // String getPhotoUrl() {
  //   const baseUrl = "http://localhost:8000/storage/";
  //   if (studentPhoto == null || studentPhoto!.isEmpty) return '';
  //   if (studentPhoto!.startsWith('http')) return studentPhoto!;

  //   // Clean up the path
  //   final cleanPath = studentPhoto!
  //       .replaceAll('posts/', '')
  //       .replaceAll('//', '/');

  //   return baseUrl + cleanPath;
  // }
}
