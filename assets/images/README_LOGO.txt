flutter:
  assets:
    - assets/images/

# After placing your cholo_logo.png in assets/images/, 
# add these dev dependencies for launcher icons:

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1

# Then add this configuration at the bottom:
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/cholo_logo.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/images/cholo_logo.png"
  
# Run these commands:
# flutter pub get
# flutter pub run flutter_launcher_icons
