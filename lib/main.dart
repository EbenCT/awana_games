// lib/main.dart (modificado para verificación de notificaciones)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/teams_provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/schedule_provider.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el servicio de notificaciones PRIMERO
  debugPrint('🔔 Inicializando servicio de notificaciones...');
  await NotificationService.initialize();
  
  // Inicializar los providers antes de construir la app
  final teamsProvider = TeamsProvider();
  final gameProvider = GameProvider();
  final themeProvider = ThemeProvider();
  final scheduleProvider = ScheduleProvider();
  
  // Cargar datos guardados de manera asíncrona
  debugPrint('📱 Cargando datos de providers...');
  await Future.wait([
    teamsProvider.initialize(),
    gameProvider.initialize(),
    themeProvider.initialize(),
    scheduleProvider.initialize(), // Esto ya incluye verificación de notificaciones
  ]);
  
  // Verificar si el onboarding ha sido completado
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  
  // NUEVA VERIFICACIÓN: Estado de notificaciones al inicio
  if (onboardingCompleted && scheduleProvider.notificationsEnabled) {
    debugPrint('✅ Verificando estado de notificaciones al inicio...');
    final notificationStatus = await scheduleProvider.getNotificationStatus();
    debugPrint('📊 Estado de notificaciones: $notificationStatus');
    
    // Si hay pocas notificaciones semanales, renovar automáticamente
    if (notificationStatus['weekly_notifications'] < 3) {
      debugPrint('🔄 Pocas notificaciones semanales, renovando automáticamente...');
      await scheduleProvider.forceRenewNotifications();
    }
  }
  
  debugPrint('🚀 Iniciando aplicación...');
  
  runApp(MyApp(
    teamsProvider: teamsProvider,
    gameProvider: gameProvider,
    themeProvider: themeProvider,
    scheduleProvider: scheduleProvider,
    onboardingCompleted: onboardingCompleted,
  ));
}

class MyApp extends StatelessWidget {
  final TeamsProvider teamsProvider;
  final GameProvider gameProvider;
  final ThemeProvider themeProvider;
  final ScheduleProvider scheduleProvider;
  final bool onboardingCompleted;
  
  const MyApp({
    Key? key,
    required this.teamsProvider,
    required this.gameProvider,
    required this.themeProvider,
    required this.scheduleProvider,
    required this.onboardingCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: teamsProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: scheduleProvider),
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