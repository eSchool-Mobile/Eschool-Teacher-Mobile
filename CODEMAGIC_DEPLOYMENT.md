# Panduan Deploy Flutter App ke iOS menggunakan Codemagic

## Prerequisites

### 1. Apple Developer Account
- Anda memerlukan Apple Developer Account ($99/tahun)
- Pastikan Anda memiliki akses ke Apple Developer Console

### 2. App Store Connect Setup
- Buat aplikasi di App Store Connect
- Dapatkan App Store Connect API credentials:
  - Issuer ID
  - Key ID  
  - Private Key (.p8 file)

### 3. iOS Certificate & Provisioning Profile
- iOS Distribution Certificate
- App Store Provisioning Profile

## Setup Codemagic

### 1. Daftar ke Codemagic
1. Kunjungi https://codemagic.io/start/
2. Sign up menggunakan GitHub/GitLab/Bitbucket account
3. Connect repository Flutter Anda

### 2. Konfigurasi iOS Code Signing

#### Di Codemagic Dashboard:
1. Go to **Team settings** > **Code signing identities**
2. Upload iOS certificate (.p12 file)
3. Upload provisioning profile (.mobileprovision file)

#### Setup App Store Connect Integration:
1. Go to **Team settings** > **Integrations**
2. Enable **App Store Connect**
3. Upload App Store Connect API key (.p8 file)
4. Masukkan:
   - Issuer ID
   - Key ID

### 3. Environment Variables
Set di Codemagic environment variables:

```
APP_STORE_CONNECT_ISSUER_ID: [Your Issuer ID]
APP_STORE_CONNECT_KEY_IDENTIFIER: [Your Key ID]  
APP_STORE_CONNECT_PRIVATE_KEY: [Your Private Key content]
BUNDLE_ID: com.yourcompany.eschoolsaasstaff
```

### 4. Update Bundle Identifier
Edit file `ios/Runner.xcodeproj/project.pbxproj`:
- Ganti `PRODUCT_BUNDLE_IDENTIFIER` dengan bundle ID Anda
- Contoh: `com.yourcompany.eschoolsaasstaff`

### 5. Update pubspec.yaml (sudah dikonfigurasi)
```yaml
version: 1.0.5+9
```

## Build Process

### 1. Trigger Build
- Push code ke repository
- Atau trigger manual build di Codemagic dashboard

### 2. Build Output
- iOS: `.ipa` file untuk App Store
- Android: `.apk` dan `.aab` files

### 3. Distribution
- **TestFlight**: Otomatis upload untuk beta testing
- **App Store**: Submit untuk review (opsional, set `submit_to_app_store: true`)

## Troubleshooting

### Common Issues:

1. **Bundle ID Mismatch**
   - Pastikan bundle ID di Xcode project sama dengan provisioning profile

2. **Certificate Issues**
   - Pastikan certificate dan provisioning profile masih valid
   - Check expiration date

3. **Build Failures**
   - Check build logs di Codemagic dashboard
   - Pastikan semua dependencies compatible dengan iOS

### Build untuk iOS dari Windows

Karena Anda menggunakan Windows, Codemagic adalah solusi terbaik karena:
- Menyediakan macOS build environment
- Automated code signing
- Direct integration dengan App Store Connect
- Support untuk Flutter iOS builds

## File Konfigurasi

File `codemagic.yaml` sudah dikonfigurasi dengan:
- iOS workflow untuk App Store deployment
- Android workflow untuk Google Play
- Automated testing
- Code signing setup
- Artifact management

## Next Steps

1. **Setup Apple Developer Account** jika belum ada
2. **Create App di App Store Connect**
3. **Generate certificates & provisioning profiles**
4. **Configure Codemagic** dengan credentials
5. **Update Bundle ID** di project
6. **Trigger first build**

## Contact & Support

Untuk bantuan lebih lanjut:
- Codemagic Documentation: https://docs.codemagic.io/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
