![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.x-green?logo=springboot)
![Java](https://img.shields.io/badge/Java-17-orange?logo=openjdk)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-yellow)


# 🧠 MindMosaic

**MindMosaic** is an AI-powered dementia care platform designed to assist patients with early-stage dementia and support caregivers in managing daily activities, memory reinforcement, and health monitoring.

The application combines a **Flutter mobile application**, **Spring Boot backend**, and **AI-powered modules** to provide an intelligent, secure, and user-friendly healthcare solution.

---

## ✨ Features

### 👨‍⚕️ Caregiver Module
- Secure authentication
- Patient registration and management
- Daily schedule creation
- Memory management
- View patient information
- Personalized AI assistance

### 👵 Patient Module
- Simple and accessible mobile interface
- View daily schedules
- Memory cards with photos
- AI-powered conversational assistant
- Brain engagement activities

### 🧠 AI Features
- Dementia risk prediction
- Personalized AI chatbot using Gemini API
- Memory reinforcement through image-based activities
- Intelligent recommendations based on patient interactions

---

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Provider (State Management)

### Backend
- Java
- Spring Boot
- Spring Security
- Spring Data JPA
- Hibernate
- REST APIs

### Database
- PostgreSQL

### AI & Machine Learning
- Python
- Scikit-learn
- XGBoost
- Gemini API

### Tools
- Git & GitHub
- Postman
- Android Studio
- IntelliJ IDEA
- VS Code

---

## 📂 Project Structure

```
MindMosaic
│
├── dement_flutter        # Flutter Mobile Application
│
└── dement-backend        # Spring Boot REST API
```

---

## 🚀 Getting Started

### Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/MindMosaic.git
cd MindMosaic
```

---

## Backend Setup

```bash
cd dement-backend
```

Configure your database credentials inside:

```
src/main/resources/application.properties
```

Run the Spring Boot application.

---

## Flutter Setup

```bash
cd dement_flutter
flutter pub get
flutter run
```

Ensure the backend server is running before launching the Flutter application.

---

## 🔐 Environment Variables

This project uses API keys for AI services.

Replace the placeholder values in:

```
application.properties
```

Example:

```properties
gemini.api.key=YOUR_GEMINI_API_KEY
```

Never commit real API keys to GitHub.

---

## 📸 Screenshots

> Screenshots and demo GIFs will be added soon.

---

## 🎯 Future Enhancements

- Voice-based patient interaction
- Medication reminders
- Emergency SOS alerts
- Geofencing support
- Caregiver analytics dashboard
- Wearable device integration
- Enhanced AI recommendations

---

## 👩‍💻 Developed By

**Priya Bhadekar**

Final Year Computer Engineering Student

- Java Full Stack Developer
- Flutter Developer
- AI & Machine Learning Enthusiast

---

## ⭐ Support

If you found this project useful, consider giving it a ⭐ on GitHub.
