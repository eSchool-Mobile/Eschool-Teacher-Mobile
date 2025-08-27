# 🚀 Codemagic iOS Build Setup - RINGKASAN LENGKAP

## ✅ Yang Sudah Diperbaiki

1. **Error Validation Codemagic:** ✅ FIXED
   - Removed empty environment variables
   - Changed to `ad_hoc` distribution (easier for testing)
   - Commented out App Store Connect variables

2. **Bundle ID Configuration:** ✅ UPDATED  
   - Changed from `id.ac.eschool.teacherstaff.android` 
   - To: `id.ac.eschool.teacherstaff.ios`

3. **Build Configuration:** ✅ OPTIMIZED
   - Distribution type: `ad-hoc` 
   - Simplified build script
   - Updated ExportOptions.plist

## 🎯 Langkah-langkah Setup Codemagic

### 1. Setup Apple Developer Account
```
🔐 Yang Anda Butuhkan:
- Apple Developer Program ($99/tahun)
- Login ke https://developer.apple.com/
```

### 2. Buat App ID di Apple Developer Portal
```
📱 Steps:
1. Masuk ke Apple Developer Portal
2. Certificates, Identifiers & Profiles
3. Identifiers → App IDs
4. Register App ID: id.ac.eschool.teacherstaff.ios
5. Enable capabilities yang diperlukan
```

### 3. Update Bundle ID di Project (AUTOMATED)
```bash
# Windows:
setup_ios_bundle.bat

# macOS/Linux:  
chmod +x setup_ios_bundle.sh
./setup_ios_bundle.sh
```

### 4. Setup Certificates & Provisioning Profiles

#### A. Development Certificate:
```
🛠️ Steps:
1. Keychain Access → Certificate Assistant → Request Certificate
2. Upload CSR ke Apple Developer Portal
3. Download & install certificate
```

#### B. Distribution Certificate:
```
📦 Steps:
1. Create Distribution Certificate di Apple Developer Portal
2. Download & install
```

#### C. Provisioning Profiles:
```
📋 Create 2 profiles:
1. Development Profile (for testing)
2. Ad Hoc Distribution Profile (for distribution)

Include:
- App ID: id.ac.eschool.teacherstaff.ios
- Distribution Certificate
- Test devices (UDID required)
```

### 5. Setup Codemagic Project

#### A. Login ke Codemagic:
```
🌐 Go to: https://codemagic.io/start/
- Login dengan GitHub/GitLab/Bitbucket
- Connect repository
```

#### B. Upload Certificates:
```
🔑 In Codemagic Dashboard:
1. Team settings → Code signing certificates
2. Upload .p12 files (development & distribution)
3. Enter certificate passwords
```

#### C. Upload Provisioning Profiles:
```
📄 In Codemagic Dashboard:
1. Team settings → Provisioning profiles  
2. Upload .mobileprovision files
3. Assign to bundle ID
```

### 6. Configure Build

#### A. Select Workflow:
```
⚙️ In Codemagic:
1. Select your app
2. Choose "ios-workflow"
3. Verify configuration matches codemagic.yaml
```

#### B. Environment Variables:
```
🔧 Set in Codemagic (if needed):
- TEAM_ID: Your Apple Developer Team ID
- Update email in codemagic.yaml publishing section
```

### 7. Start Build
```
🚀 In Codemagic:
1. Click "Start new build"
2. Select "ios-workflow"
3. Wait for build completion (~15-30 minutes)
```

## 📱 Install IPA di iOS Device

### Method 1: Ad Hoc Distribution (Recommended)
```
📋 Requirements:
- Device UDID registered in provisioning profile
- Device running iOS 9.0+

📥 Installation:
1. Download .ipa from Codemagic artifacts
2. Use iTunes, Xcode, atau Diawi
3. Install on registered devices
```

### Method 2: Over-the-Air (OTA)
```
🌐 Services:
- Diawi: https://www.diawi.com/
- InstallOnAir: https://www.installonair.com/
- AppBox: https://getappbox.com/

📱 Steps:
1. Upload IPA ke service
2. Share QR code/link
3. Open di Safari on iOS device
4. Follow installation prompts
```

### Method 3: TestFlight (Future)
```
🧪 When ready for TestFlight:
1. Uncomment App Store Connect config in codemagic.yaml
2. Set distribution_type: app_store
3. Add App Store Connect API keys
4. Enable submit_to_testflight: true
```

## 🔍 Troubleshooting

### Common Issues:
```
❌ "Bundle ID mismatch"
→ Pastikan Bundle ID sama di semua tempat

❌ "No matching provisioning profile"  
→ Periksa Bundle ID dan device UDID

❌ "Certificate not found"
→ Upload certificate yang benar ke Codemagic

❌ "Device not registered"
→ Tambahkan UDID device di Apple Developer Portal
```

### Get Device UDID:
```
📱 Methods:
1. Settings → General → About → Copy UDID
2. iTunes → Device → Serial Number (click to show UDID)
3. Xcode → Window → Devices and Simulators
4. diawi.com/udid (web-based)
```

## 📚 Resources

- **Apple Developer:** https://developer.apple.com/
- **Codemagic Docs:** https://docs.codemagic.io/flutter-publishing/publishing-to-app-store/
- **TestFlight:** https://developer.apple.com/testflight/
- **Bundle ID Guide:** docs/CODEMAGIC_IOS_SETUP.md

## 🎉 Summary

Konfigurasi Codemagic Anda sudah siap! File `codemagic.yaml` sudah diperbaiki dan tidak akan ada lagi error validasi. 

**Next Action:** Setup Apple Developer Account dan certificates, lalu upload ke Codemagic untuk mulai build iOS app Anda.

**Result:** IPA file yang bisa diinstall di iOS devices melalui ad hoc distribution.
