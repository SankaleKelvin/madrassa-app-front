// screens/student_page.dart
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../models/madrassa.dart';
import '../models/student.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<Student> students = [];
  List<Location> locations = [];
  List<Madrassa> madrassas = [];
  List<Student> filteredStudents = [];
  Location? selectedLocation;
  Madrassa? selectedMadrassa;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final ImagePicker _studentPicker = ImagePicker();

  XFile? _studentPhotoXFile;
  Uint8List? _webImageBytes;

  final TextEditingController _editFirstNameController =
      TextEditingController();
  final TextEditingController _editLastNameController = TextEditingController();
  final TextEditingController _editStudentNameController =
      TextEditingController();
  XFile? _editStudentPhotoXFile;
  Uint8List? _editWebImageBytes;

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchLocations();
    fetchMadrassas();
    _searchController.addListener(_filterStudents);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  // Fetch all Students (Read)
  Future<void> fetchStudents() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/student'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List studentJson = jsonResponse['Students'];
      setState(() {
        students = studentJson.map((data) => Student.fromJson(data)).toList();
        filteredStudents = students;
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Fetch all Locations (for the dropdown)
  Future<void> fetchLocations() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/location'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        locations =
            jsonResponse.map((data) => Location.fromJson(data)).toList();
        if (locations.isNotEmpty) selectedLocation = locations[0];
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Fetch all Locations (for the dropdown)
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

  // Filter Students based on the search query
  void _filterStudents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        return student.studentName.toLowerCase().contains(query) ||
            student.locationName.toLowerCase().contains(query) ||
            student.madrassaName.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Create a new Student (Create)
  Future<void> createStudent(
      String firstName,
      String lastName,
      String studentName,
      XFile? studentPhoto,
      int locationId,
      int madrassaId) async {
    try {
      var uri = Uri.parse('http://localhost:8000/api/student');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['student_name'] = studentName;
      request.fields['location_id'] = locationId.toString();
      request.fields['madrassa_id'] = madrassaId.toString();

      // Handle file upload based on platform
      if (studentPhoto != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await studentPhoto.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'student_photo',
              bytes,
              filename: path.basename(studentPhoto.path),
            ),
          );
        } else {
          // For mobile platform
          request.files.add(
            await http.MultipartFile.fromPath(
              'student_photo',
              studentPhoto.path,
              filename: path.basename(studentPhoto.path),
            ),
          );
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        fetchStudents();
        _showSnackbar('Student created successfully', Colors.green);
      } else {
        _showSnackbar('Failed to create student: ${responseData}', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error creating student: $e', Colors.red);
    }
  }

  // Update an existing Student (Update)
  Future<void> updateStudent(
      int id,
      String firstName,
      String lastName,
      String studentName,
      XFile? studentPhoto,
      int locationId,
      int madrassaId) async {
    try {
      var uri = Uri.parse('http://localhost:8000/api/student/$id');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['student_name'] = studentName;
      request.fields['location_id'] = locationId.toString();
      request.fields['madrassa_id'] = madrassaId.toString();
      request.fields['_method'] =
          'PUT'; // Laravel requires this for PUT requests

      // Handle file upload based on platform
      if (studentPhoto != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await studentPhoto.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'student_photo',
              bytes,
              filename: path.basename(studentPhoto.path),
            ),
          );
        } else {
          // For mobile platform
          request.files.add(
            await http.MultipartFile.fromPath(
              'student_photo',
              studentPhoto.path,
              filename: path.basename(studentPhoto.path),
            ),
          );
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        fetchStudents();
        _showSnackbar('Student updated successfully', Colors.green);
      } else {
        _showSnackbar('Failed to update student: ${responseData}', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error updating student: $e', Colors.red);
    }
  }

  // Delete a Student (Delete)
  Future<void> deleteStudent(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:8000/api/student/$id'));
    if (response.statusCode == 200) {
      fetchStudents();
      _showSnackbar("Student Deleted Successfully!", Colors.amberAccent);
    } else {
      _showSnackbar("Failed to Delete Student", Colors.red);
    }
  }

  Future<void> _pickStudentImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _studentPhotoXFile = pickedFile;
          if (kIsWeb) {
            // For web, immediately read the bytes
            pickedFile.readAsBytes().then((value) {
              setState(() {
                _webImageBytes = value;
              });
            });
          }
        });
      }
    } catch (e) {
      _showSnackbar('Error picking image: $e', Colors.red);
    }
  }

  // Show dialog for creating a new Student
  void showCreateDialog() {
    _firstNameController.clear();
    _lastNameController.clear();
    _studentNameController.clear();
    _studentPhotoXFile = null;
    _webImageBytes = null;
    selectedLocation = locations.isNotEmpty ? locations[0] : null;
    selectedMadrassa = madrassas.isNotEmpty ? madrassas[0] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _studentNameController,
                decoration: InputDecoration(labelText: 'Student Name'),
              ),
              ElevatedButton(
                onPressed: _pickStudentImage,
                child: Text(_studentPhotoXFile == null
                    ? 'Select Photo'
                    : 'Change Photo'),
              ),
              if (_studentPhotoXFile != null) ...[
                SizedBox(height: 10),
                if (kIsWeb && _webImageBytes != null)
                  Image.memory(
                    _webImageBytes!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else if (!kIsWeb)
                  Image.file(
                    io.File(_studentPhotoXFile!.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
              ],
              SizedBox(height: 10),
              DropdownSearch<Madrassa>(
                items: madrassas,
                itemAsString: (Madrassa madrassa) => madrassa.name,
                selectedItem: selectedMadrassa,
                onChanged: (Madrassa? newMadrassa) {
                  setState(() {
                    selectedMadrassa = newMadrassa;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownSearch<Location>(
                items: locations,
                itemAsString: (Location location) => location.name,
                selectedItem: selectedLocation,
                onChanged: (Location? newLocation) {
                  setState(() {
                    selectedLocation = newLocation;
                  });
                },
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
              if (selectedLocation != null && selectedMadrassa != null) {
                createStudent(
                  _firstNameController.text,
                  _lastNameController.text,
                  _studentNameController.text,
                  _studentPhotoXFile,
                  selectedLocation!.id,
                  selectedMadrassa!.id,
                );
                Navigator.of(context).pop();
              } else {
                _showSnackbar(
                    'Please select location and madrassa', Colors.red);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickEditStudentImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _editStudentPhotoXFile = pickedFile;
          if (kIsWeb) {
            // For web, immediately read the bytes
            pickedFile.readAsBytes().then((value) {
              setState(() {
                _editWebImageBytes = value;
              });
            });
          }
        });
      }
    } catch (e) {
      _showSnackbar('Error picking image: $e', Colors.red);
    }
  }

  //show Edit Dialog
  void showEditDialog(Student student) {
    _editFirstNameController.text = student.firstName;
    _editLastNameController.text = student.lastName;
    _editStudentNameController.text = student.studentName;
    _editStudentPhotoXFile = null;
    _editWebImageBytes = null;

    // Find and set the corresponding location and madrassa
    selectedLocation =
        locations.firstWhere((loc) => loc.id == student.locationId);
    selectedMadrassa =
        madrassas.firstWhere((mad) => mad.id == student.madrassaId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editFirstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _editLastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _editStudentNameController,
                decoration: InputDecoration(labelText: 'Student Name'),
              ),
              SizedBox(height: 10),
              // Show current photo if exists
              if (student.studentPhoto != null &&
                  _editStudentPhotoXFile == null)
                Image.network(
                  student.getPhotoUrl(),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: _pickEditStudentImage,
                child: Text(_editStudentPhotoXFile == null
                    ? 'Change Photo'
                    : 'Change Selected Photo'),
              ),
              if (_editStudentPhotoXFile != null) ...[
                SizedBox(height: 10),
                if (kIsWeb && _editWebImageBytes != null)
                  Image.memory(
                    _editWebImageBytes!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else if (!kIsWeb)
                  Image.file(
                    io.File(_editStudentPhotoXFile!.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
              ],
              SizedBox(height: 10),
              DropdownSearch<Madrassa>(
                items: madrassas,
                itemAsString: (Madrassa madrassa) => madrassa.name,
                selectedItem: selectedMadrassa,
                onChanged: (Madrassa? newMadrassa) {
                  setState(() {
                    selectedMadrassa = newMadrassa;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownSearch<Location>(
                items: locations,
                itemAsString: (Location location) => location.name,
                selectedItem: selectedLocation,
                onChanged: (Location? newLocation) {
                  setState(() {
                    selectedLocation = newLocation;
                  });
                },
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
              if (selectedLocation != null && selectedMadrassa != null) {
                updateStudent(
                  student.id,
                  _editFirstNameController.text,
                  _editLastNameController.text,
                  _editStudentNameController.text,
                  _editStudentPhotoXFile,
                  selectedLocation!.id,
                  selectedMadrassa!.id,
                );
                Navigator.of(context).pop();
              } else {
                _showSnackbar(
                    'Please select location and madrassa', Colors.red);
              }
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
      appBar: AppBar(title: Text('Students List')),
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
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: student.studentPhoto != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(student.getPhotoUrl()),
                          )
                        : null,
                    title: Text(student.studentName),
                    subtitle: Text(
                        'Madrassa: ${student.madrassaName} (${student.locationName})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showEditDialog(student),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteStudent(student.id),
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
