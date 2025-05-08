// lib/widgets/common/theme_toggle.dart (mejorado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        themeProvider.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        themeProvider.isDarkMode 
            ? 'Cambiar a modo claro' 
            : 'Cambiar a modo oscuro',
        style: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (_) {
          themeProvider.toggleTheme();
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}