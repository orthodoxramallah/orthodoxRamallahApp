plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.orthodox_church_ramallah"
    compileSdk = 36
    
    defaultConfig {
        applicationId = "com.example.orthodox_church_ramallah"
        minSdk = flutter.minSdkVersion            // must be >= 21 for desugaring
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = false   // 👈 force disable

        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // ✅ This is the correct syntax for Kotlin DSL
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}