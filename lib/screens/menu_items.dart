import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MenuItems extends StatefulWidget {
  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  List<String> userRoles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
  }

  Future<void> _loadUserRoles() async {
    final roles = await AuthService.getUserRoles();
    setState(() {
      userRoles = roles;
      isLoading = false;
    });
  }

  bool _hasAccess(List<String> requiredRoles) {
    return userRoles.any((role) => requiredRoles.contains(role));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (_hasAccess(['admin', 'teacher']))
                          _buildNavButton(
                            context,
                            'Locations',
                            Icons.pin_drop,
                            Colors.blueAccent,
                            () => Navigator.pushNamed(context, '/locations'),
                          ),

                        if (_hasAccess(['admin', 'teacher']))
                          _buildNavButton(
                            context,
                            'Madrassas',
                            Icons.home,
                            Colors.orangeAccent,
                            () => Navigator.pushNamed(context, '/madrassa'),
                          ),

                        if (_hasAccess(['admin', 'teacher']))
                          _buildNavButton(
                            context,
                            'Courses',
                            Icons.book,
                            Colors.blueAccent,
                            () => Navigator.pushNamed(context, '/courses'),
                          ),

                        if (_hasAccess(['admin', 'teacher']))
                          _buildNavButton(
                            context,
                            'Students',
                            Icons.people,
                            Colors.orangeAccent,
                            () => Navigator.pushNamed(context, '/students'),
                          ),

                        if (_hasAccess(['admin', 'teacher', 'student']))
                          _buildNavButton(
                            context,
                            'Enrollment',
                            Icons.campaign,
                            Colors.cyan,
                            () => Navigator.pushNamed(context, '/enrollment'),
                          ),

                        if (_hasAccess(['admin', 'accountant']))
                          _buildNavButton(
                            context,
                            'Billing',
                            Icons.receipt,
                            Colors.redAccent,
                            () => Navigator.pushNamed(context, '/billing'),
                          ),

                        if (_hasAccess(['admin', 'accountant', 'student']))
                          _buildNavButton(
                            context,
                            'Payment',
                            Icons.payment,
                            Colors.redAccent,
                            () => Navigator.pushNamed(context, '/payment'),
                          ),

                        // Contact Us is available to all authenticated users
                        _buildNavButton(
                          context,
                          'Contact Us',
                          Icons.contact_mail,
                          Colors.greenAccent,
                          () => Navigator.pushNamed(context, '/contact'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

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
