# PeaceMind AI — Implementation Guide: Impulsive/Reactive Type

Builds on `Impulsive-Reactive-Research.md`. This doc turns that research into buildable pieces: detection, conversation logic, data model, risk detection, and prompt design.

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

The Impulsive/Reactive type isn't a separate feature — like Avoidant/Withdrawn, it's a **behavior profile that conditions the same three systems**: the conversation engine, the signal-extraction layer, and the risk/crisis layer. Implement it as a profile config + prompt module + signal ruleset, not a standalone module.

Where this type differs structurally from Avoidant/Withdrawn: that type under-expresses and the risk is *missed* distress; this type over-expresses in the moment and the risk is *acted-on* distress — the gap between feeling and action is short, so timing matters more than wording.

---

## 2. Detection / Classification

**Inputs to the classifier (during onboarding assessment + first few sessions):**
- Self-report assessment answers (Likert-style items, e.g., "I say or do things in the heat of the moment that I regret later," "I find it hard to calm down once I'm upset")
- Early usage signals: fast reply latency, high-intensity/anger-word usage, frequent punctuation intensity (caps, multiple exclamation marks), sudden message-length spikes (venting bursts) rather than gradual buildup

**Approach:**
- Use the onboarding questionnaire for an initial label (rule-based scoring, same as the Avoidant/Withdrawn type — no need for ML on a 10–15 item assessment).
- Treat the label as **provisional and adaptive**. Re-score every N sessions using behavioral signals (Section 4) so the profile updates if the user develops more regulation over time (the app should notice and ease off the de-escalation-heavy pacing).
- Store as a **profile weight (0–1 scale)**, blendable with other types (e.g., 0.65 Impulsive/Reactive, 0.3 Anxious) — most real users aren't a pure type.

```json
// example user profile fragment
{
  "personality_profile": {
    "impulsive_reactive": 0.68,
    "anxious": 0.30,
    "avoidant_withdrawn": 0.10
  },
  "profile_confidence": "provisional", // provisional | established
  "last_rescored_at": "2026-07-15T00:00:00Z"
}
```

---

## 3. Conversation Engine Adaptation

### 3.1 System prompt module (Alibaba Cloud AI / Qwen)

Composable prompt fragment, injected when `impulsive_reactive` weight is above a threshold (e.g., >0.5):

```
When the user shows impulsive/reactive patterns:
- Do not mirror the user's intensity. Keep tone calm, steady, and non-escalating
  regardless of how heated the user's message is.
- Never say "calm down" or any variant — it reads as dismissive and tends to escalate
  further. Instead, validate the feeling before addressing the situation:
  e.g. "That sounds really frustrating. Let's take a second before anything else."
- Do not problem-solve or offer advice in the same turn as a high-intensity message.
  Logic-first responses don't land while someone is dysregulated — offer a brief
  grounding option first (STOP skill, box breathing, or a short pause) and only move
  to problem-solving once intensity has visibly dropped.
- Do not ask the user to reflect on "why" they reacted that way mid-episode. Save
  reflection/reframing for after the intensity has passed, not during it.
- Offer a fast, low-friction pause action (one-tap breathing timer, STOP skill card)
  rather than a text prompt — typing is a poor fit for someone in a reactive state.
- If message length spikes and intensity markers rise compared to the user's recent
  baseline, shift immediately to short, steady, low-stimulation responses for the
  rest of the exchange — no long paragraphs, no multiple questions at once.
```

Store as a template string with variables (`{recent_baseline}`, `{session_count}`) filled in at request time, same as the Avoidant/Withdrawn module.

### 3.2 Conversation state machine

| State | Trigger | Behavior |
|---|---|---|
| `open` | Normal engagement | Standard prompt flow |
| `escalating` | Rising intensity markers (caps, exclamation density, anger words) across 2+ consecutive messages | Switch to steady, short-response mode; surface pause action immediately |
| `volatile` | High-intensity language + fast reply latency + explicit anger/regret language in same window | Stop problem-solving entirely; single grounding prompt only (STOP skill / breathing), no follow-up questions |
| `cooling` | Intensity markers dropping, latency lengthening, tone softening after a `volatile` session | Gentle re-entry; light reflection only if user initiates it, not the app |
| `re-engaging` | User returns after a `volatile` or `escalating` session | Do NOT reference the previous outburst or "check in" about it unless the user brings it up — starting fresh avoids shame-driven re-escalation |

Session-scoped, not a permanent label — resets each session while `personality_profile` persists long-term.

---

## 4. Signal Extraction Layer

Lightweight middleware running after each user message, before the AI response is generated, same placement as the Avoidant/Withdrawn pipeline.

**Signals to compute per message/session:**

```python
signals = {
    "message_length_delta": current_len - rolling_avg_len,        # positive spike = venting burst
    "response_latency_delta": current_latency - rolling_avg_latency,  # negative = faster/more impulsive
    "intensity_word_ratio": intensity_words / total_words,          # anger/frustration lexicon
    "caps_ratio": caps_chars / total_chars,
    "exclamation_density": exclamation_marks / total_sentences,
    "regret_phrase_hit": bool,   # matched against phrase list, e.g. "I shouldn't have", "I didn't mean it"
    "escalation_trend": sentiment_delta_across_turns,               # rising negative sentiment within session
    "session_gap_days": days_since_last_session,
}
```

