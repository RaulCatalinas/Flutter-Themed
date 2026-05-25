import 'package:flutter/material.dart'
    show
        BuildContext,
        Locale,
        LocalizationsDelegate,
        MaterialApp,
        NavigatorObserver,
        RouteFactory,
        RouteInformationParser,
        RouteInformationProvider,
        RouterConfig,
        RouterDelegate,
        StatelessWidget,
        ThemeData,
        TransitionBuilder,
        ValueListenableBuilder,
        Widget,
        WidgetBuilder;

import 'flutter_themed.dart' show Themed;

/// A drop-in replacement for [MaterialApp] that automatically handles theme changes.
///
/// ThemedApp wraps [MaterialApp] and listens to [Themed] for theme updates.
/// All standard [MaterialApp] parameters are supported.
///
/// **Important:** Do not set [MaterialApp.theme] or [MaterialApp.darkTheme]
/// manually, as [Themed] controls these automatically.
///
/// ## Standard usage
/// ```dart
/// ThemedApp(
///   title: 'My App',
///   home: HomePage(),
/// )
/// ```
///
/// ## Router usage (go_router or any [RouterConfig] implementation)
/// ```dart
/// ThemedApp.router(
///   title: 'My App',
///   routerConfig: myRouter,
/// )
/// ```
class ThemedApp extends StatelessWidget {
  // ─── Shared parameters ────────────────────────────────────────────────────

  /// The title of the application.
  ///
  /// Used by the OS for task switcher and accessibility.
  final String title;

  /// Optional font family to apply to all text in the theme.
  ///
  /// This overrides the font family from the active theme.
  final String? fontFamily;

  /// The locale for this app.
  final Locale? locale;

  /// The delegates for this app's localization.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// The list of locales that this app has been localized for.
  final Iterable<Locale>? supportedLocales;

  /// A builder that can wrap the app's widgets.
  final TransitionBuilder? builder;

  /// Whether to show the debug banner in debug mode.
  final bool debugShowCheckedModeBanner;

  /// Whether to show the material grid in debug mode.
  final bool debugShowMaterialGrid;

  /// Whether to show the performance overlay.
  final bool showPerformanceOverlay;

  /// Whether to checkerboard raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Whether to checkerboard offscreen layers.
  final bool checkerboardOffscreenLayers;

  /// Whether to show the semantics debugger.
  final bool showSemanticsDebugger;

  // ─── Standard constructor parameters ─────────────────────────────────────

  /// The widget for the default route of the app.
  final Widget? home;

  /// The application's top-level routing table.
  final Map<String, WidgetBuilder>? routes;

  /// The name of the first route to show.
  final String? initialRoute;

  /// The route generator callback for when [routes] doesn't contain a route.
  final RouteFactory? onGenerateRoute;

  /// Called when [onGenerateRoute] fails to generate a route.
  final RouteFactory? onUnknownRoute;

  /// The list of observers for the [Navigator] created for this app.
  final List<NavigatorObserver>? navigatorObservers;

  // ─── Router constructor parameters ───────────────────────────────────────

  /// The router configuration for use with [MaterialApp.router].
  ///
  /// Accepts any [RouterConfig] implementation, including go_router.
  /// When provided, [routeInformationParser] and [routerDelegate] are ignored.
  final RouterConfig<Object>? routerConfig;

  /// The route information parser for use with [MaterialApp.router].
  ///
  /// Only needed when not using [routerConfig].
  final RouteInformationParser<Object>? routeInformationParser;

  /// The router delegate for use with [MaterialApp.router].
  ///
  /// Only needed when not using [routerConfig].
  final RouterDelegate<Object>? routerDelegate;

  /// The route information provider for use with [MaterialApp.router].
  final RouteInformationProvider? routeInformationProvider;

  // ─── Internal flag ────────────────────────────────────────────────────────
  final bool _isRouter;

  // ─── Standard constructor ─────────────────────────────────────────────────

  const ThemedApp({
    super.key,
    required this.title,
    this.fontFamily,
    this.home,
    this.routes,
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en')],
    this.debugShowCheckedModeBanner = true,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
  })  : _isRouter = false,
        routerConfig = null,
        routeInformationParser = null,
        routerDelegate = null,
        routeInformationProvider = null;

  // ─── Router constructor ───────────────────────────────────────────────────

  /// A drop-in replacement for [MaterialApp.router] that automatically handles theme changes.
  ///
  /// Accepts any [RouterConfig] implementation — go_router, auto_route, etc.
  /// [flutter_themed] has no dependency on any routing package.
  ///
  /// ```dart
  /// ThemedApp.router(
  ///   title: 'My App',
  ///   routerConfig: myGoRouter,
  /// )
  /// ```
  const ThemedApp.router({
    super.key,
    required this.title,
    this.fontFamily,
    this.routerConfig,
    this.routeInformationParser,
    this.routerDelegate,
    this.routeInformationProvider,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en')],
    this.debugShowCheckedModeBanner = true,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
  })  : _isRouter = true,
        home = null,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onUnknownRoute = null,
        navigatorObservers = null;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: Themed.instance.themeNotifier,
      builder: (context, theme, _) {
        final resolvedTheme = theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: fontFamily),
        );

        if (_isRouter) {
          return MaterialApp.router(
            title: title,
            theme: resolvedTheme,
            routerConfig: routerConfig,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            routeInformationProvider: routeInformationProvider,
            builder: builder,
            locale: locale,
            localizationsDelegates: localizationsDelegates,
            supportedLocales: supportedLocales ?? const [Locale('en')],
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            debugShowMaterialGrid: debugShowMaterialGrid,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
          );
        }

        return MaterialApp(
          title: title,
          theme: resolvedTheme,
          home: home,
          routes: routes ?? {},
          initialRoute: initialRoute,
          onGenerateRoute: onGenerateRoute,
          onUnknownRoute: onUnknownRoute,
          navigatorObservers: navigatorObservers ?? const [],
          builder: builder,
          locale: locale,
          localizationsDelegates: localizationsDelegates,
          supportedLocales: supportedLocales ?? const [Locale('en')],
          debugShowCheckedModeBanner: debugShowCheckedModeBanner,
          debugShowMaterialGrid: debugShowMaterialGrid,
          showPerformanceOverlay: showPerformanceOverlay,
          checkerboardRasterCacheImages: checkerboardRasterCacheImages,
          checkerboardOffscreenLayers: checkerboardOffscreenLayers,
          showSemanticsDebugger: showSemanticsDebugger,
        );
      },
    );
  }
}
