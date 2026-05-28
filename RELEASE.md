# Release Build Guide

## Android APK / AAB

### 1. Generate a signing keystore (one-time)
Run this in PowerShell, outside your project folder:

```powershell
keytool -genkey -v -keystore retail_app_release.jks `
  -alias retail_app `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

Move the .jks file to: `android/app/retail_app_release.jks`

### 2. Create key.properties
Create `android/key.properties` (never commit this file):

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=retail_app
storeFile=retail_app_release.jks
```

### 3. Update android/app/build.gradle
Add above the `android {` block:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside `android { buildTypes { release { ... } } }`:

```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### 4. Build

```powershell
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for direct install)
flutter build apk --release

# Release AAB (for Google Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Web (Firebase Hosting)

### 1. Build web
```powershell
flutter build web --release
```

### 2. Deploy
```powershell
firebase deploy --only hosting
```

Your app will be live at: `https://YOUR_PROJECT_ID.web.app`

---

## .gitignore additions
Make sure these are in your .gitignore:

```
android/key.properties
android/app/retail_app_release.jks
.env
serviceAccountKey.json
```

---

## Firestore indexes
Before launch, create these composite indexes in Firebase Console
→ Firestore → Indexes:

| Collection | Fields                              | Query scope |
|------------|-------------------------------------|-------------|
| products   | businessId ASC, isActive ASC, createdAt DESC | Collection |
| orders     | userId ASC, businessId ASC, createdAt DESC   | Collection |
| orders     | businessId ASC, createdAt DESC               | Collection |

Firestore will show an error in the console with a direct link to
create the index the first time each query runs — click the link.
