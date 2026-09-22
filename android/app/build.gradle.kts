import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ── Release imzolash kaliti ────────────────────────────────────────
// Kalit ikki joydan olinadi (birinchi topilgani ishlatiladi):
//
//  1) Bitrise (CI): kalit fayl yo'li ANDROID_KEYSTORE_PATH, parollar esa
//     Bitrise "Code Signing" bo'limi avtomatik beradigan
//     BITRISEIO_ANDROID_KEYSTORE_* muhit o'zgaruvchilaridan olinadi.
//     Parollar hech qachon repoga yozilmaydi.
//
//  2) Lokal kompyuter: android/key.properties fayli (u .gitignore'da,
//     repoga tushmaydi).
//
// Hech biri topilmasa — lokal ishlab chiqish uchun debug kalit ishlatiladi,
// LEKIN CI'da (Bitrise) bu holat xato bilan to'xtatiladi: aks holda
// debug kalit bilan imzolangan build jimgina Play Market'ga yetib borib,
// rad etilar edi.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseStorePath: String? =
    System.getenv("ANDROID_KEYSTORE_PATH") ?: keystoreProperties.getProperty("storeFile")
val releaseStorePassword: String? =
    System.getenv("BITRISEIO_ANDROID_KEYSTORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
val releaseKeyAlias: String? =
    System.getenv("BITRISEIO_ANDROID_KEYSTORE_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
val releaseKeyPassword: String? =
    System.getenv("BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")

val hasReleaseKeystore = !releaseStorePath.isNullOrBlank() && file(releaseStorePath).exists()
val isCi = System.getenv("CI") == "true"

android {
    namespace = "uz.milliymetr.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "uz.milliymetr.app"
        minSdk = flutter.minSdkVersion
        // Google Play: 2026-yil 31-avgustdan boshlab yangi ilovalar va
        // yangilanishlar Android 16 (API 36) ni nishonga olishi SHART.
        // 34 bilan yuklangan build rad etiladi.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(releaseStorePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                if (isCi) {
                    throw GradleException(
                        "Release keystore topilmadi. Bitrise'da ANDROID_KEYSTORE_PATH " +
                        "o'rnatilmagan yoki keystore Code Signing bo'limiga yuklanmagan. " +
                        "Debug kalit bilan imzolangan build Play Market'da rad etiladi."
                    )
                }
                // Faqat lokal ishlab chiqish uchun.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
