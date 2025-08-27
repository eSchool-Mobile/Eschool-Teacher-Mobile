@echo off
REM Script untuk setup dan deploy Flutter app ke iOS menggunakan Codemagic
REM Jalankan script ini di Command Prompt atau PowerShell

echo === Flutter iOS Deployment Setup dengan Codemagic ===
echo.

REM Cek apakah Flutter terinstall
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter tidak ditemukan! Pastikan Flutter sudah terinstall.
    pause
    exit /b 1
)

echo ✅ Flutter ditemukan
flutter --version | findstr /C:"Flutter"

REM Cek Flutter doctor
echo.
echo 🔍 Checking Flutter doctor...
flutter doctor

REM Clean dan get dependencies
echo.
echo 🧹 Cleaning project...
flutter clean

echo 📦 Getting dependencies...
flutter pub get

REM Analyze project
echo.
echo 🔍 Analyzing project...
flutter analyze

REM Run tests (ignore failures for setup)
echo.
echo 🧪 Running tests...
flutter test

echo.
echo ✅ Project setup selesai!
echo.
echo 📋 Langkah selanjutnya:
echo 1. Push code ke repository Git Anda
echo 2. Kunjungi https://codemagic.io dan connect repository
echo 3. Setup Apple Developer Account ^& certificates
echo 4. Configure Code Signing di Codemagic
echo 5. Trigger build untuk iOS
echo.
echo 📖 Baca file CODEMAGIC_DEPLOYMENT.md untuk panduan lengkap
echo.
pause
