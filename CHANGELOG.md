# Changelog

## 1.0.0

- Initial version.

## 1.0.0+1

- Updated documentation.

## 1.0.0+2

- Updated documentation.

## 1.0.0+3

- Improved package description for clarity.

## 1.1.0

### Added
- `isDarkMode` — returns `true` if the built-in dark theme is active
- `isLightMode` — returns `true` if the built-in light theme is active
- `isCustomTheme` — returns `true` if a custom theme is currently active
- `isActiveCustomTheme(String name)` — returns `true` if the specified custom theme is currently active

### Changed
- `toggleTheme` now switches to the nearest built-in theme based on `Brightness` when a custom theme is active, instead of always defaulting to light

## 1.2.0

### Added
- `ThemedApp.router` — named constructor that wraps `MaterialApp.router`, enabling full compatibility with any `RouterConfig` implementation (go_router, auto_route, etc.)
- No dependency on any routing package — `flutter_themed` uses Flutter's native `RouterConfig` interface

### Changed
- Updated FAQ: `ThemedApp` now supports both `MaterialApp` and `MaterialApp.router`