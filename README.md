# PeaceMind AI 🌿

> **Mental First Aid** — an AI-powered mental wellness companion built with Flutter + Firebase.
> Not a replacement for therapy. Not a medical device. Never diagnoses.

---

## 1. Problem Statement

Millions of people struggle with everyday emotional and mental stress — academic pressure, breakups, burnout, loneliness, overthinking — yet never seek traditional therapy. The barriers are real:

- **Stigma** — "What will people think if I see a therapist?"
- **Cost** — therapy is unaffordable for most students and low-income users.
- **Privacy** — fear of being judged, exposed, or labeled.
- **Access** — long waitlists, few professionals, especially in South Asia.

PeaceMind AI is a private, judgment-free companion that uses **Alibaba Cloud AI (Qwen models, served via OpenRouter)** and **CBT-based conversation techniques** to help users cope — inside their phone, on their terms, in their own language. It detects distress naturally from conversation (never from a form), guides users through calming exercises, and knows when to point them toward real professional help.

---

## 2. Concept — "Mental First Aid"

PeaceMind AI is **not therapy** — it is the **first step** people take when they would otherwise take none.

Like physical first aid:

| Physical First Aid | PeaceMind AI |
|---|---|
| Stabilizes the wound | Calms the user in the moment (grounding, breathing) |
| Prevents the injury from worsening | Interrupts spirals via inline exercises + daily routine |
| Supports until professional care | 24/7 conversation companion that remembers you |
| Refers onward when serious | Crisis flow flags risk and directs to real help |

**It never diagnoses.** It supports, tracks progress gently (the Garden), and escalates to real doctors when red flags appear (crisis keywords → immediate supportive flow + permanent safety flag in Firestore).

---

## 3. Core Functions

Everything below is implemented in the current codebase.

### 💬 Chat AI (`lib/screens/chat_screen.dart`, `lib/providers/chat_provider.dart`)
- Natural conversation with NOVA via OpenRouter REST API (model `qwen/qwen-plus`, hardcoded in `api_chat_service.dart`).
- **Distress is detected naturally** — the model tags every reply with a hidden `[DISTRESS_SCORE: 0.0–1.0]`; no self-report form, no "what's wrong with you" questions.
- When distress **> 0.7** and the model suggests an exercise, an **inline exercise popup** appears mid-conversation (3-minute cooldown, user can decline).
- Urdu replies are **spoken aloud automatically** (`[SPEAK:true]` tag → TTS); English replies are text-only.
- Session end → AI summary + history entry (category `chat`).

### 🎙️ NOVA — Voice / Call (`lib/screens/ai_audio_call_screen.dart`, `lib/providers/audio_call_provider.dart`)
- **Continuous VAD listening by default** (auto-restarts after silence and after NOVA finishes speaking); tap-to-speak is an opt-in toggle.
- Speech-to-text → language auto-detection → NOVA reply (model from `.env` `OPENROUTER_MODEL`, currently `qwen/qwen-plus`) → text-to-speech in the user's language.
- **Crisis keyword detection** (`SafetyDetector`, 12 unsafe phrases) → immediate calming overlay + grounding voice message + `safetyFlag: true` saved to Firestore.
- Call end → AI session summary, full transcript saved for replay, history entry (category `audio`).

### 🧘 Guided Exercises (4) (`lib/data/exercise_registry.dart`, `lib/screens/exercise_player_screen.dart`, `lib/widgets/stage/`)
| Exercise | Technique | Animated Stage |
|---|---|---|
| Box Breathing | 4-4-4-4 cycles | Expanding/contracting ring (`box_breathing_stage.dart`) |
| Grounding 5-4-3-2-1 | Sensory grounding | Sense orbs, ripples, motes (`grounding_stage.dart`) |
| Body Scan | Progressive body awareness | Body-node glow (`body_scan_stage.dart`) |
| Mindful Walking | Attentive walking meditation | Path/footstep scene (`mind_walking_stage.dart`) |

- One immersive player: step tracker, synced timer bar, animated stage, narration script with typewriter reveal, multilingual TTS.
- **Completion fires only when the exercise actually finishes** (last step done / TTS completion) — never on open. Timer/TTS sync is protected by generation tokens against double-advances.
- Completion overlay with stats (time, cycles, calm/focus scores, garden progress).

