# Keep MainActivity class
-keep class com.Parasmile.makeportrait.MainActivity { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Don't obfuscate Flutter
-dontwarn io.flutter.**
