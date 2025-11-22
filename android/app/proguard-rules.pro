# 🧠 GOOGLE ML KIT: Text Recognition (LATIN ONLY)
-keep class com.google.mlkit.vision.text.latin.TextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.TextRecognizerOptionsInterface { *; }

# Suppress other ML Kit language warnings (not used)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Prevent removal of MLKit internals
-keep class com.google.mlkit.** { *; }
-keep class com.google.firebase.** { *; }

# FLUTTER MethodChannel safety
-keepclassmembers class * {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}

# RAZORPAY SDK RULES (if you're using it)
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*
-dontwarn com.razorpay.**