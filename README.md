# Milliy Metr - Enterprise Multi-Vendor Construction Materials Marketplace

> **Yuqori Sifat**

## Project Overview

Milliy Metr is a highly scalable, multi-vendor marketplace designed specifically for construction materials. It implements Google-standard Flutter best practices, feature-first Clean Architecture, and Material Design 3.

## Architecture

This project strictly adheres to **Feature-First Clean Architecture**.

- `lib/core`: App-wide utilities, configuration, network, and theme infrastructure.
- `lib/shared`: Reusable UI components (widgets, dialogs) and models.
- `lib/features`: Isolated feature modules containing `data`, `domain`, and `presentation` layers.

## Getting Started

1. Copy `.env.example` to `.env` and fill in your variables.
2. Run `flutter pub get` to install dependencies.
3. Run `dart run build_runner build -d` to generate Riverpod and Freezed files.
4. Launch with `flutter run`.

## Tech Stack
- **Framework:** Flutter (Stable)
- **State Management & DI:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Routing:** GoRouter
- **Network:** Dio
- **Storage:** Hive, Flutter Secure Storage
- **Functional Error Handling:** fpdart
- **Linting:** flutter_lints, custom_lint

## License
Proprietary & Confidential.
