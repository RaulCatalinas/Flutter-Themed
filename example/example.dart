import 'package:flutter/material.dart';
import 'package:flutter_themed/flutter_themed.dart';
import 'package:flutter_themed/themed_app.dart';

// ============================================================================
// STORAGE ADAPTER (Optional - use your preferred storage)
// ============================================================================

/// Implement ThemeStorageAdapter with your preferred storage solution:
/// - SharedPreferences: await prefs.setString('theme', themeName)
/// - Hive: await box.put('theme', themeName)
/// - GetStorage: await storage.write('theme', themeName)
/// - Or any other storage you prefer
class MyThemeStorage implements ThemeStorageAdapter {
  String? _savedTheme;

  @override
  Future<void> saveTheme(String themeName) async {
    _savedTheme = themeName;
    // Replace with your storage logic
  }

  @override
  Future<String?> loadTheme() async {
    return _savedTheme;
    // Replace with your storage logic
  }
}

void main() async {
  // Only necessary if you use native plugins:
  WidgetsFlutterBinding.ensureInitialized();

  await Themed.initialize(
    storageAdapter:
        MyThemeStorage(), // Remove the storageAdapter parameter if you don't need persistence.
  );

  Themed.createTheme(
    name: 'ocean',
    primaryColor: const Color(0xFF006994),
    secondaryColor: const Color(0xFF4A90A4),
    brightness: Brightness.light,
    borderRadius: 16,
  );

  Themed.createTheme(
    name: 'sunset',
    primaryColor: Colors.deepOrange,
    secondaryColor: Colors.amber,
    brightness: Brightness.light,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedApp(
      title: 'Theme Manager Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Manager'),
        actions: [
          IconButton(
            icon: Icon(
              Themed.currentTheme.brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle light/dark theme',
            onPressed: () => Themed.toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----------------------------------------------------------------
          // Current theme info
          // ----------------------------------------------------------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.palette,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Themed.currentThemeName.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // --------------------------------------------------------
                  // Theme state properties
                  // --------------------------------------------------------
                  _ThemeStateRow(
                    label: 'isDarkMode',
                    value: Themed.isDarkMode,
                  ),
                  _ThemeStateRow(
                    label: 'isLightMode',
                    value: Themed.isLightMode,
                  ),
                  _ThemeStateRow(
                    label: 'isCustomTheme',
                    value: Themed.isCustomTheme,
                  ),
                  if (Themed.isCustomTheme)
                    _ThemeStateRow(
                      label:
                          'isActiveCustomTheme("${Themed.currentThemeName}")',
                      value: Themed.isActiveCustomTheme(
                        Themed.currentThemeName,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ----------------------------------------------------------------
          // Available themes list
          // ----------------------------------------------------------------
          Text(
            'Available Themes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...Themed.availableThemes.map((theme) {
            final isCurrent = Themed.currentThemeName == theme;
            return Card(
              child: ListTile(
                leading: Icon(
                  _getIcon(theme),
                  color: isCurrent ? Theme.of(context).primaryColor : null,
                ),
                title: Text(theme),
                trailing: isCurrent ? const Icon(Icons.check_circle) : null,
                onTap: () => Themed.setTheme(theme),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIcon(String theme) {
    return switch (theme.toLowerCase()) {
      'light' => Icons.wb_sunny,
      'dark' => Icons.nightlight_round,
      'ocean' => Icons.water,
      'sunset' => Icons.wb_twilight,
      _ => Icons.palette,
    };
  }
}

// ============================================================================
// Helper widget
// ============================================================================

class _ThemeStateRow extends StatelessWidget {
  final String label;
  final bool value;

  const _ThemeStateRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
