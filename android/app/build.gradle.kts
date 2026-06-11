import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.limonnyemalchiki.mycharacterlist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.limonnyemalchiki.mycharacterlist"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { rootProject.file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

@Suppress("DEPRECATION")
android.applicationVariants.configureEach {
    val variant = this
    outputs.configureEach {
        val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
        output.outputFileName = "MyCharacterList-v${variant.versionName}.apk"
    }
    assembleProvider.configure {
        doLast {
            val flutterApkDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
            flutterApkDir.mkdirs()
            variant.outputs.forEach { output ->
                val apk = (output as com.android.build.gradle.internal.api.BaseVariantOutputImpl).outputFile
                    ?: return@forEach
                if (!apk.exists()) return@forEach
                apk.copyTo(File(flutterApkDir, apk.name), overwrite = true)
                apk.copyTo(
                    File(flutterApkDir, "app-${variant.buildType.name}.apk"),
                    overwrite = true,
                )
            }
        }
    }
}

flutter {
    source = "../.."
}
