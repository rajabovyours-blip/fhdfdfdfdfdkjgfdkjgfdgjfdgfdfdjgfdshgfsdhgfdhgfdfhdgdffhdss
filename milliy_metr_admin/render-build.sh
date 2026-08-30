#!/usr/bin/env bash
set -o errexit

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

export PATH="$PATH:`pwd`/flutter/bin"

echo "Configuring Flutter for Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web application..."
flutter build web --release --dart-define=API_URL=https://milliymetr-backend.onrender.com/api/v1

