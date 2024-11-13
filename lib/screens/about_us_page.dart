import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  List<dynamic> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      // Replace with your backend URL
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/course'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courses = data['Courses']; // Extract courses from the response
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Introductory section
                    Text(
                      'Welcome to Madrassa App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Empowering Coastal Communities in Mombasa through Knowledge and Faith',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Our madrasa offers a variety of courses aimed at deepening understanding of Islamic principles, '
                      'history, and philosophy. We are dedicated to providing quality education for students in the coastal '
                      'region of Mombasa, nurturing both faith and intellect.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),
                    Text(
                      'Our Madrassa is dedicated to nurturing young minds through a blend of traditional Islamic teachings and modern education. Our mission is to foster a deep understanding of the Quran, Sunnah, and other Islamic sciences, while preparing students for success in a variety of fields.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20), // Space between buttons
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SIGN UP",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Courses section
                    Text(
                      'Courses Offered',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 10),

                   
                  ],
                ),
              ),
            ),
    );
  }
}

