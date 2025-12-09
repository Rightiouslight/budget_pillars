# Landing Page

A beautiful, responsive landing page for Budget Pillars that greets unauthenticated users.

## Overview

The landing page serves as the public face of the app, introducing visitors to Budget Pillars and providing clear paths to sign in, register, or download the mobile app.

## Features

### 🎨 **Beautiful Design**

- Modern, clean interface with gradient accents
- Responsive layout adapting to all screen sizes
- Professional typography and spacing
- Smooth scrolling experience

### 📱 **Mobile-Optimized Download**

- Automatic detection of mobile browsers
- Prominent APK download section (mobile only)
- "Continue in Browser" option for web experience
- Installation instructions and guidance

### ✨ **Feature Showcase**

- Grid layout highlighting key features:
  - Smart Categories
  - Sinking Funds
  - Recurring Income
  - Visual Analytics
  - Cloud Sync
  - Customizable Themes
- Icon-based cards for visual appeal
- Responsive grid (3 columns → 2 columns → 1 column)

### 🚀 **Clear Call-to-Actions**

- "Sign In" and "Get Started" buttons in header
- Hero section with primary CTAs
- Gradient CTA section mid-page
- Multiple entry points for authentication

### 🔗 **Footer**

- Links to GitHub repository
- Releases page for downloads
- Privacy Policy and Terms placeholders
- Copyright and attribution

## File Structure

```
lib/features/landing/
├── landing_page.dart              # Main landing page widget
└── widgets/
    ├── hero_section.dart          # Hero with headline and CTAs
    ├── feature_card.dart          # Individual feature showcase card
    ├── download_section.dart      # Mobile APK download section
    └── footer_section.dart        # Footer with links
```

## Sections Breakdown

### 1. App Bar

```dart
// Always visible at top
- Budget Pillars logo
- Sign In button
- Get Started button (primary)
```

### 2. Hero Section

```dart
// Large, attention-grabbing introduction
- App icon with gradient background
- Main headline: "Master Your Money With Budget Pillars"
- Subheadline explaining app purpose
- Primary CTAs (Sign In / Create Account)
- Feature badges (Cloud Sync, Secure, Cross-Platform, Smart Analytics)
```

### 3. Download Section (Mobile Only)

```dart
// Shown only when accessed from mobile browser
- Android icon with gradient background
- "Get the App" headline
- Download APK button (opens GitHub Releases)
- Continue in Browser button
- Installation instructions note
```

### 4. Features Grid

```dart
// 6 feature cards in responsive grid
- Smart Categories
- Sinking Funds
- Recurring Income
- Visual Analytics
- Cloud Sync
- Customizable Themes

Each card includes:
- Icon with colored background
- Feature title
- Short description
```

### 5. Call-to-Action Section

```dart
// Gradient container with final CTA
- "Ready to Take Control?" headline
- Social proof text
- Large "Get Started Free" button
```

### 6. Footer

```dart
// Bottom section with links
- GitHub repository link
- Releases page link
- Privacy Policy (placeholder)
- Terms of Service (placeholder)
- Copyright notice
- "Made with Flutter" badge
```

## Responsive Breakpoints

```dart
Mobile: < 600px width
  - Single column layout
  - Compact spacing
  - Stacked buttons
  - Full-width cards

Tablet: 600px - 900px
  - Two-column feature grid
  - Medium spacing
  - Horizontal button layout

Desktop: > 900px
  - Three-column feature grid
  - Wide spacing
  - Optimized for large screens
```

## Mobile Browser Detection

The download section appears only when:

1. Running on web (`kIsWeb`)
2. Screen width < 600px (`isMobile`)

This ensures the download section is shown to mobile users who can actually install APK files.

## Navigation Flow

### Unauthenticated Users

```
Landing Page (/)
├── Sign In → AuthScreen
├── Get Started → AuthScreen
├── Download APK → GitHub Releases
└── Continue in Browser → AuthScreen
```

### Authenticated Users

```
Any landing page access → Redirected to Dashboard
```

## Routing Configuration

```dart
// app/app_router.dart
GoRoute(
  path: '/',
  name: 'landing',
  builder: (context, state) => const LandingPage(),
),
GoRoute(
  path: '/sign-in',
  name: 'sign-in',
  builder: (context, state) => const AuthScreen(),
),
```

Redirect logic ensures:

- Unauthenticated users → Landing page or Auth
- Authenticated users → Dashboard (bypassing landing)

## Download Section Details

### APK Download Flow

1. User taps "Download APK"
2. Opens GitHub Releases in external browser
3. User downloads latest APK
4. Shows installation snackbar
5. User installs from downloads

### Continue in Browser Flow

1. User taps "Continue in Browser"
2. Navigates to `/sign-in`
3. Shows AuthScreen for sign in/register
4. After auth → Dashboard

## Customization

### Update GitHub Links

```dart
// download_section.dart
static const _githubReleaseUrl =
    'https://github.com/Rightiouslight/budget_pillars/releases/latest';

// footer_section.dart
_buildLink(
  context,
  'GitHub',
  'https://github.com/Rightiouslight/budget_pillars',
),
```

### Modify Features

Edit the features grid in `landing_page.dart`:

```dart
children: const [
  FeatureCard(
    icon: Icons.your_icon,
    title: 'Your Feature',
    description: 'Description here',
  ),
  // Add more features...
],
```

### Change Colors/Theming

The landing page uses app theme colors:

- `theme.colorScheme.primary` - Main accent color
- `theme.colorScheme.secondary` - Secondary accent
- `theme.colorScheme.primaryContainer` - Light backgrounds
- Adapts automatically to light/dark theme

## SEO Considerations

For better discoverability, consider:

1. Add meta tags to `web/index.html`
2. Include Open Graph tags for social sharing
3. Add structured data for app information
4. Create sitemap.xml
5. Add robots.txt

## Analytics Integration

Track user interactions:

```dart
// Add to button onPressed
onPressed: () {
  // Track "Sign In Clicked" event
  analytics.logEvent(name: 'sign_in_clicked');
  context.go('/sign-in');
},
```

## Future Enhancements

Potential improvements:

- [ ] Screenshot carousel
- [ ] Video demo
- [ ] Testimonials section
- [ ] FAQ section
- [ ] Blog/news section
- [ ] Email newsletter signup
- [ ] Social media links
- [ ] Language selector
- [ ] Dark/light theme toggle
- [ ] A/B testing variants

## Testing

Test the landing page:

```powershell
# Run web app
flutter run -d chrome -t lib/main_dev.dart

# Test on mobile browser
flutter run -d chrome -t lib/main_dev.dart --web-browser-flag="--user-agent=Mozilla/5.0 (Linux; Android 10)"

# Build for production
flutter build web -t lib/main_prod.dart
```

## Deployment

The landing page is automatically deployed with the web app:

```powershell
flutter build web -t lib/main_prod.dart
firebase deploy --only hosting
```

Access at:

- Production: `https://pocketflow-tw4kf.web.app/`
- Development: `https://budgetpillarsdev.web.app/`

---

**Created**: December 9, 2024  
**Status**: Production-ready  
**Purpose**: Public-facing landing page for Budget Pillars
