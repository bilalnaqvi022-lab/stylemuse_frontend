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




<<<<<<< HEAD
# Stylemuse-Frontend

StyleMuse — Flutter Frontend - Your Personal AI Fashion Companion

📖 Overview

StyleMuse is a full-stack AI-powered fashion app built with Flutter. It lets users discover curated outfits, manage a digital wardrobe, chat with Claude AI for personalized style suggestions, log daily looks, and try outfits on through augmented reality.

This repository contains the Flutter frontend only.
The backend (Node.js + Express + MongoDB) lives in stylemuse_backend/.

| Feature                   | Description                                                                               |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| 🔐 **Secure Auth**        | JWT login/signup with bcrypt-hashed passwords stored on device via flutter_secure_storage |
| 👗 **Discover**           | 20 curated outfits in horizontal scroll rows grouped by style tag                         |
| 🔖 **Save Outfits**       | Bookmark looks from Discover, synced to backend                                           |
| 🤖 **AI Style Generator** | Chat with Claude AI — type freely or use quick chips                                      |
| 👚 **Digital Closet**     | Add clothes via camera/gallery — auto-uploaded to Cloudinary                              |
| 📅 **Style Calendar**     | Log what you wear daily, view monthly outfit history                                      |
| 📊 **Wardrobe Stats**     | Most worn, least worn, cost-per-wear analytics                                            |
| 🪞 **AR Try-On**          | Place 3D outfit mannequin in real space using camera + gyroscope                          |
| 📷 **Camera Overlay**     | Live camera with color palette, item cards, and style tag overlaid                        |
| 🌓 **Dark / Light Theme** | Persisted theme toggle across sessions                                                    |



#🗂️ Project Structure

lib/
├── config/
│   └── api_config.dart
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
│   │
│   ├── auth/
│   │   └── login_screen.dart
│   │
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── outfit_detail_screen.dart
│   │   └── outfits_screen.dart
│   │
│   ├── style_generator/
│   │   └── style_generator_screen.dart
│   │
│   ├── closet/
│   │   └── closet_screen.dart
│   │
│   ├── calendar/
│   │   └── style_calendar_screen.dart
│   │
│   ├── stats/
│   │   └── wardrobe_stats_screen.dart
│   │
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   │
│   └── ar/
│       ├── ar_hub_screen.dart
│       ├── ar_tryon_screen.dart
│       └── camera_overlay_screen.dart
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── outfit_service.dart.
│   ├── image_upload_service.dart
│   ├── background_removal_service.dart.
│
├── theme/
│   └── app_theme.dart
│
└── widgets/
|    ├── logo_widget.dart
|    ├── outfit_card.dart
|    ├── custom_button.dart
|    └── custom_text_field.dart
|    
└── main.dart

#🚀 Getting Started
Prerequisites
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
Backend running (stylemuse_backend/)
Install
git clone https://github.com/your-username/stylemuse.git
cd stylemuse
flutter pub get
Run
flutter run

📦Dependencies
    provider
    shared_preferences
    flutter_secure_storage
    http
    image_picker
    camera
    sensors_plus
    cached_network_image
    permission_handler
    google_fonts
    uuid
    crypto
    flutter_animate
    path_provider
    
🎨Theme
    Light: Warm Beige (#EDE8DF)
    Dark: Black + Gold (#1A1218 / #C9A84C)

🔐 Auth Flow
Login → Backend → JWT Token → Secure Storage → API Calls
📸 Image Upload Flow
Pick Image → Backend → Cloudinary → URL → Closet Save
🤖 AI Style Generator

Chat powered by Claude AI via backend.
Users can describe outfits or use quick chips.

🪞 AR Features
3D mannequin placement
Camera overlays
Gyroscope movement 
Screenshot capture

🏗️ Build APK
flutter build apk --release --split-per-abi

🛠️ Common Errors
Backend not running → check API URL
Emulator issue → use 10.0.2.2
Gradle error → clean build


# stylemuse_frontend
>>>>>>> c1410ad63aeb6224c74bee6e46e5739f27c7ca9a
