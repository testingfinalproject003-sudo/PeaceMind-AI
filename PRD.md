# PeaceMind AI — Product Requirements Document

| Field | Value |
|---|---|
| **Document** | PRD (regenerated from actual codebase scan) |
| **Version** | 3.0 |
| **Date** | September 2026 |
| **Source of truth** | The code in `lib/` — this document describes what IS implemented, plus clearly-labeled **[PLANNED]** items for known gaps |

> Convention: everything unmarked below exists in code today. Anything not yet built is explicitly marked **[PLANNED]**.

---

## 1. Problem Statement & Vision (expanded)

### 1.1 Problem
Everyday emotional struggles — exam stress, breakups, burnout, loneliness, overthinking, low self-worth — affect millions, yet the vast majority never reach a therapist. Four structural barriers:

1. **Stigma** — seeking help is culturally read as weakness or "being crazy", especially in South Asia.
2. **Cost** — regular therapy is out of reach for students and low-income users.
3. **Privacy** — fear of family/social exposure, judgment, or permanent records.
4. **Access** — few professionals, long waitlists, urban concentration.

The result: people take **no step at all**. Their stress compounds silently.

### 1.2 Vision — "Mental First Aid"
PeaceMind AI is the step people take when they would otherwise take none. Like physical first aid it:
- **Stabilizes** — calms the user in the moment (inline guided exercises triggered from real distress).
- **Supports** — a 24/7 warm companion (NOVA) that remembers the user across chat and voice.
- **Tracks gently** — progress is visualized as a growing garden, never as a clinical score shown to the user.
- **Refers onward** — when red flags appear (crisis keywords), it interrupts everything and points to real help.

### 1.3 Non-negotiable principles
- **Never diagnose.** No labels, no conditions, no scores shown to the user.
- **Crisis always first.** Hard-coded keyword detection in voice calls bypasses the AI model entirely.
- **Privacy by isolation.** Every byte of user data lives under `users/{uid}` in Firestore and per-user keys locally.
- **Not a therapy replacement.** The app is a bridge, and says so.

---

## 3. Core Functions (expanded)

### 3.1 Chat AI (NOVA — text)

**Implemented in:** `screens/chat_screen.dart`, `providers/chat_provider.dart`, `services/session_manager.dart`, `services/api_chat_service.dart`

**Behavior (as coded):**
- Email/password user opens chat → session auto-created in Firestore (`users/{uid}/session/{sessionId}`), messages streamed in real time.
- Every user message → OpenRouter `chat/completions` (model `qwen/qwen-plus`) with a system prompt containing: persona rules, language rules, user profile name, cross-session memory.
- The model returns hidden tags with each reply:
  - `[DISTRESS_SCORE: 0.0–1.0]` — parsed out, never shown, drives exercise triggering.
  - `[SUGGESTED_EXERCISE: id]` — parsed out; if distress > 0.7 → inline exercise popup (3-minute cooldown; user can decline).
  - `[SPEAK:true|false]` — Urdu-script replies are auto-spoken via TTS (`ur-PK`); English replies stay silent with a manual play button.
- Quick-reply chips ("I'm feeling anxious", …) for low-effort starts.
- **End Session** flow: AI session summary generated (topics, insights, techniques, user facts, corrections) → stored to session summary + shared memory → History entry (category `chat`) with message count and last-user-message snippet.

**User story:** *As a user in distress at 2 AM, I want someone to talk to immediately, who notices I'm overwhelmed and gently offers a breathing exercise — without me having to ask or fill a form.*

**Acceptance criteria:**
- Onboarding never asks "what's wrong with you" — detection starts silently from the first message. ✅
- Distress > 0.7 + model-suggested exercise → popup appears inline mid-conversation, is declineable, respects a 3-min cooldown. ✅
- Urdu-script input → Urdu-script reply (1–3 sentences, آپ) + automatic voice. ✅
- Distress scores/tags never visible in the chat bubble (sanitizer strips them). ✅

**Data model:**
```
users/{uid}/session/{sessionId}            # status, createdAt
users/{uid}/session/{sessionId}/messages   # sender(user|nova), text, language, distressLevel, timestamp
users/{uid}/sessionSummaries/{sessionId}   # summary, updatedAt
users/{uid}/memory/userFacts               # facts[ ], updatedAt   ← shared with voice
```

### 3.2 NOVA — Voice Call

**Implemented in:** `screens/ai_audio_call_screen.dart`, `providers/audio_call_provider.dart`, `services/audio_call_service.dart`, `services/speech_to_text_service.dart`

