#!/bin/bash

# Script untuk mengubah Bundle ID iOS dari Android ke iOS
# Run dari root directory project

echo "🔧 Mengubah Bundle ID untuk iOS..."

# Backup files terlebih dahulu
echo "📋 Membuat backup files..."
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.backup
cp ios/Runner/Info.plist ios/Runner/Info.plist.backup

# Update Bundle ID di project.pbxproj
echo "🔄 Updating project.pbxproj..."
sed -i 's/id\.ac\.eschool\.teacherstaff\.android/id.ac.eschool.teacherstaff.ios/g' ios/Runner.xcodeproj/project.pbxproj

# Update Bundle ID di Info.plist jika hardcoded
echo "🔄 Checking Info.plist..."
if grep -q "id.ac.eschool.teacherstaff.android" ios/Runner/Info.plist; then
    sed -i 's/id\.ac\.eschool\.teacherstaff\.android/id.ac.eschool.teacherstaff.ios/g' ios/Runner/Info.plist
    echo "✅ Updated Bundle ID in Info.plist"
else
    echo "ℹ️  Info.plist uses PRODUCT_BUNDLE_IDENTIFIER variable (good)"
fi

# Update pubspec.yaml jika ada bundle ID hardcoded
echo "🔄 Checking pubspec.yaml..."
if grep -q "id.ac.eschool.teacherstaff.android" pubspec.yaml; then
    sed -i 's/id\.ac\.eschool\.teacherstaff\.android/id.ac.eschool.teacherstaff.ios/g' pubspec.yaml
    echo "✅ Updated Bundle ID in pubspec.yaml"
fi

# Clean iOS build
echo "🧹 Cleaning iOS build..."
flutter clean
cd ios
rm -rf Pods
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
cd ..

# Get packages
echo "📦 Getting Flutter packages..."
flutter pub get

# Install pods
echo "🎯 Installing CocoaPods..."
cd ios
pod install --repo-update
cd ..

echo ""
echo "✅ Bundle ID berhasil diubah ke: id.ac.eschool.teacherstaff.ios"
echo ""
echo "📋 Langkah selanjutnya:"
echo "1. Buka Apple Developer Portal"
echo "2. Buat App ID dengan Bundle ID: id.ac.eschool.teacherstaff.ios"
echo "3. Setup certificates dan provisioning profiles"
echo "4. Upload ke Codemagic"
echo "5. Test build"
echo ""
echo "📖 Baca panduan lengkap di: docs/CODEMAGIC_IOS_SETUP.md"
