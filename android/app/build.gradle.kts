plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unisavee.ravvera"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.unisavee.ravvera"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.1"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Core desugaring (Java 8+ APIs on older Androids)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Kotlin + multidex
    implementation(kotlin("stdlib-jdk8"))
    implementation("androidx.multidex:multidex:2.0.1")


    // If any library tries to pull RTSP again, exclude it globally
    configurations.all {
        exclude(group = "androidx.media3", module = "media3-exoplayer-rtsp")
    }
}

flutter {
    source = "../.."
}
