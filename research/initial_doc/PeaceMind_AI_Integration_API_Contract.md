# PeaceMind AI — Integration API Contract

| Field | Value |
|---|---|
| **Document Type** | API Contract (Client-Server) |
| **Source** | PeaceMind AI Product PRD v2.2, Technical PRD v1.1 |
| **Version** | 1.0 (v1.0 MVP — Core Mobile APIs) |
| **Date** | August 17, 2026 |
| **Status** | Approved for Development |
| **API Style** | Firebase Callable Functions (primary) |
| **Deferred to v2.0** | REST endpoints (doctor booking, payments, webhooks, public API) |

---

## 1. Overview

### 1.1 Purpose

This document defines the **contract** between the Flutter client (PeaceMind AI mobile app) and the Firebase Cloud Functions backend. All API calls are authenticated Firebase Callable Functions (`functions.https.onCall`). This is the **single source of truth** for request/response schemas, validation rules, error codes, and error handling.

### 1.2 Base URL (Callable Functions)

All Callable Functions are invoked via the Firebase SDK. No base URL is specified; the Firebase SDK resolves the correct endpoint based on the environment.

| Environment | SDK Configuration |
|-------------|-------------------|
| **Production** | `FirebaseOptions(projectId: "peacemind-prod", ...)` |
| **Staging** | `FirebaseOptions(projectId: "peacemind-staging", ...)` |
| **Development** | `FirebaseOptions(projectId: "peacemind-dev", ...)` |
| **Local Emulator** | `FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001)` |

### 1.3 Authentication

**All Callable Functions require authentication** unless explicitly marked as `(public)`.

| Method | Implementation |
|--------|----------------|
| **Auth Type** | Firebase Authentication — Email + Password (v1) |
| **Token Location** | Automatically injected by Firebase SDK into `context.auth` |
| **Refresh Strategy** | Firebase SDK automatically refreshes ID tokens |
| **Anonymous Users** | Not supported in v1 — sign-up required before accessing the app |

**In the Cloud Function, `context.auth.uid` is the authenticated user ID.**

### 1.4 API Versioning

Since these are Firebase Callable Functions, versioning is handled by the function name itself. For future major changes, we will create new function names (e.g., `sendChatMessageV2`).

| Version | Label | Function Name Pattern | Status |
|---------|-------|----------------------|--------|
| **v1.0** | Current | `functionName` (e.g., `sendChatMessage`) | Active |
| **v2.0** | Future | `functionNameV2` (e.g., `sendChatMessageV2`) | Planned |

### 1.5 Common Headers / Metadata

Firebase SDK automatically handles authentication and context. No manual headers are required for Callable Functions.

### 1.6 Response Envelope

All Callable Functions return either:
- **Success:** A typed object (schema defined per endpoint)
- **Error:** A `FirebaseFunctionsException` with `code` and `message`

```dart
// Success (typed object)
final result = await functions.httpsCallable('sendChatMessage').call(data);
final reply = result.data['reply']; // Type-safe in Flutter with generated models

// Error
try {
  await functions.httpsCallable('sendChatMessage').call(data);
} on FirebaseFunctionsException catch (e) {
  // e.code = 'ENTITLEMENT_EXCEEDED'
  // e.message = 'You have reached your daily message limit.'
}
```

---

## 2. Authentication Flow

### 2.1 `signUp`

**Description:** Create a new user account.

**Authentication Required:** ❌ No (public)

