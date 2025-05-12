// lib/main.dart (modificado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/teams_provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/schedule_provider.dart'; // Añadido
import 'services/notification_service.dart'; // Añadido
import 'screens/onboarding_screen.dart'; // Añadido
import 'package:shared_preferences/shared_preferences.dart'; // Añadido

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el servicio de notificaciones
  await NotificationService.initialize();
  
  // Inicializar los providers antes de construir la app
  final teamsProvider = TeamsProvider();
  final gameProvider = GameProvider();
  final themeProvider = ThemeProvider();
  final scheduleProvider = ScheduleProvider(); // Añadido
  
  // Cargar datos guardados de manera asíncrona
  await Future.wait([
    teamsProvider.initialize(),
    gameProvider.initialize(),
    themeProvider.initialize(),
    scheduleProvider.initialize(), // Añadido
  ]);
  
  // Verificar si el onboarding ha sido completado
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  
  runApp(MyApp(
    teamsProvider: teamsProvider,
    gameProvider: gameProvider,
    themeProvider: themeProvider,
    scheduleProvider: scheduleProvider, // Añadido
    onboardingCompleted: onboardingCompleted, // Añadido
  ));
}

class MyApp extends StatelessWidget {
  final TeamsProvider teamsProvider;
  final GameProvider gameProvider;
  final ThemeProvider themeProvider;
  final ScheduleProvider scheduleProvider; // Añadido
  final bool onboardingCompleted; // Añadido
  
  const MyApp({
    Key? key,
    required this.teamsProvider,
    required this.gameProvider,
    required this.themeProvider,
    required this.scheduleProvider, // Añadido
    required this.onboardingCompleted, // Añadido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: teamsProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: scheduleProvider), // Añadido
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Awana Games',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRoutes.generateRoute,
            // Si el onboarding no ha sido completado, mostrar la pantalla de onboarding
            initialRoute: onboardingCompleted ? '/' : '/onboarding',
            // Agregar la ruta para la pantalla de onboarding
            routes: {
              ...AppRoutes.routes,
              '/onboarding': (context) => const OnboardingScreen(),
            },
          );
        },
      ),
    );
  }
}