### 📓 Journaling (`lib/screens/journal_screen.dart`)
- Three gentle prompts: Positive / Challenge / Let Go.
- Saves to **SharedPreferences + Firestore** (`users/{uid}/journal`), marks the daily journal task complete, and grows the garden.

### 📅 Daily Routine (`lib/providers/daily_routine_provider.dart`)
- Auto-generates **exactly 5 tasks per day: 4 exercises + 1 journal entry**.
- Regenerates fresh on local date change; avoids repeating yesterday's exact set.

### 🌳 Garden Gamification (`lib/providers/garden_provider.dart`, `lib/widgets/garden_widget.dart`)
- Replaces a plain streak counter — see Section 5.

### 📈 Reports (`lib/screens/history_screen.dart`)
- Streak / activities / performance summary cards, weekly activity bar chart, mood-trend line chart, category pie chart, filterable session list (All / Tasks / Exercises / Calls / Chat). Real data only — no fake entries.

---

## 4. AI Working — Actual Request Flow

### Chat path
```
User types message
 └─ ChatProvider.sendMessage()                      (providers/chat_provider.dart)
     └─ SessionManager.sendMessage()                (services/session_manager.dart)
         ├─ saves user msg → Firestore users/{uid}/session/{sessionId}/messages
         └─ ApiChatService.sendMessage()            (services/api_chat_service.dart)
             ├─ builds system prompt (persona + memory + language rules)
             ├─ POST https://openrouter.ai/api/v1/chat/completions
             │      model: qwen/qwen-plus (hardcoded)
             └─ parses hidden tags from reply:
                 [DISTRESS_SCORE: X.X]  → exercise trigger if > 0.7
                 [SUGGESTED_EXERCISE: id] → inline popup
                 [SPEAK:true/false]      → auto TTS (Urdu) or silent (English)
     └─ reply saved → same Firestore messages subcollection
     └─ if [SPEAK:true] → flutter_tts speaks reply (locale ur-PK)
```

### Voice path
```
User speaks → speech_to_text (STT)
 └─ AudioCallProvider.handleRecognizedTranscript()
     ├─ SafetyDetector.evaluate() — crisis keywords?
     │    └─ YES → panic overlay + calming TTS + safetyFlag:true (Firestore)
     └─ NO → AudioCallService.callNova()           (services/audio_call_service.dart)
         ├─ POST OpenRouter chat/completions
         │      model: .env OPENROUTER_MODEL (qwen/qwen-plus)
         └─ reply → [SPEAK] tag stripped → TTS speaks (detected locale)
     └─ each turn saved → Firestore users/{uid}/chatMessages
     └─ call end → session summary → users/{uid}/sessionSummaries
                  + full transcript → users/{uid}/audioCallSessions
                  + history entry (category 'audio')
```

### Shared cross-session memory (`services/session_memory_service.dart`)
Chat and voice **share** the same memory: latest session summary + durable user facts (`users/{uid}/memory/userFacts`) are read before every AI call and merged back at session end — so NOVA never re-asks what it already knows, in either mode.

---

## 5. Garden Concept (replaces streak)

The garden is a 12-slot visual growth system driven by **real task completion**, not a counter.

**How it grows in code** (`garden_provider.growTree()`):
- **Exercise completed** (all steps finished in the player) → `+1 tree`
- **Journal entry saved** → `+1 tree`
- Daily routine tasks completing also feed growth through the same provider.
- `treeCount++` and `totalTrees++`; the new slot index is recorded for the growth highlight.
- **Full garden (12 trees)** → `gardenStreak++`, slots reset to 0 — a completed "garden cycle", not a daily login streak.

**Visual states** (`widgets/garden_widget.dart`):
- Empty slot → soft translucent circle with `+`
- Completed slot → static tree Lottie (`assets/animations/garden_tree_static.json`)
- Progress bar `treeCount/12` under the grid; header shows total trees grown + garden-cycle streak
- Growth celebration card after completing an activity (`garden_celebration_card.dart`)

