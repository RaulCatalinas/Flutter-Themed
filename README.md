# Flutter Themed

A simple, plug-and-play theme management library for Flutter with optional persistence and zero configuration required.

## Features

✨ **Zero Configuration** - Works out of the box with light and dark themes  
🎨 **Unlimited Custom Themes** - Create as many themes as you need with a simple API  
🚀 **Drop-in Replacement** - Just replace `MaterialApp` with `ThemedApp`

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_themed: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

The simplest possible implementation - just replace MaterialApp with ThemedApp:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_themed/flutter_themed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.palette),
              onPressed: () => Themed.toggleTheme(),
            ),
          ],
        ),
        body: Center(
          child: Text('Current theme: ${Themed.currentThemeName}'),
        ),
      ),
    );
  }
}
```

That's it! Your app now supports light and dark themes with a single button.

## Storage Adapter (Optional)

To persist theme preferences across app restarts, implement `ThemeStorageAdapter` with your preferred storage solution:

```dart
/// Example: In-memory storage (no persistence)
/// Replace with SharedPreferences, Hive, GetStorage, or any other solution
class MyThemeStorage implements ThemeStorageAdapter {
  String? _savedTheme;

  @override
  Future<void> saveTheme(String themeName) async {
    _savedTheme = themeName;
    // Your storage logic here:
    // - SharedPreferences: await prefs.setString('theme', themeName)
    // - Hive: await box.put('theme', themeName)
    // - GetStorage: await storage.write('theme', themeName)
  }

  @override
  Future<String?> loadTheme() async {
    return _savedTheme;
    // Your storage logic here:
    // - SharedPreferences: return prefs.getString('theme')
    // - Hive: return box.get('theme')
    // - GetStorage: return storage.read('theme')
  }
}

void main() async {
  // Only needed if using native plugins (SharedPreferences, Hive, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  await Themed.initialize(
    storageAdapter: MyThemeStorage(), // Optional: remove if you don't need persistence
  );

  runApp(const MyApp());
}
```

**Note:** The storage adapter is completely optional. Without it, the library still works but won't persist theme preferences between app restarts. Uncomment `WidgetsFlutterBinding.ensureInitialized()` only if your storage uses native plugins (SharedPreferences, Hive, etc.).

## Custom Themes

Create multiple themed experiences for your app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_themed/flutter_themed.dart';

void main() async {
  await Themed.initialize();

  // 🌊 Ocean theme
  Themed.createTheme(
    name: 'ocean',
    primaryColor: const Color(0xFF006994),
    secondaryColor: const Color(0xFF4A90A4),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F8FF),
  );

  // 🌲 Forest theme
  Themed.createTheme(
    name: 'forest',
    primaryColor: const Color(0xFF2E7D32),
    secondaryColor: const Color(0xFF66BB6A),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A2F1A),
    cardColor: const Color(0xFF263D26),
  );

  // 🌸 Rose theme
  Themed.createTheme(
    name: 'rose',
    primaryColor: Colors.pink[400]!,
    secondaryColor: Colors.pinkAccent,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.pink[50],
    borderRadius: 20,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedApp(
      title: 'Custom Themes Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: Themed.availableThemes.length,
        itemBuilder: (context, index) {
          final theme = Themed.availableThemes[index];
          final isCurrent = Themed.currentThemeName == theme;

          return ElevatedButton(
            onPressed: () => Themed.setTheme(theme),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrent ? Theme.of(context).primaryColor : null,
            ),
            child: Text(theme),
          );
        },
      ),
    );
  }
}
```

## Creating Custom Themes

Themed provides a simple API to create custom themes. Only four parameters are required:

```dart
Themed.createTheme(
  name: 'my_theme',              // Required: unique identifier
  primaryColor: Colors.blue,      // Required: main app color
  secondaryColor: Colors.blueAccent, // Required: accent color
  brightness: Brightness.light,   // Required: light or dark
  
  // All other parameters are optional:
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.grey[100],
  appBarColor: Colors.blue,
  buttonColor: Colors.blue,
  fabColor: Colors.blue,
  borderRadius: 16,
  elevation: 4,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
  useMaterial3: true,
  useRippleEffect: true,
  // ... and many more
);
```

