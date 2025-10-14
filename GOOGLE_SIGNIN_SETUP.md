# Google Sign-In Setup Guide

This guide will help you configure Google Sign-In for your email application.

## Prerequisites

1. A Google Cloud Console account
2. Flutter SDK installed
3. Android Studio / Xcode (for Android/iOS development)

---

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google+ API** and **Gmail API**

---

## Step 2: Configure OAuth Consent Screen

1. In Google Cloud Console, go to **APIs & Services** > **OAuth consent screen**
2. Choose **External** user type (or Internal if using Google Workspace)
3. Fill in the required fields:
   - App name: `Mail App` (or your app name)
   - User support email: Your email
   - Developer contact email: Your email
4. Add scopes:
   - `email`
   - `profile`
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.send`
5. Save and continue

---

## Step 3: Create OAuth 2.0 Credentials

### For Android:

1. In Google Cloud Console, go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Select **Android** as application type
4. Get your SHA-1 fingerprint:

   **For Debug:**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   Look for `SHA1:` under `Variant: debug` and copy it.

   **Alternative method (using keytool):**
   ```bash
   # Windows
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

   # macOS/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

5. Enter the SHA-1 fingerprint
6. Enter package name: `com.example.email_app` (check in `android/app/build.gradle.kts`)
7. Click **Create**
8. Save the **Client ID** (you'll need this later)

### For iOS:

1. In Google Cloud Console, go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Select **iOS** as application type
4. Enter Bundle ID: `com.example.emailApp` (check in `ios/Runner.xcodeproj/project.pbxproj`)
5. Click **Create**
6. Download the `GoogleService-Info.plist` file

### For Web (Optional):

1. Create another OAuth client ID
2. Select **Web application**
3. Add authorized JavaScript origins:
   - `http://localhost`
   - `http://localhost:3000`
4. Save the **Client ID**

---

## Step 4: Configure Android

1. Update `android/app/build.gradle.kts`:
   
   Make sure you have the correct package name:
   ```kotlin
   android {
       namespace = "com.example.email_app"
       // ... rest of config
   }
   ```

2. No additional configuration needed - the plugin handles it automatically!

---

## Step 5: Configure iOS

1. Add the following to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
               <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
           </array>
       </dict>
   </array>
   ```

2. Place `GoogleService-Info.plist` in `ios/Runner/` directory

---

## Step 6: Configure Web (Optional)

1. Update `web/index.html`:
   
   Add this before the closing `</head>` tag:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```

---

## Step 7: Test the Integration

Run the app:
```bash
flutter run
```

Click the "Sign in with Google" button to test the authentication flow.

---

## Troubleshooting

### Android Issues:

**Error: "Sign in failed: PlatformException"**
- Verify SHA-1 fingerprint is correct
- Check package name matches in Google Cloud Console
- Wait a few minutes after creating credentials

**Developer Error / Error 10**
- SHA-1 doesn't match - regenerate and update in Google Cloud Console
- Make sure you're using the debug keystore for development

### iOS Issues:

**Error: "No valid URL scheme found"**
- Check `CFBundleURLSchemes` in `Info.plist`
- Verify REVERSED_CLIENT_ID is correct

**Error: "GoogleService-Info.plist not found"**
- Make sure the file is in `ios/Runner/` directory
- Clean and rebuild: `flutter clean && flutter pub get`

### General Issues:

**Error: "Access blocked: This app's request is invalid"**
- OAuth consent screen not configured properly
- Add test users if app is in testing mode

**Error: "The OAuth client was not found"**
- Client ID doesn't exist or was deleted
- Create new credentials in Google Cloud Console

---

## Important Notes

1. **For Production**: Generate release SHA-1 and create another OAuth client ID
   ```bash
   keytool -list -v -keystore your-release-key.jks -alias your-key-alias
   ```

2. **Gmail API**: Make sure Gmail API is enabled in Google Cloud Console

3. **Scopes**: The app requests:
   - `email`: To get user's email address
   - `gmail.readonly`: To read emails
   - `gmail.send`: To send emails

4. **Privacy Policy**: Google requires a privacy policy for apps accessing Gmail

---

## Next Steps

After successful sign-in:
1. Store user credentials securely
2. Implement Gmail API integration
3. Create inbox screen to display emails
4. Implement compose and send functionality

---

## Useful Links

- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Gmail API Documentation](https://developers.google.com/gmail/api)
- [OAuth 2.0 for Mobile Apps](https://developers.google.com/identity/protocols/oauth2/native-app)