**Persistence:** SharedPreferences instantly + Firestore `users/{uid}/garden` (cloud wins if greater — offline-friendly merge).

---

## 6. App Flow (as coded)

```
main.dart → AuthGate                                  (screens/auth_gate.dart)
 ├─ not logged in            → AuthScreen             (email/password sign-up & login)
 ├─ logged in, no onboarding → OnboardingScreen       (once per account, flag in SharedPreferences)
 └─ logged in + onboarded    → HomeScreen
                               ├─ 💬 ChatScreen          (NOVA text chat)
                               │    └─ 📞 → AiAudioCallScreen (switch to voice)
                               ├─ 🎙️ AiAudioCallScreen   (NOVA voice call)
                               ├─ 🧘 ExerciseScreen      (exercise catalog)
                               │    └─ ExercisePlayerScreen (any exercise)
                               ├─ 📅 RoutineScreen       (daily 5-task set)
                               │    └─ ExercisePlayerScreen (task exercises)
                               ├─ 📓 JournalScreen       (journaling)
                               ├─ ⚙️ SettingsScreen
                               │    └─ 📈 HistoryScreen  (Progress & History report)
                               └─ routine tasks on home cards → ExercisePlayerScreen
```

Session persistence: logged-in users return straight to Home on app restart; logout happens only via Settings.

---

## 7. Why People Use It / Benefits

- **Private** — all data lives under your own `users/{uid}`; accounts fully isolated; no social features.
- **Free to start** — the whole app is currently free; no paywall (tier limits planned, see Section 11).
- **Doctor-approved CBT techniques** — exercises and conversation behavior follow established CBT practice (breathing, grounding, body scan, behavioral activation) *(clinical review certification: planned)*.
- **Judgment-free** — NOVA never shames, blames, diagnoses, or labels.
- **Always available** — 24/7 companion that remembers you across sessions.
- **Your language** — Urdu (with voice) and English out of the box.

---

## 8. Safety & Ethics

**Currently implemented:**
- **Never diagnoses** — both system prompts explicitly instruct: *"Never assume or diagnose"*, *"Never reveal internal issue detection or scoring"*.
- **Crisis detection in voice calls** — 12 keyword patterns (self-harm, suicide ideation, …) trigger an immediate calm overlay, a grounding voice message, and a permanent `safetyFlag: true` entry in Firestore. Detection bypasses the AI entirely (hard-coded, cannot be prompt-injected).
- **Chat safety** — handled at prompt level (the model is instructed to stay calm, take it seriously, and encourage real-world help).

**Planned / not yet implemented** *(being honest — these are not in the code yet)*:
- In-app AI disclosure banner ("I'm an AI and may make mistakes").
- Helpline/emergency contact screen with one-tap call.
- "Book a real physical doctor" referral prompt.
- Flagged-issue tiering (trauma, eating/body concerns, substance use → coping-only + referral, never fully AI-handled).
- Data-usage explanation screen.

---

## 9. Technical Architecture

| Layer | Technology | Where in code |
|---|---|---|
| Framework | Flutter (Dart SDK ^3.11), Material 3 | `pubspec.yaml`, `main.dart` |
| State management | Provider (`ChangeNotifier`), 7 providers in `MultiProvider` | `lib/providers/*`, wired in `main.dart` |
| Backend | Firebase Auth (email/password) + Cloud Firestore | `firebase_options.dart`, `services/firestore_service.dart`, `services/firebase_chat_service.dart` |
| Local storage | **SharedPreferences** (per-user keys; Hive is NOT used) | all providers/services |
| AI — Chat | OpenRouter REST, model **`qwen/qwen-plus`** (hardcoded) | `services/api_chat_service.dart` |
| AI — Voice | OpenRouter REST, model from `.env` `OPENROUTER_MODEL` (currently `qwen/qwen-plus`) | `services/audio_call_service.dart` |
| STT | `speech_to_text` plugin, locale follows detected language (ur-PK / pa-IN / en-IN / en-US) | `services/speech_to_text_service.dart` |
| TTS | `flutter_tts` device voices, locale per detected language | `services/speech_to_text_service.dart` (`speak()`), `widgets/audio_player_widget.dart` |
| Charts | `fl_chart` | `screens/history_screen.dart` |
| Animations | Lottie + Flutter `AnimationController` | `assets/animations/`, `lib/widgets/stage/*` |
| Config | `.env` (API keys; loaded at startup in `main.dart` via `flutter_dotenv`) | `.env`, `main.dart` |

