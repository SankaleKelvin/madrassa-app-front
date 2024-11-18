
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/course.dart';
import '../models/madrassa.dart';
import '../services/auth_service.dart';

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<Course> courses = [];
  List<Madrassa> madrassas = [];
  List<Course> filteredCourses = [];
  Madrassa? selectedMadrassa;
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchMadrassas();
    _searchController.addListener(_filterCourses);
  }

  // Helper method to get headers with auth token
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
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  // Fetch all Courses (Read)
  Future<void> fetchCourses() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/course'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List courseJson = jsonResponse['Courses'];
        setState(() {
          courses = courseJson.map((data) => Course.fromJson(data)).toList();
          filteredCourses = courses;
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to load courses', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fetch all Madrassas
  Future<void> fetchMadrassas() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/madrassa'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          madrassas = jsonResponse.map((data) => Madrassa.fromJson(data)).toList();
          if (madrassas.isNotEmpty) selectedMadrassa = madrassas[0];
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to load madrassas', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredCourses = courses.where((course) {
        return course.courseName.toLowerCase().contains(query) ||
            course.madrassaName.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Create a new Course (Create)
  Future<void> createCourse(String courseName, String description, double charges, int madrassaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/course'),
        headers: headers,
        body: jsonEncode({
          "course_name": courseName,
          "description": description,
          "charges": charges,
          "madrassa_id": madrassaId
        }),
      );

      if (response.statusCode == 200) {
        fetchCourses();
        _showSnackbar('Course created successfully', const Color.fromARGB(255, 43, 90, 44));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to create course', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Update an existing Course (Update)
  Future<void> updateCourse(int id, String courseName, String description, double charges, int madrassaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/course/$id'),
        headers: headers,
        body: jsonEncode({
          "course_name": courseName,
          "description": description,
          "charges": charges,
          "madrassa_id": madrassaId
        }),
      );

      if (response.statusCode == 200) {
        fetchCourses();
        _showSnackbar('Course updated successfully', const Color.fromARGB(255, 164, 192, 53));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to update course', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Delete a Course (Delete)
  Future<void> deleteCourse(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/course/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchCourses();
        _showSnackbar('Course deleted successfully', Colors.amberAccent[700]!);
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to delete course', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void showCreateDialog() {
    _courseNameController.clear();
    _descriptionController.clear();
    _chargesController.clear();
    selectedMadrassa = madrassas.isNotEmpty ? madrassas[0] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _chargesController,
                decoration: InputDecoration(labelText: 'Course Charges'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              DropdownSearch<Madrassa>(
                items: madrassas,
                itemAsString: (Madrassa madrassa) => madrassa.name,
                selectedItem: selectedMadrassa,
                onChanged: (Madrassa? newMadrassa) {
                  setState(() {
                    selectedMadrassa = newMadrassa;
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Madrassa",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedMadrassa != null) {
                double charges = 0.0;
                try {
                  charges = double.parse(_chargesController.text);
                } catch (e) {
                  _showSnackbar('Invalid charges input', Colors.red);
                  return;
                }
                createCourse(
                  _courseNameController.text,
                  _descriptionController.text,
                  charges,
                  selectedMadrassa!.id,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(Course course) {
    _courseNameController.text = course.courseName;
    _descriptionController.text = course.description;
    _chargesController.text = course.charges.toString();
    selectedMadrassa = madrassas.firstWhere(
      (madrassa) => madrassa.id == course.madrassaId,
      orElse: () => madrassas[0],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _chargesController,
                decoration: InputDecoration(labelText: 'Course Charges'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              DropdownSearch<Madrassa>(
                items: madrassas,
                itemAsString: (Madrassa madrassa) => madrassa.name,
                selectedItem: selectedMadrassa,
                onChanged: (Madrassa? newMadrassa) {
                  setState(() {
                    selectedMadrassa = newMadrassa;
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Madrassa",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedMadrassa != null) {
                double charges = 0.0;
                try {
                  charges = double.parse(_chargesController.text);
                } catch (e) {
                  _showSnackbar('Invalid charges input', Colors.red);
                  return;
                }
                updateCourse(
                  course.id,
                  _courseNameController.text,
                  _descriptionController.text,
                  charges,
                  selectedMadrassa!.id,
                );
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
      appBar: AppBar(title: Text('Courses List')),
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
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(course.courseName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Madrassa: ${course.madrassaName}'),
                              Text('Charges: \KShs.${course.charges.toStringAsFixed(2)}'),
                              Text('Description: ${course.description}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => showUpdateDialog(course),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteCourse(course.id),
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
        onPressed: showCreateDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}