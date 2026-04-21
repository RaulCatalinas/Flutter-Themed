import 'package:flutter/material.dart'
    show Brightness, Colors, FontWeight, RoundedRectangleBorder, TextStyle;
import 'package:flutter_test/flutter_test.dart'
    show
        test,
        expect,
        group,
        setUp,
        contains,
        isTrue,
        isFalse,
        isA,
        throwsException;
import 'package:flutter_themed/flutter_themed.dart' show Themed;

import 'test_utils.dart' show MockThemeStorageAdapter;

void main() {
  final mockStorage = MockThemeStorageAdapter();

  setUp(() async {
    await mockStorage.reset();
  });

  group('Themed - Initialization', () {
    test('should have light and dark themes by default', () {
      expect(Themed.hasTheme('light'), isTrue);
      expect(Themed.hasTheme('dark'), isTrue);
    });

    test('should list all available themes', () {
      final themes = Themed.availableThemes;
      expect(themes, contains('light'));
      expect(themes, contains('dark'));
    });

    test('should initialize with light theme by default', () async {
      await Themed.initialize();
      expect(Themed.currentTheme.brightness, Brightness.light);
    });

    test('should load last saved theme if it exists', () async {
      await mockStorage.saveTheme('dark');

      await Themed.initialize(storageAdapter: mockStorage);

      expect(Themed.currentTheme.brightness, Brightness.dark);
      expect(mockStorage.loadCallCount, 1);
    });

    test('should use light theme if saved theme does not exist', () async {
      await Themed.initialize(storageAdapter: mockStorage);

      expect(Themed.currentTheme.brightness, Brightness.light);
    });
  });

  group('Themed - Theme switching', () {
    setUp(() async {
      await Themed.initialize(storageAdapter: mockStorage);
    });

    test('should switch theme correctly', () {
      Themed.setTheme('dark');
      expect(Themed.currentTheme.brightness, Brightness.dark);
    });

    test('should persist theme when switching', () async {
      Themed.setTheme('dark');

      // Give time for async operation to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(mockStorage.savedTheme, 'dark');
      expect(mockStorage.saveCallCount, 1);
    });

    test('should do nothing if theme does not exist', () {
      final initialBrightness = Themed.currentTheme.brightness;
      Themed.setTheme('nonexistent');

      expect(Themed.currentTheme.brightness, initialBrightness);
      expect(mockStorage.saveCallCount, 0);
    });

    test('should toggle between light and dark', () {
      // Starts with light
      Themed.setTheme('light');
      expect(Themed.currentTheme.brightness, Brightness.light);

      Themed.toggleTheme();
      expect(Themed.currentTheme.brightness, Brightness.dark);

      Themed.toggleTheme();
      expect(Themed.currentTheme.brightness, Brightness.light);
    });
  });

  group('Themed - Notifications', () {
    test('should notify theme changes', () async {
      await Themed.initialize();

      var notificationCount = 0;
      Themed.instance.themeNotifier.addListener(() {
        notificationCount++;
      });

      Themed.setTheme('dark');
      await Future.delayed(Duration(milliseconds: 50));

      expect(notificationCount, 1);

      Themed.setTheme('light');
      await Future.delayed(Duration(milliseconds: 50));

      expect(notificationCount, 2);
    });
  });

  group('Themed - Custom themes', () {
    test('should create a custom theme', () {
      Themed.createTheme(
        name: 'custom',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      expect(Themed.hasTheme('custom'), isTrue);
      expect(Themed.availableThemes, contains('custom'));
    });

    test('should not overwrite default themes', () {
      expect(
        () => Themed.createTheme(
          name: 'light',
          primaryColor: Colors.purple,
          secondaryColor: Colors.amber,
          brightness: Brightness.light,
        ),
        throwsException,
      );

      expect(
        () => Themed.createTheme(
          name: 'dark',
          primaryColor: Colors.purple,
          secondaryColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        throwsException,
      );
    });

    test('should not create multiple themes with the same name', () {
      Themed.createTheme(
        name: 'duplicate',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      expect(
        () => Themed.createTheme(
          name: 'duplicate',
          primaryColor: Colors.green,
          secondaryColor: Colors.red,
          brightness: Brightness.dark,
        ),
        throwsException,
      );
    });

    test('should apply custom colors correctly', () {
      Themed.createTheme(
        name: 'custom_colors',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
      );

      Themed.setTheme('custom_colors');
      final theme = Themed.currentTheme;

      expect(theme.colorScheme.primary, Colors.purple);
      expect(theme.colorScheme.secondary, Colors.amber);
      expect(theme.scaffoldBackgroundColor, Colors.grey[100]);
    });

    test('should apply Material3 configuration', () {
      Themed.createTheme(
        name: 'material3',
        primaryColor: Colors.blue,
        secondaryColor: Colors.orange,
        brightness: Brightness.light,
        useMaterial3: true,
      );

      Themed.setTheme('material3');
      expect(Themed.currentTheme.useMaterial3, true);
    });

    test('should apply custom border radius', () {
      Themed.createTheme(
        name: 'rounded',
        primaryColor: Colors.blue,
        secondaryColor: Colors.orange,
        brightness: Brightness.light,
        borderRadius: 20.0,
      );

      Themed.setTheme('rounded');
      final theme = Themed.currentTheme;
      final buttonShape = theme.elevatedButtonTheme.style?.shape?.resolve({});

      expect(buttonShape, isA<RoundedRectangleBorder>());
    });

    test('should remove custom theme', () {
      Themed.createTheme(
        name: 'custom_to_remove',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      expect(Themed.hasTheme('custom_to_remove'), isTrue);

      Themed.removeTheme('custom_to_remove');
      expect(Themed.hasTheme('custom_to_remove'), isFalse);
    });

    test('should not allow removing default themes', () {
      expect(
        () => Themed.removeTheme('light'),
        throwsException,
      );

      expect(
        () => Themed.removeTheme('dark'),
        throwsException,
      );
    });

    test('should clear only custom themes', () {
      Themed.createTheme(
        name: 'custom1',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      Themed.createTheme(
        name: 'custom2',
        primaryColor: Colors.green,
        secondaryColor: Colors.red,
        brightness: Brightness.dark,
      );

      Themed.clearCustomThemes();

      expect(Themed.hasTheme('light'), isTrue);
      expect(Themed.hasTheme('dark'), isTrue);
      expect(Themed.hasTheme('custom1'), isFalse);
      expect(Themed.hasTheme('custom2'), isFalse);
    });
  });

  group('Themed - Text styles and fonts', () {
    test('should apply custom font', () {
      Themed.createTheme(
        name: 'custom-font',
        primaryColor: Colors.blue,
        secondaryColor: Colors.orange,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
      );

      Themed.setTheme('custom-font');
      final textStyle =
          Themed.currentTheme.textButtonTheme.style?.textStyle?.resolve({});

      expect(textStyle?.fontFamily, 'Roboto');
      expect(textStyle?.fontWeight, FontWeight.bold);
    });

    test('should apply custom text styles', () {
      final headlineStyle =
          TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      final bodyStyle = TextStyle(fontSize: 16);

      Themed.createTheme(
        name: 'custom-text',
        primaryColor: Colors.blue,
        secondaryColor: Colors.orange,
        brightness: Brightness.light,
        headlineStyle: headlineStyle,
        bodyStyle: bodyStyle,
      );

      Themed.setTheme('custom-text');
      final theme = Themed.currentTheme;

      expect(theme.textTheme.headlineLarge?.fontSize, 32);
      expect(theme.textTheme.bodyLarge?.fontSize, 16);
    });
  });

  group('Themed - Edge cases', () {
    test('should handle multiple initializations', () async {
      await Themed.initialize();
      await Themed.initialize(); // Should not cause issues

      expect(Themed.hasTheme('light'), isTrue);
    });

    test('should work without storage adapter', () async {
      await Themed.initialize();
      Themed.setTheme('dark');

      // Should not throw error
      expect(Themed.currentTheme.brightness, Brightness.dark);
    });
  });

  group('Themed - Theme state properties', () {
    setUp(() async {
      await Themed.initialize();
    });

    test('isDarkMode should return true when dark theme is active', () {
      Themed.setTheme('dark');
      expect(Themed.isDarkMode, isTrue);
      expect(Themed.isLightMode, isFalse);
    });

    test('isLightMode should return true when light theme is active', () {
      Themed.setTheme('light');
      expect(Themed.isLightMode, isTrue);
      expect(Themed.isDarkMode, isFalse);
    });

    test('isCustomTheme should return false for built-in themes', () {
      Themed.setTheme('light');
      expect(Themed.isCustomTheme, isFalse);

      Themed.setTheme('dark');
      expect(Themed.isCustomTheme, isFalse);
    });

    test('isCustomTheme should return true when custom theme is active', () {
      Themed.createTheme(
        name: 'custom_state',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      Themed.setTheme('custom_state');
      expect(Themed.isCustomTheme, isTrue);
    });

    test('isActiveCustomTheme should return true for active custom theme', () {
      Themed.createTheme(
        name: 'active_custom',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      Themed.setTheme('active_custom');
      expect(Themed.isActiveCustomTheme('active_custom'), isTrue);
    });

    test('isActiveCustomTheme should return false for inactive custom theme',
        () {
      Themed.createTheme(
        name: 'inactive_custom',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      Themed.setTheme('light');
      expect(Themed.isActiveCustomTheme('inactive_custom'), isFalse);
    });

    test('isActiveCustomTheme should throw for built-in themes', () {
      expect(() => Themed.isActiveCustomTheme('light'), throwsException);
      expect(() => Themed.isActiveCustomTheme('dark'), throwsException);
    });
  });

  group('Themed - toggleTheme with custom themes', () {
    setUp(() async {
      await Themed.initialize();
    });

    test(
        'toggleTheme should switch to dark when custom theme has Brightness.dark',
        () {
      Themed.createTheme(
        name: 'custom_dark',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.dark,
      );

      Themed.setTheme('custom_dark');
      Themed.toggleTheme();

      expect(Themed.isDarkMode, isTrue);
    });

    test(
        'toggleTheme should switch to light when custom theme has Brightness.light',
        () {
      Themed.createTheme(
        name: 'custom_light',
        primaryColor: Colors.purple,
        secondaryColor: Colors.amber,
        brightness: Brightness.light,
      );

      Themed.setTheme('custom_light');
      Themed.toggleTheme();

      expect(Themed.isLightMode, isTrue);
    });
  });
}
