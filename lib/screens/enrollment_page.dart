import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../services/auth_service.dart';

class EnrollmentPage extends StatefulWidget {
  @override
  _EnrollmentPageState createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  List<Enrollment> enrollments = [];
  List<Student> students = [];
  List<Course> courses = [];
  List<Enrollment> filteredEnrollments = [];
  Student? selectedStudent;
  Course? selectedCourse;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchEnrollments();
    fetchStudentsAndCourses();
    _searchController.addListener(_filterEnrollments);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  void _filterEnrollments() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredEnrollments = enrollments.where((enrollment) {
        return enrollment.studentName.toLowerCase().contains(query) ||
            enrollment.courseName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchEnrollments() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/student_course'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['StudentCourses'];
        setState(() {
          enrollments =
              jsonResponse.map((data) => Enrollment.fromJson(data)).toList();
          filteredEnrollments = enrollments;
        });
      } else {
        _showSnackbar('Failed to load enrollments', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred >> ', Colors.red);
      print("Enrollment data >>>>>>>>>>>: ");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchStudentsAndCourses() async {
    try {
      final headers = await _getHeaders();
      final studentsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/student'),
        headers: headers,
      );
      final coursesResponse = await http.get(
        Uri.parse('http://localhost:8000/api/course'),
        headers: headers,
      );

      if (studentsResponse.statusCode == 200 &&
          coursesResponse.statusCode == 200) {
        print(studentsResponse.statusCode);

        setState(() {
          students = List<Student>.from(json
              .decode(studentsResponse.body)['Students']
              .map((data) => Student.fromJson(data)));

          courses = List<Course>.from(json
              .decode(coursesResponse.body)['Courses']
              .map((data) => Course.fromJson(data)));
          if (students.isNotEmpty) selectedStudent = students[0];
          if (courses.isNotEmpty) selectedCourse = courses[0];
        });
      } else {
        _showSnackbar('Failed to load students or courses', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  Future<void> createEnrollment(DateTime enrollmentDate, double amountCharged,
      int studentId, int courseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/student_course'),
        headers: headers,
        body: jsonEncode({
          "enrollment_date": enrollmentDate.toIso8601String(),
          "amount_charged": amountCharged,
          "student_id": studentId,
          "course_id": courseId
        }),
      );

      if (response.statusCode == 200) {
        fetchEnrollments();
        _showSnackbar('Enrollment created successfully', Colors.green);
      } else {
        _showSnackbar('Failed to create enrollment', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  Future<void> deleteEnrollment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/student_course/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchEnrollments();
        _showSnackbar('Enrollment deleted successfully', Colors.amber);
      } else {
        _showSnackbar('Failed to delete enrollment', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void showCreateEnrollmentDialog() {
    DateTime selectedDate = DateTime.now();
    _amountController.clear();
    selectedStudent = students.isNotEmpty ? students[0] : null;
    selectedCourse = courses.isNotEmpty ? courses[0] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Enrollment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownSearch<Student>(
              items: students,
              itemAsString: (Student student) => student.studentName,
              selectedItem: selectedStudent,
              onChanged: (Student? newStudent) {
                setState(() {
                  selectedStudent = newStudent;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Student",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownSearch<Course>(
              items: courses,
              itemAsString: (Course course) => course.courseName,
              selectedItem: selectedCourse,
              onChanged: (Course? newCourse) {
                setState(() {
                  selectedCourse = newCourse;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Course",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount Charged',
                prefixText: '\KShs. ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enrollment Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: selectedDate.toLocal().toString().split(' ')[0],
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  selectedDate = pickedDate;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedStudent != null && selectedCourse != null) {
                createEnrollment(
                    selectedDate,
                    double.parse(_amountController.text),
                    selectedStudent!.id,
                    selectedCourse!.id);
              }
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> updateEnrollment(int enrollmentId, DateTime enrollmentDate,
      double amountCharged, int studentId, int courseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/student_course/$enrollmentId'),
        headers: headers,
        body: jsonEncode({
          "enrollment_date": enrollmentDate.toIso8601String(),
          "amount_charged": amountCharged,
          "student_id": studentId,
          "course_id": courseId
        }),
      );

      if (response.statusCode == 200) {
        fetchEnrollments();
        _showSnackbar('Enrollment updated successfully', Colors.green);
      } else {
        _showSnackbar('Failed to update enrollment', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void showEditEnrollmentDialog(Enrollment enrollment) {
    DateTime selectedDate = enrollment.enrollmentDate;
    _amountController.text = enrollment.amountCharged.toString();
    selectedStudent = students.firstWhere((s) => s.id == enrollment.studentId);
    selectedCourse = courses.firstWhere((c) => c.id == enrollment.courseId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Enrollment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Similar to create dialog, but pre-populate with existing data
            DropdownSearch<Student>(
              items: students,
              itemAsString: (Student student) => student.studentName,
              selectedItem: selectedStudent,
              onChanged: (Student? newStudent) {
                setState(() {
                  selectedStudent = newStudent;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Student",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Similar dropdowns and text fields as in create dialog
            // Similar to create dialog, but pre-populate with existing data
            DropdownSearch<Course>(
              items: courses,
              itemAsString: (Course course) => course.courseName,
              selectedItem: selectedCourse,
              onChanged: (Course? newCourse) {
                setState(() {
                  selectedCourse = newCourse;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Course",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount Charged',
                prefixText: '\KShs. ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enrollment Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: selectedDate.toLocal().toString().split(' ')[0],
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedStudent != null && selectedCourse != null) {
                updateEnrollment(
                    enrollment.id,
                    selectedDate,
                    double.parse(_amountController.text),
                    selectedStudent!.id,
                    selectedCourse!.id);
              }
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Enrollments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredEnrollments.length,
                    itemBuilder: (context, index) {
                      final enrollment = filteredEnrollments[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(enrollment.studentName),
                          subtitle: Text(
                              '${enrollment.courseName} - \KShs. ${enrollment.amountCharged}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    showEditEnrollmentDialog(enrollment),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    deleteEnrollment(enrollment.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateEnrollmentDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
