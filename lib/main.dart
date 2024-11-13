import 'package:flutter/material.dart';
import 'package:madrassa_app/screens/welcome_page.dart';
import 'routes/route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madrassa App',
      theme: ThemeData(primarySwatch: Colors.blue),   
      routes: appRoutes,
    );
  }
}
