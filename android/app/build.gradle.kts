plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_akhir_yg_bener"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14033849"

    compileOptions {
        // ✅ Aktifkan desugaring
        isCoreLibraryDesugaringEnabled = true

        // Versi Java modern
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.project_akhir_yg_bener"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Ganti versi desugar_jdk_libs ke 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}