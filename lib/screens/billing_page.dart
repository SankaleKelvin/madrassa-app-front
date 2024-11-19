import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/billing.dart';
import '../services/auth_service.dart';
import '../screens/payment_page.dart';

class UnpaidBillsPage extends StatefulWidget {
  @override
  _UnpaidBillsPageState createState() => _UnpaidBillsPageState();
}

class _UnpaidBillsPageState extends State<UnpaidBillsPage> {
  List<StudentBillSummary> studentBills = [];
  List<StudentBillSummary> filteredBills = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUnpaidBills();
    _searchController.addListener(_filterBills);
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
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  Future<void> fetchUnpaidBills() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      // Fetch both enrollments and billings
      final enrollmentsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/student_course'),
        headers: headers,
      );
      final billingsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/billing'),
        headers: headers,
      );

      if (enrollmentsResponse.statusCode == 200 && billingsResponse.statusCode == 200) {
        // Parse responses
        final enrollments = json.decode(enrollmentsResponse.body)['StudentCourses'];
        final billings = json.decode(billingsResponse.body)['Billings'];

        // Process and group by student
        Map<String, StudentBillSummary> summaryMap = {};

        // First, add all enrollments
        for (var enrollment in enrollments) {
          final studentName = enrollment['student_name'];
          if (!summaryMap.containsKey(studentName)) {
            summaryMap[studentName] = StudentBillSummary(
              studentName: studentName,
              totalCharged: 0,
              totalPaid: 0,
              courses: [],
            );
          }
          
          summaryMap[studentName]!.totalCharged += 
              double.parse(enrollment['amount_charged'].toString());
          summaryMap[studentName]!.courses.add(
            CourseBilling(
              courseName: enrollment['course_name'],
              amountCharged: double.parse(enrollment['amount_charged'].toString()),
              enrollmentDate: enrollment['enrollment_date'],
            )
          );
        }

        // Then subtract paid amounts from billings
        for (var billing in billings) {
          final studentName = billing['student_name'];
          if (summaryMap.containsKey(studentName)) {
            summaryMap[studentName]!.totalPaid += 
                double.parse(billing['amount_charged'].toString());
          }
        }

        // Filter out fully paid students
        summaryMap.removeWhere((key, value) => 
            value.totalPaid >= value.totalCharged);

        setState(() {
          studentBills = summaryMap.values.toList();
          filteredBills = studentBills;
        });
      } else {
        _showSnackbar('Failed to load billing data', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterBills() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredBills = studentBills.where((summary) =>
        summary.studentName.toLowerCase().contains(query) ||
        summary.courses.any((course) => 
          course.courseName.toLowerCase().contains(query))
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unpaid Bills'),
        actions: [
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by student or course',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final summary = filteredBills[index];
                      final unpaidAmount = summary.totalCharged - summary.totalPaid;
                      
                      return ExpansionTile(
                        title: Text(summary.studentName),
                        subtitle: Text(
                          'Unpaid: \$${unpaidAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          ...summary.courses.map((course) => ListTile(
                            title: Text(course.courseName),
                            subtitle: Text(
                              'Charged: \$${course.amountCharged.toStringAsFixed(2)}\n'
                              'Enrolled: ${course.enrollmentDate}',
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Charged: \$${summary.totalCharged.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Total Paid: \$${summary.totalPaid.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class StudentBillSummary {
  final String studentName;
  double totalCharged;
  double totalPaid;
  final List<CourseBilling> courses;

  StudentBillSummary({
    required this.studentName,
    required this.totalCharged,
    required this.totalPaid,
    required this.courses,
  });
}

class CourseBilling {
  final String courseName;
  final double amountCharged;
  final String enrollmentDate;

  CourseBilling({
    required this.courseName,
    required this.amountCharged,
    required this.enrollmentDate,
  });
}