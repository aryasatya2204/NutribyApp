import 'package:flutter/material.dart';
import 'package:nutriby_frontend/presentation/screens/welcome_screen.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'NutriBy',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}