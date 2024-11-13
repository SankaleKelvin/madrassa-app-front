import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Description
              Text(
                'Welcome to the Madrassa!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Providing quality Islamic and general education for students of all ages.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),

              // Image of Madrassa
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'image4.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Navigation Buttons
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  _buildNavButton(
                    context,
                    'Locations',
                    Icons.pin_drop,
                    Colors.blueAccent,
                    () {
                      Navigator.pushNamed(context, '/locations');
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Madrassas',
                    Icons.home,
                    Colors.orangeAccent,
                    () {
                      Navigator.pushNamed(context, '/madrassa');
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Courses',
                    Icons.book,
                    Colors.blueAccent,
                    () {
                      Navigator.pushNamed(context, '/courses');
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Students',
                    Icons.people,
                    Colors.orangeAccent,
                    () {
                      Navigator.pushNamed(context, '/students');
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Enrollment',
                    Icons.campaign,
                    Colors.redAccent,
                    () {
                      // Navigate to Announcements Page
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Billing',
                    Icons.campaign,
                    Colors.redAccent,
                    () {
                      // Navigate to Announcements Page
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Payment',
                    Icons.campaign,
                    Colors.redAccent,
                    () {
                      // Navigate to Announcements Page
                    },
                  ),
                  _buildNavButton(
                    context,
                    'Contact Us',
                    Icons.contact_mail,
                    Colors.greenAccent,
                    () {
                      // Navigate to Contact Page
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build navigation buttons
  Widget _buildNavButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
        onPressed: onPressed,
      ),
    );
  }
}