**Request:**
```dart
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `email` | Required, valid email format, max 256 characters |
| `password` | Required, min 8 characters, at least one number, one uppercase, one lowercase |

**Success Response:**
```dart
{
  "uid": "firebase_uid_123",
  "email": "user@example.com",
  "createdAt": "2026-08-17T10:00:00Z"
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `EMAIL_ALREADY_IN_USE` | Email already registered | Show "Email already in use" message |
| `WEAK_PASSWORD` | Password too weak | Show "Password must be at least 8 characters..." |
| `INVALID_EMAIL` | Malformed email | Show "Please enter a valid email address" |

---

### 2.2 `signIn`

**Description:** Authenticate an existing user.

**Authentication Required:** ❌ No (public)

**Request:**
```dart
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response:**
```dart
{
  "uid": "firebase_uid_123",
  "email": "user@example.com",
  "subscriptionTier": "free",
  "profileConfidence": "provisional",
  "preferredLanguage": "en",
  "sessionHistoryCount": 0
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `USER_NOT_FOUND` | Email not registered | Show "No account found with this email" |
| `INVALID_PASSWORD` | Wrong password | Show "Invalid password" |
| `TOO_MANY_ATTEMPTS` | Too many failed logins | Show "Too many attempts. Try again later." |

---

### 2.3 `resetPassword`

**Description:** Send a password reset email.

**Authentication Required:** ❌ No (public)

**Request:**
```dart
{
  "email": "user@example.com"
}
```

**Success Response:**
```dart
{
  "success": true,
  "message": "Password reset email sent. Please check your inbox."
}
```

**Error Codes:**
| Code | Scenario |
|------|----------|
| `USER_NOT_FOUND` | Email not registered |

---

### 2.4 `refreshToken`

**Description:** Get a refreshed authentication token (handled automatically by Firebase SDK; provided here for reference).

**Authentication Required:** ✅ Yes

**Request:** `{}` (no body — Firebase SDK handles this)

**Success Response:**
```dart
{
  "token": "new_firebase_id_token",
  "expiresAt": "2026-08-17T11:00:00Z"
}
```

---

## 3. Chat & Conversation

### 3.1 `sendChatMessage`

**Description:** Send a user message in an existing session. The function orchestrates crisis detection, AI reply generation, and distress scoring. Returns the AI reply and optionally triggers a guided exercise if distress exceeds the threshold.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123",      // Required. Existing session ID (returned from `createSession`)
  "messageText": "I feel really anxious about work tomorrow.", // Required. Min 1 char, max 2000 chars
  "channel": "chat"                // Required. "chat" | "voice" | "video"
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `sessionId` | Required, alphanumeric, min 4 chars |
| `messageText` | Required, min 1 char, max 2000 chars |
| `channel` | Required, one of `chat`, `voice`, `video` |

**Success Response:**
```dart
{
  "reply": {
    "messageId": "msg_xyz789",                    // Unique ID for the AI's reply
    "text": "I hear that you're feeling anxious about work. Let's pause and take a slow breath together. Breathe in for 4... hold for 4... out for 4...",  // AI reply text
    "timestamp": "2026-08-17T10:01:00Z"           // ISO 8601 UTC
  },
  "triggerExercise": {                            // Optional — included only if distress_level >= 0.7
    "type": "box_breathing",                      // "box_breathing" | "grounding" | "mindful_walking" | "release_tension" | "body_scan" | "cognitive_reframing" | "accept_emotions" | "stop_skill"
    "name": "Box Breathing",                      // Human-readable name
    "script": "Breathe in for 4... hold for 4... out for 4...", // Full script
    "durationSeconds": 120,                       // Estimated duration
    "audioUrl": "https://storage.../box_breathing_guide.mp3" // Pre-recorded audio (optional)
  },
  "remainingEntitlements": {
    "messagesRemaining": 3,                       // Messages left in the current period (Free/Basic)
    "voiceMinutesRemaining": 10,                  // Voice minutes left in the current period (Free/Basic)
    "periodEndsAt": "2026-08-18T00:00:00Z"       // End of the current period
  },
  "crisisDetected": false                         // true if a crisis keyword was matched
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `UNAUTHENTICATED` | User session expired | Redirect to login |
| `ENTITLEMENT_EXCEEDED` | Free user exceeded daily message limit | Show upgrade screen (US-4) |
| `CRISIS_DETECTED` | Crisis keyword matched | **Bypass normal reply.** Immediately show Crisis Help screen (US-6) |
| `SESSION_NOT_FOUND` | `sessionId` does not exist | Create a new session or retry |
| `MESSAGE_TOO_LONG` | `messageText` > 2000 chars | Show "Message too long (max 2000 characters)" |
| `AI_UNAVAILABLE` | Qwen API unreachable | Show "I'm having trouble connecting. Please try again in a moment." |
| `INVALID_CHANNEL` | `channel` not `chat`/`voice`/`video` | Show "Please select a valid channel" |

---

### 3.2 `createSession`

**Description:** Create a new session (chat or voice). Sessions are channel-agnostic (PRD §4.2 Cross-channel consistency).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "channel": "chat"                // Required. "chat" | "voice" | "video"
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `channel` | Required, one of `chat`, `voice`, `video` |

**Success Response:**
```dart
{
  "sessionId": "sess_abc123",
  "createdAt": "2026-08-17T10:00:00Z",
  "channel": "chat",
  "state": "open"
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `INVALID_CHANNEL` | Invalid channel value | Show error and retry |

---

### 3.3 `getSessionHistory`

**Description:** Get a paginated list of a user's sessions (for the Home screen and History screen).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "limit": 20,                     // Optional. Default 20, max 50
  "cursor": "sess_xyz789"          // Optional. Pagination cursor (session ID of the last item from previous page)
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `limit` | Optional, min 1, max 50 |
| `cursor` | Optional, alphanumeric |

**Success Response:**
```dart
{
  "sessions": [
    {
      "sessionId": "sess_abc123",
      "channel": "chat",
      "state": "closed",
      "createdAt": "2026-08-17T10:00:00Z",
      "messageCount": 5,
      "lastMessagePreview": "I hear that you're feeling anxious..."
    },
    {
      "sessionId": "sess_def456",
      "channel": "voice",
      "state": "open",
      "createdAt": "2026-08-16T09:00:00Z",
      "messageCount": 2,
      "lastMessagePreview": "Let's try the grounding exercise..."
    }
  ],
  "nextCursor": "sess_def456",     // Optional — if more sessions exist
  "hasMore": true
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `INVALID_LIMIT` | `limit` > 50 | Show "Limit must be 50 or less" |

---

### 3.4 `getMessages`

**Description:** Get all messages for a specific session (for the Chat screen). Supports pagination for long sessions.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123",      // Required.
  "limit": 50,                     // Optional. Default 50, max 100
  "before": "msg_xyz789"           // Optional. Get messages before this message ID (for older messages)
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `sessionId` | Required, valid session ID |
| `limit` | Optional, min 1, max 100 |
| `before` | Optional, alphanumeric |

**Success Response:**
```dart
{
  "messages": [
    {
      "messageId": "msg_abc123",
      "sender": "user",
      "text": "I feel really anxious about work tomorrow.",
      "timestamp": "2026-08-17T10:00:00Z"
    },
    {
      "messageId": "msg_xyz789",
      "sender": "ai",
      "text": "I hear that you're feeling anxious...",
      "timestamp": "2026-08-17T10:01:00Z"
    }
  ],
  "hasMore": false
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `SESSION_NOT_FOUND` | Invalid `sessionId` | Show "Session not found" |

---

## 4. Voice

### 4.1 `startVoiceSession`

**Description:** Begin a one-off voice message session (SenseVoice STT + CosyVoice TTS). Returns a pre-signed URL for uploading the voice recording.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123"       // Required. Existing session ID
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `sessionId` | Required, valid session ID |

**Success Response:**
```dart
{
  "sessionId": "sess_abc123",
  "uploadUrl": "https://storage.googleapis.com/peacemind-prod/voice/audio_123.m4a?token=...", // Pre-signed URL (expires in 60 seconds)
  "transcriptReady": false,
  "maxDurationSeconds": 60          // Maximum recording length
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `SESSION_NOT_FOUND` | Invalid `sessionId` | Show "Session not found" |
| `UPLOAD_URL_EXPIRED` | Pre-signed URL expired | Retry `startVoiceSession` |

---

### 4.2 `streamVoiceTurn`

**Description:** After uploading voice audio, trigger the transcription + conversation pipeline. The audio is processed by SenseVoice for STT and emotion detection, then the same conversation pipeline as chat (crisis detection, AI reply). The reply is synthesized with CosyVoice.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123",      // Required
  "audioFileId": "audio_123.m4a"   // Required. The file name/ID from the upload
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `sessionId` | Required, valid session ID |
| `audioFileId` | Required, alphanumeric + extension |

**Success Response:**
```dart
{
  "transcript": "I feel really anxious about work tomorrow.",  // The transcribed text
  "reply": {
    "messageId": "msg_xyz789",
    "text": "I hear that you're feeling anxious about work...",
    "timestamp": "2026-08-17T10:02:00Z"
  },
  "audioUrl": "https://storage.googleapis.com/.../reply_123.mp3", // Pre-signed URL for the AI voice reply
  "triggerExercise": { ... },       // Same structure as `sendChatMessage`
  "remainingEntitlements": { ... },
  "crisisDetected": false
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `AUDIO_NOT_FOUND` | Invalid `audioFileId` | Retry upload |
| `STT_FAILED` | SenseVoice transcription failed | Show "Could not understand audio. Please try again." |
| `ENTITLEMENT_EXCEEDED` | Voice limit exceeded | Show upgrade screen |

---

### 4.3 `startLiveAudioCall`

**Description:** Initiate a real-time, bidirectional voice call using Qwen-Omni-Realtime. Returns a WebSocket URL and token for the live audio stream.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123"       // Required. Existing session ID
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `sessionId` | Required, valid session ID |

**Success Response:**
```dart
{
  "callId": "call_456",
  "websocketUrl": "wss://api.peacemind.ai/realtime/call_456", // WebSocket endpoint
  "turnToken": "ws_token_xyz789",   // One-time token for WebSocket authentication
  "expiresAt": "2026-08-17T10:05:00Z" // Token expiration
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `ENTITLEMENT_EXCEEDED` | Voice call limit exceeded | Show upgrade screen |
| `AI_UNAVAILABLE` | Qwen-Omni-Realtime unreachable | Show "Call service unavailable. Try again later." |

---

### 4.4 `endLiveAudioCall`

**Description:** End the live audio call. Logs the call duration, metrics, and saves the transcript (for the SessionReport).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "callId": "call_456",            // Required. ID returned from `startLiveAudioCall`
  "durationSeconds": 180           // Required. Total call duration in seconds
}
```

**Success Response:**
```dart
{
  "success": true,
  "transcriptSummary": "User discussed anxiety about work. AI suggested box breathing.",
  "sessionReportGenerated": true
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `CALL_NOT_FOUND` | Invalid `callId` | Show "Call not found" |
| `INVALID_DURATION` | `durationSeconds` invalid | Show error |

---

## 5. Tasks (Coping Tasks)

### 5.1 `getTasks`

**Description:** Get pending and recent completed tasks for a user.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "status": "pending"              // Optional. "pending" | "completed" | "all". Default "pending"
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `status` | Optional, one of `pending`, `completed`, `all` |

**Success Response:**
```dart
{
  "tasks": [
    {
      "taskId": "task_123",
      "sessionId": "sess_abc123",
      "description": "Try noticing one moment of calm today.",
      "assignedAt": "2026-08-17T10:00:00Z",
      "status": "pending",
      "gardenGrowthApplied": false
    }
  ]
}
```

---

### 5.2 `submitTaskCompletion`

**Description:** Mark a task as completed. Triggers Garden growth server-side (PRD §4.6, §4.2).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "taskId": "task_123"             // Required. Task ID from `getTasks`
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `taskId` | Required, valid task ID |

**Success Response:**
```dart
{
  "success": true,
  "gardenUpdate": {
    "plantAdded": true,
    "plantType": "🌱",
    "newStage": 2,
    "unlockedAt": "2026-08-17T10:05:00Z"
  }
}
```

**Error Codes:**
| Code | Scenario | Client Action |
|------|----------|---------------|
| `TASK_NOT_FOUND` | Invalid `taskId` | Show "Task not found" |
| `TASK_ALREADY_COMPLETED` | Task already completed | Show "Task already completed" |

---

## 6. Garden (Gamification)

### 6.1 `getGardenState`

**Description:** Get the current state of the user's Garden (plants, stages, unlocked at times).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{} // No body — user derived from authentication
```

**Success Response:**
```dart
{
  "plants": [
    {
      "plantType": "🌱",            // Emoji or icon identifier
      "stage": 2,                   // Growth stage (1 = seed, 2 = sprout, 3 = bloom, 4 = full)
      "unlockedAt": "2026-08-15T10:00:00Z"
    },
    {
      "plantType": "🌸",
      "stage": 1,
      "unlockedAt": "2026-08-16T09:00:00Z"
    }
  ],
  "totalPlants": 5,
  "nextMilestone": 10              // Plants needed for next milestone
}
```

---

## 7. Mood Tracking

### 7.1 `logMood`

**Description:** Log a mood check-in (1-10). Used for progress dashboard and trend charts (PRD §4.8).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "moodValue": 4,                  // Required. 1-10
  "source": "tap"                  // Required. "tap" | "journal"
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `moodValue` | Required, integer between 1 and 10 |
| `source` | Required, one of `tap`, `journal` |

**Success Response:**
```dart
{
  "success": true,
  "logId": "mood_123",
  "timestamp": "2026-08-17T10:00:00Z"
}
```

---

### 7.2 `getMoodHistory`

**Description:** Get historical mood logs for the Progress Dashboard (trend chart, calendar view).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "limit": 30,                     // Optional. Default 30, max 90
  "startDate": "2026-08-01",       // Optional. Filter by date range (ISO date)
  "endDate": "2026-08-17"          // Optional. Filter by date range
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| `limit` | Optional, min 1, max 90 |
| `startDate` | Optional, ISO date format (YYYY-MM-DD) |
| `endDate` | Optional, ISO date format (YYYY-MM-DD) |

**Success Response:**
```dart
{
  "logs": [
    {
      "moodValue": 4,
      "timestamp": "2026-08-17T10:00:00Z",
      "source": "tap"
    },
    {
      "moodValue": 6,
      "timestamp": "2026-08-16T09:00:00Z",
      "source": "journal"
    }
  ]
}
```

---

## 8. Reports

### 8.1 `generateSessionReport`

**Description:** Generate the post-session summary (mood before/after, tools used, insight, next step). This is shown to the user after each session (PRD §4.8).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "sessionId": "sess_abc123"       // Required. Session ID
}
```

**Success Response:**
```dart
{
  "moodBefore": 4,
  "moodAfter": 7,
  "toolsUsed": [
    { "techniqueId": 1, "name": "Box Breathing" },
    { "techniqueId": 2, "name": "Grounding (5-4-3-2-1)" }
  ],
  "insight": "You noticed that your anxiety is often triggered by thinking about work deadlines.",
  "nextStep": "Try the 'Cognitive Reframing' exercise when you notice work-related anxiety."
}
```

### 8.2 `generateDoctorSummaryReport` (v2.0 — Deferred)

**Description:** Generate an opt-in, anonymized summary report for a clinician (Premium only). Requires explicit user consent. **Not available in v1.0.**

**Status:** Planned for v2.0

**Request:**
```dart
{
  "userId": "user_123",            // Required. Derived from auth
  "consentGiven": true             // Required. Explicit user consent
}
```

**Success Response:**
```dart
{
  "reportUrl": "https://storage.../report_123.pdf",
  "expiresAt": "2026-08-24T10:00:00Z"
}
```

---

## 9. Crisis Handling (PRD §4.9, §6)

### 9.1 `getHelplines`

**Description:** Get a list of region-appropriate crisis helplines (offline-safe — static list is also bundled in Hive for offline use).

**Authentication Required:** ❌ No (public)

**Request:**
```dart
{
  "countryCode": "PK"             // Optional. ISO country code. Defaults to user's location or "PK" (Pakistan)
}
```

**Success Response:**
```dart
{
  "helplines": [
    {
      "name": "Rozan Helpline",
      "country": "PK",
      "phoneNumbers": ["+92-42-35761990", "042-35761990"],
      "type": "Mental Health",
      "available24_7": true,
      "languages": ["en", "ur"],
      "sms": false,
      "website": "https://rozan.org/"
    },
    {
      "name": "Umang Helpline",
      "country": "PK",
      "phoneNumbers": ["+92-301-2345678"],
      "type": "Crisis",
      "available24_7": true,
      "languages": ["ur"],
      "sms": true,
      "website": "https://umang.org.pk/"
    }
  ]
}
```

---

### 9.2 `triggerCrisisFlow` (Internal)

**Description:** This is not a client-callable function. It is triggered automatically by `sendChatMessage` when a crisis keyword is matched. The client receives `crisisDetected: true` in the response and the Crisis Help screen is shown (US-6).

**Client Action on `crisisDetected: true`:**

```dart
if (result.data['crisisDetected'] == true) {
  // 1. Bypass normal reply display
  // 2. Show Crisis Help screen
  // 3. Load helplines (from Hive cache or call getHelplines)
  // 4. Log SafetyFlag (done server-side)
}
```

---

## 10. Profile & Preferences

### 10.1 `getProfile`

**Description:** Get the user's profile information.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{} // No body — user derived from auth
```

**Success Response:**
```dart
{
  "uid": "firebase_uid_123",
  "email": "user@example.com",
  "subscriptionTier": "free",
  "profileConfidence": "provisional",  // "provisional" | "established"
  "preferredLanguage": "en",           // "en" | "ur" | "ur-roman"
  "createdAt": "2026-08-17T10:00:00Z"
}
```

---

### 10.2 `updateProfile`

**Description:** Update user profile fields.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "preferredLanguage": "ur"       // Optional. "en" | "ur" | "ur-roman"
}
```

**Success Response:**
```dart
{
  "success": true,
  "updatedFields": {
    "preferredLanguage": "ur"
  }
}
```

---

### 10.3 `updatePreferences`

**Description:** Update app preferences (notification settings, etc.).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "notificationsEnabled": true,   // Optional. Default true
  "reminderTime": "09:00",        // Optional. HH:MM 24-hour format
  "reminderDays": [1,2,3,4,5,6,7] // Optional. 1 = Monday, 7 = Sunday
}
```

**Success Response:**
```dart
{
  "success": true
}
```

---

## 11. Coping Tools

### 11.1 `getTools`

**Description:** Get available coping tools (breathing, grounding, walking, etc.) with their usage status.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{} // No body
```

**Success Response:**
```dart
{
  "tools": [
    {
      "techniqueId": 1,
      "name": "Box Breathing",
      "description": "4-4-4-4 breathing technique for anxiety",
      "isCompleted": false,
      "lastUsedAt": null,
      "totalUses": 0
    },
    {
      "techniqueId": 2,
      "name": "Grounding (5-4-3-2-1)",
      "description": "Redirect your attention to the present moment",
      "isCompleted": true,
      "lastUsedAt": "2026-08-16T09:00:00Z",
      "totalUses": 3
    }
  ]
}
```

---

### 11.2 `completeTool`

**Description:** Log that a user completed a coping tool exercise.

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "techniqueId": 1                 // Required. ID from `getTools`
}
```

**Success Response:**
```dart
{
  "success": true,
  "gardenUpdate": { ... }          // Same as `submitTaskCompletion` — tools can also grow the garden
}
```

---

## 12. Data Export & Deletion

### 12.1 `exportUserData`

**Description:** Export all user data (for user-initiated data portability, PRD §6.1).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "format": "json"                 // Optional. "json" | "pdf". Default "json"
}
```

**Success Response:**
```dart
{
  "downloadUrl": "https://storage.../user_data_123.zip",
  "expiresAt": "2026-08-18T10:00:00Z",
  "includes": ["messages", "sessions", "moods", "tasks", "garden"]
}
```

---

### 12.2 `deleteUserData`

**Description:** Permanently delete all user data (soft delete with audit trail, PRD §6.1).

**Authentication Required:** ✅ Yes

**Request:**
```dart
{
  "confirm": true                  // Required. User must explicitly confirm
}
```

**Success Response:**
```dart
{
  "success": true,
  "deletedAt": "2026-08-17T10:00:00Z",
  "dataRetentionDays": 30          // Data will be permanently purged after this period
}
```

---

## 13. Error Handling — Complete Error Code Reference

### 13.1 Standard Error Response

All errors use the Firebase Functions exception format:

```dart
{
  "code": "ENTITLEMENT_EXCEEDED",
  "message": "You have reached your daily message limit. Please upgrade to continue.",
  "details": {                     // Optional, context-specific
    "remaining": 0,
    "periodEndsAt": "2026-08-18T00:00:00Z"
  }
}
```

### 13.2 Error Code Table

| Code | HTTP Equivalent | Description | Client Action |
|------|-----------------|-------------|---------------|
| **Authentication** | | | |
| `UNAUTHENTICATED` | 401 | Firebase Auth token invalid/expired | Redirect to login screen |
| `EMAIL_ALREADY_IN_USE` | 409 | Email already registered | Show "Email already in use" |
| `WEAK_PASSWORD` | 400 | Password too weak | Show password requirements |
| `USER_NOT_FOUND` | 404 | User not found | Show "No account found" |
| `INVALID_PASSWORD` | 401 | Wrong password | Show "Invalid password" |
| `TOO_MANY_ATTEMPTS` | 429 | Too many login attempts | Show "Too many attempts. Try again later." |
| `INVALID_EMAIL` | 400 | Malformed email | Show "Please enter a valid email address" |
| **Entitlement** | | | |
| `ENTITLEMENT_EXCEEDED` | 403 | Free/Basic user exceeded limit | Show upgrade screen (US-4) |
| `PREMIUM_REQUIRED` | 403 | Feature only available for Premium | Show upgrade screen |
| **Data** | | | |
| `SESSION_NOT_FOUND` | 404 | Session ID doesn't exist | Create new session or retry |
| `TASK_NOT_FOUND` | 404 | Task ID doesn't exist | Refresh task list |
| `TASK_ALREADY_COMPLETED` | 409 | Task already marked completed | Show "Task already completed" |
| `MESSAGE_TOO_LONG` | 400 | Message exceeds 2000 chars | Show max length error |
| `INVALID_CHANNEL` | 400 | Invalid channel value | Show "Please select a valid channel" |
| `INVALID_LIMIT` | 400 | Pagination limit invalid | Show "Limit must be 50 or less" |
| `AUDIO_NOT_FOUND` | 404 | Voice file not found | Retry upload |
| `CALL_NOT_FOUND` | 404 | Call ID invalid | Show "Call not found" |
| **AI / Model** | | | |
| `AI_UNAVAILABLE` | 503 | Qwen API unreachable | Show "I'm having trouble connecting. Try again in a moment." |
| `STT_FAILED` | 500 | SenseVoice transcription failed | Show "Could not understand audio. Please try again." |
| `TTS_FAILED` | 500 | CosyVoice synthesis failed | Show "Could not generate voice reply." |
| **Crisis** | | | |
| `CRISIS_DETECTED` | 200 (success) | Crisis keyword matched | **Bypass normal flow.** Show Crisis Help screen (US-6) |
| **General** | | | |
| `INTERNAL_ERROR` | 500 | Unexpected server error | Show "Something went wrong. Try again later." |
| `INVALID_ARGUMENT` | 400 | Malformed request | Show generic error |

---

## 14. Pagination Strategy

### 14.1 Cursor-Based Pagination

All paginated endpoints use **cursor-based pagination** (Firestore-native, more efficient than offset/limit).

| Pattern | Example |
|---------|---------|
| **First page** | `getSessionHistory({ limit: 20 })` |
| **Next page** | `getSessionHistory({ limit: 20, cursor: "sess_xyz789" })` |
| **No more data** | `hasMore: false` |

### 14.2 Supported Paginated Endpoints

| Endpoint | Default Limit | Max Limit | Sort Order |
|----------|---------------|-----------|------------|
| `getSessionHistory` | 20 | 50 | CreatedAt DESC |
| `getMessages` | 50 | 100 | Timestamp ASC |
| `getMoodHistory` | 30 | 90 | Timestamp DESC |

---

## 15. Swagger/OpenAPI 3.0.0 Structure

Since PeaceMind AI uses **Firebase Callable Functions**, the Swagger/OpenAPI spec is **informational only** — it documents the request/response schemas rather than serving as a working API endpoint specification.

```yaml
openapi: 3.0.0
info:
  title: PeaceMind AI API Contract (Callable Functions)
  description: |
    This document describes the request/response schemas for PeaceMind AI's
    Firebase Callable Functions. These are not REST endpoints — they are
    Firebase `functions.https.onCall` functions invoked via the Firebase SDK.
    This spec is provided for documentation and model generation purposes only.
  version: 1.0.0
  contact:
    name: PeaceMind AI Team
    email: engineering@peacemind.ai

servers:
  - url: https://us-central1-peacemind-prod.cloudfunctions.net
    description: Production
  - url: https://us-central1-peacemind-staging.cloudfunctions.net
    description: Staging
  - url: http://localhost:5001/peacemind-dev/us-central1
    description: Local Emulator

tags:
  - name: Authentication
    description: Login, signup, password reset
  - name: Chat
    description: Session management, messaging
  - name: Voice
    description: Voice messages and live calls
  - name: Tasks
    description: Coping task management
  - name: Garden
    description: Gamification / plant growth
  - name: Mood
    description: Mood tracking
  - name: Reports
    description: Session reports and exports
  - name: Crisis
    description: Helplines and safety flow
  - name: Profile
    description: User profile and preferences
  - name: Tools
    description: Coping tools
  - name: Data
    description: Export and delete user data

components:
  securitySchemes:
    FirebaseAuth:
      type: apiKey
      in: header
      name: Authorization
      description: |
        Firebase ID Token in the format 'Bearer <idToken>'.
        The Firebase SDK injects this automatically for Callable Functions.

  schemas:
    # === Shared Models ===
    ErrorResponse:
      type: object
      properties:
        code:
          type: string
          description: Error code for programmatic handling
          example: ENTITLEMENT_EXCEEDED
        message:
          type: string
          description: Human-readable error message
          example: You have reached your daily message limit.
        details:
          type: object
          description: Optional context-specific details
          additionalProperties: true

    Timestamp:
      type: string
      format: date-time
      description: ISO 8601 UTC timestamp
      example: 2026-08-17T10:00:00Z

    RemainingEntitlements:
      type: object
      properties:
        messagesRemaining:
          type: integer
          description: Messages left in the current period (Free/Basic)
          example: 3
        voiceMinutesRemaining:
          type: integer
          description: Voice minutes left in the current period (Free/Basic)
          example: 10
        periodEndsAt:
          $ref: '#/components/schemas/Timestamp'
          description: End of the current billing/usage period

    GardenUpdate:
      type: object
      properties:
        plantAdded:
          type: boolean
        plantType:
          type: string
          example: 🌱
        newStage:
          type: integer
          example: 2
        unlockedAt:
          $ref: '#/components/schemas/Timestamp'

    # === Authentication ===
    SignUpRequest:
      type: object
      required:
        - email
        - password
      properties:
        email:
          type: string
          format: email
          maxLength: 256
          example: user@example.com
        password:
          type: string
          minLength: 8
          pattern: ^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$
          description: At least 8 chars, one uppercase, one lowercase, one number
          example: SecurePass123!

    SignUpResponse:
      type: object
      properties:
        uid:
          type: string
          example: firebase_uid_123
        email:
          type: string
          example: user@example.com
        createdAt:
          $ref: '#/components/schemas/Timestamp'

    SignInRequest:
      type: object
      required:
        - email
        - password
      properties:
        email:
          type: string
          format: email
          example: user@example.com
        password:
          type: string
          example: SecurePass123!

    SignInResponse:
      type: object
      properties:
        uid:
          type: string
          example: firebase_uid_123
        email:
          type: string
          example: user@example.com
        subscriptionTier:
          type: string
          enum: [free, basic, premium]
          example: free
        profileConfidence:
          type: string
          enum: [provisional, established]
          example: provisional
        preferredLanguage:
          type: string
          enum: [en, ur, ur-roman]
          example: en
        sessionHistoryCount:
          type: integer
          example: 5

    # === Chat ===
    SendMessageRequest:
      type: object
      required:
        - sessionId
        - messageText
        - channel
      properties:
        sessionId:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          description: Existing session ID (returned from `createSession`)
          example: sess_abc123
        messageText:
          type: string
          minLength: 1
          maxLength: 2000
          example: I feel really anxious about work tomorrow.
        channel:
          type: string
          enum: [chat, voice, video]
          example: chat

    SendMessageResponse:
      type: object
      properties:
        reply:
          type: object
          properties:
            messageId:
              type: string
              example: msg_xyz789
            text:
              type: string
              example: I hear that you're feeling anxious about work. Let's pause...
            timestamp:
              $ref: '#/components/schemas/Timestamp'
        triggerExercise:
          type: object
          properties:
            type:
              type: string
              enum:
                - box_breathing
                - grounding
                - mindful_walking
                - release_tension
                - body_scan
                - cognitive_reframing
                - accept_emotions
                - stop_skill
            name:
              type: string
              example: Box Breathing
            script:
              type: string
              example: Breathe in for 4... hold for 4...
            durationSeconds:
              type: integer
              example: 120
            audioUrl:
              type: string
              format: uri
              example: https://storage.googleapis.com/peacemind-prod/audio/box_breathing.mp3
        remainingEntitlements:
          $ref: '#/components/schemas/RemainingEntitlements'
        crisisDetected:
          type: boolean
          example: false

    CreateSessionRequest:
      type: object
      required:
        - channel
      properties:
        channel:
          type: string
          enum: [chat, voice, video]
          example: chat

    CreateSessionResponse:
      type: object
      properties:
        sessionId:
          type: string
          example: sess_abc123
        createdAt:
          $ref: '#/components/schemas/Timestamp'
        channel:
          type: string
          enum: [chat, voice, video]
        state:
          type: string
          enum: [open, guarded, withdrawing, re-engaging]
          example: open

    GetSessionHistoryRequest:
      type: object
      properties:
        limit:
          type: integer
          minimum: 1
          maximum: 50
          default: 20
          example: 20
        cursor:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          description: Session ID of the last item from the previous page
          example: sess_xyz789

    GetSessionHistoryResponse:
      type: object
      properties:
        sessions:
          type: array
          items:
            type: object
            properties:
              sessionId:
                type: string
              channel:
                type: string
                enum: [chat, voice, video]
              state:
                type: string
                enum: [open, guarded, withdrawing, re-engaging]
              createdAt:
                $ref: '#/components/schemas/Timestamp'
              messageCount:
                type: integer
              lastMessagePreview:
                type: string
                maxLength: 100
        nextCursor:
          type: string
          description: Session ID for the next page
        hasMore:
          type: boolean

    GetMessagesRequest:
      type: object
      required:
        - sessionId
      properties:
        sessionId:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          example: sess_abc123
        limit:
          type: integer
          minimum: 1
          maximum: 100
          default: 50
          example: 50
        before:
          type: string
          description: Get messages before this message ID (for older messages)
          example: msg_xyz789

    GetMessagesResponse:
      type: object
      properties:
        messages:
          type: array
          items:
            type: object
            properties:
              messageId:
                type: string
              sender:
                type: string
                enum: [user, ai]
              text:
                type: string
              timestamp:
                $ref: '#/components/schemas/Timestamp'
        hasMore:
          type: boolean

    # === Tasks ===
    GetTasksRequest:
      type: object
      properties:
        status:
          type: string
          enum: [pending, completed, all]
          default: pending
          example: pending

    GetTasksResponse:
      type: object
      properties:
        tasks:
          type: array
          items:
            type: object
            properties:
              taskId:
                type: string
                example: task_123
              sessionId:
                type: string
                example: sess_abc123
              description:
                type: string
                example: Try noticing one moment of calm today.
              assignedAt:
                $ref: '#/components/schemas/Timestamp'
              status:
                type: string
                enum: [pending, completed]
              gardenGrowthApplied:
                type: boolean
                example: false

    SubmitTaskCompletionRequest:
      type: object
      required:
        - taskId
      properties:
        taskId:
          type: string
          example: task_123

    SubmitTaskCompletionResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        gardenUpdate:
          $ref: '#/components/schemas/GardenUpdate'

    # === Garden ===
    GetGardenStateResponse:
      type: object
      properties:
        plants:
          type: array
          items:
            type: object
            properties:
              plantType:
                type: string
                example: 🌱
              stage:
                type: integer
                minimum: 1
                maximum: 4
                example: 2
              unlockedAt:
                $ref: '#/components/schemas/Timestamp'
        totalPlants:
          type: integer
          example: 5
        nextMilestone:
          type: integer
          example: 10

    # === Mood ===
    LogMoodRequest:
      type: object
      required:
        - moodValue
        - source
      properties:
        moodValue:
          type: integer
          minimum: 1
          maximum: 10
          example: 4
        source:
          type: string
          enum: [tap, journal]
          example: tap

    LogMoodResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        logId:
          type: string
          example: mood_123
        timestamp:
          $ref: '#/components/schemas/Timestamp'

    GetMoodHistoryRequest:
      type: object
      properties:
        limit:
          type: integer
          minimum: 1
          maximum: 90
          default: 30
          example: 30
        startDate:
          type: string
          format: date
          description: Filter by date range (ISO date)
          example: 2026-08-01
        endDate:
          type: string
          format: date
          description: Filter by date range (ISO date)
          example: 2026-08-17

    GetMoodHistoryResponse:
      type: object
      properties:
        logs:
          type: array
          items:
            type: object
            properties:
              moodValue:
                type: integer
                minimum: 1
                maximum: 10
              timestamp:
                $ref: '#/components/schemas/Timestamp'
              source:
                type: string
                enum: [tap, journal]

    # === Reports ===
    GenerateSessionReportRequest:
      type: object
      required:
        - sessionId
      properties:
        sessionId:
          type: string
          example: sess_abc123

    GenerateSessionReportResponse:
      type: object
      properties:
        moodBefore:
          type: integer
          minimum: 1
          maximum: 10
          example: 4
        moodAfter:
          type: integer
          minimum: 1
          maximum: 10
          example: 7
        toolsUsed:
          type: array
          items:
            type: object
            properties:
              techniqueId:
                type: integer
              name:
                type: string
        insight:
          type: string
          example: You noticed that your anxiety is often triggered by work deadlines.
        nextStep:
          type: string
          example: Try the Cognitive Reframing exercise when you notice work-related anxiety.

    # === Crisis ===
    GetHelplinesRequest:
      type: object
      properties:
        countryCode:
          type: string
          minLength: 2
          maxLength: 2
          description: ISO country code (defaults to user's location or 'PK')
          example: PK

    GetHelplinesResponse:
      type: object
      properties:
        helplines:
          type: array
          items:
            type: object
            properties:
              name:
                type: string
              country:
                type: string
                description: ISO country code
              phoneNumbers:
                type: array
                items:
                  type: string
              type:
                type: string
              available24_7:
                type: boolean
              languages:
                type: array
                items:
                  type: string
              sms:
                type: boolean
              website:
                type: string
                format: uri

    # === Profile ===
    GetProfileResponse:
      type: object
      properties:
        uid:
          type: string
        email:
          type: string
        subscriptionTier:
          type: string
          enum: [free, basic, premium]
        profileConfidence:
          type: string
          enum: [provisional, established]
        preferredLanguage:
          type: string
          enum: [en, ur, ur-roman]
        createdAt:
          $ref: '#/components/schemas/Timestamp'

    UpdateProfileRequest:
      type: object
      properties:
        preferredLanguage:
          type: string
          enum: [en, ur, ur-roman]

    UpdateProfileResponse:
      type: object
      properties:
        success:
          type: boolean
        updatedFields:
          type: object

    UpdatePreferencesRequest:
      type: object
      properties:
        notificationsEnabled:
          type: boolean
          example: true
        reminderTime:
          type: string
          pattern: ^([01]\d|2[0-3]):([0-5]\d)$
          description: HH:MM 24-hour format
          example: 09:00
        reminderDays:
          type: array
          items:
            type: integer
            minimum: 1
            maximum: 7
          description: 1 = Monday, 7 = Sunday

    UpdatePreferencesResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true

    # === Coping Tools ===
    GetToolsResponse:
      type: object
      properties:
        tools:
          type: array
          items:
            type: object
            properties:
              techniqueId:
                type: integer
              name:
                type: string
              description:
                type: string
              isCompleted:
                type: boolean
              lastUsedAt:
                $ref: '#/components/schemas/Timestamp'
              totalUses:
                type: integer

    CompleteToolRequest:
      type: object
      required:
        - techniqueId
      properties:
        techniqueId:
          type: integer
          example: 1

    CompleteToolResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        gardenUpdate:
          $ref: '#/components/schemas/GardenUpdate'

    # === Data Export/Delete ===
    ExportUserDataRequest:
      type: object
      properties:
        format:
          type: string
          enum: [json, pdf]
          default: json
          example: json

    ExportUserDataResponse:
      type: object
      properties:
        downloadUrl:
          type: string
          format: uri
          example: https://storage.googleapis.com/peacemind-prod/export/user_data_123.zip
        expiresAt:
          $ref: '#/components/schemas/Timestamp'
        includes:
          type: array
          items:
            type: string

    DeleteUserDataRequest:
      type: object
      required:
        - confirm
      properties:
        confirm:
          type: boolean
          example: true

    DeleteUserDataResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        deletedAt:
          $ref: '#/components/schemas/Timestamp'
        dataRetentionDays:
          type: integer
          example: 30

    # === Voice ===
    StartVoiceSessionRequest:
      type: object
      required:
        - sessionId
      properties:
        sessionId:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          example: sess_abc123

    StartVoiceSessionResponse:
      type: object
      properties:
        sessionId:
          type: string
          example: sess_abc123
        uploadUrl:
          type: string
          format: uri
          description: Pre-signed URL for audio upload (expires in 60 seconds)
          example: https://storage.googleapis.com/peacemind-prod/voice/audio_123.m4a?token=...
        transcriptReady:
          type: boolean
          example: false
        maxDurationSeconds:
          type: integer
          example: 60

    StreamVoiceTurnRequest:
      type: object
      required:
        - sessionId
        - audioFileId
      properties:
        sessionId:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          example: sess_abc123
        audioFileId:
          type: string
          pattern: ^[a-zA-Z0-9_\-]+\.(m4a|mp3|wav)$
          example: audio_123.m4a

    StreamVoiceTurnResponse:
      type: object
      properties:
        transcript:
          type: string
          example: I feel really anxious about work tomorrow.
        reply:
          $ref: '#/components/schemas/SendMessageResponse/properties/reply'
        audioUrl:
          type: string
          format: uri
          description: Pre-signed URL for the AI voice reply
        triggerExercise:
          $ref: '#/components/schemas/SendMessageResponse/properties/triggerExercise'
        remainingEntitlements:
          $ref: '#/components/schemas/RemainingEntitlements'
        crisisDetected:
          type: boolean
          example: false

    StartLiveAudioCallRequest:
      type: object
      required:
        - sessionId
      properties:
        sessionId:
          type: string
          pattern: ^sess_[a-zA-Z0-9]+$
          example: sess_abc123

    StartLiveAudioCallResponse:
      type: object
      properties:
        callId:
          type: string
          example: call_456
        websocketUrl:
          type: string
          format: uri
          description: WebSocket endpoint for bidirectional audio
          example: wss://api.peacemind.ai/realtime/call_456
        turnToken:
          type: string
          description: One-time token for WebSocket authentication
          example: ws_token_xyz789
        expiresAt:
          $ref: '#/components/schemas/Timestamp'

    EndLiveAudioCallRequest:
      type: object
      required:
        - callId
        - durationSeconds
      properties:
        callId:
          type: string
          example: call_456
        durationSeconds:
          type: integer
          minimum: 0
          example: 180

    EndLiveAudioCallResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        transcriptSummary:
          type: string
          example: User discussed anxiety about work. AI suggested box breathing.
        sessionReportGenerated:
          type: boolean
          example: true

security:
  - FirebaseAuth: []

# === Deferred Endpoints (v2.0) ===
# The following endpoints are planned for v2.0:
# - applyUpgrade (subscription/upgrade)
# - bookDoctorAppointment (doctor booking)
# - getUpgradeOptions (pricing plans)
# - REST endpoints for doctor booking, payments, webhooks, and public API
```

---

## 16. Deferred APIs (v2.0+)

These endpoints are **planned for future versions** after the MVP launch. They are defined here to provide visibility into the future roadmap.

| Endpoint | Version | Description |
|----------|---------|-------------|
| `applyUpgrade` | v2.0 | Apply a subscription tier upgrade (payment processing) |
| `getUpgradeOptions` | v2.0 | Get available pricing plans |
| `bookDoctorAppointment` | v2.0 | Book a physical doctor visit (Premium) |
| `getDoctorAppointments` | v2.0 | List user's doctor appointments |
| `cancelDoctorAppointment` | v2.0 | Cancel a doctor appointment |
| REST `/v1/bookings` | v2.0 | Partner API for doctor bookings |
| REST `/v1/webhooks/payment` | v2.0 | Payment provider webhooks |
| REST `/v1/webhooks/doctor` | v2.0 | Doctor partner webhooks |
| REST `/v1/public/plans` | v2.0 | Public pricing API |

---

## 17. Summary

| Section | Status |
|---------|--------|
| **Authentication** | ✅ Complete |
| **Chat & Sessions** | ✅ Complete |
| **Voice** | ✅ Complete |
| **Tasks** | ✅ Complete |
| **Garden** | ✅ Complete |
| **Mood** | ✅ Complete |
| **Reports** | ✅ Complete |
| **Crisis** | ✅ Complete |
| **Profile & Preferences** | ✅ Complete |
| **Coping Tools** | ✅ Complete |
| **Data Export/Delete** | ✅ Complete |
| **Swagger/OpenAPI** | ✅ Complete |
| **Deferred APIs (v2.0)** | 📋 Defined |

---

## 18. Revision History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | August 17, 2026 | Initial version. Core mobile APIs (v1.0 MVP). Deferred v2.0 endpoints noted. |

---

## 19. Next Steps

1. **Review** this contract with the engineering team
2. **Generate Flutter models** from the schemas (using `json_serializable` or similar)
3. **Implement Cloud Functions** per the specifications
4. **Write integration tests** against the contract
5. **Set up mock server** for parallel frontend development

---

**This concludes the complete API Contract for PeaceMind AI v1.0.**