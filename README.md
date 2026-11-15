# NuNews

Clean, distraction-free Indonesian news reader available as a full **Flutter & Dart (Riverpod)** project (`lib/`, `pubspec.yaml`, `test/`) alongside the interactive web preview.

NuNews fetches live Indonesian headlines directly from official CNN Indonesia, CNBC Indonesia, and Antara News RSS feeds without relying on external third-party API wrappers.

---

## Features

- **Live Indonesian News Feeds** – Real-time headlines and category feeds (Nasional, Internasional, Ekonomi, Olahraga, Teknologi, Hiburan, Gaya Hidup) plus CNBC Indonesia & Antara News channels.
- **Pull-to-Refresh** – Pull down on the Home screen to refresh and fetch the latest RSS updates manually.
- **Reader Customization (*Customize your view*)** – Tap **Aa** in any article to switch between Sans and Serif fonts, resize text, adjust reading brightness, and choose between four themes (White, Warm Pastel Yellow, Slate, and OLED Black).
- **Inline Search & Filters** – Search articles directly on the home feed and switch between Populer, Tren, and Terkini tabs.
- **Bookmarks** – Save articles locally to read later, with clean badge counts.
- **Light & Dark Mode** – High-contrast dark & light mode palettes accented with a subtle pastel yellow highlight and low-opacity dark-mode hover states.

---

## Running the Flutter & Dart App in VS Code

### Prerequisites

- **Flutter SDK** (`>=3.24`, Dart `^3.5.0`)
- **VS Code** with the official **Flutter** and **Dart** extensions
- **Android Emulator** (Android Studio AVD) or a physical Android device

### Setup

```bash
flutter pub get
flutter create --platforms=android .   # generates local gradlew & local.properties without overwriting UI/manifest
flutter run
```

To run static analysis and unit tests:

```bash
flutter analyze
flutter test
```

---

## Running the Web Preview in VS Code (Node.js)

If you want to run the browser preview locally on `http://localhost:3000`:

```bash
npm install
npm run dev
```

---

## Project Structure (Flutter & Dart)

```text
pubspec.yaml
analysis_options.yaml
android/                                      # Android Gradle runner, manifest & launcher icons
assets/
└── images/
    └── fallback_news.jpg
lib/
├── main.dart                                   # Entry point & ProviderScope initialization
├── app.dart                                    # Root MaterialApp & ThemeMode wiring
├── core/
│   ├── constants/
│   │   ├── api_constants.dart                  # Official RSS endpoints & cache TTL
│   │   └── news_category.dart                  # Category definitions & icons
│   ├── theme/
│   │   └── app_theme.dart                      # Light/Dark Material 3 themes & ReaderSettings
│   └── utils/
│       └── date_formatter.dart                 # Indonesian relative timestamps
├── data/
│   ├── models/
│   │   └── article.dart                        # Immutable Article model
│   └── services/
│       ├── bookmark_storage.dart               # SharedPreferences bookmarks & likes
│       ├── news_api_exception.dart             # Typed network exceptions
│       ├── news_api_service.dart               # Direct RSS XML fetcher & parser
│       └── theme_storage.dart                  # SharedPreferences theme & reader prefs
├── providers/
│   ├── dependency_provider.dart                # Riverpod service providers
│   ├── news_provider.dart                      # Feed, pull-to-refresh, filters, bookmarks
│   ├── reader_settings_provider.dart           # "Customize your view" state
│   └── theme_provider.dart                     # Light / Dark theme mode state
└── ui/
    ├── screens/
    │   ├── main_shell/                         # Main navigation shell & bottom bar
    │   ├── home/                               # Home screen with pull-to-refresh & carousel
    │   ├── detail/                             # Article reader view & "Aa" modal
    │   ├── explore/                            # Category & media channel browser
    │   ├── bookmarks/                          # Saved articles view
    │   └── settings/                           # Theme toggle & reader preferences
    └── widgets/
        └── article_tile.dart                   # Shared article list tile
test/
└── article_test.dart                           # Unit tests for RSS parser, dates & settings
```

---

## License

MIT