## API Reference

### ThemedApp Widget

`ThemedApp` is a drop-in replacement for `MaterialApp` that automatically handles theme changes. It accepts all the same parameters as `MaterialApp`:

```dart
ThemedApp(
  title: 'My App',
  home: HomePage(),
  routes: {...},
  // Don't use theme or darkTheme - Themed handles them
  // ... all other MaterialApp parameters work normally
)
```

**Important:** Do not set `theme` or `darkTheme` parameters manually as Themed controls these automatically.

### Themed Methods

```dart
// Initialize (optional, but required for storage)
await Themed.initialize(storageAdapter: MyStorage());

// Create a custom theme
Themed.createTheme(
  name: 'custom',
  primaryColor: Colors.purple,
  secondaryColor: Colors.purpleAccent,
  brightness: Brightness.dark,
);

// Switch themes
Themed.setTheme('custom');

// Toggle between light and dark
Themed.toggleTheme();

// Check available themes
List<String> themes = Themed.availableThemes;

// Get current theme
String currentName = Themed.currentThemeName;
ThemeData currentTheme = Themed.currentTheme;

// Check if theme exists
bool exists = Themed.hasTheme('ocean');

// Remove custom themes (cannot remove 'light' or 'dark')
Themed.removeTheme('custom');
Themed.clearCustomThemes();
```

## Best Practices

### 1. Create Themes Before runApp

Define all your custom themes in `main()` before calling `runApp()`:

```dart
void main() async {
  await Themed.initialize();
  
  Themed.createTheme(
    name: 'custom',
    primaryColor: Colors.purple,
    secondaryColor: Colors.purpleAccent,
    brightness: Brightness.dark,
  );
  
  runApp(const MyApp());
}
```

### 2. Use Descriptive Theme Names

Choose clear, meaningful names for your themes:

```dart
// ❌ Bad
Themed.createTheme(name: 'theme1', ...);

// ✅ Good
Themed.createTheme(name: 'ocean_breeze', ...);
```

### 3. Provide Visual Feedback

Show users which theme is currently active:

```dart
ListTile(
  title: Text(themeName),
  trailing: Themed.currentThemeName == themeName 
    ? const Icon(Icons.check) 
    : null,
  onTap: () => Themed.setTheme(themeName),
)
```

### 4. Access Theme Anywhere

Theme data is accessible throughout your widget tree:

```dart
// Using Themed
final isDark = Themed.currentTheme.brightness == Brightness.dark;

// Using Theme.of(context) as usual
final primaryColor = Theme.of(context).primaryColor;
```

## FAQ

### How does persistence work?

Flutter Theme Manager supports persistence only when you provide a `ThemeStorageAdapter`.

**If a ThemeStorageAdapter is provided:**
- The selected theme is saved whenever it changes
- When the app starts, the previously saved theme is automatically loaded
- If no theme was saved yet, the default is light

**If no adapter is provided:**
- The selected theme is not persisted
- The app always starts with the default light theme

### Can I use it without SharedPreferences?

Yes! You can store themes using any solution that implements `ThemeStorageAdapter` (e.g., SharedPreferences, Hive, GetStorage, SQLite, custom solutions, etc.).

If you don't provide an adapter, the library still works — just without persistence.

### Does it work with MaterialApp.router?

Currently, Flutter Theme Manager only supports the standard `MaterialApp`. Support for `MaterialApp.router` may be added in a future version.

### Can I change themes programmatically?

Absolutely! Use `Themed.setTheme('themeName')` from anywhere in your code - no BuildContext required.

### Can I override the default light/dark themes?

No. The built-in `light` and `dark` themes cannot be replaced or modified.

This is intentional to avoid conflicts with Flutter's own `ThemeData.light()` and `ThemeData.dark()`.

You can still create unlimited custom themes (e.g., `ocean`, `sunset`, `my_dark`).

## Roadmap

Future features under consideration:

- 🔄 Theme transitions/animations
- 📱 System theme detection
- 🎨 Theme presets library
- 🌙 Automatic dark mode scheduling
- 🎯 Theme inheritance

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/RaulCatalinas/Flutter-Theme-Manager/issues) on GitHub.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.
