# PeaceMind AI — Which Alibaba Model Do We Actually Need?

*Updated version — includes the Qwen-Flash swap, CosyVoice, current token limits, our single-account decision, and the new live audio-call feature.*

## ⚡ Quick Answer

We don't need just **one** model — we need **five**, each doing a different job. Using one model for everything either wastes money or breaks quality.

| Model | Role in PeaceMind AI | Priority |
| --- | --- | --- |
| 🧠 **Qwen-Plus** | The main brain — runs every real conversation, personality detection, and silent PHQ-9/GAD-7/PSS scoring | **Must have** |
| 🎙️ **SenseVoice** | Reads tone and emotion when the user sends a one-off voice message in chat | **Must have** |
| ⚡ **Qwen-Flash** | Fast, cheap helper for small background tasks *(replaces Qwen-Turbo — Alibaba retired it)* | **Nice to have** (saves cost) |
| 🔊 **CosyVoice** | Reads our AI Avatar Scripts out loud — breathing guides, grounding scripts, calming narration | **New — worth adding** |
| 📞 **Qwen-Omni-Realtime** | Powers the **live audio call feature** — a real, back-and-forth spoken conversation with the AI | **New — needed for the call feature** |
| 📝 **Paraformer** | Transcribing long recorded audio with multiple speakers | **Not needed yet** |

---

## 🧠 1. Qwen-Plus — The Main Brain (Core Requirement)

This is the model that actually **talks to the user** in every session.

