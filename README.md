# 🖌️ InkSync – Real-Time Multiplayer Drawing And Word Guessing Game

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Node.js](https://img.shields.io/badge/Backend-Node.js-green?logo=node.js)
![Socket.IO](https://img.shields.io/badge/Socket.IO-Realtime-black?logo=socket.io)
![MongoDB](https://img.shields.io/badge/Database-MongoDB-brightgreen?logo=mongodb)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-orange)

> 🎮 A real-time, competitive drawing game where players sketch and guess words to score points — powered by Flutter, Node.js, MongoDB, and Socket.IO.

🔗 **Live Repo:** [https://github.com/your-username/inksync](https://github.com/your-username/inksync)

---

## 📚 Table of Contents

- [📥 App Link](#-app-link)
- [📸 Screenshots](#-screenshots)
- [🌟 Features](#-features)
- [🧩 Game Flow](#-game-flow)
- [🧰 Tech Stack](#-tech-stack)
- [📂 Folder Structure](#-folder-structure)
- [🚀 Getting Started](#-getting-started)
- [🤝 Contributing](#-contributing)
- [👨‍💻 Author](#-author)
- [📄 License](#-license)

---

## 📥 App Link

🔗 **Download APK**: _Coming soon..._

---

## 📸 Screenshots

<p>
  <img src="https://github.com/user-attachments/assets/901d91c0-f723-4bfd-9193-8bfa5132eb77" width="220" height="400" />
  <img src="https://github.com/user-attachments/assets/185870f4-115d-47d0-b87f-4887cf9ffa04" width="220" height="400" />
  <img src="https://github.com/user-attachments/assets/8f0ede1f-5e81-4035-8cf3-da94434408bd" width="220" height="400" />
  <img src="https://github.com/user-attachments/assets/cc7ff6b9-369b-4c75-89a8-2be469090dfb" width="220" height="400" />
  <img src="https://github.com/user-attachments/assets/162f7bb7-017a-4367-bc3d-b85de5e62085" width="220" height="400" />
  <img src="https://github.com/user-attachments/assets/c9be93ff-cb99-4362-9e23-3e564e289791" width="220" height="400" />
</p>

---

## 🌟 Features

- 🎨 Real-time drawing canvas with color and brush options
- 🔒 Secure room creation and joining with custom codes
- ⏱️ Countdown-based drawing and guessing gameplay
- 🧠 Earn points for correct guesses
- 🏆 Winner screen to declare the round champion
- ⚡ Ultra-fast sync using Socket.IO

---

## 🧩 Game Flow

### 👋 Welcome Screen
- Choose to create or join a room.

### 🏗️ Create / Join Room
- Enter player name and room code.
- Start or join an active room.

### ⏳ Waiting Lobby
- Wait for another player to join before starting.

### 🎮 Game Screen
- Draw freely with tools like color picker, thickness control, and eraser.
- Players guess the word based on the drawing.
- Points awarded for correct guesses.

### 🏆 Winner Screen
- After time runs out, winner is shown based on scores.

---

## 🧰 Tech Stack

| Layer        | Technology            |
|--------------|------------------------|
| Frontend     | Flutter (Dart)         |
| Backend      | Node.js (Express)      |
| Realtime     | Socket.IO              |
| Database     | MongoDB (Mongoose)     |
| State Mgmt   | Flutter BLoC / setState |

---

## 📂 Folder Structure

```
📦 inksync/
├── 📁 backend/
│   ├── models/
│   ├── routes/
│   ├── socket/
│   └── index.js
├── 📁 frontend/
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── main.dart
```

---

## 🚀 Getting Started

### ⚙️ Prerequisites

- Flutter SDK
- Node.js & npm
- MongoDB Atlas or local MongoDB

### 🔌 Backend Setup

```bash
cd backend
npm install
node index.js
```

### 📱 Flutter Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

> ⚠️ Make sure to update your backend IP in the Flutter config.

---

## 🤝 Contributing

Pull requests are welcome!  
Feel free to open issues or suggest new features 🚀

---

## 👨‍💻 Author

**Ankit Kumar**  
[GitHub](https://github.com/Dev-Ankit-Ks)  
[LinkedIn](https://linkedin.com/in/your-profile)  
[Twitter](https://twitter.com/your-handle)

---

## 📄 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

> Made with 💙 by Ankit Kumar using Flutter + Node.js + Socket.IO + MongoDB
