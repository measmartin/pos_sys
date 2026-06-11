# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.gson.** { *; }
-keepclassmembers class * implements java.io.Serializable { *; }

# Keep JSON parsing classes
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep model classes
-keep class com.amrit.pos.** { *; }

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Thermal printer
-keep class com.flutterthermalprinter.** { *; }

# PDF/Printing
-keep class net.nfet.flutter.printing.** { *; }
-keep class org.bouncycastle.** { *; }

# HTTP client
-keep class com.android.org.conscrypt.** { *; }
-keep class org.apache.harmony.xnet.provider.jsse.** { *; }
