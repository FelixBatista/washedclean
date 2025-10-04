# Washed Clean - Flutter App

A Flutter app that helps users clean and maintain clothes via search, camera-based label reading, and educational content.

## Features

- **Smart Search**: Find solutions for stains, fabrics, and products
- **Label Scanner**: Scan care labels to understand symbols
- **Expert Tips**: Learn from comprehensive care guides
- **Favorites**: Save your favorite items locally
- **Ratings**: Rate helpful content
- **Offline-First**: Works without internet connection

## Brand Guidelines

- **Primary Colors**: Teal (#00A188), Dark Gray (#333333), White (#FFFFFF)
- **Typography**: Cocogoose for headings, Avenir for body text
- **Tone**: Minimalistic, simple, easy-to-use

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd washedclean
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
  app.dart
  main.dart
  core/
    theme/app_theme.dart          # Brand colors and typography
    routing/app_router.dart       # Navigation configuration
    services/                     # Business logic services
      content_service.dart        # Content management
      search_service.dart         # Search functionality
      favorites_service.dart      # Favorites management
      ratings_service.dart        # Ratings system
    data/
      models/                     # Data models
  features/                       # Feature-based screens
    splash/
    intro/
    home/
    search/
    camera/
    articles/
    stain/
    fabric/
    product/
    favorites/
  widgets/                        # Reusable UI components
    atoms/                        # Basic components
    molecules/                    # Composite components
    organisms/                    # Complex components
assets/
  images/                         # App images and icons
  fonts/                          # Custom fonts
  seed/                           # JSON data files
    articles.json
    stains.json
    fabrics.json
    products.json
    care_symbols.json
```

## Key Features Implementation

### 1. Search System
- Intelligent search across stains, fabrics, products, and articles
- Fuzzy matching with Levenshtein distance
- Type-based scoring and ranking

### 2. Camera Integration
- Camera permission handling
- Care label scanning interface
- Symbol detection and explanation

### 3. Content Management
- Local JSON-based content storage
- Markdown support for rich text
- Offline-first architecture

### 4. Favorites & Ratings
- Local storage using SharedPreferences
- Persistent user preferences
- Easy to extend to backend integration

### 5. Navigation
- GoRouter for type-safe navigation
- Deep linking support
- Bottom navigation with 4 main tabs

## Data Models

### Article
- Educational content with markdown support
- Featured articles for homepage
- CTA buttons for navigation

### Stain
- Urgency levels (red/yellow/green)
- Fabric-specific instructions
- Related products and fabrics

### Fabric
- Care instructions and overview
- Common stains and recommended products
- Material-specific guidance

### Product
- Ingredient information
- Usage instructions
- Affiliate links for monetization

### Care Symbol
- Symbol definitions and explanations
- Visual representation support
- Standardized care label symbols

## Customization

### Adding New Content
1. Add entries to the appropriate JSON file in `assets/seed/`
2. Follow the existing data structure
3. Update the content service if needed

### Styling
- Modify `lib/core/theme/app_theme.dart` for global styling
- Brand colors and typography are centralized
- Component-specific styling in widget files

### Adding New Features
1. Create new feature folder in `lib/features/`
2. Add routing configuration in `lib/core/routing/app_router.dart`
3. Update navigation in relevant screens

## Dependencies

- **State Management**: flutter_riverpod, hooks_riverpod
- **Navigation**: go_router
- **Storage**: shared_preferences, isar
- **UI**: flutter_markdown, flutter_svg, cached_network_image
- **Camera**: camera, permission_handler
- **Search**: collection
- **External Links**: url_launcher
- **Analytics**: firebase_core, firebase_analytics
- **Ads**: google_mobile_ads
- **Localization**: intl, flutter_localizations

## Development Notes

### Code Generation
The project uses code generation for data models. Run:
```bash
flutter packages pub run build_runner build
```

### Testing
```bash
flutter test
```

### Building for Release
```bash
flutter build apk --release
flutter build ios --release
```

## Future Enhancements

- [ ] ML-based symbol detection
- [ ] Backend integration
- [ ] User accounts and sync
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Accessibility improvements

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
