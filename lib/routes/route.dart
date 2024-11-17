// // routes.dart
// import 'package:flutter/material.dart';
// import '../screens/login_page.dart';
// import '../screens/register_page.dart';
// import '../screens/about_us_page.dart';
// import '../screens/student_page.dart';
// import '../screens/location_page.dart';
// import '../screens/welcome_page.dart';
// import '../screens/home_page.dart';
// import '../screens/madrassa_page.dart';
// import '../screens/courses_page.dart';
// import '../screens/menu_items.dart';
// import './route_guard.dart';

// final Map<String, WidgetBuilder> appRoutes = {
//   '/': (context) => HomePage(),
//   '/about-us': (context) => AboutUsPage(),
//   '/register': (context) => RegisterPage(),
//   '/login': (context) => LoginPage(),
//   '/welcome' : (context) => RouteGuard(child: WelcomePage()),
//   '/menu' : (context) => RouteGuard(child: MenuItems()),
//   '/madrassa': (context) => RouteGuard(child: MadrassaPage()),
//   '/courses': (context) => RouteGuard(child: CoursePage()),
//   '/locations': (context) => RouteGuard(child: LocationPage()),
//   '/students' : (context) => RouteGuard(child: StudentPage())
  
// };

// routes.dart
import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/about_us_page.dart';
import '../screens/student_page.dart';
import '../screens/location_page.dart';
import '../screens/welcome_page.dart';
import '../screens/home_page.dart';
import '../screens/madrassa_page.dart';
import '../screens/courses_page.dart';
import '../screens/menu_items.dart';
import './route_guard.dart';
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => HomePage(),
  '/about-us': (context) => AboutUsPage(),
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/welcome': (context) => RouteGuard(child: WelcomePage()),
  '/menu': (context) => RouteGuard(
        child: MenuItems(),
        allowedRoles: ['Admin', 'Teacher'],
      ),
  '/madrassa': (context) => RouteGuard(
        child: MadrassaPage(),
        allowedRoles: ['Admin', 'Teacher'],
      ),
  '/courses': (context) => RouteGuard(
        child: CoursePage(),
        allowedRoles: ['Admin', 'Teacher', 'Student'],
      ),
  '/locations': (context) => RouteGuard(
        child: LocationPage(),
        allowedRoles: ['Admin', 'Teacher', 'Student'],
      ),
  '/students': (context) => RouteGuard(
        child: StudentPage(),
        allowedRoles: ['Admin', 'Teacher'],
      ),
};
