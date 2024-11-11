class Student {
  int id;
  String firstName;
  String lastName;
  String studentName;
  String studentPhoto;
  int locationId;
  String locationName;

  Student(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.studentName,
      required this.studentPhoto,
      required this.locationId,
      required this.locationName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        studentName: json['studentName'],
        studentPhoto: json['studentPhoto'],
        locationId: json['locationId'],
        locationName: json['locationName']);
  }
}
