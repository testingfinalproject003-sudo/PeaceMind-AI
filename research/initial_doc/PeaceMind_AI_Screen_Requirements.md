# PeaceMind AI — Screen-by-Screen Requirements Document

**Version:** 2.2  
**Date:** August 2026  
**Based on:** PeaceMind AI PRD v2.0 + Exercise UI Unification + AI Data Agreement + Specific Exercise Catalog  
**Platform:** Flutter (Frontend) + Firebase (Backend)  

---

## Table of Contents
1. [Splash / Launch Screen](#1-splash--launch-screen)
2. [Onboarding Flow](#2-onboarding-flow)
3. [Authentication](#3-authentication-screen)
4. [Home Dashboard](#4-home-dashboard)
5. [AI Chat Interface](#5-ai-chat-interface)
6. [AI Voice Interface](#6-ai-voice-interface)
7. [Crisis Intervention Screen](#7-crisis-intervention-screen)
8. [Exercise Player (Unified UI)](#8-exercise-player-unified-ui)
9. [Exercise Library / Discovery](#9-exercise-library--discovery)
10. [Professional Care Bridge](#10-professional-care-bridge)
11. [Settings & Privacy Center](#11-settings--privacy-center)
12. [Conversation History](#12-conversation-history--journal)
13. [Mood Check-in](#13-mood-check-in-modal)
14. [Admin Dashboard (Web)](#14-admin-dashboard-web)

---

## 1. Splash / Launch Screen

### Purpose
Establish brand trust, initialize core services, and route users based on authentication and onboarding state.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| SPL-01 | Display PeaceMind AI logo, tagline ("Your private space to feel heard"), and calming background animation | P0 |
| SPL-02 | Initialize Firebase Core, Auth, Firestore, and Crashlytics in parallel | P0 |
| SPL-03 | Check local auth state; route to Onboarding (first launch), Home (authenticated), or Login (logged out) | P0 |
| SPL-04 | Display loading indicator if initialization exceeds 1.5 seconds | P1 |
| SPL-05 | Max total splash duration: 3 seconds before forced navigation | P1 |

### Non-Functional Requirements
- Cold start time ≤ 2.5 seconds on mid-tier Android/iOS devices
- All network calls during splash must be non-blocking with timeouts

### UI/UX Requirements
- Calming color palette (soft blues, warm neutrals) — no clinical whites
- No red, urgent, or alarmist colors
- Accessibility: Screen reader announces "PeaceMind AI is loading"

### Security & Privacy
- No PII logged during initialization
- Firebase config must use environment-specific keys

---

## 2. Onboarding Flow

### Purpose
Build trust, set expectations, obtain informed consent, and educate users about the app's limitations, crisis protocols, and **how their data is used by AI solely for their benefit**.

### Sub-Screens
2A. Welcome Screen  
2B. Privacy Promise Screen  
2C. **AI & Data Agreement Screen** *(NEW)*  
2D. Medical Disclaimer Screen  
2E. Crisis Resources Info Screen  
2F. Informed Consent Screen  

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| ONB-01 | **Welcome:** Display value proposition (24/7, judgment-free, multi-language, voice + chat, guided exercises) with illustration | P0 |
| ONB-02 | **Privacy Promise:** Explain end-to-end encryption, anonymous usage option, data retention policy, and Firebase security | P0 |
| ONB-03 | **AI & Data Agreement:** Clear explanation that AI analyzes user data (conversations, mood, exercise progress) **ONLY to personalize support and coaching for the user's benefit**. No data is used to train external models. No data is sold or shared. User must explicitly agree. | P0 |
| ONB-04 | **Disclaimer:** Clear, bold statement: "PeaceMind AI is not a replacement for licensed therapy or medical diagnosis. It is a coping-support companion only." User must scroll to bottom | P0 |
| ONB-05 | **Crisis Info:** Explain that the app detects crisis language and will immediately offer real emergency resources | P0 |
| ONB-06 | **Consent:** Checkbox + explicit button: "I understand and agree to the Terms of Service, Privacy Policy, and AI Data Use Agreement" | P0 |
| ONB-07 | Swipeable carousel with progress dots; back navigation allowed on all screens | P1 |
| ONB-08 | Language selector available from Screen 2A (defaults to device locale) | P1 |
| ONB-09 | Onboarding completion state persisted locally and in Firestore | P0 |
| ONB-10 | AI Agreement acceptance timestamp and version stored in Firestore for audit | P0 |

### UI/UX Requirements
- Copy tone: Warm, respectful, encouraging — never robotic or clinical
- Typography: Readable sans-serif, minimum 16px body text
- Illustrations: Diverse, inclusive, calming imagery (no clinical/stereotypical mental health icons)
- **AI & Data Agreement screen:** Use reassuring visuals (shield, lock, heart icons). Emphasize "for your benefit only" messaging. No legal jargon.
- Crisis Info screen must use supportive, non-alarmist language
- **No skip button on any onboarding screen** — all screens must be viewed and acknowledged

### Edge Cases
- User force-quits during onboarding → resume at last completed screen
- No internet connection → allow onboarding completion, sync consent state later
- AI Agreement updated in future → prompt user to re-accept on next app open

---

## 3. Authentication Screen

### Purpose
Provide secure, private access with minimal friction and maximum anonymity.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| AUTH-01 | **Sign Up:** Email + password with Firebase Auth; email verification required | P0 |
| AUTH-02 | **Anonymous Sign-In:** "Continue Anonymously" as primary CTA; account can be linked to email later | P0 |
| AUTH-03 | **Social Login:** Optional Google Sign-In (Apple Sign-In on iOS) | P1 |
| AUTH-04 | **Biometric Login:** Fingerprint / Face ID toggle after first successful login | P1 |
| AUTH-05 | No requirement for real name, phone number, or any PII | P0 |
| AUTH-06 | Password reset via email link | P0 |
| AUTH-07 | Session management: Auto-logout after 7 days of inactivity (configurable) | P1 |
| AUTH-08 | Rate limiting on login attempts (Firebase built-in) | P0 |

### Security & Privacy
- Passwords: Minimum 8 chars, 1 uppercase, 1 number (Firebase Auth enforcement)
- Anonymous users must be warned about data loss risk if app is uninstalled before linking
- All auth tokens stored securely via flutter_secure_storage

### UI/UX Requirements
- Clean, minimal form design
- Error messages: Supportive tone ("Let's try that again") not punitive ("Invalid credentials")
- Accessibility: Full screen reader support for all form fields

---

## 4. Home Dashboard

### Purpose
Central hub providing immediate access to the AI companion, guided exercises, and critical safety features.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| DASH-01 | **Greeting:** Time-aware greeting ("Good morning", "Good evening") + personalized by conversation patterns | P1 |
| DASH-02 | **Primary CTAs:** Large, accessible buttons for "Start Chat", "Start Voice Session", and "Guided Exercises" | P0 |
| DASH-03 | **Crisis Shortcut:** Persistent but subtle emergency button (bottom-right FAB or top bar) labeled "Get Help Now" | P0 |
| DASH-04 | **Recent Activity:** Preview of last conversation or exercise (timestamp + truncated preview) | P1 |
| DASH-05 | **Mood Prompt:** Optional 1-tap mood check-in widget (dismissible, non-intrusive) | P1 |
| DASH-06 | **Resources Card:** Quick link to Professional Care Bridge | P2 |
| DASH-07 | **Offline Indicator:** Banner when device loses connectivity | P1 |
| DASH-08 | **Language Indicator:** Show current app language; tap to change | P2 |
| DASH-09 | Pull-to-refresh for conversation sync status | P2 |
| DASH-10 | **Exercise Quick-Resume:** If user left an exercise mid-session, show "Continue Your Exercise" card | P1 |

### UI/UX Requirements
- No wellbeing scores, charts, or clinical metrics displayed anywhere (per PRD: scoring stays hidden)
- Dashboard must feel like a safe space, not a medical portal
- Smooth animations (Flutter Hero transitions to Chat/Voice/Exercise)
- Bottom navigation: Home | Exercises | History | Resources | Settings

### Data Requirements
- Fetch user profile, last conversation metadata, last exercise state, and unread status from Firestore
- Cache dashboard data locally for offline viewing

---

## 5. AI Chat Interface

### Purpose
Primary therapeutic interaction channel — text-based conversation with the AI companion.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| CHAT-01 | **Message Bubbles:** User messages (right, warm accent color); AI messages (left, soft neutral) | P0 |
| CHAT-02 | **AI Tone:** Warm, emotionally intelligent, respectful — never clinical, never slang-heavy, never diagnostic | P0 |
| CHAT-03 | **Typing Indicator:** Animated ellipsis when AI is generating response | P0 |
| CHAT-04 | **Message Status:** Sent ✓, Delivered ✓✓, Read (subtle, no timestamps in bubble to reduce anxiety) | P1 |
| CHAT-05 | **Contextual Quick-Replies:** 2-3 suggested responses based on AI's last message (dismissible) | P2 |
| CHAT-06 | **Crisis Detection:** Real-time analysis of user input via on-device + cloud NLP for self-harm, suicide, or danger indicators | P0 |
| CHAT-07 | **Crisis Trigger:** If crisis detected, immediately overlay Crisis Intervention Screen (non-blocking thread, cannot be dismissed accidentally) | P0 |
| CHAT-08 | **Conversation Persistence:** All messages encrypted and stored in Firestore; user can delete history | P0 |
| CHAT-09 | **Text Input:** Multi-line text field with send button; voice-to-text mic icon | P0 |
| CHAT-10 | **Auto-Scroll:** Scroll to bottom on new messages; user can scroll up to view history | P0 |
| CHAT-11 | **Pagination:** Load previous messages in batches of 50 on scroll-up | P1 |
| CHAT-12 | **Error Handling:** If AI API fails, show "I'm having trouble connecting. Let's try again." with retry button | P0 |
| CHAT-13 | **Multi-Language:** Auto-detect user language; AI responds in same language; manual override in input bar | P0 |
| CHAT-14 | **No Diagnosis:** AI must never label user with conditions ("depression", "anxiety disorder", etc.) | P0 |
| CHAT-15 | **Exercise Recommendations:** AI can suggest relevant exercises based on conversation context (e.g., "Would you like to try Box Breathing?") | P1 |

### AI/ML Requirements
- Backend proxy to LLM API (OpenAI / Claude / Custom) with system prompt enforcing PeaceMind AI persona
- System prompt must include: "You are a supportive companion, not a doctor. Never diagnose. Use warm, respectful language. If user expresses self-harm intent, trigger crisis protocol. Suggest exercises when appropriate."
- Conversation context window: Last 20 messages maintained for continuity
- Response latency target: < 3 seconds for text generation
- **Data use policy:** Conversations are used ONLY to generate responses within the session. No conversation data is used to train or fine-tune external AI models.

### Security & Privacy
- Messages encrypted at rest (Firestore encryption) and in transit (TLS 1.3)
- AI API calls must not log PII; use anonymized session IDs
- Crisis detection triggers logged securely with timestamp (access-controlled)

### Edge Cases
- User sends crisis message while offline → queue message, detect on sync, trigger crisis screen immediately
- AI generates harmful content → content moderation layer blocks and regenerates
- Very long user message (>2000 chars) → truncate with warning

---

## 6. AI Voice Interface

### Purpose
Voice-based therapeutic interaction for users who prefer speaking over typing.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| VOICE-01 | **Microphone Control:** Large, central microphone button with press-and-hold or tap-to-talk modes | P0 |
| VOICE-02 | **Real-Time Transcription:** Display user's speech as text in real-time with confidence indicators | P0 |
| VOICE-03 | **AI Response Playback:** Play AI response via TTS; display text transcript simultaneously | P0 |
| VOICE-04 | **Playback Controls:** Play, Pause, Stop, Replay buttons; scrubbing not required | P1 |
| VOICE-05 | **Visual Feedback:** Animated waveform/sound wave during listening and playback | P1 |
| VOICE-06 | **Crisis Detection:** Apply same real-time NLP analysis to transcribed voice input | P0 |
| VOICE-07 | **Background Noise Handling:** Basic noise filtering; prompt user to move to quieter space if unintelligible | P2 |
| VOICE-08 | **Permissions:** Graceful handling of microphone permission denial with educational prompt | P0 |
| VOICE-09 | **Audio Storage:** Raw audio NOT stored unless user explicitly opts in for quality improvement | P0 |
| VOICE-10 | **Switch to Chat:** Floating button to transition current session to text chat (context preserved) | P1 |
| VOICE-11 | **Language Support:** STT and TTS in all supported languages | P1 |
| VOICE-12 | **Exercise Launch from Voice:** User can say "Start Box Breathing" or similar to launch an exercise directly | P1 |

### UI/UX Requirements
- Full-screen immersive experience with calming background gradient
- Microphone button: 80px minimum touch target
- Visual state transitions: Idle → Listening → Processing → Speaking
- Haptic feedback on state changes (optional, respects accessibility settings)

### Technical Requirements
- STT: Firebase ML Kit or cloud STT API with language auto-detection
- TTS: Cloud TTS with adjustable speed/pitch (Settings-controlled)
- Audio processing: Real-time streaming to backend; no local persistence

---

## 7. Crisis Intervention Screen

### Purpose
Immediate, non-judgmental safety response when user expresses self-harm, suicide, or danger to others.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| CRISIS-01 | **Auto-Trigger:** Activates automatically when crisis language detected in Chat or Voice | P0 |
| CRISIS-02 | **Manual Trigger:** Accessible via "Get Help Now" button from any screen | P0 |
| CRISIS-03 | **Override Behavior:** Overrides all other app flows; cannot be dismissed via back button or swipe | P0 |
| CRISIS-04 | **Supportive Messaging:** Header: "You are not alone. Help is available right now." — warm, non-panicked tone | P0 |
| CRISIS-05 | **Emergency Numbers:** Display local emergency number (911/US, 999/UK, 112/EU) based on device locale | P0 |
| CRISIS-06 | **Crisis Hotlines:** Display relevant text/call hotlines (988 Suicide & Crisis Lifeline, Crisis Text Line, local equivalents) | P0 |
| CRISIS-07 | **One-Tap Actions:** "Call Emergency", "Text Crisis Line", "Call Hotline" buttons with phone/sms deep links | P0 |
| CRISIS-08 | **Grounding Exercise:** Optional 1-tap access to breathing exercise or 5-4-3-2-1 grounding technique | P1 |
| CRISIS-09 | **Location Sharing:** Optional "Share my location" button (explicit user consent required per tap) | P2 |
| CRISIS-10 | **Safety Planning:** "I've called for help" checkbox + gentle prompt to stay on line / not be alone | P1 |
| CRISIS-11 | **Post-Crisis:** After 5 minutes or user dismissal, gentle transition back to chat with follow-up resources | P1 |
| CRISIS-12 | **Logging:** Crisis event logged securely with timestamp, type (auto/manual), and anonymized session ID | P0 |

### UI/UX Requirements
- Color scheme: Calming but distinct (deep teal / soft purple) — avoid red/alarm colors that increase panic
- Large, high-contrast buttons for accessibility during distress
- No clinical language ("suicidal ideation" → "thoughts of hurting yourself")
- Screen reader: Immediate priority announcement upon activation

### Legal & Compliance
- Duty-to-care compliance varies by jurisdiction; log all crisis interventions
- Hotline numbers must be verified and updated quarterly
- Crisis response flow must be reviewed by licensed mental health professional

### Edge Cases
- User triggers crisis but has no phone/SMS capability → display web chat links for hotlines
- International user with no local hotline → display international resources (Befrienders Worldwide)
- User repeatedly triggers crisis in short timeframe → escalate logging, suggest professional care strongly

---

## 8. Exercise Player (Unified UI)

### Purpose
A single, consistent interface for ALL therapeutic exercises — whether fully scripted or AI-coached. The UI remains identical; only the content source and interaction mode change.

### Supported Exercise Catalog (6 Exercises)

#### 8.1 Box Breathing and Grounding
| Attribute | Detail |
|---|---|
| **Category** | Calm / Anxiety |
| **Duration** | 5–10 minutes |
| **Visual** | Expanding/contracting square/circle animation synced to breath count |
| **Scripted Steps** | Inhale (4s) → Hold (4s) → Exhale (4s) → Hold (4s), repeated 6–10 cycles |
| **AI-Coached** | AI adapts hold duration based on user comfort; suggests grounding cues ("Feel your feet on the floor") |
| **Best For** | Acute anxiety, panic moments, pre-sleep wind-down |

#### 8.2 Release Tension and Acceptance Emotion
| Attribute | Detail |
|---|---|
| **Category** | Emotional Release |
| **Duration** | 10–15 minutes |
| **Visual** | Body heat-map with tension points glowing red → fading to warm gold as released |
| **Scripted Steps** | Scan body for tension → breathe into tight areas → visualize tension dissolving → acceptance affirmation |
| **AI-Coached** | AI identifies emotional themes from recent conversations; guides targeted release phrases |
| **Best For** | Suppressed emotions, grief, anger, physical stress |

#### 8.3 Cognitive Reframing
| Attribute | Detail |
|---|---|
| **Category** | Cognitive / Thought Work |
| **Duration** | 8–12 minutes |
| **Visual** | Thought bubbles appearing and transforming (dark → light, jagged → soft) |
| **Scripted Steps** | Identify negative thought → examine evidence → generate alternative → practice compassionate reframe |
| **AI-Coached** | AI uses conversation context to suggest personalized reframes; asks Socratic questions |
| **Best For** | Negative self-talk, catastrophizing, rumination |

#### 8.4 Mindful Walking
| Attribute | Detail |
|---|---|
| **Category** | Movement / Active |
| **Duration** | 10–20 minutes |
| **Visual** | Gentle path/footstep animation; optional outdoor photo backdrop |
| **Scripted Steps** | Stand still → feel weight shift → slow steps → notice heel-to-toe → sync breath with pace → pause and observe |
| **AI-Coached** | AI adjusts pace guidance based on user energy level; suggests observation prompts |
| **Best For** | Restlessness, low energy, need for gentle movement |
| **Note** | Audio-only friendly — designed for eyes-open, mobile use |

#### 8.5 Body Scan
| Attribute | Detail |
|---|---|
| **Category** | Relaxation / PMR |
| **Duration** | 15–20 minutes |
| **Visual** | Anatomical body diagram with scanning beam and glowing joints |
| **Scripted Steps** | Toes → feet → legs → hips → stomach → chest → hands → arms → shoulders → neck → face → whole body |
| **AI-Coached** | AI lingers on areas user historically reports tension; adjusts scan speed |
| **Best For** | Deep relaxation, sleep preparation, chronic tension |

#### 8.6 STOP Skill
| Attribute | Detail |
|---|---|
| **Category** | Crisis / Impulse Control |
| **Duration** | 3–5 minutes |
| **Visual** | Four-quadrant compass or stoplight animation |
| **Scripted Steps** | **S**top → **T**ake a breath → **O**bserve (body, thoughts, feelings) → **P**roceed mindfully |
| **AI-Coached** | AI asks what triggered the impulse; guides observation without judgment; suggests next step |
| **Best For** | Urge surfing, emotional overwhelm, impulse control, crisis prevention |

### Functional Requirements (All Exercises)
| ID | Requirement | Priority |
|---|---|---|
| EX-01 | **Unified Layout:** All exercises share the same screen structure: Top Bar → Progress Tracker → Visual Stage → Script/Instruction Panel → Controls | P0 |
| EX-02 | **Progress Tracker:** Step dots showing exercise phases (e.g., "Breathe In → Hold → Breathe Out → Hold → Ground" for Box Breathing) | P0 |
| EX-03 | **Timer Bar:** Visual progress bar showing current step duration and total session time | P0 |
| EX-04 | **Visual Stage:** Central area displaying exercise-specific visuals (see catalog above) | P0 |
| EX-05 | **Script Panel:** Scrollable text area showing current instruction with typing animation and live indicator | P0 |
| EX-06 | **Voice-Guided TTS:** All exercises support text-to-speech narration in user's chosen language | P0 |
| EX-07 | **Play/Pause/Next/Previous Controls:** Consistent control bar across all exercises | P0 |
| EX-08 | **Mute Toggle:** Quick mute/unmute for voice guidance | P0 |
| EX-09 | **Eye Overlay:** Optional "Close your eyes" overlay during immersive phases (Body Scan, Release Tension) | P1 |
| EX-10 | **Voice Wave Animation:** Animated bars during TTS playback | P1 |
| EX-11 | **Session Completion Overlay:** Celebration screen with stats (total time, cycles completed, estimated calm score), confetti animation, and exercise-specific insight | P0 |
| EX-12 | **Restart / New Cycle:** Post-completion option to restart same exercise or choose another | P0 |
| EX-13 | **Offline Support:** Scripted exercises work fully offline; AI-coached requires connectivity | P0 |

### Scripted Exercise Mode
| ID | Requirement | Priority |
|---|---|---|
| EX-SCR-01 | Pre-written scripts for all 6 exercises stored locally or fetched from Firestore CDN | P0 |
| EX-SCR-02 | Scripts available in all supported languages | P0 |
| EX-SCR-03 | Fixed timing per step (configurable in settings) | P1 |
| EX-SCR-04 | No AI involvement — purely deterministic playback | P0 |

### AI-Coached Exercise Mode
| ID | Requirement | Priority |
|---|---|---|
| EX-AI-01 | AI generates personalized guidance based on user's current mood, recent conversations, and exercise history | P0 |
| EX-AI-02 | AI adapts pacing in real-time (extends holds, suggests breaks) based on user responsiveness | P1 |
| EX-AI-03 | AI can respond to voice input during exercise ("This feels hard", "Can we slow down?") | P2 |
| EX-AI-04 | AI uses ONLY user's own data (mood history, conversation context, exercise completion) to personalize — no external data sources | P0 |
| EX-AI-05 | AI coaching tone: Warm, encouraging, gentle — never pushy or clinical | P0 |
| EX-AI-06 | User can switch from AI-coached to scripted mid-session without losing progress | P1 |
| EX-AI-07 | AI coaching sessions are logged for quality improvement (anonymized, opt-in) | P2 |

### UI/UX Requirements
- **Consistency:** Identical layout, colors, typography, and controls across ALL exercise types
- **Immersive:** Dark stage area with soft glow effects; calming gradient backgrounds
- **Non-Clinical:** No medical terminology, no "prescription" language
- **Accessible:** Large touch targets, screen reader support, high contrast option
- **Responsive:** Visuals adapt to exercise type (see catalog above)

### Data Requirements
- Exercise progress stored in Firestore: completed steps, total duration, cycles, timestamp
- AI-coached sessions store anonymized coaching logs for quality review
- Exercise completion contributes to hidden wellbeing scoring (not shown to user)

### Edge Cases
- User exits mid-exercise → save progress, offer "Resume" on next visit
- Network loss during AI-coached session → gracefully fall back to scripted mode
- TTS fails → display text prominently with manual advance

---

## 9. Exercise Library / Discovery

### Purpose
Browse, search, and filter all 6 available exercises. Each exercise card indicates whether it's scripted or AI-coached.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| LIB-01 | **Grid/List View:** Browse exercises by category (Calm, Emotional Release, Cognitive, Movement, Relaxation, Crisis Skills) | P0 |
| LIB-02 | **Exercise Cards:** Title, duration, type icon (scripted vs AI), difficulty level, language availability | P0 |
| LIB-03 | **Search:** Full-text search by exercise name or benefit ("anxiety", "sleep", "anger") | P1 |
| LIB-04 | **Filters:** By duration (3-5min, 5-10min, 10-15min, 15-20min+), by type (scripted/AI), by language | P1 |
| LIB-05 | **Favorites:** Star/bookmark exercises for quick access | P1 |
| LIB-06 | **Recently Played:** Quick-access row of last 3 exercises | P1 |
| LIB-07 | **Recommended For You:** AI-suggested exercises based on mood and conversation history | P1 |
| LIB-08 | **Download for Offline:** Scripted exercises can be downloaded; AI-coached marked as "Online Only" | P1 |

### UI/UX Requirements
- Clean card-based layout with calming imagery thumbnails per exercise type
- Clear badges: "AI-Coached" (sparkle icon) vs "Guided" (book icon)
- No overwhelming choice — all 6 exercises visible without scrolling
- Exercise-specific color accents (Box Breathing = blue, STOP = amber, etc.)

---

## 10. Professional Care Bridge

### Purpose
Educate users on when and how to seek professional help, and provide vetted resources.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| PCB-01 | **Educational Content:** "When to seek professional help" — clear, non-judgmental guidance | P0 |
| PCB-02 | **Resource Directory:** Categorized list: Crisis Hotlines, Online Therapy, Local Therapists, Support Groups | P0 |
| PCB-03 | **Filters:** By language, insurance/self-pay, virtual/in-person, specialty (grief, trauma, LGBTQ+, etc.) | P1 |
| PCB-04 | **How-To Guides:** "How to talk to a doctor", "What to expect in therapy", "How to use insurance" | P1 |
| PCB-05 | **Conversation Export:** User can generate encrypted PDF summary of recent conversations to share with a therapist (opt-in, user-controlled) | P2 |
| PCB-06 | **Exercise History Export:** User can share exercise completion patterns with therapist (opt-in) | P2 |
| PCB-07 | **Crisis Resources Pinned:** Top section always shows immediate crisis numbers | P0 |
| PCB-08 | **No Booking Integration:** App provides information only; no direct scheduling (maintains "bridge, not replacement" stance) | P0 |
| PCB-09 | **Warm Encouragement:** AI-generated or templated encouraging messages based on user's journey stage | P2 |

### UI/UX Requirements
- Resource cards: Clear title, description, contact info, "Call" / "Visit Website" actions
- No paywalls or affiliate links (maintains trust)
- Regular content audits to ensure resource accuracy

---

## 11. Settings & Privacy Center

### Purpose
Give users full control over their experience, data, and privacy.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| SET-01 | **Account:** Change password, link anonymous account to email, enable/disable biometric login | P0 |
| SET-02 | **Privacy:** View data policy, request data export (JSON/PDF), request account deletion | P0 |
| SET-03 | **AI Data Controls:** Toggle AI personalization on/off, view what data AI uses, revoke AI Agreement | P0 |
| SET-04 | **Conversation Management:** Delete all history, delete specific conversations, auto-delete after X days | P0 |
| SET-05 | **Exercise Data:** Clear exercise history, reset progress | P1 |
| SET-06 | **Notifications:** Toggle push notifications, set quiet hours, choose notification tone | P1 |
| SET-07 | **Language:** In-app language selector (15+ languages), independent of device settings | P0 |
| SET-08 | **Accessibility:** Font size (Small/Medium/Large), high contrast mode, reduce motion, screen reader optimizations | P0 |
| SET-09 | **AI Preferences:** Response length (brief/detailed), voice speed (Voice mode), theme color | P2 |
| SET-10 | **Exercise Preferences:** Default exercise mode (scripted vs AI), TTS speed, background sound volume | P1 |
| SET-11 | **Crisis Contacts:** User can add personal emergency contacts (optional, encrypted) | P1 |
| SET-12 | **About:** App version, build number, open-source licenses, Terms of Service, Privacy Policy, AI Data Agreement | P1 |

### Security & Privacy
- Data export: Generated server-side, encrypted, download link expires in 24 hours
- Account deletion: Irreversible, deletes all Firestore data, anonymizes crisis logs
- AI Agreement revocation: Immediately stops AI personalization; falls back to generic scripted content
- All privacy settings must be enforceable in code (no "dark patterns")

---

## 12. Conversation History / Journal

### Purpose
Allow users to reflect on past conversations and track their emotional journey without clinical scoring.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| HIST-01 | **Chronological List:** All conversations with date, time, and truncated preview | P0 |
| HIST-02 | **Search:** Full-text search across all conversation messages | P1 |
| HIST-03 | **Filters:** By date range, by mood (if mood check-in was completed), by AI vs User messages | P2 |
| HIST-04 | **Delete:** Swipe-to-delete individual conversations; bulk delete option | P0 |
| HIST-05 | **Export:** Generate encrypted PDF of single conversation or date range | P2 |
| HIST-06 | **No Scores Displayed:** Wellbeing scores remain hidden per PRD; no graphs, charts, or trend lines shown to user | P0 |
| HIST-07 | **Mood Entries:** If user completed mood check-ins, display their own entries (emoji + text) alongside conversations | P1 |
| HIST-08 | **Exercise History:** Show completed exercises with timestamp and duration | P1 |

### UI/UX Requirements
- Journal-like aesthetic: Calming, reflective
- No clinical or analytical presentation
- Easy to delete sensitive content

---

## 13. Mood Check-in (Modal)

### Purpose
Lightweight, optional emotional state capture to inform AI context and hidden wellbeing tracking.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| MOOD-01 | **Trigger:** Periodic gentle prompt (max 1x/day) or user-initiated from dashboard | P1 |
| MOOD-02 | **Interface:** 5-point emoji scale or word cloud ("Calm", "Overwhelmed", "Hopeful", "Heavy", "Okay") | P0 |
| MOOD-03 | **No Clinical Labels:** Never use diagnostic terms ("depressed", "anxious") | P0 |
| MOOD-04 | **Optional Journal:** Free-text field (max 280 chars) — "Want to say more?" | P1 |
| MOOD-05 | **Completion Time:** < 30 seconds | P0 |
| MOOD-06 | **Data Usage:** Stored privately; informs AI conversation context and exercise recommendations; contributes to hidden backend scoring only | P0 |
| MOOD-07 | **Dismissible:** User can skip without penalty or repeated nagging | P0 |

### UI/UX Requirements
- Modal overlay, not full screen
- Soft, warm animations on selection
- Immediate positive reinforcement ("Thank you for checking in")

---

## 14. Admin Dashboard (Web)

### Purpose
Internal tool for monitoring AI performance, crisis alerts, exercise usage, and system health.

### Functional Requirements
| ID | Requirement | Priority |
|---|---|---|
| ADM-01 | **Crisis Alert Feed:** Real-time table of crisis events with timestamp, session ID (anonymized), trigger type, resolution status | P0 |
| ADM-02 | **Wellbeing Analytics:** Aggregated, anonymized trend data from hidden scoring system; no individual user identification | P0 |
| ADM-03 | **AI Quality Metrics:** Response latency, error rates, user feedback scores, moderation flags, exercise coaching quality | P1 |
| ADM-04 | **Content Moderation Queue:** Review AI responses flagged by safety filters | P1 |
| ADM-05 | **Exercise Analytics:** Most popular exercises, completion rates, scripted vs AI-coached usage split, per-exercise stats | P1 |
| ADM-06 | **User Management:** Search by anonymized ID, view conversation history (decrypted, access-logged), delete accounts | P0 |
| ADM-07 | **Role-Based Access:** Admin, Moderator, Viewer roles with different permissions | P0 |
| ADM-08 | **Audit Logs:** All admin actions logged immutably | P0 |
| ADM-09 | **AI Agreement Compliance:** Track user acceptance rates, agreement version distribution | P1 |

### Security & Privacy
- 2FA required for all admin accounts
- All access to user data requires justification and is logged
- Crisis alerts must be actionable within 5 minutes during business hours

---

## Cross-Cutting Requirements

### Crisis Protocol (Applies to ALL Screens)
- **CRI-Global-01:** Crisis detection must be active in every user input channel (chat text, voice transcription, exercise voice input)
- **CRI-Global-02:** Crisis screen activation latency: < 500ms from detection to UI overlay
- **CRI-Global-03:** Crisis resources must be localized to user's country/region
- **CRI-Global-04:** No A/B testing or feature experimentation on crisis flow

### AI Persona (Applies to Chat + Voice + Exercise Coaching)
- **AI-Global-01:** Never diagnose medical or mental health conditions
- **AI-Global-02:** Never prescribe medication or specific treatments
- **AI-Global-03:** Always encourage professional help for severe or persistent issues
- **AI-Global-04:** Use person-first, non-stigmatizing language
- **AI-Global-05:** Respect user's cultural and linguistic context
- **AI-Global-06:** AI uses user data ONLY for that user's benefit — no model training, no data selling, no external sharing

### Privacy (Applies to ALL Screens)
- **PRIV-Global-01:** Wellbeing scores remain hidden from users at all times
- **PRIV-Global-02:** No third-party analytics or advertising SDKs
- **PRIV-Global-03:** All data encrypted at rest and in transit
- **PRIV-Global-04:** User data never sold or shared without explicit consent
- **PRIV-Global-05:** AI Agreement acceptance is required before any AI personalization begins
- **PRIV-Global-06:** Users can revoke AI Agreement at any time; app continues to function with scripted content

### Exercise System (Applies to ALL Exercises)
- **EX-Global-01:** Unified UI components shared across all 6 exercise types — no per-exercise custom screens
- **EX-Global-02:** All exercises support voice guidance, pause/resume, and progress tracking
- **EX-Global-03:** AI-coached and scripted modes must be visually distinguishable only by badge/icon, not by layout
- **EX-Global-04:** Exercise completion data contributes to hidden wellbeing scoring

---

*End of Screen-by-Screen Requirements Document v2.2*
