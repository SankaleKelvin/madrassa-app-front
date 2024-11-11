// routes.dart
import 'package:flutter/material.dart';
import '../screens/location_page.dart';
import '../screens/home_page.dart';
import '../screens/madrassa_page.dart';
import '../screens/courses_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => HomePage(),
  '/madrassa': (context) => MadrassaPage(),
  '/courses': (context) => CoursePage(),
  '/locations': (context) => LocationPage()
};
