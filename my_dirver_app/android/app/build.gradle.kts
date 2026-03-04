plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // فكي التعليق عن السطر التالي فقط بعد إضافة ملف google-services.json
    // id("com.google.gms.google-services")
}

android {
    // تأكدي أن الـ namespace مطابق لاسم مشروعك (Elite Rider)
    namespace = "com.example.elite_rider_app" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // الـ Application ID هو المعرف الوحيد لتطبيقك في متجر جوجل
        applicationId = "com.example.elite_rider_app"
        
        // تم التعديل لـ 21 لضمان عمل الخرائط وخدمات الموقع بسلاسة
        minSdk = 21 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // في المرحلة الحالية نستخدم إعدادات الديباج للتجربة
            signingConfig = signingConfigs.debug
            
            // إضافة لتحسين الأداء وتقليل حجم التطبيق
            minifyEnabled = false
            shrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}