# PeaceMind AI 🌿

> A private, judgment-free mental wellness companion built with Flutter + Firebase.
> **Not a replacement for licensed therapy or medical diagnosis.**

PeaceMind AI helps you build healthy daily routines, practice guided therapeutic exercises, talk to **NOVA** — an AI voice companion — and track your mood and progress over time.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Firebase email/password sign-up & login with persistent sessions |
| 👋 **Onboarding** | Guided welcome flow (once per user, saved per account) |
| 🏠 **Home Dashboard** | Next focus, routine carousel, mood tracker, garden that grows with your progress |
| 📅 **Routines** | Daily routines by category (morning / afternoon / evening / night) with reminders |
| 🧘 **Guided Exercises** | 4 voice-guided exercises with animated stages, scripts & multi-language TTS |
| 🎙️ **NOVA Voice Calls** | Speech-to-text + AI conversation (OpenRouter) with text-to-speech replies and live call timer |
| 🛡️ **Crisis Safety** | Real-time safety detection during calls with an immediate supportive overlay |
| 📈 **Progress & History** | Every routine, exercise and voice call saved locally + on Firebase, shown with charts |
| 📓 **Journal** | Write your calm — private journal entries |
| ⚙️ **Settings** | Profile editing, notifications info, report access, logout |

---

## 🧘 Exercise Catalog

All exercises share one immersive player UI — step tracker, timer bar, animated stage, narration script with typewriter reveal, and a completion overlay with stats.

| Exercise | Focus | Technique |
|---|---|---|
| **Box Breathing** | Calm the nervous system | 4-4-4-4 breathing cycles |
| **Grounding 5-4-3-2-1** | Reconnect with senses | Sensory grounding technique |
| **Mindful Walking** | Walk with awareness | Slow, attentive walking meditation |
| **Body Scan** | Release tension slowly | Progressive body awareness |

**Narration languages:** English, اردو (Urdu), Roman Urdu, 中文 (Chinese), ਪੰਜਾਬੀ (Punjabi).

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider (`ChangeNotifier`) |
| **Backend** | Firebase Auth + Cloud Firestore |
| **Local Storage** | SharedPreferences (per-user keys) |
| **AI** | OpenRouter API (configurable model via `.env`) |
| **Voice** | `speech_to_text` (STT) + `flutter_tts` (TTS) |
| **Charts** | `fl_chart` |
| **Notifications** | `flutter_local_notifications` |
| **Animations** | Lottie, Flutter Animate |

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry, Firebase init, MultiProvider setup
├── firebase_options.dart      # Firebase configuration
├── data/                      # Exercise definitions & step scripts
├── logic/                     # Audio call state machine
├── models/                    # User, Routine, History, Exercise, Call models
├── providers/                 # Auth, Routine, AudioCall (state management)
├── screens/                   # UI screens (auth, home, exercise, calls...)
├── services/                  # Firestore, AI (OpenRouter), STT/TTS services
├── theme/                     # App colors & theme
└── widgets/                   # Reusable components + exercise stage widgets
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.x, Dart >= 3.0)
- A Firebase project
- An OpenRouter API key

### Setup

```bash
# 1. Clone & install dependencies
git clone <your-repo-url>
cd PeaceMind-AI
flutter pub get

# 2. Configure Firebase
#    (flutterfire configure  generates lib/firebase_options.dart)
flutterfire configure

# 3. Create .env file in the project root:
```

`.env` contents:

```env
OPENROUTER_API_KEY=your_key_here
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_MODEL=qwen/qwen-plus
```

```bash
# 4. Run the app
flutter run
```

---

## 🔥 Firebase Data Model

```
users/{uid}
├── (profile)            # name, email, mood, routineCount, taskCount
├── history/{entryId}    # every completed routine / exercise / voice call
├── audioCallSessions/   # NOVA call session snapshots
├── chatMessages/        # individual user & NOVA messages (safetyFlag if crisis)
└── sessionSummaries/    # rolling conversation summary for AI context
```

- History entries include: activity title, category (`morning`/`afternoon`/`evening`/`night`/`exercise`/`audio`), completion time, mood score (optional) and notes (duration, cycles, transcript snippet).
- Local (SharedPreferences) and Firestore history are **merged by ID** on login — no duplicates, works offline.

---

## 📈 Progress & History Report

The report screen shows:

- **Summary cards** — streak, total activities, performance (average mood + streak bonus)
- **Weekly Activity bar chart** — activities per day (last 7 days)
- **Mood Trend line chart** — average mood per day (entries with a mood)
- **Category breakdown pie chart** — your activity mix
- **Recent sessions list** — filterable by Tasks / Exercises / Calls

---

## 🛡️ Safety

During NOVA voice calls, user speech is checked against a crisis keyword list. If unsafe language is detected:

1. A calm supportive overlay appears immediately.
2. A grounding voice message is spoken.
3. The message is flagged (`safetyFlag: true`) in Firestore.

**If you are in crisis, please contact your local emergency services or a crisis hotline immediately. This app is a companion, not a medical service.**

---

## 🔒 Privacy

- Your history and profile are stored under your own user ID — accounts are fully separated.
- Local data is keyed per user; logging out switches to the next user's data automatically.
- The AI API key lives in `.env` (never committed).

---

## 📄 License

Proprietary — All rights reserved.

---

<div align="center">

**PeaceMind AI** — *Your space, your pace. Small steps are still progress.* 🌱

</div>
