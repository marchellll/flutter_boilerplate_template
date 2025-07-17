# flutter_boilerplate_template

A new Flutter project.

## Getting Started

# Flutter Boilerplate Template

A comprehensive Flutter boilerplate template following Clean Architecture principles with modern best practices.

## 🚀 Features

### Architecture & State Management
- **Clean Architecture** with clear separation of concerns
- **BLoC Pattern** for state management
- **Dependency Injection** with Injectable & GetIt
- **Repository Pattern** for data layer abstraction

### Core Features
- ✅ **Todo CRUD Operations** - Add, update, delete, mark complete
- 🌐 **HTTP Client** - Dio for API communication
- 📱 **Routing** - GoRouter for navigation
- 🌍 **Internationalization** - Support for multiple languages (EN/ID)
- 🎨 **Material 3 Theming** - Light/Dark mode support
- 💾 **Data Storage** - In-memory storage (easily extensible)
- 🔧 **Debug Screen** - Development utilities
- 📊 **Crash Reporting** - Firebase Crashlytics ready
- 🧪 **Testing Setup** - Unit and widget test utilities

### Technical Stack
- **Flutter 3.32.6** (Latest stable)
- **Dart 3.x** with null safety
- **BLoC 9.1.1** for state management
- **GoRouter 16.0.0** for navigation
- **Injectable 2.5.0** for dependency injection
- **Dio 5.4.3** for HTTP requests

### Platform Support
- ✅ **Android** (API 21+) with multidex support
- ✅ **iOS** (iOS 12+)
- ✅ **Web** with modern initialization
- ✅ **macOS**
- ✅ **Linux**
- ✅ **Windows**

## 📁 Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App constants
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── network/                   # HTTP client setup
│   ├── theme/                     # App theming
│   └── utils/                     # Utilities
├── features/                      # Feature modules
│   ├── debug/                     # Debug screen
│   └── todo/                      # Todo feature
│       ├── data/                  # Data layer
│       ├── domain/                # Domain layer
│       └── presentation/          # Presentation layer
└── l10n/                         # Localization files
```

## 🛠 Getting Started

### Prerequisites
- Flutter 3.32.6 or higher
- Dart 3.x or higher
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd flutter_boilerplate_template
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   ```

## 📋 Usage

### Adding New Features

1. **Create feature directory structure:**
   ```
   lib/features/your_feature/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── presentation/
       ├── bloc/
       ├── pages/
       └── widgets/
   ```

2. **Register dependencies in `service_locator.dart`**

3. **Add routes in `app_router.dart`**

4. **Add localization strings in `l10n/`**

### Customization

#### Package Name
The template uses `xyz.marchell.flutter_boilerplate_template`. To change:

1. Update `pubspec.yaml`
2. Update Android `build.gradle` files
3. Update iOS configuration files
4. Rename Kotlin package directories

#### Theme
Modify `lib/core/theme/app_theme.dart` for custom colors and styling.

#### Localization
Add new language files in `lib/l10n/` following the `app_en.arb` format.

## 🧪 Testing

Run tests with:
```bash
# All tests
flutter test

# Specific test file
flutter test test/path/to/test_file.dart

# With coverage
flutter test --coverage
```

## 📱 Build & Deployment

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Configuration

### Environment Setup
The project uses `mise.toml` for Flutter version management. Make sure to have:
- Flutter 3.32.6
- Proper Android SDK setup
- Xcode (for iOS/macOS development)

### Firebase Setup (Optional)
1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Configure Firebase Crashlytics in `pubspec.yaml`
3. Initialize Firebase in `main.dart`

## 📚 Learning Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- Clean Architecture principles by Robert C. Martin
- Open source community for various packages used

---

**Happy Coding! 🚀**
