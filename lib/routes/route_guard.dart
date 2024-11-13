import 'package:flutter/material.dart';
import '../services/token_storage_service.dart';
import 'package:flutter/material.dart' as material;

class RouteGuard extends StatefulWidget {
  final Widget child;
  RouteGuard({required this.child});

  @override
  _RouteGuardState createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  bool _isLoggedIn = false;
  bool _isCheckingLoginStatus = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Future<void> _checkLoginStatus() async {
  //   final token = await TokenStorageService.getToken();
  //   print('Login with $token');
  //   setState(() {
  //     // _isLoggedIn = token != null && token.isNotEmpty;
  //     if(token != null && token.isNotEmpty){
  //       _isLoggedIn = true;
  //     } else {
  //       _isLoggedIn = false;
  //     }
  //   });
  // }

 Future<void> _checkLoginStatus() async {
    if (_isCheckingLoginStatus) return;
    _isCheckingLoginStatus = true;

    final token = await TokenStorageService.getToken();
    print('Login with $token');

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });

    _isCheckingLoginStatus = false;
  }


  @override
  Widget build(BuildContext context) {
    print('_isLoggedIn1: $_isLoggedIn');

    if (_isCheckingLoginStatus) {
      return const material.SizedBox.shrink(); // Return an empty widget while checking login status
    }
    
    if (_isLoggedIn) {
      return widget.child;
    } else {
      // Redirect the user to the home page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const material.SizedBox.shrink(); // Return an empty widget to avoid rendering anything
    }
  }
}