**Behavior (as coded):**
- **Continuous VAD listening is the default** — mic auto-starts, auto-restarts on silence and after NOVA finishes speaking. Tap-to-speak is an explicit opt-in toggle (`toggleManualTapMode`).
- Per-utterance pipeline: STT → language detection → crisis check → NOVA API call (`.env` model) → `[SPEAK]` tag stripped → sanitizer → TTS in detected locale.
- Duplicate-utterance guard (`_lastSubmittedTranscript`) prevents double submissions.
- Web/STT-unavailable paths degrade gracefully with clear error states.
- **End Call:** AI summary (via same summarizer as chat) → shared `sessionSummaries` → user facts merged → full transcript saved → History entry (category `audio`) with duration, turn count, snippet.

**User story:** *As a user who finds typing exhausting when upset, I want to just talk — and be talked to — like a phone call.*

**Acceptance criteria:**
- Call starts listening automatically without any tap. ✅
- Reply language + TTS voice follow each utterance's detected language. ✅
- A failed API call shows "Network issue. Please try again." and recovers — never freezes on "Processing…". ✅
- Ending a call always persists summary + transcript, even if Firestore writes partially fail. ✅

**Data model:**
```
users/{uid}/chatMessages              # every voice turn {sessionId, text, role, source:'audio_call', safetyFlag?}
users/{uid}/audioCallSessions/{id}    # session snapshot + transcript[ {role,text,time} ]
users/{uid}/sessionSummaries/{id}     # shared cross-mode memory (chat AND voice)
```

### 3.3 Guided Exercises (4)

**Implemented in:** `data/exercise_registry.dart` + `data/*_data.dart` (step scripts), `screens/exercise_player_screen.dart`, `widgets/stage/*`

- Box Breathing, Grounding 5-4-3-2-1, Body Scan, Mindful Walking.
- One shared immersive player: animated stage per exercise, step tracker, timer bar, narration with typewriter reveal, multilingual TTS narration.
- **Completion integrity:** "done" fires only from `_finishSession()` — the last step actually finishing (TTS-completion driven with fallback timer). Opening an exercise never marks it complete.
- **Timer/TTS sync:** step advances are guarded by a generation token so a late TTS callback can never double-advance or desync the timer bar.
- Completion overlay: total time, cycles, calm/focus score rings, previous-vs-current comparison, garden progress, confetti.

**User story:** *As an overwhelmed user, I want the exercise to just run itself — voice guiding me, visuals pacing me — so I can't do it "wrong".*

**Acceptance criteria:**
- Exercise completes only when its steps actually finish. ✅
- Timer bar and narration stay in sync across pause/resume/TTS failure. ✅
- Completion → garden tree + history entry (category `exercise`). ✅

### 3.4 Journaling
`screens/journal_screen.dart`, `services/journal_service.dart` — Positive / Challenge / Let Go prompts; saves to `users/{uid}/journal` + SharedPreferences; completes the daily journal task; grows garden.

### 3.5 Daily Routine
`providers/daily_routine_provider.dart` — exactly **5 tasks/day (4 exercises + 1 journal)**; regenerated on local date change; no-repeat vs yesterday's set; exercise completion syncs back via a static id map.

### 3.6 Garden (see README §5 for mechanics)
12 slots; growth from real completions; full garden → cycle streak++ and slots reset; SharedPreferences + Firestore (`users/{uid}/garden`).

### 3.7 Reports & History
`screens/history_screen.dart` — real data only: streak/activities/performance cards, 7-day activity bar chart, mood-trend line, category pie, filterable list (All/Tasks/Exercises/Calls/Chat).

---

## 6. App Flow (expanded)

### 6.1 Navigation graph (as coded)
```
main.dart
 └─ AuthGate (screens/auth_gate.dart)
     ├─ FirebaseAuth.currentUser == null → AuthScreen (sign-up / login)
     ├─ logged in + onboardingCompleted == false → OnboardingScreen (once; flag persisted)
     └─ logged in + onboarded → HomeScreen
          ├─ ChatScreen ──(📞 icon)──> AiAudioCallScreen
          ├─ AiAudioCallScreen (direct from home)
          ├─ ExerciseScreen ──> ExercisePlayerScreen(exercise)
          ├─ RoutineScreen ──> ExercisePlayerScreen(task.exerciseInfo)
          ├─ JournalScreen
          ├─ home routine cards ──> ExercisePlayerScreen
          └─ SettingsScreen ──> HistoryScreen (Report)
```

### 6.2 State & lifecycle rules
- Returning users skip auth and onboarding (persisted session + flag).
- Logout only via Settings → providers rebind to the next user's data.
- Garden and routine load local-first (instant UI), then merge cloud in background with 5s timeout.

### 6.3 Session lifecycle (both channels)
open → messages/turns appended live → end → AI summary → shared memory merge → history entry → providers reset for the next session.

**[PLANNED]** Post-session report screen shown to the user (mood before/after, one insight, one next step) — summary data exists today but goes to memory/History only.

---

## 9. Technical Architecture (expanded)

