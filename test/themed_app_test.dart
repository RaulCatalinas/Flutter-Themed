import 'package:flutter/material.dart'
    show Brightness, Builder, Colors, MaterialApp, Scaffold, Text, Theme;
import 'package:flutter_test/flutter_test.dart'
    show
        WidgetTester,
        expect,
        find,
        findsOneWidget,
        group,
        setUp,
        testWidgets,
        findsNothing;
import 'package:flutter_themed/flutter_themed.dart' show Themed;
import 'package:flutter_themed/themed_app.dart' show ThemedApp;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;

GoRouter _buildRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: Text('Home')),
      ),
      GoRoute(
        path: '/second',
        builder: (context, state) => Scaffold(body: Text('Second Screen')),
      ),
    ],
  );
}

void main() {
  setUp(() async {
    await Themed.initialize();
  });

  group('ThemedApp.router', () {
    testWidgets(
      'should build with MaterialApp.router',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: _buildRouter(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      },
    );

    testWidgets(
      'should use current theme from Themed',
      (WidgetTester tester) async {
        Themed.setTheme('light');

        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: _buildRouter(),
          ),
        );

        await tester.pumpAndSettle();

        final context = tester.element(find.text('Home'));
        expect(Theme.of(context).brightness, Brightness.light);
      },
    );

    testWidgets(
      'should react to theme changes',
      (WidgetTester tester) async {
        Themed.setTheme('light');

        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: _buildRouter(),
          ),
        );

        await tester.pumpAndSettle();

        var context = tester.element(find.text('Home'));
        expect(Theme.of(context).brightness, Brightness.light);

        Themed.setTheme('dark');
        await tester.pumpAndSettle();

        context = tester.element(find.text('Home'));
        expect(Theme.of(context).brightness, Brightness.dark);
      },
    );

    testWidgets(
      'should apply custom theme colors',
      (WidgetTester tester) async {
        Themed.createTheme(
          name: 'custom',
          primaryColor: Colors.purple,
          secondaryColor: Colors.amber,
          brightness: Brightness.light,
        );

        Themed.setTheme('custom');

        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: _buildRouter(),
          ),
        );

        await tester.pumpAndSettle();

        final context = tester.element(find.text('Home'));
        expect(Theme.of(context).colorScheme.primary, Colors.purple);
      },
    );

    testWidgets(
      'should apply fontFamily to theme',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            fontFamily: 'Roboto',
            routerConfig: _buildRouter(),
          ),
        );

        await tester.pumpAndSettle();

        final context = tester.element(find.text('Home'));
        expect(Theme.of(context).textTheme.bodyLarge?.fontFamily, 'Roboto');
      },
    );

    testWidgets(
      'should maintain theme during navigation',
      (WidgetTester tester) async {
        Themed.setTheme('dark');

        final router = _buildRouter();

        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        var context = tester.element(find.text('Home'));
        expect(Theme.of(context).brightness, Brightness.dark);

        router.go('/second');
        await tester.pumpAndSettle();

        context = tester.element(find.text('Second Screen'));
        expect(Theme.of(context).brightness, Brightness.dark);
      },
    );

    testWidgets(
      'should render correct initial route',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: _buildRouter(initialLocation: '/second'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Second Screen'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
      },
    );

    testWidgets(
      'should use Builder to access theme via context',
      (WidgetTester tester) async {
        Themed.setTheme('dark');

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Builder(
                builder: (context) => Scaffold(body: Text('Content')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ThemedApp.router(
            title: 'Test App',
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        final context = tester.element(find.text('Content'));
        expect(Theme.of(context).brightness, Brightness.dark);
      },
    );
  });
}
