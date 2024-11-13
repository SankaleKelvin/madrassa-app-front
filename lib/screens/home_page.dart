import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hero Section Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('logo.jpg'), // Replace with your image path
                fit: BoxFit.contain,
              ),
            ),
            height: 300,//MediaQuery.of(context).size.height,
            width: 400,//MediaQuery.of(context).size.width,
          ),
          // Dark overlay for better contrast
          Container(
            color: const Color.fromARGB(255, 37, 110, 40).withOpacity(0.5),
          ),
          // Content overlaid on top of the hero image
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Subtitle
                Text(
                  'MADRASA APP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Amplify Your Faith',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Buttons
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    // TODO: Navigate to Sign In
                    Navigator.pushNamed(context, '/about-us');
                  },
                  child: Text(
                    "GET STARTED",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                SizedBox(height: 20), // Space between buttons
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SIGN IN",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.key_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
