// // payment_page.dart

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/payment.dart';
// import '../services/auth_service.dart';

// class PaymentPage extends StatefulWidget {
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   List<Payment> payments = [];
//   List<Payment> filteredPayments = [];
//   List<StudentDebt> students = [];
//   StudentDebt? selectedStudent;

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _studentSearchController =
//       TextEditingController();

//   bool _isLoading = false;
//   bool _hasEditPermission = false;
//   bool _isLoadingStudents = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchPayments();
//     fetchStudentsWithDebt();
//     _checkPermissions();
//     _searchController.addListener(_filterPayments);
//   }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/payment.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<Payment> payments = [];
  List<Payment> filteredPayments = [];
  List<StudentDebt> students = [];
  StudentDebt? selectedStudent;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _studentSearchController =
      TextEditingController();
  final TextEditingController _receiptNumberController =
      TextEditingController();

  bool _isLoading = false;
  bool _hasEditPermission = false;
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    fetchPayments();
    fetchStudentsWithDebt();
    _checkPermissions();
    _searchController.addListener(_filterPayments);
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await AuthService.hasAnyRole(['Admin', 'Finance']);
    setState(() {
      _hasEditPermission = hasPermission;
    });
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

  Future<void> fetchStudentsWithDebt() async {
    setState(() => _isLoadingStudents = true);
    try {
      final headers = await _getHeaders();

      // Fetch both enrollments and payments to calculate debt
      final enrollmentsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/student_course'),
        headers: headers,
      );
      final paymentsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/payment'),
        headers: headers,
      );

      if (enrollmentsResponse.statusCode == 200 &&
          paymentsResponse.statusCode == 200) {
        final enrollments =
            json.decode(enrollmentsResponse.body)['StudentCourses'];
        final payments = json.decode(paymentsResponse.body)['Payments'];

        // Calculate debt for each student
        Map<int, StudentDebt> studentDebts = {};

        // Sum up charges from enrollments
        for (var enrollment in enrollments) {
          final studentId = enrollment['student_id'];
          final studentName = enrollment['student_name'];

          if (!studentDebts.containsKey(studentId)) {
            studentDebts[studentId] = StudentDebt(
              id: studentId,
              name: studentName,
              totalCharged: 0,
              totalPaid: 0,
            );
          }

          studentDebts[studentId]!.totalCharged +=
              double.parse(enrollment['amount_charged'].toString());
        }

        // Subtract payments
        for (var payment in payments) {
          final studentId = payment['student_id'];
          if (studentDebts.containsKey(studentId)) {
            studentDebts[studentId]!.totalPaid +=
                double.parse(payment['amount_paid'].toString());
          }
        }

        // Filter out fully paid students
        studentDebts
            .removeWhere((key, value) => value.totalPaid >= value.totalCharged);

        setState(() {
          students = studentDebts.values.toList();
        });
      }
    } catch (e) {
      _showSnackbar('Failed to load student data', Colors.red);
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  // Future<void> fetchPayments() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final headers = await _getHeaders();
  //     final response = await http.get(
  //       Uri.parse('http://localhost:8000/api/payment'),
  //       headers: headers,
  //     );

  //     if (response.statusCode == 200) {
  //       List jsonResponse = json.decode(response.body)['Payments'];
  //       setState(() {
  //         payments =
  //             jsonResponse.map((data) => Payment.fromJson(data)).toList();
  //         filteredPayments = payments;
  //       });
  //     } else if (response.statusCode == 401) {
  //       _showSnackbar('Session expired. Please login again.', Colors.red);
  //     }
  //   } catch (e) {
  //     _showSnackbar('Network error occurred', Colors.green);
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/payment'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final paymentsList = jsonData['Payments'] as List;

        setState(() {
          payments =
              paymentsList.map((data) => Payment.fromJson(data)).toList();
          filteredPayments = payments;
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPayments() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredPayments = payments.where((payment) {
        return payment.studentName.toLowerCase().contains(query) ||
            payment.receiptNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    // Format: YYYY-MM-DD
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> createPayment(int studentId, double amount) async {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to create payments', Colors.red);
      return;
    }

    try {
      final headers = await _getHeaders();
      final now = DateTime.now();
      final formattedDate = _formatDate(now);

      print('Sending payment request:');
      print({
        "student_id": studentId,
        "amount_paid": amount,
        "payment_date": formattedDate,
        "receipt_number": _receiptNumberController.text.isEmpty
            ? 'RCP-${now.millisecondsSinceEpoch}'
            : _receiptNumberController.text,
      });

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/payment'),
        headers: headers,
        body: jsonEncode({
          "student_id": studentId,
          "amount_paid": amount,
          "payment_date": formattedDate,
          "receipt_number": _receiptNumberController.text.isEmpty
              ? 'RCP-${now.millisecondsSinceEpoch}'
              : _receiptNumberController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchPayments();
        await fetchStudentsWithDebt();
        _showSnackbar('Payment recorded successfully',
            const Color.fromARGB(255, 43, 90, 44));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        final errorData = json.decode(response.body);
        _showSnackbar(
            errorData['error'] ?? 'Failed to record payment', Colors.red);
      }
    } catch (e) {
      print('Error creating payment: $e');
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void showCreateDialog() {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to create payments', Colors.red);
      return;
    }

    _amountController.clear();
    _receiptNumberController.clear();
    selectedStudent = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Record Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _studentSearchController,
                  decoration: InputDecoration(
                    labelText: 'Search Student',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                Container(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students
                        .where((student) => student.name.toLowerCase().contains(
                            _studentSearchController.text.toLowerCase()))
                        .length,
                    itemBuilder: (context, index) {
                      final student = students
                          .where((student) => student.name
                              .toLowerCase()
                              .contains(
                                  _studentSearchController.text.toLowerCase()))
                          .toList()[index];

                      return ListTile(
                        title: Text(student.name),
                        subtitle: Text(
                            'Balance: KShs. ${(student.totalCharged - student.totalPaid).toStringAsFixed(2)}'),
                        selected: selectedStudent?.id == student.id,
                        onTap: () {
                          setState(() {
                            selectedStudent = student;
                            _studentSearchController.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
                if (selectedStudent != null) ...[
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${selectedStudent!.name}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Total Charged: KShs. ${selectedStudent!.totalCharged.toStringAsFixed(2)}'),
                          Text(
                              'Total Paid: KShs. ${selectedStudent!.totalPaid.toStringAsFixed(2)}'),
                          Text(
                            'Balance: KShs. ${(selectedStudent!.totalCharged - selectedStudent!.totalPaid).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount to Pay',
                    prefixText: 'KShs. ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    // Trigger rebuild when amount changes
                    setState(() {});
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _receiptNumberController,
                  decoration: InputDecoration(
                    labelText: 'Receipt Number (Optional)',
                    hintText: 'Auto-generated if left empty',
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
                // Check if student is selected and amount is valid
                if (selectedStudent != null &&
                    _amountController.text.isNotEmpty &&
                    double.tryParse(_amountController.text) != null) {
                  double amount = double.parse(_amountController.text);
                  if (amount > 25500) {
                    _showSnackbar(
                        'Amount cannot exceed KShs. 25,500', Colors.red);
                    return;
                  }
                  if (amount <= 0) {
                    _showSnackbar('Amount must be greater than 0', Colors.red);
                    return;
                  }
                  createPayment(
                    selectedStudent!.id,
                    amount,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Record'),
              style: TextButton.styleFrom(
                backgroundColor: selectedStudent != null &&
                        _amountController.text.isNotEmpty &&
                        double.tryParse(_amountController.text) != null
                    ? null // Use default color
                    : Colors.grey, // Disabled color
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Payments',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('${payment.studentName}'),
                          subtitle: Text('Receipt #: ${payment.receiptNumber}\n'
                              'Amount: KShs. ${payment.amountPaid.toStringAsFixed(2)}'),
                          trailing: Text(
                            'Date: ${payment.paymentDate.toString().split(' ')[0]}',
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

// class StudentDebt {
//   final int id;
//   final String name;
//   double totalCharged;
//   double totalPaid;

//   StudentDebt({
//     required this.id,
//     required this.name,
//     required this.totalCharged,
//     required this.totalPaid,
//   });
// }

class StudentDebt {
  final int id;
  final String name;
  double totalCharged;
  double totalPaid;

  StudentDebt({
    required this.id,
    required this.name,
    required this.totalCharged,
    required this.totalPaid,
  });
}
