**ScreenShots**
<p align="center">
  <img src="https://github.com/user-attachments/assets/c25bbcea-e65c-45ff-86c2-1c476ed001e9" width="220" hspace="10"/>

  <img src="https://github.com/user-attachments/assets/9c3c411d-8c5f-41da-b52a-3bae339b02e7" width="220" hspace="10"/>

  <img src="https://github.com/user-attachments/assets/ec427cd9-cf2c-43f9-a83f-69c6f18da2a7" width="220" hspace="10"/>
</p>

<br/>

<p align="center">
  <img src="https://github.com/user-attachments/assets/3bb8fcc1-f9dd-45b5-a1ba-54231ff5996c" width="220" hspace="10"/>

  <img src="https://github.com/user-attachments/assets/c037fcaf-d8a5-43dc-864b-e0778eb2e5a3" width="220" hspace="10"/>
</p>


# 👗 StyleMuse — Flutter Frontend

> **Your Personal AI Fashion Companion** — Discover outfits, manage your digital wardrobe, chat with Claude AI, log daily looks, and try on clothes in AR.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=flat-square&logo=dart)](https://dart.dev/)
[![Claude AI](https://img.shields.io/badge/Claude-AI%20Powered-D97706?style=flat-square)](https://anthropic.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## 📖 Overview

StyleMuse is a full-stack AI-powered fashion app built with Flutter. This repository contains the **Flutter frontend only**.

> 🔗 The backend (Node.js + Express + MongoDB) lives in [`stylemuse_backend/`](../stylemuse_backend)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔐 **Secure Auth** | JWT login/signup with bcrypt-hashed passwords stored on device via `flutter_secure_storage` |
| 👗 **Discover** | 20 curated outfits in horizontal scroll rows grouped by style tag |
| 🔖 **Save Outfits** | Bookmark looks from Discover, synced to backend |
| 🤖 **AI Style Generator** | Chat with Claude AI — type freely or use quick prompt chips |
| 👚 **Digital Closet** | Add clothes via camera/gallery — auto-uploaded to Cloudinary |
| 📅 **Style Calendar** | Log what you wear daily, view monthly outfit history |
| 📊 **Wardrobe Stats** | Most worn, least worn, and cost-per-wear analytics |
| 🪞 **AR Try-On** | Place a 3D outfit mannequin in real space using camera + gyroscope |
| 📷 **Camera Overlay** | Live camera with color palette, item cards, and style tags overlaid |
| 🌓 **Dark / Light Theme** | Persisted theme toggle across sessions |

---

## 🗂️ Project Structure

```
lib/
├── config/
│   └── api_config.dart               # Base URLs and environment config
│
├── models/
│   ├── calendar_entry_model.dart
│   ├── closet_item_model.dart
│   ├── outfit_model.dart
│   └── user_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── calendar_provider.dart
│   ├── closet_provider.dart
│   └── theme_provider.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── outfit_detail_screen.dart
│   │   └── outfits_screen.dart
│   ├── style_generator/
│   │   └── style_generator_screen.dart
│   ├── closet/
│   │   └── closet_screen.dart
│   ├── calendar/
│   │   └── style_calendar_screen.dart
│   ├── stats/
│   │   └── wardrobe_stats_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   └── ar/
│       ├── ar_hub_screen.dart
│       ├── ar_tryon_screen.dart
│       └── camera_overlay_screen.dart
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── outfit_service.dart
│   ├── image_upload_service.dart
│   └── background_removal_service.dart
│
├── theme/
│   └── app_theme.dart
│
├── widgets/
│   ├── logo_widget.dart
│   ├── outfit_card.dart
│   ├── custom_button.dart
│   └── custom_text_field.dart
│
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`
- Backend running at `stylemuse_backend/` (see backend repo)

### Install & Run

```bash
# Clone the repository
git clone https://github.com/your-username/stylemuse.git
cd stylemuse

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Build APK

```bash
flutter build apk --release --split-per-abi
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Persist theme and light settings |
| `flutter_secure_storage` | Secure JWT token storage |
| `http` | REST API communication |
| `image_picker` | Camera and gallery access |
| `camera` | Live camera feed for AR and overlays |
| `sensors_plus` | Gyroscope data for AR mannequin movement |
| `cached_network_image` | Efficient remote image loading |
| `permission_handler` | Runtime permission requests |
| `google_fonts` | Custom typography |
| `uuid` | Unique ID generation |
| `crypto` | Password hashing utilities |
| `flutter_animate` | Declarative UI animations |
| `path_provider` | Local file system access |

---

## 🎨 Theme

| Mode | Background | Accent |
|------|-----------|--------|
| ☀️ Light | Warm Beige `#EDE8DF` | — |
| 🌙 Dark | Deep Black `#1A1218` | Gold `#C9A84C` |

Theme preference is persisted across sessions via `ThemeProvider` + `shared_preferences`.

---

## 🔐 Auth Flow

```
User Login / Signup
      ↓
Backend (Node.js + bcrypt)
      ↓
JWT Token issued
      ↓
Stored in flutter_secure_storage
      ↓
Injected into all API request headers
```

---

## 📸 Image Upload Flow

```
Pick Image (camera / gallery)
      ↓
Send to Backend
      ↓
Backend uploads to Cloudinary
      ↓
Cloudinary URL returned
      ↓
Saved to Closet in MongoDB
```

---

## 🤖 AI Style Generator

Chat is powered by **Claude AI** via the backend proxy.

- Users type free-form style requests or select **quick prompt chips**
- The backend forwards messages to the Claude API and streams responses
- Suggestions include outfit combinations, color pairings, and occasion styling

---

## 🪞 AR Features

| Feature | Detail |
|---------|--------|
| 3D Mannequin | Placed in real-world space via the device camera |
| Gyroscope Tracking | `sensors_plus` moves the mannequin as the phone rotates |
| Camera Overlays | Color palette, item cards, and style tags rendered live |
| Screenshot Capture | Save AR try-on results to device gallery |

---

## 🛠️ Troubleshooting

| Issue | Fix |
|-------|-----|
| API calls failing | Ensure backend is running; verify base URL in `api_config.dart` |
| Emulator can't reach backend | Use `10.0.2.2` instead of `localhost` for Android emulator |
| Camera permission denied | Grant camera + storage permissions in device settings |
| AR not rendering | Confirm `camera` and `sensors_plus` permissions are accepted |
| Cloudinary upload failing | Check backend `.env` for correct Cloudinary credentials |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
Gradle error → clean build


# stylemuse_frontend
>>>>>>> c1410ad63aeb6224c74bee6e46e5739f27c7ca9a