Implementation notes:
- Intensity-word ratio: small anger/frustration lexicon (NRC Emotion Lexicon anger/anticipation categories work, or a custom list) — same reasoning as the Avoidant/Withdrawn emotion-word ratio: cheap, local, no LLM call needed per message.
- Caps ratio / exclamation density: trivial to compute, but surprisingly strong early signal for this type specifically — worth weighting more heavily than for other profiles.
- Escalation trend: track sentiment turn-over-turn within a session rather than a single-message score — one heated message isn't `volatile`, a rising trend across 2–3 is.
- Keep this layer **fast and local**, same constraint as Avoidant/Withdrawn — it has to inform the same turn's response, and for this type response speed matters more (a slow app response during a reactive moment is itself a frustration trigger).

**Rolling baseline:** per-user rolling averages (last 5–10 sessions) for latency and intensity, so escalation is relative to *that user's* normal — someone who's naturally expressive shouldn't get flagged as `volatile` at their normal baseline.

---

## 5. Risk / Crisis Layer

This type over-expresses distress in words but the actual risk is **short deliberation time between feeling and action** — impulsivity narrows the gap that would normally let someone talk themselves down.

**Escalation logic specific to this type:**
- Weight the *combination* of high intensity + fast latency + explicit action language ("I'm going to...", "I can't take this anymore and I'm going to...") more urgently than for other profiles — the same words from a slower-building user might warrant a passive resource surface, but a burst message from this profile warrants an immediate, direct crisis-resource prompt.
- Do not rely on a cooling-off delay before surfacing resources for this type — waiting for the `volatile` state to naturally settle is appropriate for tone-of-response, but never for withholding crisis resources when explicit risk language appears.
- Log a flag for human/clinical-advisor review on borderline cases, same as Avoidant/Withdrawn, but treat the review queue for this type as higher-priority given shorter action latency.

**Hard rule regardless of type:** any explicit self-harm/suicide or harm-to-others language, from any user, always routes to the standard crisis-resource flow immediately — the personality-adapted pacing above only governs *tone and delivery*, never whether a genuine crisis signal gets surfaced.

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
  state TEXT DEFAULT 'open', -- open | escalating | volatile | cooling | re-engaging
  message_length_avg FLOAT,
  latency_avg FLOAT,
  intensity_word_ratio FLOAT,
  caps_ratio FLOAT,
  regret_phrase_count INT DEFAULT 0,
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

(Same tables as Avoidant/Withdrawn — `state` enum values differ per type; consider a shared `session_signals` table with a type-specific `state` domain rather than duplicating the schema per personality type.)

---

## 7. UI/UX Implementation Notes

- **One-tap pause tool**: surface a breathing timer or STOP-skill card as a single tappable action, not buried in a menu — for this type, the friction of typing during a reactive moment is itself a barrier.
- **Fast response time matters**: app latency itself becomes a frustration trigger for this profile more than others — prioritize this type's conversation flow for low-latency responses where possible.
- **No outburst callouts**: never surface "you've had 3 heated sessions this week" style framing — this reads as a scoreboard of failures and invites shame-driven re-escalation, mirroring the "we noticed you've been quiet" anti-pattern from Avoidant/Withdrawn but for the opposite reason.
- **Progress dashboard**: show streaks or counts of *regulation tool use* ("you used the pause tool 4 times this week") rather than counts of escalation events — reinforces the coping behavior instead of the reactive one.
- **Re-engagement notifications**: neutral and low-pressure, same principle as Avoidant/Withdrawn ("Whenever you're ready, I'm here") — never referencing the prior outburst.

---

## 8. Testing & Validation

- **Prompt regression tests**: maintain a small eval set of scripted high-intensity conversations (caps, exclamation-heavy, anger language) and check the model never mirrors intensity, never says "calm down," and doesn't attempt problem-solving in the same turn as a high-intensity message.
- **Signal accuracy**: manually label a sample of real (or synthetic) sessions for `escalating`/`volatile` state and check precision/recall before trusting the state machine to drive UX changes — false positives here (flagging normal expressiveness as volatile) are as costly as misses.
- **A/B consideration**: if you have enough users, test one-tap pause tool vs. text-based check-in for users scoring high on this profile, and measure de-escalation time (how fast intensity signals drop within a session) rather than message volume — volume is a poor signal for this type since venting bursts are expected.

---

## Suggested Build Order

1. Onboarding assessment scoring → `personality_profile` field (fast to ship, unlocks everything else)
2. Prompt module injection based on profile weight (biggest UX impact for least engineering effort)
3. Signal extraction middleware + rolling baselines
4. Session state machine (`open/escalating/volatile/cooling/re-engaging`)
5. Risk layer integration (behavioral + keyword-based, tuned for shorter action latency)
6. UI adjustments (one-tap pause tool, regulation-streak dashboard framing)
7. Re-scoring loop to keep the profile adaptive over time
