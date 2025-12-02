import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutriby_frontend/presentation/screens/welcome_screen.dart';
import 'package:nutriby_frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

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