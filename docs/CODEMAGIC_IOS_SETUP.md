# Setup Codemagic untuk iOS Build

## Langkah-langkah Setup

### 1. Persiapan Akun Apple Developer
- Pastikan Anda memiliki akun Apple Developer Program ($99/tahun)
- Login ke [Apple Developer Portal](https://developer.apple.com/)

### 2. Setup Bundle ID di Apple Developer
1. Buka Apple Developer Portal
2. Pergi ke "Certificates, Identifiers & Profiles"
3. Klik "Identifiers" 
4. Buat App ID baru dengan Bundle ID: `id.ac.eschool.teacherstaff.ios` (ubah dari android ke ios)
5. Enable capabilities yang diperlukan (Push Notifications, dll)

### 3. Setup Certificates & Provisioning Profiles
1. **Development Certificate:**
   - Buat CSR (Certificate Signing Request) di Keychain Access
   - Upload ke Apple Developer Portal
   - Download certificate dan install

2. **Distribution Certificate:**
   - Buat untuk App Store atau Ad Hoc distribution
   - Download dan install

3. **Provisioning Profiles:**
   - Buat Development Provisioning Profile
   - Buat Distribution Provisioning Profile (App Store atau Ad Hoc)

### 4. Setup App Store Connect (Opsional - untuk TestFlight/App Store)
1. Buka [App Store Connect](https://appstoreconnect.apple.com/)
2. Buat app baru dengan Bundle ID yang sama
3. Isi informasi app yang diperlukan

### 5. Setup Codemagic Environment Variables

#### Untuk Distribution Ad Hoc (Lebih mudah untuk testing):
Tidak perlu environment variables khusus, cukup upload certificates dan provisioning profiles di Codemagic UI.

#### Untuk App Store Distribution (Advanced):
Jika ingin publish ke App Store, uncomment dan isi variabel berikut di Codemagic Environment Variables:

```yaml
APP_STORE_CONNECT_ISSUER_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
APP_STORE_CONNECT_KEY_IDENTIFIER: "XXXXXXXXXX" 
APP_STORE_CONNECT_PRIVATE_KEY: |
  -----BEGIN PRIVATE KEY-----
  Your App Store Connect API Key
  -----END PRIVATE KEY-----
CERTIFICATE_PRIVATE_KEY: |
  -----BEGIN PRIVATE KEY-----
  Your Certificate Private Key
  -----END PRIVATE KEY-----
```

### 6. Update Bundle ID di iOS Project
Ubah Bundle ID di file `ios/Runner.xcodeproj/project.pbxproj` dan `ios/Runner/Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>id.ac.eschool.teacherstaff.ios</string>
```

### 7. Cara Install IPA di iOS Device

#### Metode 1: TestFlight (Recommended)
1. Upload ke TestFlight melalui App Store Connect
2. Tambahkan tester email
3. Tester install TestFlight app
4. Install dari TestFlight

#### Metode 2: Ad Hoc Distribution
1. Build dengan distribution type: ad_hoc
2. Tambahkan UDID device di Apple Developer Portal
3. Include UDID dalam provisioning profile
4. Distribute IPA file via iTunes, Xcode, atau tools seperti Diawi

#### Metode 3: Over-the-Air Installation (OTA)
1. Upload IPA ke service seperti Diawi, InstallOnAir, atau build sendiri
2. Generate QR code atau link
3. Buka link di Safari iOS device
4. Follow installation prompts

### 8. Current Configuration
File `codemagic.yaml` saat ini dikonfigurasi untuk:
- **Distribution Type:** `ad_hoc` (lebih mudah untuk testing)
- **Bundle ID:** `id.ac.eschool.teacherstaff.android` (perlu diubah ke ios)
- **Build Output:** IPA file yang bisa di-distribute

### 9. Troubleshooting
- **Bundle ID mismatch:** Pastikan Bundle ID sama di semua tempat
- **Certificate issues:** Pastikan certificate dan provisioning profile valid
- **Device UDID:** Untuk ad hoc, pastikan device UDID terdaftar
- **Expiry dates:** Periksa tanggal expiry certificates dan profiles

### 10. Next Steps
1. Update Bundle ID dari `android` ke `ios`
2. Setup Apple Developer account dan certificates
3. Upload certificates ke Codemagic
4. Test build
5. Distribute ke tester

## Links Berguna
- [Apple Developer Portal](https://developer.apple.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Codemagic iOS Documentation](https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/)
- [TestFlight](https://developer.apple.com/testflight/)