> Note: `.env` contains `TTS_MODEL=rapid-flash` and `YOUR_VOICE_API_KEY`, but **no code reads them yet** — current TTS uses on-device `flutter_tts` voices. Cloud TTS integration is planned.

---

## 10. Language Support

Handled by `services/language_detection_service.dart` — the **same** service drives both chat and voice:

| User input | Detection | NOVA replies | Voice |
|---|---|---|---|
| Urdu script (ا ب پ …) | `ur` | Simple Urdu script, 1–3 sentences, آپ respect | Auto-spoken (`ur-PK`) — in chat via `[SPEAK:true]`, always in calls |
| English or Roman Urdu ("aap kaise hain") | `en` / `hinglish` | English | Chat: silent (manual play button); calls: spoken `en-US`/`en-IN` |
| Punjabi (Gurmukhi) | `pa` | Punjabi | `pa-IN` voice |
| Hindi (Devanagari) | forced → `en` | English — **Hindi is never returned and both prompts say "NEVER use Hindi/Devanagari script"** | — |
| Mixed Urdu + English | Urdu wins | Urdu | Spoken |

Per-message auto-detection: chat (`chat_provider` → reply language saved per message) and per-utterance in calls (`audio_call_provider`), including STT locale switching.

---

## 11. Business Model (Freemium) — *planned*

> ⚠️ **Not yet enforced in code.** There is currently **no tier, quota, or session-counter logic anywhere in the app** — every user has full unlimited access. The table below is the target model for implementation.

| Tier | Duration | Chat Sessions | Call Sessions | Extras |
|---|---|---|---|---|
| **Free** | 1 month | 30 | 15 | — |
| **Basic** | 2 months | 60 | 35 | — |
| **Premium** | 5 months | Unlimited | Unlimited | Real psychiatrist doctor booking (future) |

Implementation notes (planned): monthly counters per `users/{uid}`, upgrade prompt when limits are reached, crisis flow must always bypass limits.

---

## 12. App Structure

```
PeaceMind-AI/
├── .env                          # OpenRouter API key + model (never commit)
├── firebase.json                 # Firebase project config
├── pubspec.yaml
├── assets/
│   ├── animations/               # garden_tree_static.json, mood lotties (happy/sad/meh/…)
│   ├── audio/                    # yappy.mp3
│   └── images/                   # splash.png, exercise covers, home/ backgrounds
├── android/ · ios/ · web/ · windows/
├── research/                     # clinical + personality research docs (reference only)
└── lib/
    ├── main.dart                 # entry: dotenv + Firebase init + MultiProvider + AuthGate
    ├── firebase_options.dart
    ├── data/                     # exercise step scripts & registry
    │   ├── exercise_registry.dart
    │   ├── box_breathing_data.dart · grounding_data.dart
    │   ├── body_scan_data.dart   · mind_walking_data.dart
    │   └── exercises.dart
    ├── logic/                    # audio_call_session_logic.dart (call state machine)
    ├── models/                   # user, routine, history, journal, exercise, call session
    ├── providers/                # auth, chat, audio_call, routine, daily_routine,
    │   │                         # journal, garden
    ├── screens/                  # auth_gate, auth, onboarding, home, chat,
    │                             # ai_audio_call, exercise (+player), routine,
    │                             # journal, history, settings, call_screen
    ├── services/                 # api_chat, audio_call, firebase_chat, session_manager,
    │                             # session_memory, language_detection, speech_to_text,
    │                             # nova_text_sanitizer, journal/history/garden services
    ├── theme/app_theme.dart
    └── widgets/                  # garden, exercise popup/completion, audio call UI,
                                    # panic overlay, stage/ (4 animated exercise stages)
```

---

**PeaceMind AI** — *Your space, your pace. Small steps are still progress.* 🌱
