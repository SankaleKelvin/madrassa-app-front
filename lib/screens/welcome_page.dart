// welcome_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Map<String, dynamic>? _user;
  Map<String, bool>? _abilities;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userString;
    if (kIsWeb) {
      userString = html.window.localStorage['user'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      userString = prefs.getString('user');
    }

    if (userString != null) {
      final userData = jsonDecode(userString);
      setState(() {
        _user = userData;
        _abilities = userData['abilities'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('image4.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          // Overlay for better text contrast
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Welcome Message Content
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 120.0), // Adjust padding as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_user?['name']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Role: ${_user?['role']['name']}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We’re glad to have you back!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (_abilities != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abilities:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ..._abilities!.entries.map(
                            (entry) => Text('- ${entry.key}: ${entry.value}')),
                      ],
                    ),
                  SizedBox(height: 30),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/menu');
                    },
                    child: Text(
                      "Explore Now",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
