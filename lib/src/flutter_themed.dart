import 'package:flutter/material.dart'
    show
        AppBarTheme,
        BorderRadius,
        BorderSide,
        Brightness,
        CardThemeData,
        Color,
        ColorScheme,
        Colors,
        ElevatedButton,
        ElevatedButtonThemeData,
        FloatingActionButtonThemeData,
        FontWeight,
        IconThemeData,
        InkRipple,
        InputDecorationTheme,
        NoSplash,
        OutlineInputBorder,
        OutlinedButton,
        OutlinedButtonThemeData,
        RoundedRectangleBorder,
        TextButton,
        TextButtonThemeData,
        TextStyle,
        TextTheme,
        ThemeData,
        ValueNotifier;

/// Interface for implementing custom theme storage solutions.
///
/// Implement this interface to persist theme preferences using your
/// preferred storage mechanism (SharedPreferences, Hive, GetStorage, etc.).
abstract class ThemeStorageAdapter {
  /// Saves the selected theme name to persistent storage.
  ///
  /// Called automatically whenever the theme changes via [Themed.setTheme]
  /// or [Themed.toggleTheme].
  Future<void> saveTheme(String themeName);

  /// Loads the previously saved theme name from persistent storage.
  ///
  /// Called once during [Themed.initialize]. Return `null` if no
  /// theme was previously saved.
  Future<String?> loadTheme();
}

/// Manages theme switching and persistence for Flutter applications.
///
/// Themed is a singleton that handles:
/// - Built-in light and dark themes
/// - Custom theme creation and management
/// - Automatic theme persistence (when storage adapter is provided)
/// - Reactive theme updates via [ValueNotifier]
class Themed {
  static final Themed _instance = Themed._internal();
  late ValueNotifier<ThemeData> themeNotifier;
  final Map<String, ThemeData> _themes = {};
  String _currentThemeName = 'light';
  ThemeStorageAdapter? _storageAdapter;

  /// Returns the singleton instance of Themed.
  static Themed get instance => _instance;

  /// Returns the currently active [ThemeData].
  static ThemeData get currentTheme => _instance.themeNotifier.value;

  /// Returns the name of the currently active theme.
  static String get currentThemeName => _instance._currentThemeName;

  /// Returns a list of all available theme names.
  ///
  /// Includes built-in themes ('light', 'dark') and any custom themes created with [createTheme].
  static List<String> get availableThemes => _instance._themes.keys.toList();

  /// Checks if a theme with the given [name] exists.
  ///
  /// Returns `true` if the theme exists, `false` otherwise.
  static bool hasTheme(String name) => _instance._themes.containsKey(name);

  /// Returns `true` if the currently active theme is the built-in dark theme.
  ///
  /// This only returns `true` for the default 'dark' theme.
  /// Custom themes with [Brightness.dark] will **not** be considered dark mode.
  ///
  /// Example:
  /// ```dart
  /// if (Themed.isDarkMode) {
  ///   print('Dark theme is active');
  /// }
  /// ```
  static bool get isDarkMode => _instance._currentThemeName == 'dark';

  /// Returns `true` if the currently active theme is the built-in light theme.
  ///
  /// This only returns `true` for the default 'light' theme.
  /// Custom themes with [Brightness.light] will **not** be considered light mode.
  ///
  /// Example:
  /// ```dart
  /// if (Themed.isLightMode) {
  ///   print('Light theme is active');
  /// }
  /// ```
  static bool get isLightMode => _instance._currentThemeName == 'light';

  /// Returns `true` if the currently active theme is a custom theme.
  ///
  /// A custom theme is any theme that is not the built-in 'light' or 'dark' theme.
  ///
  /// Example:
  /// ```dart
  /// if (Themed.isCustomTheme) {
  ///   print('A custom theme is active: ${Themed.currentThemeName}');
  /// }
  /// ```
  static bool get isCustomTheme =>
      _instance._currentThemeName != 'light' &&
      _instance._currentThemeName != 'dark';

  /// Returns `true` if the custom theme with the given [name] is currently active.
  ///
  /// Throws [Exception] if [name] is 'light' or 'dark' — use [isDarkMode] or
  /// [isLightMode] instead for built-in themes.
  ///
  /// Example:
  /// ```dart
  /// if (Themed.isActiveCustomTheme('ocean')) {
  ///   print('Ocean theme is active');
  /// }
  /// ```
  static bool isActiveCustomTheme(String name) {
    if (name == 'light' || name == 'dark') {
      throw Exception(
        'Use isDarkMode or isLightMode for built-in themes',
      );
    }

    return _instance._currentThemeName == name;
  }

  factory Themed() => _instance;

  Themed._internal() {
    _themes['light'] = ThemeData.light();
    _themes['dark'] = ThemeData.dark();
    themeNotifier = ValueNotifier(_themes['light']!);
  }