**Why it fits our exact spec:**
- We need the AI to hold a **multi-day, multi-session memory** (remember Day 1's "couldn't sleep" when Day 2's stress signal comes in) — Qwen-Plus has up to a **1,000,000 token context window**, enough to hold a user's entire conversation history, not just the last few messages.
- Our whole system runs on **silent background scoring** — PHQ-9, GAD-7, PSS — which needs the model to output clean, structured data (a hidden score + a warm reply) at the same time. Qwen-Plus is built for exactly this kind of structured output alongside natural conversation.
- Our disorder logic has real branching rules (18 disorders, tier levels, crisis overrides, personality adaptation) — this needs real reasoning, not just quick pattern-matching.

**Where it's used in our app:** every chat reply, every personality detection, every "which technique should I suggest" decision, every crisis-flow trigger.

---

## 🎙️ 2. SenseVoice — For Voice & Emotion (Core Requirement)

Look back at our own research document — almost every disorder entry lists **"Signs (text/voice)"** with lines like *"voice sounds shaky, scared, or too quiet"* or *"voice cracks or sounds flat."* That's not just text — that's tone detection, which a text model literally cannot do.

**Why it fits our exact spec:**
- If we let users **send a voice message** instead of typing, SenseVoice can detect the actual **emotion in their voice** — sad, anxious, flat — in real time.
- It's built for **live, real-time** input, not just recorded files — perfect for a chat-based check-in, not a slow upload-and-wait system.
- It handles multiple languages and regional accents well, which matters since our users may switch between English and Urdu mid-conversation.

**Where it's used in our app:** any voice-message feature, and detecting emotional tone as an extra signal feeding our background scoring (Section 0.1 in our research doc).

---

## ⚡ 3. Qwen-Flash — The Cost-Saving Helper *(Updated: replaces Qwen-Turbo)*

**Important update:** Alibaba has officially stopped updating Qwen-Turbo and now recommends **Qwen-Flash** as its replacement. Same role in our architecture, newer model.

We should **not** send every tiny task to Qwen-Plus — that's expensive and slower than it needs to be.

**Where Flash saves us money without losing safety:**
- **Crisis keyword pre-check**: before a message even reaches Plus, Flash does a first, ultra-fast pass to flag anything that might be self-harm or danger related — then Plus (or the Crisis Flow directly) takes over. This makes our safety response *faster*, not slower.
- **Quick intent routing**: deciding "is this a greeting, a real conversation, or a settings request?" doesn't need deep reasoning — Flash can route it instantly and cheaply.
- **High-volume simple replies**: short follow-up parsing (yes/no/short answer) doesn't need Plus-level intelligence.
- It also carries a full **1,000,000 token context window** now, at a fraction of Plus's price — so it's strictly better than the old Turbo for our use case.

**Important:** Flash should **never** be the model making the final call on anything disorder-related, crisis-related, or emotionally sensitive — it's a filter in front of Plus, not a replacement for it.

---

## 🔊 4. CosyVoice — Reading Our Scripts Out Loud *(New Addition)*

This is the one we were missing. Our own research doc already designed **AI Avatar Scripts** meant to be spoken aloud — the breathing screen literally says *"Breathe in through nose... hold... exhale"* as guided narration, and every coping activity (Box Breathing, Grounding, Release Tension) has a paced, spoken-style script.

**Why it fits our exact spec:**
- CosyVoice is Alibaba's speech-generation model — it can actually **speak** our existing avatar scripts in a calm, human-sounding voice instead of just showing text on screen.
- **Voice creation is free** — no cost to set up a custom calming voice for the app.
- Fits directly into features we already designed: the breathing circle screen, grounding walkthroughs, and the wind-down sleep routine all assumed a "spoken guide" experience.

**Where it's used in our app:** any guided activity screen — Box Breathing, Grounding 5-4-3-2-1, Release Tension, Settling Into Sleep.

---

## 📞 5. Qwen-Omni-Realtime — For The Live Audio Call Feature *(New Addition)*

This is a different need from CosyVoice and SenseVoice. Those two are for **one-off voice messages inside a chat** — user sends a voice note, AI reads it, AI speaks a script back. But a real **phone-call-style feature**, where the user talks and the AI responds back and forth live, like talking to a real person, needs a different kind of model.

**Why the other models can't do this alone:**
Stitching together SenseVoice (listen) → Qwen-Plus (think) → CosyVoice (speak) for every single sentence would be too slow for a live call — there would be an awkward delay after every sentence, and the AI couldn't handle the user interrupting mid-sentence the way a real conversation does.

**Qwen-Omni-Realtime solves this as one model:**
- It's a single, **end-to-end model** — it listens, understands, and speaks back in real time over one continuous connection, instead of three separate steps.
- **Handles natural interruptions.** If the user starts talking while the AI is still speaking, it knows the difference between the user actually interrupting versus just saying "mm-hmm" in the background — and stops naturally, like a real person would.
- **Full back-and-forth conversation**, not a request-then-wait pattern — this is what makes it feel like "real human discussion" instead of a chatbot reading messages aloud.
- Supports emotional tone control — the AI's voice can sound calmer, softer, or warmer depending on the moment, which matters a lot for a wellness app.
- Comes in two versions, same pattern as our other models: **qwen3.5-omni-plus-realtime** (higher quality, for the main call experience) and **qwen3.5-omni-flash-realtime** (cheaper, lighter option).
- Speech recognition works across many languages, including Urdu — good for our user base.

**Where it's used in our app:** the audio call feature specifically — this replaces the need to chain SenseVoice + Qwen-Plus + CosyVoice together for that one feature. Text chat still uses the original Qwen-Plus + Qwen-Flash setup; CosyVoice still handles the pre-written guided activity scripts (breathing, grounding) since those are fixed narration, not live conversation.

---

## 📝 6. Paraformer — Not Needed For Our Current App (Skip For Now)

Paraformer is built for **transcribing long recordings with multiple speakers** — think podcasts, meetings, interviews. Our app is a **1-on-1 conversation** between one user and the AI, not a multi-speaker recording.

**When we'd actually need it:** only if we later add a feature like "record your therapy session and get a transcript" or a group-support voice feature with several people talking. Good to know about, but not part of MVP.

---

## 🏗️ Suggested Architecture (How They Work Together)

```
Text chat / one-off voice message
        │
        ▼
 [Voice message?] ──Yes──▶ SenseVoice (emotion + text)
        │ No                          │
        ▼                             ▼
   Qwen-Flash (fast pre-check: greeting? crisis keyword? intent?)
        │
        ├── Crisis keyword found ──▶ Crisis Flow (immediate, safety first)
        │
        └── Normal message ──▶ Qwen-Plus (full reasoning, personality
                                 detection, silent PHQ-9/GAD-7/PSS
                                 scoring, warm human-like reply)
                                         │
                                         ▼
                              CosyVoice (speaks the reply out loud,
                              only on guided-activity screens)

Live audio call feature (separate path)
        │
        ▼
Qwen-Omni-Realtime (listens, understands, and speaks back live,
                     handles interruptions, one continuous call —
                     same crisis-keyword safety rules still apply)
```

---

## 💰 Free Quota & Token Limits (Current)

We are using **one official Alibaba Cloud Model Studio account** for PeaceMind AI, registered under the project.

| Model | Context / Limit | Approx. Price (per 1M tokens) | Free Quota |
| --- | --- | --- | --- |
| Qwen-Plus | 1,000,000 tokens (price steps up above 256K input) | ~$0.40 input / $2.40 output | 1,000,000 free tokens, 90 days |
| Qwen-Flash | 1,000,000 tokens | ~$0.10 input / $0.40 output | 1,000,000 free tokens, 90 days |
| SenseVoice | Billed by audio duration, not tokens | Low per-minute cost | 90-day trial included |
| CosyVoice | Instruction text limit: 1,600 tokens per request | Voice creation: free | Free voice creation, 90 days |
| Qwen-Omni-Realtime | 256K context, handles 10+ hours of audio per session | Billed per session/minute (check console for live rate) | 90-day trial included |
| Paraformer | Billed by audio duration | Per-minute cost | 90-day trial included |

**Notes:**
- The free quota is **per model**, not shared — so Qwen-Plus and Qwen-Flash each get their own 1M free tokens.
- Free quota only applies in the **Singapore region** and lasts **90 days** from account activation.
- After the free quota is used, the account switches to normal pay-as-you-go billing — no service interruption, just billed usage.
- **Batch calls get a 50% discount** — worth using for anything that doesn't need to be instant, like background scoring passes.

---

## 💡 Why This Setup Is Actually Cheaper, Not More Expensive

Using 4 models sounds like more cost, but it's the opposite:
- Flash handles the high-volume, simple stuff for pennies, so Plus (the expensive one) is only called when real thinking is needed.
- SenseVoice and CosyVoice only run when a user actually sends or needs voice — they don't add cost to text-only chats.
- One-model-for-everything (all on Plus) would cost more overall, because every tiny message would pay full price.
