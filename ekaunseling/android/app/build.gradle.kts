plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id ("com.google.gms.google-services")

}

android {
    namespace = "com.example.doctor_appointment_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.doctor_appointment_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") as com.android.build.api.dsl.ApkSigningConfig
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // Existing ones
    implementation("com.google.android.gms:play-services-auth:20.5.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // ✅ Pusher Channels
    implementation("com.pusher:pusher-java-client:2.2.6")

    // ✅ Pusher Beams
    implementation("com.pusher:push-notifications-android:1.9.0")

    // ✅ Firebase Messaging (needed for Beams to work)
    implementation("com.google.firebase:firebase-messaging:21.1.0")
}
