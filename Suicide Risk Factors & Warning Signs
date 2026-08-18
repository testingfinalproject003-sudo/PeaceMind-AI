# Suicide Risk Factors & Warning Signs

Reference document for the PeaceMind AI risk/crisis layer. Sourced only from credible public-health bodies — NIMH (U.S. National Institute of Mental Health) and WHO (World Health Organization). Internal reference for the app's risk logic and team understanding — **never shown to the user as a diagnostic checklist**.

> ⚠️ **Scope note:** This is educational/informational content, not a diagnostic tool. It should inform how the app recognizes and responds to risk (tone, escalation, resource surfacing) — it is not a substitute for clinical judgment, and PeaceMind AI should never attempt to "diagnose" suicide risk on its own.

---

## 1. Warning Signs (immediate-risk indicators)

Per NIMH, these are signs that someone may be at **immediate** risk and need urgent attention, especially when a behavior is new or has recently increased:

**Talking about:**
- Wanting to die or wanting to kill themselves
- Feeling empty, hopeless, or having no reason to live
- Feeling trapped, or that there are no solutions
- Great guilt or shame, or being a burden to others
- Unbearable emotional or physical pain

**Feeling / mood changes:**
- Extremely sad, more anxious, agitated, or full of rage
- Marked, sudden mood swings — including a sudden sense of calm or relief after a period of depression, which can itself be a warning sign rather than a sign of improvement

**Behavior changes:**
- Making a plan or researching ways to die
- Withdrawing from friends and activities, saying goodbye, giving away important possessions, or getting affairs in order
- Increasing alcohol or drug use
- Sleeping or eating noticeably more or less than usual
- Taking dangerous risks (e.g. driving recklessly)

---

## 2. Risk Factors (raise likelihood, don't predict on their own)

Per WHO, suicide is rarely caused by a single factor — it's usually a combination of factors converging. Most people who have risk factors will never attempt suicide, so these should be read as context, not prediction:

- **A previous suicide attempt** — by far the strongest single risk factor
- Mental health conditions, particularly depression and alcohol use disorders (though WHO notes many suicides also happen impulsively, in a moment of crisis, without any prior diagnosis)
- Experience of loss, loneliness, or isolation
- Relationship conflict or breakdown
- Financial problems
- Chronic pain or illness
- Violence, abuse, or conflict (including humanitarian crises)
- Discrimination — WHO specifically notes higher rates among groups facing discrimination (e.g. refugees/migrants, indigenous peoples, LGBTQ+ people, prisoners)
- Stigma around mental health and suicide, which itself keeps people from seeking help

Stressful life events (bereavement, legal trouble, financial difficulty) and interpersonal stressors (shame, harassment, bullying, relationship trouble) compound risk especially when they co-occur with the factors above.

---

## 3. How This Should Inform PeaceMind AI's Risk Layer

Ties directly into the risk/crisis sections already built for each personality type (`Avoidant-Withdrawn-Implementation.md`, `Impulsive-Reactive-Implementation.md`, `Low-Self-Esteem-Implementation.md`):

- **Warning signs** (Section 1) are the higher-urgency, more immediate signal — weight these more heavily in real-time escalation logic.
- **Risk factors** (Section 2) are contextual and slower-moving — useful for adjusting a user's baseline risk sensitivity over time, not for triggering an immediate crisis response on their own.
- A single risk factor is normal and not, by itself, actionable. A warning sign — especially combined with one or more risk factors — should raise escalation priority.
- Per WHO, many suicides happen impulsively in a moment of crisis with no prior mental health diagnosis — so the risk layer should never gate crisis-resource surfacing behind a "does this user have a known condition/profile" check. Explicit warning-sign language should always route to crisis resources regardless of personality-type profile or confidence score.

**Hard rule (already established in every implementation doc, repeated here for the risk-layer team):** any explicit self-harm/suicide language, from any user, always routes to the standard crisis-resource flow immediately, independent of personality-type tone/pacing logic.

---

## 4. Crisis Resources (for in-app surfacing)

- **US:** 988 Suicide & Crisis Lifeline — call or text 988, or chat at 988lifeline.org
- **Global:** WHO does not run a single global hotline; region-specific helplines should be surfaced based on the user's location/locale rather than hardcoding a US-only number for all users
- App should keep a crisis-resource option **persistently visible**, not just shown once during onboarding

---

## References

- National Institute of Mental Health (NIMH). *Warning Signs of Suicide.* https://www.nimh.nih.gov/health/publications/warning-signs-of-suicide
- National Institute of Mental Health (NIMH). *Frequently Asked Questions About Suicide.* https://www.nimh.nih.gov/health/publications/suicide-faq
- World Health Organization (WHO). *Suicide* (fact sheet). https://www.who.int/news-room/fact-sheets/detail/suicide
- World Health Organization (WHO). *Suicide* (health topic page). https://www.who.int/health-topics/suicide
