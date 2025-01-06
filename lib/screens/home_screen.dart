// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/common/primary_button.dart';
import '../config/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Iniciar Juego',
                onPressed: () => Navigator.pushNamed(context, '/score'),
                backgroundColor: Colors.purple,
                fullWidth: true,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Ver Posiciones',
                onPressed: () => Navigator.pushNamed(context, '/standings'),
                backgroundColor: Colors.blue,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}