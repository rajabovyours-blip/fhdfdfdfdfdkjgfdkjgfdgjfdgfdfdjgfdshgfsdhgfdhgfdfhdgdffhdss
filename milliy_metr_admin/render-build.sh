#!/usr/bin/env bash
set -o errexit

echo "Using existing Flutter SDK..."
# Render environment already has or caches Flutter in /opt/render/flutter
export PATH="$PATH:/opt/render/flutter/bin:$HOME/flutter/bin:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Configuring Flutter for Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web application..."
flutter build web --release --dart-define=API_URL=https://milliymetr-backend.onrender.com/api/v1

