📋 Task Manager – Flutter Technical Assignment
📌 Overview

This project is a Task Management mobile application built using Flutter as part of a technical assessment.
The app allows users to securely log in and manage their tasks with full Create, Read, Update, and Delete (CRUD) functionality.

The main focus of this project is clean UI/UX, proper state management, API integration (mocked), secure token handling, and maintainable architecture.

✨ Features

User Login (mock authentication)

Secure token storage using encrypted storage

View task list fetched from API

Create new tasks

Edit existing tasks

Delete tasks with confirmation

Task fields:

Title

Description

Status (Pending / Completed)

Due Date

Pull-to-refresh

Loading, empty, and error states

Clean and modern Material 3 UI

🛠️ Tech Stack

Flutter (Material 3)

Provider – State management

Mock REST API service

flutter_secure_storage – Secure token storage

🧠 Architecture & Design

The app follows a clean and scalable architecture, separating concerns clearly:

lib/
├── models/        → Data models (Task)
├── services/      → API & authentication services
├── providers/     → State management logic
├── screens/       → App screens (Login, Home)
├── widgets/       → Reusable UI components
└── main.dart      → App entry point

This structure makes the app easier to maintain, test, and extend.

🔄 State Management

Provider is used for managing application state.

TaskProvider handles:

Fetching tasks

Adding, updating, and deleting tasks

Loading and error states

UI automatically updates when the state changes.

🌐 API Integration

A mock REST-style API service is implemented to simulate real backend behavior.

API layer includes:

Simulated network latency

Random failure handling

Structured API responses (success / error)

This approach keeps the app realistic without requiring a real backend.

🔐 Authentication & Security

Authentication is simulated using a dummy token.

Tokens are stored securely using flutter_secure_storage, which uses:

Android: EncryptedSharedPreferences

iOS: Keychain

On app launch, the user is automatically redirected based on login state.

🎨 UI / UX

Clean and modern Material 3 design

Consistent spacing, typography, and colors

Bottom sheet used for Add/Edit Task for better user experience

Responsive and mobile-friendly layout

🚀 Getting Started
Prerequisites

Flutter SDK (3.x or later)

Android Studio / VS Code

Android emulator or physical device

Setup Instructions
git clone <your-repo-url>
cd task_manager
flutter pub get
flutter run
📦 APK Build

To generate the release APK:

flutter build apk --release

APK location:

build/app/outputs/flutter-apk/app-release.apk

(Upload this APK and share the link in submission.)

🤖 AI Usage

AI tools (Claude AI and Figma AI) were used only for guidance and productivity.
All code, architecture decisions, and logic were understood and implemented manually.
I am comfortable explaining every part of this project.

✅ Assignment Coverage Checklist

✔ Login UI

✔ Task list from API

✔ Create / Edit / Delete tasks

✔ State management (Provider)

✔ API integration (mock)

✔ Secure token storage

✔ Clean architecture

✔ Loading, empty, and error states

✔ APK build

👤 Author

Arun Kumar
Flutter Developer (Student)

🏁 Final Note

This project demonstrates my ability to build production-ready Flutter applications with clean architecture, proper state management, secure data handling, and a strong focus on user experience.
