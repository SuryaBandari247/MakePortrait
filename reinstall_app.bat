@echo off
echo Uninstalling old app...
adb uninstall com.parasmile.makeportrait
adb uninstall com.example.photo_resize_app
echo.
echo Cleaning Flutter project...
flutter clean
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Building and installing app...
flutter run --debug
pause
