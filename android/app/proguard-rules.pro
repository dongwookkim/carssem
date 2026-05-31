# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Kotlin
-keep class kotlin.Metadata { *; }

# Supabase / OkHttp / Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Geolocator / permission_handler
-keep class com.baseflow.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# device_info_plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Play Core (Flutter deferred components — keep even if unused to avoid R8 warnings)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
