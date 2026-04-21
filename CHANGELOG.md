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
