
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../models/course.dart';
import '../models/madrassa.dart';

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

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchMadrassas();
    _searchController.addListener(_filterCourses); 
  }

  void _showCreatedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 43, 90, 44),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }
  
  void _showUpdatedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 164, 192, 53),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }
   
  void _showDeletedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.amberAccent[700],
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }
  
  void _showFailedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 232, 27, 13),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  // Fetch all Courses (Read)
  Future<void> fetchCourses() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/course'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List courseJson = jsonResponse['Courses'];
      setState(() {
        courses = courseJson.map((data) => Course.fromJson(data)).toList();
        filteredCourses = courses; 
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // Fetch all Madrassas (for the dropdown)
  Future<void> fetchMadrassas() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/madrassa'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        madrassas =
            jsonResponse.map((data) => Madrassa.fromJson(data)).toList();
        if (madrassas.isNotEmpty) selectedMadrassa = madrassas[0];
      });
    } else {
      throw Exception('Failed to load madrassas');
    }
  }

  // Filter Courses based on the search query
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
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/course'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"course_name": courseName, "description": description, "charges": charges, "madrassa_id": madrassaId}),
    );
    if (response.statusCode == 200) {
      fetchCourses();
      _showCreatedSnackbar('Course created successfully');
    } else {
      _showFailedSnackbar('Failed to create course');
    }
  }

  // Update an existing Course (Update)
  Future<void> updateCourse(int id, String courseName, String description, double charges, int madrassaId) async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/course/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"course_name": courseName, "description": description, "charges": charges, "madrassa_id": madrassaId}),
    );
    if (response.statusCode == 200) {
      fetchCourses();
      _showUpdatedSnackbar("Course Update Successful");
    } else {
      _showFailedSnackbar("Failed to Update Course");
    }
  }

  // Delete a Course (Delete)
  Future<void> deleteCourse(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:8000/api/course/$id'));
    if (response.statusCode == 200) {
      fetchCourses();
      _showDeletedSnackbar("Course Deleted Successfully!");
    } else {
      _showFailedSnackbar("Failed to Delete Course");
    }    
  }

  // Show dialog for creating a new Course
  void showCreateDialog() {
    _courseNameController.clear();
    _descriptionController.clear();
    _chargesController.clear();

    selectedMadrassa = madrassas.isNotEmpty ? madrassas[0] : null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Course'),
        content: Column(
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
        actions: [
          TextButton(
            onPressed: () {
              if (selectedMadrassa != null) {
                double charges = 0.0;
                try {
                  charges = double.parse(_chargesController.text);
                } catch (e){
                  print('Invalid charges input: $e');
                }
                createCourse(_courseNameController.text, _descriptionController.text, charges, selectedMadrassa!.id);
              }
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  // Show dialog for updating an existing Course
  void showUpdateDialog(Course course) {
    _courseNameController.text = course.courseName;
    selectedMadrassa = madrassas.firstWhere(
        (madrassa) => madrassa.id == course.madrassaId,
        orElse: () => madrassas[0]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Course'),
        content: Column(
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
        actions: [
          TextButton(
            onPressed: () {
              if (selectedMadrassa != null) {
                 double charges = 0.0;
                try {
                  charges = double.parse(_chargesController.text);
                } catch (e){
                  print('Invalid charges input: $e');
                }
                updateCourse(
                    course.id, _courseNameController.text, _descriptionController.text, charges, selectedMadrassa!.id);
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
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(course.courseName),
                    subtitle: Text('Madrassa ID: ${course.madrassaName}'),
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
