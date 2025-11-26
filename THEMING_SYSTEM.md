# Theming System Implementation

## Overview

The Budget Pillars app now supports a comprehensive theming system with:

- **3 Theme Palettes**: Mint (default), Oceanic, Super
- **4 Display Modes**: Light, Dark, Black, System

## Theme Palettes

### 1. Mint Theme (Default)

Matches the original app proposal with soft, natural colors.

- **Primary Color (Soft Teal)**: `hsl(166, 47%, 65%)` - #74C7B8
- **Background Color (Light Cream)**: `hsl(60, 56%, 91%)` - #F8F6E3
- **Accent Color (Muted Orange)**: `hsl(32, 63%, 51%)` - #D28A3D

### 2. Oceanic Theme

Blues and cool grays with a vibrant red accent.

- **Primary Color (Bright Blue)**: `hsl(194, 88%, 48%)` - #0EB7E0
- **Background Color (Cool Gray)**: `hsl(251, 20%, 92%)` - #E8E6F0
- **Accent Color (Vibrant Red)**: `hsl(355, 71%, 58%)` - #EA4A5A

### 3. Super Theme

High-contrast theme with bold reds and blues.

- **Primary Color (Strong Red)**: `hsl(355, 85%, 55%)` - #F22D41
- **Background Color (Light Gray-Blue)**: `hsl(220, 20%, 94%)` - #ECEEF2
- **Accent Color (Sky Blue)**: `hsl(210, 80%, 60%)` - #3D9EF5

## Display Modes

### 1. Light Mode

- Uses the theme's light background color
- Dark text on light backgrounds
- Standard Material Design 3 light theme

### 2. Dark Mode

- System-generated dark theme based on primary color
- Light text on dark backgrounds
- Material Design 3 dark theme

### 3. Black Mode

- Pure black (#000000) background for OLED displays
- Maximum contrast and battery savings on OLED screens
- Slightly lighter cards (#121212) for depth

### 4. System Mode

- Automatically switches between light and dark based on device settings
- Uses light theme when device is in light mode
- Uses dark theme when device is in dark mode
- Respects user's device-level preference

## Implementation Details

### HSL to RGB Conversion

The `hslToColor()` function in `app_theme.dart` converts HSL values to Flutter Color objects:

- Takes hue (0-360), saturation (0-100), lightness (0-100)
- Returns Material Color object
- Matches the exact HSL values from the TypeScript version

### Dynamic Theme Generation

```dart
AppTheme.getTheme(
  themeName: 'mint' | 'oceanic' | 'super',
  appearance: 'light' | 'dark' | 'black' | 'system',
)
```

### Providers

#### `lightThemeProvider`

Returns the current light theme based on user's selected theme palette.

#### `darkThemeProvider`

Returns the current dark theme based on user's selected theme palette.

#### `blackThemeProvider`

Returns the black theme variant based on user's selected theme palette.

#### `themeModeProvider`

Returns the current ThemeMode (light, dark, or system) based on user settings.

#### `useBlackThemeProvider`

Boolean indicating if black theme should be used instead of regular dark theme.

### App Integration

The `BudgetPillarsApp` widget watches all theme providers and applies them dynamically:

```dart
MaterialApp.router(
  theme: lightTheme,           // Used in light mode
  darkTheme: useBlackTheme ? blackTheme : darkTheme,  // Used in dark mode
  themeMode: themeMode,        // Controls which theme is active
)
```

### Settings Screen

The existing settings screen (`lib/features/settings/settings_screen.dart`) provides UI for:

1. **Appearance Selection**: Visual grid with icons

   - Light (☀️ icon)
   - Dark (🌙 icon)
   - Black (🌃 icon)
   - System (💻 icon)

2. **Theme Palette Dropdown**:
   - Mint
   - Oceanic
   - Super

Changes are saved to Firestore and immediately reflected across the app.

## Data Storage

Theme settings are stored in Firestore at `/users/{uid}/data/settings`:

```json
{
  "theme": {
    "appearance": "system", // light | dark | black | system
    "name": "mint" // mint | oceanic | super
  }
}
```

## Material Design 3 Integration

All themes use Material Design 3 with:

- Dynamic color schemes generated from seed colors
- Proper surface tints and elevation
- Consistent component styling
- Accessible contrast ratios

## Usage

Users can change themes in the Settings screen:

1. Navigate to Settings from the user menu
2. Select appearance mode (Light/Dark/Black/System)
3. Select theme palette (Mint/Oceanic/Super)
4. Click "Save Settings"
5. Theme updates immediately across the entire app

## Cross-Platform Compatibility

The theme structure matches the TypeScript/React version:

- Same HSL color values
- Same theme names and appearance modes
- Same Firestore storage structure
- Users can switch between web and mobile seamlessly

## Benefits

✅ **3 Beautiful Palettes** - Mint, Oceanic, Super with carefully chosen colors  
✅ **4 Display Modes** - Light, Dark, Black (OLED), System  
✅ **Dynamic Updates** - Changes apply immediately without restart  
✅ **Persistent** - Saved to Firestore, synced across devices  
✅ **Accessible** - Proper contrast ratios for all themes  
✅ **OLED Optimized** - Black mode saves battery on OLED displays  
✅ **System Integration** - Respects device dark mode preference  
✅ **Cross-Platform** - 100% compatible with TypeScript version
