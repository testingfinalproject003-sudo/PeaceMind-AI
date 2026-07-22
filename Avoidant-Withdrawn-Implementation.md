# PeaceMind AI — Implementation Guide: Avoidant/Withdrawn Type

Builds on `Avoidant-Withdrawn-Research.md`. This doc turns that research into buildable pieces: detection, conversation logic, data model, risk detection, and prompt design.

---

## 1. Where This Fits in the Existing Pipeline

```
Onboarding → AI Personality Assessment → Type Classification (stored on user profile)
                                              ↓
                          Conversation Engine reads type → adapts behavior
                                              ↓
                    Mood Tracking + Journaling → Signal Extraction → Risk Layer
                                              ↓
                            Progress Dashboard + Crisis Resource Layer
```

The Avoidant/Withdrawn type isn't a separate feature — it's a **behavior profile that conditions three existing systems**: the conversation engine, the signal-extraction layer, and the risk/crisis layer. Implement it as a profile config + prompt module + signal ruleset, not a standalone module.

---

## 2. Detection / Classification

**Inputs to the classifier (during onboarding assessment + first few sessions):**
- Self-report assessment answers (Likert-style items, e.g., "I usually keep my problems to myself," "I've been hurt before when I opened up to someone")
- Early usage signals: short answer length, high deflection-phrase frequency, low emotion-word usage relative to fact-word usage

