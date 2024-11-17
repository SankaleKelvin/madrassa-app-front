import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import 'package:flutter/material.dart' as material;

// class RouteGuard extends StatefulWidget {
//   final Widget child;
//   RouteGuard({required this.child});

//   @override
//   _RouteGuardState createState() => _RouteGuardState();
// }

// class _RouteGuardState extends State<RouteGuard> {
//   bool _isLoggedIn = false;
//   bool _isCheckingLoginStatus = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   // Future<void> _checkLoginStatus() async {
//   //   final token = await TokenStorageService.getToken();
//   //   print('Login with $token');
//   //   setState(() {
//   //     // _isLoggedIn = token != null && token.isNotEmpty;
//   //     if(token != null && token.isNotEmpty){
//   //       _isLoggedIn = true;
//   //     } else {
//   //       _isLoggedIn = false;
//   //     }
//   //   });
//   // }

//  Future<void> _checkLoginStatus() async {
//     if (_isCheckingLoginStatus) return;
//     _isCheckingLoginStatus = true;

//     final token = await TokenStorageService.getToken();
//     print('Login with $token');

//     setState(() {
//       _isLoggedIn = token != null && token.isNotEmpty;
//     });

//     _isCheckingLoginStatus = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('_isLoggedIn1: $_isLoggedIn');

//     if (_isCheckingLoginStatus) {
//       return const material.SizedBox.shrink(); // Return an empty widget while checking login status
//     }

//     if (_isLoggedIn) {
//       return widget.child;
//     } else {
//       // Redirect the user to the home page
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.of(context).pushReplacementNamed('/');
//       });
//       return const material.SizedBox.shrink(); // Return an empty widget to avoid rendering anything
//     }
//   }
// }

// route_guard.dart
// class RouteGuard extends StatefulWidget {
//   final Widget child;
//   final List<String>? allowedRoles;

//   const RouteGuard({
//     Key? key,
//     required this.child,
//     this.allowedRoles,
//   }) : super(key: key);

//   @override
//   _RouteGuardState createState() => _RouteGuardState();
// }

// class _RouteGuardState extends State<RouteGuard> {
//   bool _isLoggedIn = false;
//   bool _isAuthorized = false;
//   bool _isCheckingStatus = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkAccessStatus();
//   }

//   Future<void> _checkAccessStatus() async {
//     if (!mounted) return;

//     final token = await TokenStorageService.getToken();
//     bool isLoggedIn = token != null && token.isNotEmpty;
//     bool isAuthorized = true;

//     if (isLoggedIn && widget.allowedRoles != null) {
//       isAuthorized = await AuthService.hasAnyRole(widget.allowedRoles!);
//     }

//     if (mounted) {
//       setState(() {
//         _isLoggedIn = isLoggedIn;
//         _isAuthorized = isAuthorized;
//         _isCheckingStatus = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isCheckingStatus) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (!_isLoggedIn) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.of(context).pushReplacementNamed('/login');
//       });
//       return const SizedBox.shrink();
//     }

//     if (!_isAuthorized) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('You do not have permission to access this page'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         Navigator.of(context).pushReplacementNamed('/welcome');
//       });
//       return const SizedBox.shrink();
//     }

//     return widget.child;
//   }
// }

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
      // return LoginPage();
      Navigator.pushNamed(context, '/login');
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
