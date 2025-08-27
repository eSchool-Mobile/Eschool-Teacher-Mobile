@echo off
echo 🔧 Mengubah Bundle ID untuk iOS...

echo 📋 Membuat backup files...
copy "ios\Runner.xcodeproj\project.pbxproj" "ios\Runner.xcodeproj\project.pbxproj.backup" >nul
copy "ios\Runner\Info.plist" "ios\Runner\Info.plist.backup" >nul

echo 🔄 Updating project.pbxproj...
powershell -Command "(Get-Content 'ios\Runner.xcodeproj\project.pbxproj') -replace 'id\.ac\.eschool\.teacherstaff\.android', 'id.ac.eschool.teacherstaff.ios' | Set-Content 'ios\Runner.xcodeproj\project.pbxproj'"

echo 🔄 Checking Info.plist...
findstr /c:"id.ac.eschool.teacherstaff.android" "ios\Runner\Info.plist" >nul
if %errorlevel% equ 0 (
    powershell -Command "(Get-Content 'ios\Runner\Info.plist') -replace 'id\.ac\.eschool\.teacherstaff\.android', 'id.ac.eschool.teacherstaff.ios' | Set-Content 'ios\Runner\Info.plist'"
    echo ✅ Updated Bundle ID in Info.plist
) else (
    echo ℹ️  Info.plist uses PRODUCT_BUNDLE_IDENTIFIER variable (good)
)

echo 🔄 Checking pubspec.yaml...
findstr /c:"id.ac.eschool.teacherstaff.android" "pubspec.yaml" >nul
if %errorlevel% equ 0 (
    powershell -Command "(Get-Content 'pubspec.yaml') -replace 'id\.ac\.eschool\.teacherstaff\.android', 'id.ac.eschool.teacherstaff.ios' | Set-Content 'pubspec.yaml'"
    echo ✅ Updated Bundle ID in pubspec.yaml
)

echo 🧹 Cleaning iOS build...
flutter clean
if exist "ios\Pods" rmdir /s /q "ios\Pods"
if exist "ios\.symlinks" rmdir /s /q "ios\.symlinks"
if exist "ios\Flutter\Flutter.framework" rmdir /s /q "ios\Flutter\Flutter.framework"
if exist "ios\Flutter\Flutter.podspec" del "ios\Flutter\Flutter.podspec"

echo 📦 Getting Flutter packages...
flutter pub get

echo 🎯 Installing CocoaPods...
cd ios
pod install --repo-update
cd ..

echo.
echo ✅ Bundle ID berhasil diubah ke: id.ac.eschool.teacherstaff.ios
echo.
echo 📋 Langkah selanjutnya:
echo 1. Buka Apple Developer Portal
echo 2. Buat App ID dengan Bundle ID: id.ac.eschool.teacherstaff.ios
echo 3. Setup certificates dan provisioning profiles
echo 4. Upload ke Codemagic
echo 5. Test build
echo.
echo 📖 Baca panduan lengkap di: docs\CODEMAGIC_IOS_SETUP.md
pause
