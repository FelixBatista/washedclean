Google Play — assets in this folder
====================================

UPLOAD CHECKLIST (Play Console → Grow → Store presence → Main store listing)

1) App icon (high resolution)
   File: icon/store_icon_512.png  (512 x 512 px, 32-bit PNG)
   If you already have a final logo, replace this file with your exported 512×512 PNG.

2) Feature graphic (required for most listings)
   File: feature_graphic.png  (1024 x 500 px)
   Upload in the “Feature graphic” slot.

3) Phone screenshots
   Folder: phone/
   Use at least 2 images; up to 8 are allowed.
   Files captured from the Android emulator (Pixel 9 class, 1080×2424):
   - 01_home.png       — Home / search
   - 02_search.png     — Search (example: WINE query)
   - 03_favorites.png  — Favorites
   - 04_profile.png    — Profile / sign-in

4) Tablet screenshots — 7-inch (Play Console “7-inch tablets”)
   Folder: tablet_7inch/
   Resolution used: 1200 × 1920 (portrait), via adb shell wm size on the emulator.
   - 01_home.png, 02_search.png, 03_favorites.png, 04_profile.png

5) Tablet screenshots — 10-inch (Play Console “10-inch tablets”)
   Folder: tablet_10inch/
   Resolution used: 1600 × 2560 (portrait), via adb shell wm size on the emulator.
   - 01_home.png, 02_search.png, 03_favorites.png, 04_profile.png

   Note: Upload each set to the matching tablet section in Play Console. If you
   create dedicated 7" / 10" AVDs later, you can retake these for pixel-perfect
   layouts; adb resize is standard for quick store assets.

TIP: Before uploading, open each PNG and confirm text is readable and no
personal data appears.

Regenerating screenshots locally
--------------------------------
- Start an emulator:  flutter emulators --launch Pixel_9
- Run the app:        flutter run -d emulator-5554
- Capture:            flutter screenshot -o play_store_assets/phone/your_name.png
