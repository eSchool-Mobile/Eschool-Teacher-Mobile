#!/bin/bash

# Script untuk setup dan deploy Flutter app ke iOS menggunakan Codemagic
# Jalankan script ini di terminal/command prompt

echo "=== Flutter iOS Deployment Setup dengan Codemagic ==="
echo ""

# Cek apakah Flutter terinstall
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter tidak ditemukan! Pastikan Flutter sudah terinstall."
    exit 1
fi

echo "✅ Flutter ditemukan: $(flutter --version | head -n1)"

# Cek Flutter doctor
echo ""
echo "🔍 Checking Flutter doctor..."
flutter doctor

# Clean dan get dependencies
echo ""
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Analyze project
echo ""
echo "🔍 Analyzing project..."
flutter analyze

# Run tests
echo ""
echo "🧪 Running tests..."
flutter test

echo ""
echo "✅ Project setup selesai!"
echo ""
echo "📋 Langkah selanjutnya:"
echo "1. Push code ke repository Git Anda"
echo "2. Kunjungi https://codemagic.io dan connect repository"
echo "3. Setup Apple Developer Account & certificates"
echo "4. Configure Code Signing di Codemagic"
echo "5. Trigger build untuk iOS"
echo ""
echo "📖 Baca file CODEMAGIC_DEPLOYMENT.md untuk panduan lengkap"
