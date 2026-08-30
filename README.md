# PeaceMind AI

> A private, judgment-free AI companion for everyday mental and emotional support.  
> **Not a replacement for licensed therapy or medical diagnosis.**

---

## Table of Contents
- [Overview](#overview)
- [Core Principles](#core-principles)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Key Features](#key-features)
- [Exercise Catalog](#exercise-catalog)
- [Exercise System](#exercise-system)
- [Crisis Protocol](#crisis-protocol)
- [Privacy & Security](#privacy--security)
- [AI Data Agreement](#ai-data-agreement)
- [AI Persona Guidelines](#ai-persona-guidelines)
- [Localization](#localization)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)
- [Emergency Resources](#emergency-resources)

---

## Overview

PeaceMind AI is a Flutter-based mobile application that provides 24/7 emotional support through AI-powered chat, voice conversations, and **6 guided therapeutic exercises**. Built with a Firebase backend, the app acts as a coping-support layer — a bridge to professional care, not a replacement for it.

The app features a **unified exercise player** that supports both **fully scripted** and **AI-coached** therapeutic sessions within the same consistent interface.

---

## Core Principles

1. **Privacy First** — End-to-end encryption, anonymous usage options, no third-party trackers
2. **Your Data, Your Benefit** — AI uses your data ONLY to personalize your experience. Never for model training. Never sold.
3. **Crisis Always First** — Any indication of self-harm or danger immediately triggers emergency resources
4. **Never Diagnoses** — The AI supports and encourages; it never labels users with conditions
5. **Scoring Stays Hidden** — Background wellbeing signals are never shown to users as tests or numbers
6. **Warm & Respectful** — Every interaction feels like a caring person, never robotic or cold
7. **A Bridge, Not a Replacement** — The app actively encourages users toward real professional care when needed
8. **One UI, Six Exercises** — All exercises share the same calming, immersive player interface

---

## Tech Stack

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform mobile framework (iOS & Android) |
| **Dart** | Programming language |
| **BLoC / Riverpod** | State management |
| **Hive / SQLite** | Local data caching |
| **flutter_secure_storage** | Secure token & key storage |
| **Lottie** | Animations |
| **just_audio** | Audio playback for exercise TTS |

### Backend
| Technology | Purpose |
|---|---|
| **Firebase Authentication** | Anonymous, email, social login |
| **Cloud Firestore** | Real-time database for messages, user data, exercise progress |
| **Firebase Cloud Functions** | AI proxy API, data export, admin logic, exercise content delivery |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Crashlytics** | Error tracking & analytics |
| **Firebase ML Kit** | On-device NLP & speech recognition |

### AI / ML
| Technology | Purpose |
|---|---|
| **OpenAI GPT-4 / Claude** | Conversational AI + exercise coaching (via secure proxy) |
| **Custom NLP Pipeline** | Crisis detection & content moderation |
| **Cloud Text-to-Speech** | AI voice responses + exercise narration |
| **Cloud Speech-to-Text** | Voice input transcription |

### DevOps & Security
| Technology | Purpose |
|---|---|
| **GitHub Actions / Codemagic** | CI/CD pipeline |
| **OWASP Mobile Security** | Security standards compliance |
| **AES-256 / TLS 1.3** | Data encryption |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App (iOS/Android)              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  Splash  │  │  Onboard │  │   Home   │  │     Chat     │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘ │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  Voice   │  │ Exercise │  │  Crisis  │  │   Library    │ │
│  │          │  │  Player  │  │          │  │              │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS / gRPC
┌──────────────────────────▼──────────────────────────────────┐
│                    Firebase Backend                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │     Auth     │  │  Firestore   │  │ Cloud Functions  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │     FCM      │  │  Crashlytics │  │   Cloud Storage  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│              AI Services (via Cloud Functions Proxy)        │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │   LLM API        │  │  Crisis NLP      │                 │
│  │ (GPT-4 / Claude) │  │  (Custom Model)  │                 │
│  └──────────────────┘  └──────────────────┘                 │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │  Text-to-Speech  │  │ Speech-to-Text   │                 │
│  └──────────────────┘  └──────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow
1. User input (text/voice/exercise) → Flutter app
2. Input encrypted client-side → sent to Cloud Functions
3. Cloud Functions proxy to AI services (anonymized session IDs)
4. AI response + crisis analysis returned
5. If crisis detected → immediate Crisis Intervention Screen
6. Response decrypted and displayed to user
7. Conversation / exercise progress stored encrypted in Firestore

---

## Getting Started

### Prerequisites
- Flutter SDK >= 3.19.0
- Dart >= 3.0.0
- Firebase CLI
- Android Studio / Xcode
- OpenAI API key (or Claude API key)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/peacemind-ai.git
cd peacemind-ai

# Install dependencies
flutter pub get

# Configure Firebase
firebase login
flutterfire configure

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys and Firebase config

# Run code generation (if using freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Variables
Create a `.env` file in the project root:

```env
# Firebase
FIREBASE_API_KEY=your_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id

# AI API (via Cloud Functions — do NOT store in client code)
# These should be in Firebase Functions environment
OPENAI_API_KEY=your_openai_key
CRISIS_NLP_ENDPOINT=your_crisis_endpoint

# Feature Flags
ENABLE_VOICE=true
ENABLE_BIOMETRIC_AUTH=true
ENABLE_AI_COACHING=true
ENABLE_ANALYTICS=false
```

---

## Project Structure

```
peacemind-ai/
├── android/                    # Android-specific config
├── ios/                        # iOS-specific config
├── lib/
│   ├── main.dart               # Entry point
│   ├── app.dart                # MaterialApp configuration
│   ├── config/                 # Routes, themes, constants
│   ├── core/                   # Utilities, extensions, errors
│   ├── data/                   # Repositories, data sources
│   ├── domain/                 # Entities, use cases
│   ├── presentation/           # UI layer
│   │   ├── splash/
│   │   ├── onboarding/         # No skip button — all screens mandatory
│   │   ├── auth/
│   │   ├── home/
│   │   ├── chat/
│   │   ├── voice/
│   │   ├── exercise/           # Unified player + library (6 exercises)
│   │   ├── crisis/
│   │   ├── resources/
│   │   ├── settings/
│   │   ├── history/
│   │   └── widgets/            # Shared UI components
│   └── services/               # Firebase, AI API, local storage, TTS
├── functions/                  # Firebase Cloud Functions
│   ├── src/
│   │   ├── ai-proxy/           # LLM API proxy (chat + coaching)
│   │   ├── crisis-detection/   # Crisis NLP pipeline
│   │   ├── data-export/        # GDPR/data export
│   │   ├── moderation/         # Content moderation
│   │   └── exercise-content/   # Scripted exercise delivery
│   └── package.json
├── assets/
│   ├── images/                 # App images
│   ├── animations/             # Lottie files
│   └── exercise_scripts/       # 6 exercise JSON scripts
├── test/                       # Unit & widget tests
├── integration_test/           # E2E tests
├── l10n/                       # Localization files (ARB)
└── pubspec.yaml
```

---

## Key Features

### 🤖 AI Companion
- **Text Chat:** Real-time, context-aware conversations with warm, respectful tone
- **Voice Mode:** Speech-to-text input and AI voice responses
- **Multi-Language:** Supports 15+ languages with automatic detection
- **Context Memory:** AI remembers last 20 messages for continuity
- **Exercise Recommendations:** AI suggests relevant exercises based on conversation context

### 🧘 Unified Exercise Player
All 6 exercises share the **same immersive UI** — only the content changes:

| Exercise | Visual | Guidance Mode | Duration |
|---|---|---|---|
| **Box Breathing & Grounding** | Expanding square synced to breath | Scripted or AI-Coached | 5–10 min |
| **Release Tension & Acceptance** | Body heat-map red→gold fade | Scripted or AI-Coached | 10–15 min |
| **Cognitive Reframing** | Thought bubbles dark→light transform | Scripted or AI-Coached | 8–12 min |
| **Mindful Walking** | Path/footstep animation | Scripted or AI-Coached | 10–20 min |
| **Body Scan** | Anatomical body with scanning beam | Scripted or AI-Coached | 15–20 min |
| **STOP Skill** | Four-quadrant compass/stoplight | Scripted or AI-Coached | 3–5 min |

**Shared UI Components:**
- Progress tracker (step dots)
- Timer bar (step + total time)
- Visual stage (pluggable visualizer)
- Script panel with typing animation
- Play / Pause / Next / Previous / Mute controls
- Voice wave animation during TTS
- Session completion overlay with stats & confetti

### 🛡️ Crisis Safety
- **Real-Time Detection:** NLP analysis of every user input for self-harm/danger indicators
- **Immediate Response:** Non-dismissible crisis screen with emergency numbers
- **Localized Resources:** Automatic country-based hotline detection
- **Grounding Tools:** Built-in breathing exercises and grounding techniques

### 🔒 Privacy & Anonymity
- **Anonymous Mode:** Use the app without email or personal information
- **End-to-End Encryption:** All messages encrypted at rest and in transit
- **No Third-Party Trackers:** No ads, no analytics SDKs, no data selling
- **User Control:** Full data export and account deletion capabilities
- **AI Data Agreement:** Users explicitly consent to AI using their data ONLY for their benefit

### 🌉 Professional Bridge
- **Resource Directory:** Vetted mental health professionals and hotlines
- **Educational Content:** When and how to seek professional help
- **Conversation Export:** Optional encrypted summaries for sharing with therapists
- **Exercise History Export:** Share exercise patterns with therapists (opt-in)

---

## Exercise Catalog

### 1. Box Breathing and Grounding
> *Calm your nervous system with rhythmic breathing*

- **Category:** Calm / Anxiety
- **Duration:** 5–10 minutes
- **Visual:** Expanding/contracting square synced to 4-4-4-4 breath cycle
- **Steps:** Inhale (4s) → Hold (4s) → Exhale (4s) → Hold (4s), 6–10 cycles
- **AI Coaching:** Adapts hold duration; suggests grounding cues ("Feel your feet on the floor")
- **Best For:** Acute anxiety, panic moments, pre-sleep wind-down

### 2. Release Tension and Acceptance Emotion
> *Let go of what you're holding inside*

- **Category:** Emotional Release
- **Duration:** 10–15 minutes
- **Visual:** Body heat-map with tension points glowing red → fading to warm gold
- **Steps:** Scan body for tension → breathe into tight areas → visualize dissolving → acceptance affirmation
- **AI Coaching:** Identifies emotional themes from conversations; guides targeted release
- **Best For:** Suppressed emotions, grief, anger, physical stress

### 3. Cognitive Reframing
> *Shift your perspective with compassion*

- **Category:** Cognitive / Thought Work
- **Duration:** 8–12 minutes
- **Visual:** Thought bubbles appearing and transforming (dark → light, jagged → soft)
- **Steps:** Identify negative thought → examine evidence → generate alternative → practice compassionate reframe
- **AI Coaching:** Uses conversation context for personalized reframes; Socratic questions
- **Best For:** Negative self-talk, catastrophizing, rumination

### 4. Mindful Walking
> *Find peace in gentle movement*

- **Category:** Movement / Active
- **Duration:** 10–20 minutes
- **Visual:** Gentle path/footstep animation; optional outdoor photo backdrop
- **Steps:** Stand still → feel weight shift → slow steps → notice heel-to-toe → sync breath with pace → pause and observe
- **AI Coaching:** Adjusts pace guidance based on energy level; suggests observation prompts
- **Best For:** Restlessness, low energy, need for gentle movement
- **Note:** Audio-only friendly — designed for eyes-open, mobile use

### 5. Body Scan
> *Journey through your body with awareness*

- **Category:** Relaxation / PMR
- **Duration:** 15–20 minutes
- **Visual:** Anatomical body diagram with scanning beam and glowing joints
- **Steps:** Toes → feet → legs → hips → stomach → chest → hands → arms → shoulders → neck → face → whole body
- **AI Coaching:** Lingers on areas user historically reports tension; adjusts scan speed
- **Best For:** Deep relaxation, sleep preparation, chronic tension

### 6. STOP Skill
> *Pause before you react*

- **Category:** Crisis / Impulse Control
- **Duration:** 3–5 minutes
- **Visual:** Four-quadrant compass or stoplight animation
- **Steps:** **S**top → **T**ake a breath → **O**bserve (body, thoughts, feelings) → **P**roceed mindfully
- **AI Coaching:** Asks what triggered the impulse; guides observation without judgment
- **Best For:** Urge surfing, emotional overwhelm, impulse control, crisis prevention

---

## Exercise System

### Scripted Mode
- Pre-written therapeutic scripts for all 6 exercises stored locally or fetched from Firestore
- Available in all supported languages
- Deterministic playback with fixed timing
- Works fully offline
- Content reviewed by licensed mental health professionals

### AI-Coached Mode
- AI generates personalized guidance in real-time
- Adapts pacing based on user's mood and responsiveness
- Can respond to voice input during exercise ("Can we slow down?")
- Uses ONLY user's own data (mood history, conversation context, exercise completion)
- **Never uses external data sources or user data for model training**

### Switching Modes
Users can switch from AI-coached to scripted mode mid-session without losing progress. If network is lost during AI-coached mode, the app gracefully falls back to scripted content.

### Adding a New Exercise
1. Create exercise JSON following the schema in `assets/exercise_scripts/schema.json`
2. Add translations in `l10n/exercises/`
3. Build visualizer in `lib/presentation/exercise/visualizers/`
4. Register in Firestore `exercises` collection
5. No UI changes needed — unified player handles all exercises

---

## Crisis Protocol

> ⚠️ **CRITICAL:** The crisis intervention system is the highest-priority feature in PeaceMind AI.

### Trigger Conditions
The crisis screen activates automatically when user input contains:
- Intent to self-harm or suicide
- Intent to harm others
- Severe crisis language (custom NLP model + keyword detection)

### User Experience
1. **Immediate Overlay:** Crisis screen appears within 500ms of detection
2. **Cannot Be Dismissed:** Back button and swipe gestures are disabled
3. **Supportive Messaging:** "You are not alone. Help is available right now."
4. **One-Tap Help:** Direct call/text links to emergency services and crisis hotlines
5. **Post-Crisis Care:** Gentle return to app with follow-up resources

### For Developers
- Crisis detection runs on both client (lightweight) and server (comprehensive)
- All crisis events are logged securely with anonymized session IDs
- The crisis flow is **exempt from A/B testing** — never experiment on safety features
- Hotline numbers are verified quarterly

---

## Privacy & Security

### Data Handling
| Data Type | Storage | Encryption | Retention |
|---|---|---|---|
| Messages | Firestore | AES-256 | Until user deletes |
| User Profile | Firestore | AES-256 | Until account deletion |
| Mood Entries | Firestore | AES-256 | Until account deletion |
| Exercise Progress | Firestore | AES-256 | Until account deletion |
| Crisis Events | Firestore | AES-256 | 7 years (legal) |
| Auth Tokens | Local (Secure Storage) | Platform keychain | Session-based |

### Security Measures
- Firebase Security Rules strictly control data access
- All AI API calls proxied through Cloud Functions (API keys never in client)
- OWASP Mobile Top 10 compliance
- Regular penetration testing
- Clinical review of all AI-generated content guidelines

### Wellbeing Scoring
- Background wellbeing signals are calculated server-side
- **Scores are NEVER displayed to users** — they inform AI context and exercise recommendations only
- Aggregated, anonymized data may be used for app improvement

---

## AI Data Agreement

Before any AI personalization begins, users must explicitly agree to the **AI Data Use Agreement** during onboarding (no skip option):

### What Users Agree To
- ✅ AI analyzes their conversations, mood entries, and exercise progress **only to personalize support**
- ✅ Data is used **solely for their benefit** — better responses, relevant exercises, timely suggestions
- ✅ **No data is used to train or fine-tune external AI models**
- ✅ **No data is sold, shared, or monetized**
- ✅ They can revoke this agreement at any time in Settings

### What Happens If Revoked
- AI personalization stops immediately
- App continues to function with generic scripted content
- Previous data remains encrypted and accessible to the user
- No data is deleted upon revocation (unless user requests full deletion)

### For Developers
- AI Agreement acceptance is stored with version number and timestamp
- App must check agreement status before enabling AI features
- Agreement updates must prompt re-acceptance on next app open
- All AI data usage must be auditable

---

## AI Persona Guidelines

The AI must adhere to these principles in every interaction:

1. **Supportive, Not Clinical** — Use warm, conversational language. Avoid medical jargon.
2. **Never Diagnose** — Do not label users with conditions ("depression", "anxiety disorder", etc.)
3. **Never Prescribe** — Do not suggest medication, dosage, or specific treatments
4. **Encourage Professional Help** — For severe or persistent issues, always suggest speaking to a professional
5. **Person-First Language** — "You are experiencing" not "You are"
6. **Culturally Aware** — Respect the user's cultural and linguistic context
7. **Crisis-Ready** — If user expresses self-harm, immediately transition to crisis protocol
8. **Exercise-Aware** — Suggest relevant exercises naturally, never forcefully

### Example Tone
> ❌ **Wrong:** "It sounds like you have generalized anxiety disorder."
> ✅ **Right:** "It sounds like you've been carrying a lot of worry lately. That can feel really heavy. Would a breathing exercise help right now?"

---

## Localization

PeaceMind AI supports 15+ languages at launch:

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Portuguese (pt)
- Italian (it)
- Dutch (nl)
- Russian (ru)
- Chinese Simplified (zh)
- Japanese (ja)
- Korean (ko)
- Arabic (ar) — RTL support
- Hindi (hi)
- Turkish (tr)
- Polish (pl)
- Urdu (ur) — RTL support
- Punjabi (pa)

### Adding a New Language
1. Add ARB file in `l10n/`
2. Add exercise scripts in `l10n/exercises/`
3. Run `flutter gen-l10n`
4. Update `supportedLocales` in `app.dart`
5. Verify RTL layout if applicable

---

## Testing

### Test Pyramid
```
    /\
   /  \     E2E Tests (integration_test/)
  /----\
 /      \   Widget Tests (test/presentation/)
/--------\
           Unit Tests (test/domain/, test/data/)
```

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/presentation/

# E2E tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Crisis flow simulation (manual)
# 1. Launch app
# 2. Navigate to chat
# 3. Type: "I want to hurt myself"
# 4. Verify crisis screen appears within 500ms

# Exercise player test (manual)
# 1. Launch app
# 2. Go to Exercise Library
# 3. Start any of the 6 exercises
# 4. Verify unified UI loads: tracker, timer, stage, script, controls
# 5. Switch between scripted and AI-coached modes
# 6. Verify completion overlay with stats
```

### Critical Test Scenarios
- [ ] Crisis detection triggers on explicit self-harm language
- [ ] Crisis detection triggers on implicit/vague crisis language
- [ ] Messages encrypt and decrypt correctly
- [ ] Anonymous user can use full app features
- [ ] Offline mode caches messages and exercises, syncs on reconnect
- [ ] Account deletion removes all user data
- [ ] AI never generates diagnostic language
- [ ] Voice transcription handles background noise
- [ ] **All 6 exercises render correctly in unified player**
- [ ] **AI-coached mode falls back to scripted on network loss**
- [ ] **AI Agreement must be accepted before AI features activate (no skip)**
- [ ] **Revoking AI Agreement immediately disables personalization**

---

## Deployment

### Pre-Release Checklist
- [ ] All P0 tasks complete
- [ ] Crisis protocol tested by licensed mental health professional
- [ ] Security audit passed (OWASP Mobile)
- [ ] Legal review of Terms of Service, Privacy Policy, and **AI Data Agreement**
- [ ] Hotline numbers verified for all supported countries
- [ ] Accessibility audit passed (WCAG 2.1 AA)
- [ ] Load testing completed (10k concurrent users)
- [ ] **All 6 exercise scripts reviewed by clinical advisor**
- [ ] App store assets prepared (screenshots, descriptions, age rating)

### Release Channels
```
Development → Staging → Internal Testing → Closed Beta → Open Beta → Production
```

### App Store Submission
- **Age Rating:** 17+ (Mature themes, crisis content)
- **Content Warnings:** Mental health, crisis resources
- **Privacy Nutrition Label:** Data linked to user (encrypted), no third-party sharing
- **AI Disclosure:** App uses AI for personalization; data not used for model training

---

## Contributing

We welcome contributions that align with our mission. Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Special Considerations
- **Crisis Features:** Any changes to crisis detection or intervention flows require review by a licensed mental health professional
- **AI Prompts:** All system prompt changes must be reviewed for safety and tone
- **Exercise Scripts:** New scripted content must be reviewed by a clinical advisor
- **Privacy:** Never introduce tracking, analytics, or data sharing without explicit user consent
- **Accessibility:** All UI changes must maintain screen reader and high-contrast support
- **AI Agreement:** Any changes to AI data usage require legal review and version bump
- **Onboarding:** Never add a skip button — all onboarding screens are mandatory for legal and safety compliance

### Reporting Security Issues
Please email security@peacemind.ai with encrypted details. Do not open public issues for security vulnerabilities.

---

## License

PeaceMind AI is licensed under the [Apache License 2.0](LICENSE).

**Important:** This software is provided as-is for emotional support purposes. It is not a medical device and should not be used as a substitute for professional mental health care.

---

## Emergency Resources

If you or someone you know is in crisis, help is available immediately:

| Country | Resource | Contact |
|---|---|---|
| **United States** | 988 Suicide & Crisis Lifeline | Call or text **988** |
| **United States** | Crisis Text Line | Text **HOME** to **741741** |
| **United Kingdom** | Samaritans | Call **116 123** |
| **Canada** | Talk Suicide Canada | Call **1-833-456-4566** |
| **Australia** | Lifeline Australia | Call **13 11 14** |
| **India** | AASRA | Call **91-9820466726** |
| **International** | Befrienders Worldwide | [befrienders.org](https://www.befrienders.org) |
| **Emergency** | Local Emergency Services | Call your local emergency number |

**If you are in immediate danger, call your local emergency number right away.**

---

<div align="center">

**PeaceMind AI** — *You are not alone.*

peacemind.support@gmail.com

</div>