  /// Initializes Themed with optional persistent storage.
  ///
  /// Should be called before [runApp]. If [storageAdapter] is provided, loads the saved theme and persists future changes.
  static Future<void> initialize({ThemeStorageAdapter? storageAdapter}) async {
    _instance._storageAdapter = storageAdapter;

    _instance._themes['light'] = ThemeData.light();
    _instance._themes['dark'] = ThemeData.dark();

    String? lastTheme;

    if (storageAdapter != null) {
      lastTheme = await storageAdapter.loadTheme();
    }

    final theme = _instance._themes[lastTheme] ?? _instance._themes['light']!;
    _instance.themeNotifier.value = theme;
    _instance._currentThemeName = lastTheme ?? 'light';
  }

  /// Switches to the theme with the specified [name].
  ///
  /// If a storage adapter was provided during initialization, the theme
  /// preference is automatically saved.
  ///
  /// Does nothing if the theme doesn't exist. Use [hasTheme] to check first.
  static void setTheme(String name) async {
    final theme = _instance._themes[name];

    if (theme == null) return;

    _instance.themeNotifier.value = theme;
    _instance._currentThemeName = name;

    if (_instance._storageAdapter != null) {
      await _instance._storageAdapter!.saveTheme(name);
    }
  }

  /// Toggles between the built-in light and dark themes.
  ///
  /// If the current theme is light, switches to dark and vice versa.
  ///
  /// **Note:** If a custom theme is currently active, instead of toggling,
  /// this method switches to the built-in theme that matches the custom
  /// theme's [Brightness] — [Brightness.dark] maps to 'dark' and
  /// [Brightness.light] maps to 'light'.
  ///
  /// Example:
  /// ```dart
  /// Themed.toggleTheme(); // light → dark
  /// Themed.toggleTheme(); // dark → light
  ///
  /// Themed.setTheme('ocean'); // ocean has Brightness.dark
  /// Themed.toggleTheme();     // ocean → dark (built-in)
  /// ```
  static void toggleTheme() {
    if (isCustomTheme) {
      setTheme(
        _instance.themeNotifier.value.brightness == Brightness.dark
            ? 'dark'
            : 'light',
      );

      return;
    }

    setTheme(isLightMode ? 'dark' : 'light');
  }

  /// Removes a custom theme.
  ///
  /// Throws [Exception] if attempting to remove 'light' or 'dark'.
  static void removeTheme(String name) {
    if (name.toLowerCase() == 'light' || name.toLowerCase() == 'dark') {
      throw Exception("Can't remove default themes");
    }

    _instance._themes.remove(name);
  }

  /// Removes all custom themes, keeping only 'light' and 'dark'.
  static void clearCustomThemes() {
    _instance._themes.removeWhere((key, _) => key != 'light' && key != 'dark');
  }

  /// Creates a custom theme with the specified configuration.
  ///
  /// Required: [name], [primaryColor], [secondaryColor], [brightness].
  /// All other parameters are optional for detailed customization.
  ///
  /// Throws [Exception] if [name] is 'light'/'dark' or already exists.
  static void createTheme({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    required Brightness brightness,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? scaffoldBackgroundColor,
    Color? appBarColor,
    Color? cardColor,
    Color? dividerColor,
    Color? iconColor,
    Color? textColor,
    Color? hintColor,
    Color? disabledColor,
    Color? errorColor,
    Color? buttonColor,
    double? borderRadius,
    double? elevation,
    Color? fabColor,
    Color? inputFillColor,
    Color? inputBorderColor,
    String? fontFamily,
    FontWeight? fontWeight,
    TextStyle? headlineStyle,
    TextStyle? bodyStyle,
    TextStyle? buttonTextStyle,
    bool? useMaterial3,
    bool? useRippleEffect,
  }) {
    if (name.toLowerCase() == 'light' || name.toLowerCase() == 'dark') {
      throw Exception("Can't override default themes");
    }

    if (_instance._themes.containsKey(name)) {
      throw Exception(
        'Theme with name $name already exists, choose a different name',
      );
    }

    final isLight = brightness == Brightness.light;

    final theme = ThemeData(
      useMaterial3: useMaterial3,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      disabledColor: disabledColor,
      hintColor: hintColor,
      iconTheme: IconThemeData(color: iconColor),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: textColor ?? Colors.white,
        secondary: secondaryColor,
        onSecondary: textColor ?? Colors.white,
        error: errorColor ?? Colors.red,
        onError: Colors.white,
        surface:
            surfaceColor ?? (isLight ? Colors.white : const Color(0xFF1E1E1E)),
        onSurface: textColor ?? (isLight ? Colors.black : Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        elevation: elevation,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabColor,
        foregroundColor: textColor,
        elevation: elevation,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: elevation,
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: TextStyle(fontWeight: fontWeight, fontFamily: fontFamily),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        hintStyle: TextStyle(color: hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: inputBorderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: inputBorderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      textTheme: TextTheme(headlineLarge: headlineStyle, bodyLarge: bodyStyle),
      splashFactory: (useRippleEffect ?? true)
          ? InkRipple.splashFactory
          : NoSplash.splashFactory,
    );

    _instance._themes[name] = theme;
  }
}
