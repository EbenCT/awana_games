import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awana Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      initialRoute: '/',
    );
  }
}