**Approach:**
- Use the onboarding questionnaire for an initial label (rule-based scoring is fine here — don't over-engineer with ML for a 10-15 item assessment).
- Treat the label as **provisional and adaptive**, not fixed. Re-score every N sessions using behavioral signals (Section 4) so the profile updates if the user's pattern shifts (e.g., opens up more over time — the app should notice and ease off the avoidant-specific pacing).
- Store as a **profile weight (0–1 scale)** rather than a hard category if you're supporting multiple types — most real users are a blend (e.g., 0.7 Avoidant/Withdrawn, 0.3 Anxious). This lets the conversation engine blend behaviors instead of hard-switching personas.

```json
// example user profile fragment
{
  "personality_profile": {
    "avoidant_withdrawn": 0.72,
    "anxious": 0.15,
    "low_self_esteem": 0.40
  },
  "profile_confidence": "provisional", // provisional | established
  "last_rescored_at": "2026-07-15T00:00:00Z"
}
```

---

## 3. Conversation Engine Adaptation

### 3.1 System prompt module (Alibaba Cloud AI / Qwen)

Keep this as a **composable prompt fragment** injected into the base companion system prompt when `avoidant_withdrawn` weight is above a threshold (e.g., >0.5):

```
When the user shows avoidant/withdrawn patterns:
- Do not ask direct "how do you feel" questions in the first messages of a session.
- Prefer fact-based, low-pressure openers over emotion-first openers.
- If the user gives a short or deflecting answer, do NOT press further in the same turn.
  Acknowledge briefly and leave space: e.g. "That's okay, no need to go into it."
- Never name or call out the avoidance pattern directly to the user.
- Offer structured choices (talk / journal / mood tag / just sit quietly) instead of
  open-ended prompts.
- Increase validation-only responses; decrease follow-up-question density.
- If message length or response speed drops compared to the user's recent baseline,
  shift to lower-intensity, higher-safety language for the rest of the session.
```

This should be model-agnostic — store it as a template string with variables (`{recent_baseline}`, `{session_count}`) filled in at request time, so you're not hardcoding thresholds into the prompt.

### 3.2 Conversation state machine

Add a lightweight state per session:

| State | Trigger | Behavior |
|---|---|---|
| `open` | Normal engagement | Standard prompt flow |
| `guarded` | 2+ deflection signals in a row | Switch to low-pressure mode; offer choice menu |
| `withdrawing` | Message length drop + latency increase + topic switch | Stop follow-ups; offer to end gently or switch to passive mode (breathing exercise, journaling with no follow-up) |
| `re-engaging` | User returns after a `withdrawing` session | Do NOT reference the previous withdrawal; start fresh, low-pressure |

This state should live server-side per session, not persist as a permanent label — it resets each session while the underlying `personality_profile` score persists long-term.

---

## 4. Signal Extraction Layer

This is the pipeline that turns raw chat/journal data into the behavioral signals from the research doc. Suggested to build as a lightweight middleware that runs after each user message, before the AI response is generated (so the response can adapt in real time).

**Signals to compute per message/session:**

```python
signals = {
    "message_length_delta": current_len - rolling_avg_len,       # negative = shrinking
    "response_latency_delta": current_latency - rolling_avg_latency,
    "deflection_phrase_hit": bool,   # matched against a phrase list, e.g. "it's fine", "doesn't matter", "not important"
    "topic_switch_detected": bool,   # simple heuristic: embedding similarity drop between turns
    "emotion_word_ratio": emotion_words / total_words,
    "mood_tag_text_mismatch": bool,  # e.g. logged mood = "low" but journal text is neutral/flat
    "session_gap_days": days_since_last_session,
}
```

Implementation notes:
- Deflection-phrase matching: start with a curated phrase list + fuzzy matching, upgrade to embedding-similarity matching later if the list undershoots.
- Emotion-word ratio: use a small emotion lexicon (e.g., NRC Emotion Lexicon or a custom list) rather than calling the LLM for this — cheaper and faster for a per-message signal.
- Topic switch detection: cheap sentence-embedding cosine similarity between consecutive user turns is enough; don't need a heavy classifier here.
- Keep this layer **fast and local** (no LLM call) since it needs to run on every message to inform that same turn's response.

**Rolling baseline:** compute per-user rolling averages (last 5–10 sessions) for message length and latency so "shrinking" is relative to *that user's* normal, not a global average — critical, since a naturally terse user shouldn't be flagged constantly.

---

## 5. Risk / Crisis Layer

This type under-reports distress in words, so **don't rely on keyword-based crisis detection alone** — it will systematically under-trigger for this profile.

**Escalation logic specific to this type:**
- Weight *behavioral disengagement* signals (sudden total drop-off after a heavier session, mood-tag decline with empty/neutral text, late-night usage spikes) alongside explicit distress language when deciding whether to surface crisis resources.
- If `avoidant_withdrawn` score is high AND behavioral risk signals cross a threshold, surface crisis resources **passively** — a persistent, low-key "talk to someone now" option — rather than an interruptive modal, which this type is more likely to react to by disengaging entirely.
- Log a flag for human/clinical-advisor review (if your product has one) rather than only an automated pop-up, for borderline cases where confidence is low but stakes are high.

**Hard rule regardless of type:** any explicit self-harm/suicide language, from any user, always routes to your standard crisis-resource flow immediately — the personality-adapted pacing logic above only governs *tone and delivery*, never whether a genuine crisis signal gets surfaced.

---

## 6. Data Model Additions

```sql
-- profile-level (persists)
ALTER TABLE user_profiles ADD COLUMN personality_profile JSONB;
ALTER TABLE user_profiles ADD COLUMN profile_confidence TEXT DEFAULT 'provisional';
ALTER TABLE user_profiles ADD COLUMN last_rescored_at TIMESTAMP;

-- session-level (resets each session)
CREATE TABLE session_signals (
  session_id UUID PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(id),
  state TEXT DEFAULT 'open', -- open | guarded | withdrawing | re-engaging
  message_length_avg FLOAT,
  latency_avg FLOAT,
  deflection_count INT DEFAULT 0,
  topic_switch_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT now()
);

-- rolling baseline (for relative comparisons)
CREATE TABLE user_baselines (
  user_id UUID PRIMARY KEY REFERENCES user_profiles(id),
  avg_message_length FLOAT,
  avg_response_latency FLOAT,
  updated_at TIMESTAMP DEFAULT now()
);
```

---

## 7. UI/UX Implementation Notes

- **Private vault**: surface a visible, reassuring "only you can see this" indicator directly above any journaling prompt for this type — not just in settings/onboarding once.
- **Choice-based entry points**: replace a single "How are you feeling today?" text box with a row of options (Talk / Journal privately / Just log a mood / Breathing exercise) when `avoidant_withdrawn` is high — reduces the perceived demand to produce words.
- **No "we noticed you've been quiet" messaging** — this recreates the original wound (being called out). If you want to re-engage a disengaged user, do it via a neutral, low-pressure notification ("Whenever you're ready, I'm here") not a pattern-callout.
- **Progress dashboard**: for this type, consider showing engagement trends (e.g., "you've checked in 4 times this week") rather than emotion-depth metrics, since visible "you're still not opening up" framing would backfire.

---

## 8. Testing & Validation

- **Prompt regression tests**: maintain a small eval set of scripted conversations (short/deflecting user replies) and check that the model doesn't press for more disclosure within the same turn.
- **Signal accuracy**: manually label a sample of real (or synthetic) sessions for withdrawal state and check precision/recall of the `guarded`/`withdrawing` state triggers before trusting them to drive UX changes.
- **A/B consideration**: if you have enough users, test choice-menu entry points vs. open text boxes specifically for users scoring high on this profile, and measure session return rate rather than message volume (return rate is the more meaningful signal for this type — volume will naturally stay low).

---

## Suggested Build Order

1. Onboarding assessment scoring → `personality_profile` field (fast to ship, unlocks everything else)
2. Prompt module injection based on profile weight (biggest UX impact for least engineering effort)
3. Signal extraction middleware + rolling baselines
4. Session state machine (`open/guarded/withdrawing/re-engaging`)
5. Risk layer integration (behavioral + keyword-based, combined)
6. UI adjustments (choice menus, vault framing, dashboard framing)
7. Re-scoring loop to keep the profile adaptive over time