### 9.1 Stack (actual)
| Layer | Choice | Evidence |
|---|---|---|
| UI | Flutter, Material 3, custom glassmorphism theme | `theme/app_theme.dart` |
| State | Provider — 7 ChangeNotifiers in MultiProvider | `main.dart` |
| Auth | Firebase Auth email/password | `providers/auth_provider.dart` |
| Cloud DB | Cloud Firestore | all services |
| Local DB | **SharedPreferences only** (no Hive in pubspec) | providers |
| AI gateway | OpenRouter REST over `http` | `api_chat_service.dart`, `audio_call_service.dart` |
| Chat model | `qwen/qwen-plus` (hardcoded) | `api_chat_service.dart` |
| Voice model | `.env OPENROUTER_MODEL` (currently `qwen/qwen-plus`) | `audio_call_service.dart` |
| STT | `speech_to_text`, locale per detected language | `speech_to_text_service.dart` |
| TTS | `flutter_tts` device voices (ur-PK / pa-IN / en-IN / en-US) | `speech_to_text_service.dart` |
| Charts | `fl_chart` | `history_screen.dart` |
| Anim | Lottie + AnimationController | `widgets/stage/*` |
| Config | `.env` via flutter_dotenv, loaded before Firebase init | `main.dart` |

### 9.2 Data flow guarantees (as coded)
- **Shared memory:** `SessionMemoryService` is the single cross-channel memory (sessionSummaries + userFacts), read before every AI call in both chat and voice.
- **Non-fatal persistence:** every Firestore write in the call path is wrapped — a cloud failure never breaks the conversation.
- **Sanitization:** `NovaTextSanitizer` strips emojis/markdown/symbols before text is displayed or spoken.
- **Error recovery:** API timeouts (30s chat / 60s voice) return null → visible error state, never an infinite spinner.

### 9.3 [PLANNED] items
- Cloud TTS via `TTS_MODEL=rapid-flash` / `YOUR_VOICE_API_KEY` (present in `.env`, **no code reads them**).
- Confirmed clinical review of prompts/exercise scripts.
- Alibaba Cloud Enclave for sensitive inference.

---

## 11. Business Model — Freemium (expanded)

> ⚠️ **Current status: [PLANNED] — zero enforcement in code.** No tier field, no counters, no gating, no upgrade screen. All users have unlimited access today. The requirements below are the implementation spec.

### 11.1 Tiers

| Tier | Duration | Chat Sessions | Call Sessions | Extras |
|---|---|---|---|---|
| **Free** | 1 month | 30 | 15 | — |
| **Basic** | 2 months | 60 | 35 | — |
| **Premium** | 5 months | Unlimited | Unlimited | Real psychiatrist doctor booking **[PLANNED — future]** |

### 11.2 Functional requirements (to build)
- `users/{uid}` gains `subscriptionTier: free|basic|premium` and a monthly usage doc `{chatSessions, callSessions, periodStart}`.
- Counters increment on session **end** (a session abandoned at 0 messages must not consume quota).
- Gate at limit: friendly upgrade sheet at the *start* of a new session — never mid-conversation.
- **Edge case — crisis bypass:** if `SafetyDetector` triggers, or a distress score > 0.7 arrives, tier limits are ignored entirely for that session. A user in crisis must never hit a paywall.
- **Edge case — period rollover:** counters reset on period expiry (1/2/5 months), not calendar month.
- **Edge case — offline:** quota check must not block an offline/failed read; degrade to allow-with-log, reconcile later.

### 11.3 User stories
- *As a free user, I want to see my remaining sessions before I'm cut off* → quota chip in chat/call entry points **[PLANNED]**.
- *As a paying user, my limits must lift instantly after upgrade* → tier read at session start.

---

## Appendix A — Edge cases already handled in code
| Edge case | Handling |
|---|---|
| Crisis keywords in voice call | Hard-coded detector → overlay + calming TTS + `safetyFlag: true` (bypasses AI entirely) |
| AI/ network failure | Timeout → visible error → state reset; never stuck "Processing…" |
| Duplicate STT utterance | `_lastSubmittedTranscript` guard |
| Exercise timer vs TTS desync | Generation tokens; completion only from real finish |
| Offline garden/history | Local-first reads; cloud merge takes the greater value |
| Model omits `[SPEAK]` tag | Client-side fallback: Urdu-script input ⇒ speak |
| Free-tier model retired (404) | `.env` model is configurable without code change |

## Appendix B — Known gaps ([PLANNED], priority order)
1. AI disclosure banner ("AI companion, may make mistakes") — none in UI today.
2. Helpline / emergency screen + "contact a real doctor" prompt in crisis flow.
3. Tier-limit enforcement (Section 11).
4. User-facing post-session report screen.
5. Flagged-issue tiering (trauma / eating / substance → coping-only + referral).
6. Cloud TTS (rapid-flash) integration.
7. Doctor booking (Premium).
8. Chat-path hard crisis detection (currently prompt-level only; voice has the hard detector).
