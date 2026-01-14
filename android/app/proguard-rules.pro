# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Google Play Billing
-keep class com.android.vending.billing.**

# Keep Firebase (if used)
-keep class com.google.firebase.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Prevent R8 from stripping interface information
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# For enumeration classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
