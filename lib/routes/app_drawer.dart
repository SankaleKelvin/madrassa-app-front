// app_drawer.dart or menu_widget.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final user = snapshot.data;
        final role = user?['role']?['name']?.toLowerCase() ?? '';

        return Drawer(
          child: ListView(
            children: [
              // Always visible items
              ListTile(
                title: Text('Welcome'),
                onTap: () => Navigator.pushNamed(context, '/welcome'),
              ),
              ListTile(
                title: Text('Courses'),
                onTap: () => Navigator.pushNamed(context, '/courses'),
              ),

              // Role-based items
              if (role == 'admin' || role == 'teacher') ...[
                ListTile(
                  title: Text('Manage Students'),
                  onTap: () => Navigator.pushNamed(context, '/students'),
                ),
                ListTile(
                  title: Text('Manage Madrassa'),
                  onTap: () => Navigator.pushNamed(context, '/madrassa'),
                ),
              ],

              // Admin-only items
              if (role == 'admin') ...[
                ListTile(
                  title: Text('Menu Settings'),
                  onTap: () => Navigator.pushNamed(context, '/menu'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
