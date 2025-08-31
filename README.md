Step 1: First run 'node process' to create the json files.

Step 2:

Run the route '/curriculum/create-corejs' for the main app and
'/curriculum/collect-files' route for other apps

In 'android/app/build.grade change the 'applicationId'

In 'android/app/google-services.json' - place the right file

In 'android/app/src/main/res - Place the right folder

android/app/src/main/AndroidManifest.xml - update package and 'android:label'

android\app\src\debug\AndroidManifest.xml

Step 3:

1. Edit config.dart

commands

```
flutter build apk --release
flutter build appbundle --release
```

Upload debug symbols

https://stackoverflow.com/questions/62568757/playstore-error-app-bundle-contains-native-code-and-youve-not-uploaded-debug

\build\app\intermediates\merged_native_libs\release\out\lib

zip the three folders (arm64-v8a, armeabi-v7a, x86_64)

Upload it after uploading the bundle by clicking the three dots

# PSchool Main app checklist

1. Disable the Test route
2. Remove the games that are unavailable for android

# pschool_math

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets of PSchool Main app

```
assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/math/
    - assets/sound/en/
    - assets/sound/kg-5/
    - assets/sound/kg-5/phonics/
    - assets/sound/kg-5/reading/
    - assets/sound/kg-5/words/
    - assets/sound/social/
    - assets/sound/science/
    - assets/sound/gk/
    - assets/img/dragDrop/
    - assets/img/story/
    - assets/img/story/crow/
    - assets/img/fruits/
    - assets/img/math/
    - assets/img/math/dataHandling/
    - assets/img/math/money/
    - assets/img/physics/
    - assets/img/science/
    - assets/img/science/healthy-eating-habits/
    - assets/img/science/kg-2/
    - assets/img/science/mango-story/
    - assets/img/vocabulary/
    - assets/img/social/
    - assets/img/social/flags/
    - assets/img/social/house/
    - assets/img/social/india-monuments/
    - assets/img/social/leaders/
    - assets/img/social/road-sign/
    - assets/img/social/transport-manners/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/posts/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```

# Assets for the Math app

```
assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/math/
    - assets/sound/kg-5/
    - assets/img/dragDrop/
    - assets/img/fruits/
    - assets/img/math/
    - assets/img/math/dataHandling/
    - assets/img/math/money/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/posts/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/pyKKeS_EDIf0tPWwruYSk/
```

# Assets for PalaguTamil

```
assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/ta/
    - assets/img/dragDrop/
    - assets/img/story/
    - assets/img/story/crow/
    - assets/img/science/
    - assets/img/science/healthy-eating-habits/
    - assets/img/science/mango-story/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```

# Assets for Bengali

```
  assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/bn/
    - assets/img/dragDrop/
    - assets/img/story/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```

# Assets for Hindi

```
  assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/hi/
    - assets/img/dragDrop/
    - assets/img/story/
    - assets/img/story/crow/
    - assets/img/math/dataHandling/
    - assets/img/science/
    - assets/img/science/healthy-eating-habits/
    - assets/img/science/mango-story/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```

# Assets for Malayalam

```
  assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/ml/
    - assets/img/dragDrop/
    - assets/img/story/
    - assets/img/science/
    - assets/img/science/healthy-eating-habits/
    - assets/img/science/mango-story/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```

# Assets for Marathi

```
  assets:
    - assets/
    - assets/icons/
    - assets/playlists/
    - assets/stockimg/
    - assets/sound/mr/
    - assets/img/dragDrop/
    - assets/img/story/crow/
    - assets/img/science/
    - assets/img/science/healthy-eating-habits/
    - assets/img/science/mango-story/
    - webNextjs/
    - webNextjs/acts/
    - webNextjs/_next/static/media/
    - webNextjs/_next/static/css/
    - webNextjs/_next/static/chunks/
    - webNextjs/_next/static/chunks/pages/
    - webNextjs/_next/static/chunks/pages/acts/
    - webNextjs/_next/static/gLHTh-UisMAiy3D17LJ57/
```
