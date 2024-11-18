import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import 'package:flutter/material.dart' as material;
import '../screens/login_page.dart';

class RouteGuard extends StatefulWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const RouteGuard({
    Key? key,
    required this.child,
    this.allowedRoles,
  }) : super(key: key);

  @override
  _RouteGuardState createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  bool _isLoggedIn = false;
  bool _isAuthorized = false;
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkAccessStatus();
  }

  Future<void> _checkAccessStatus() async {
    if (!mounted) return;

    try {
      final userData = await AuthService.getCurrentUser();
      final bool isLoggedIn = userData != null;
      bool isAuthorized = true;

      if (isLoggedIn && widget.allowedRoles != null) {
        isAuthorized = await AuthService.hasAnyRole(widget.allowedRoles!);        
      print('>>>>>Allowed Roles: $isLoggedIn');
      }

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isAuthorized = isAuthorized;
          _isCheckingStatus = false;
        });
      }
    } catch (e) {
      print('Error in _checkAccessStatus: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isAuthorized = false;
          _isCheckingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn) {
      return LoginPage();
    }

    if (!_isAuthorized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'You do not have permission to access this page.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                },
                child: const Text('Go to Welcome Page'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
