# PeaceMind AI — Research Entries (Javeria Usmani)

**Total Items:** 28 (18 Disorders & Issues · 2 Personality Profiles · 8 Coping Activities)
**Tier key:** 🟢 Standard · 🚩 Flagged · 🚨 Crisis

---

## 0. How the AI Should Talk to the User

- **Talk like a caring, respectful friend — not too casual, not a robot.** Warm and human, but no slang, no joking around, no being clingy.
- **Use the person's name** sometimes, not every line — just enough to feel personal, like "Take a breath, Ayesha, I'm right here with you."
- **Notice the feeling behind the words, not just the words.** Tone, short replies, long pauses, fast typing — all of this tells the AI something. Change pace and warmth based on what the person is really showing.
- **Make the conversation itself feel safe — don't just tell someone to "go be safe."** If someone says they don't feel safe (like in Domestic Violence 🚨), the AI should keep the chat itself calm and discreet, use code words, and let the person set the pace — instead of just saying "leave" and ending the chat. Stay with them.

---

## 0.1 🧠 Background Check-In Logic (Never Shown to the User as a Test)

These are simple, well-known question sets used only by the AI, in the background. The AI never shows these as a form or a quiz, never gives a diagnosis, and never says a score out loud. The user just has a normal chat — the AI quietly listens for these patterns in what's already being said, and keeps score behind the scenes.

- 💬 **The user only ever has a normal, human conversation.** No test, no form, no "please rate 0 to 3."
- 🧩 **The AI matches the meaning, not the exact words.** If someone says "I can't sleep and nothing feels fun anymore," that already answers two PHQ-9 questions — the AI doesn't need to ask them directly.
- 🔒 **Scoring stays behind the scenes.** It gets saved quietly to the session history, so the AI (and later, the team) can see if things are improving or getting worse over time.
- 🚫 **No diagnosis, ever.** The AI never says "you have depression" or gives a score to the user. If the pattern looks moderate-to-severe over time, the AI gently encourages talking to a real doctor or therapist — nothing more.
- 🚨 **Crisis answers skip everything else.** Any hint of self-harm or wanting to die goes straight to the Crisis Flow immediately, no matter what the running score says.

### 🎯 Example Check-In Tasks (how the signal actually gets collected)

The AI never asks the real questions — it drops small, natural check-ins into the conversation, and the answer quietly feeds the right screener.

- 🟦 *For depression signal:* "What's one small thing you're looking forward to this week?" · "How did you sleep last night?"
- 🟨 *For anxiety signal:* "Does your body feel keyed up today, or calmer than usual?" · "Was today more of a worry day or an easy day?"
- 🟩 *For stress signal:* "Did today feel manageable, or like things piled up?" · "Did you get a chance to switch off today?"

A flat, tired, or worried answer to these — repeated over several days — quietly builds the signal. One answer never means anything on its own.

### 🟦 PHQ-9 — Depression Signal
The AI listens for these over time, not all at once:
- Little interest or pleasure in doing things
- Feeling down, sad, or hopeless
- Trouble sleeping, or sleeping too much
- Feeling tired or low on energy
- Poor appetite or eating too much
- Feeling bad about themselves, or like they've let people down
- Trouble focusing on things like reading or TV
- Moving or talking slower than normal, or being restless
- Thoughts of being better off dead, or of hurting themselves 🚨

Each one is silently scored 0 to 3 based on how often it seems to show up. The total (0–27) is tracked in the history only:
- 0–4 minimal
- 5–9 mild
- 10–14 moderate
- 15–19 moderately severe
- 20–27 severe

*(Runs quietly alongside the Depression entry below.)*

### 🟨 GAD-7 — Anxiety Signal
The AI listens for these over time:
- Feeling nervous anxious or on edge
- Not being able to stop or control worrying
- Worrying too much about different things
- Trouble relaxing
- Being so restless it's hard to sit still
- Getting easily annoyed or irritable
- Feeling afraid like something bad might happen

Same silent 0–3 scoring, total 0–21, tracked in history only:
- 5 mild
- 10 moderate
- 15 severe

*(Runs quietly alongside the Anxiety entry below.)*

### 🟩 PSS — Stress Signal
The AI listens for these over time:
- Feeling unable to control the important things in their life
- Feeling confident about handling personal problems
- Feeling like things are going their way
- Feeling unable to cope with everything they have to do
- Feeling like problems are piling up too high to get over

Scored silently 0–4 per signal, tracked in history only.

*(Runs quietly alongside Working from Home · Tradepeople & Contractors · Life Changes below.)*


---

## 1. 🧠 Disorders & Issues

### 1. Domestic Violence 🚨 *(cluster: Trauma & Safety)*

| Heading | Content |
| --- | --- |
| **What it is** | When a partner or family member hurts someone — physically, emotionally, sexually, or mentally — to control and scare them. It keeps happening, it's not a one-time bad day, and it is never the victim's fault. |
| **Why it occurs** | The abuser wants power and control, not anything the victim did wrong. It usually goes in a cycle — tension builds, abuse happens, then a "making up" phase that keeps the person hoping things will change and feeling stuck. |
| **Signs (text/voice)** | Voice sounds shaky, scared, or too quiet; short, nervous texts; replies suddenly stop; makes excuses for the other person ("they didn't mean it"); mentions an injury without explaining it. |
| **Triggers** | A partner checking their phone, loud noises, arguments, being asked where they are, hearing a car pull up, or anything about an unsafe home. |
| **Thought pattern** | "If I just do better, they'll stop." "No one will believe me." "It's my fault." "I have nowhere to go." "It's not that bad." |
| **Self-view / Behavior / Social pattern** | Feels worthless and stuck; walks on eggshells; always "available" for the partner; cancels plans suddenly; may hide injuries; cut off from friends and family — often on purpose by the abuser. |
| **Best-fit activities (2–4 + why)** | **Notice 3 Things** — quiet and quick, can even be done silently with the partner nearby. **Breathing (Box Breathing)** — calms panic without needing to look at a screen. *Do not suggest journaling — the partner might find it, and this isn't a general coping situation anyway.* |
| **How AI should respond** | 🚨 **CRISIS — skip normal steps.** No probing questions, no general coping tips first. Ask gently, by name: "Are you okay to keep chatting right now?" Then focus on making *this chat* feel safe — quiet wording, a fast way to exit the screen, a code word, no pushing for details they haven't shared. Never say "just leave" or ask "why don't you leave." Share real help (a helpline, a safe next step) once they've been heard, and stay with them the whole time. |
| **App UI / Visual Design** | **Emergency screen** with a red "Quick Exit" button always visible; app icon disguised as something ordinary (weather/calculator); one-tap **panic button** to call a helpline or trusted contact; downloadable **Safety Plan card** with local shelters and code words for friends. |
| **Sources used** | 1. World Health Organization (WHO) — Violence Against Women, who.int/news-room/fact-sheets/detail/violence-against-women · 2. National Domestic Violence Hotline — thehotline.org · 3. NHS — nhs.uk/live-well/getting-help-for-domestic-violence · 4. Refuge — refuge.org.uk |

### 2. Grief 🚩 *(cluster: Mood)*

| Heading | Content |
| --- | --- |
| **What it is** | The deep sadness and emptiness after losing someone or something important — love with nowhere left to go. It's not a disorder, but the feelings can be strong and messy. |
| **Why it occurs** | The mind and body are trying to get used to a world that has changed for good, after a death or any big loss (a relationship, health, a pet, a way of life). |
| **Signs (text/voice)** | Voice cracks or sounds flat; long pauses; says "I should be over this by now"; talks about the person as if they're still here; sadness that comes and goes without warning. |
| **Triggers** | Anniversaries, holidays, hearing "their" song, finding old photos, being asked "how are you holding up." |
| **Thought pattern** | "I'll never feel happy again." "It's not fair." "I should have done more." "Who am I without them?" |
| **Self-view / Behavior / Social pattern** | Pulls away from friends, or swings between talking about it constantly and avoiding it; can't focus at work; forgets to eat or sleep. |
| **Best-fit activities (2–4 + why)** | **Accepting emotions without judgement** — grief has no timeline, so this helps stop fighting the pain. **Mindful Walking** — gentle movement for when they feel stuck. **Seeing life more positively** — small moments of light, never fake positivity. |
| **How AI should respond** | 🚩 Extra care here. Warm, patient, slow. Never say "they're in a better place" or rush anyone through "stages" of grief. Say instead: "This is so hard. I'm here with you." Let them cry, don't rush to fix anything — and if there's any sign they can't function or are thinking of hurting themselves, move to the crisis flow right away. |
| **App UI / Visual Design** | **Memory Garden screen** — upload a photo, light a virtual candle, write unsent letters (see Chart 4 below). **Grief Wave Tracker** — a visual chart showing grief isn't a straight line, normal ups and downs. Soft colors (lavender, soft blue). |
| **Sources used** | 1. NHS — nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/grief-bereavement-loss · 2. Mind — mind.org.uk/information-support/guides-to-support-and-services/bereavement · 3. Mental Health UK — mentalhealth-uk.org/help-and-information/grief · 4. HelpGuide — helpguide.org/mental-health/grief/coping-with-grief-and-loss |

### 3. Anxiety 🟢 *(cluster: Anxiety & Panic)*

| Heading | Content |
| --- | --- |
| **What it is** | Ongoing worry, unease, or fear that gets in the way of daily life — like an alarm stuck in the "on" position, shouting danger even when the person is safe. |
| **Why it occurs** | A mix of the brain's fear system being over-active, chemical imbalance, family history, and past stressful experiences that keep the nervous system on high alert. |
| **Signs (text/voice)** | Talks fast; lots of "what if" messages; keeps asking for reassurance; mentions a racing heart or tight chest; types and deletes messages; can't settle on an answer. |
| **Triggers** | Not knowing what will happen, upcoming events (exams, interviews), health scares, conflict, deadlines, news, changes in routine — sometimes no clear trigger at all. |
| **Thought pattern** | Always expecting the worst outcome: "What if something bad happens?" "I can't handle this." "Everyone is judging me." |
| **Self-view / Behavior / Social pattern** | Feels unable to cope with not knowing; over-prepares for everything; avoids the thing that worries them; keeps checking or asking for reassurance; may pull back from social plans. |
| **Best-fit activities (2–4 + why)** | **Breathing (Box Breathing)** — calms the body's panic response directly. **Grounding 5-4-3-2-1** and **Notice 3 Things** — quick ways to break the anxiety spiral fast. |
| **How AI should respond** | Comfort first, calm and steady tone (don't match their panic), one question at a time. Say "this feels really scary right now, but you are safe," then walk through one simple grounding step, instead of just giving logical reasons why it's fine. |
| **Screening signal** | 🟨 **GAD-7** — tracked silently in the background, never shown as a test. *Example tasks:* "does your body feel keyed up today, or calmer than usual?" · after a busy day, "was today more of a worry day or an easy one?" Small, casual questions like these quietly build the signal over time. |
| **App UI / Visual Design** | **Anxiety Tracker** — calendar view showing anxiety level 1–10 with notes on what triggered it. **Panic Button** for fast access to grounding tools. Soft, calm background colors. |
| **Sources used** | 1. NHS inform — nhsinform.scot/illnesses-and-conditions/mental-health/anxiety · 2. Mayo Clinic — mayoclinic.org/diseases-conditions/anxiety · 3. Healthline — healthline.com/health/anxiety · 4. Mind — mind.org.uk/information-support/types-of-mental-health-problems/anxiety-and-panic-attacks |

### 4. Health Anxiety 🟢 *(cluster: Anxiety & Panic)*

| Heading | Content |
| --- | --- |
| **What it is** | Ongoing fear of having or getting a serious illness, even with little or no medical proof — every small ache feels like proof something is terribly wrong. |
| **Why it occurs** | The brain reads normal body feelings as dangerous. Often starts after a real illness (their own or someone close), a stressful time, or growing up around a family member who worried a lot about health. |
| **Signs (text/voice)** | Lists many symptoms in detail; asks "could this be cancer/heart disease?"; keeps checking their body; mentions searching symptoms online a lot, or avoiding doctors completely. |
| **Triggers** | A new body feeling, health news, a friend's diagnosis, medical TV shows, waiting for test results. |
| **Thought pattern** | "This headache must mean something is seriously wrong." "If I don't get it checked now, it'll be too late." |
| **Self-view / Behavior / Social pattern** | Sees their body as weak or unreliable; keeps checking pulse, lumps, moles; may tire out friends/family asking for reassurance; may avoid plans out of fear of being sick. |
| **Best-fit activities (2–4 + why)** | **Notice 3 Things** — moves attention away from body-checking, out into the world. **Breathing (Box Breathing)** — calms the anxious feelings that mimic illness symptoms. |
| **How AI should respond** | Don't confirm or rule out a medical explanation — that's not the AI's job. Validate the fear without feeding it: "I hear how scary this feels. The worry itself is making your body feel worse — let's calm your body first." Gently suggest a real doctor for any physical concern. |
| **App UI / Visual Design** | **Symptom-checker alternative** — instead of a diagnosis, shows "anxiety can cause: chest tightness, dizziness, stomach issues." **Reality Check tool** — "before you search online: have you eaten, slept, had caffeine?" |
| **Sources used** | 1. NHS — nhs.uk/mental-health/conditions/health-anxiety · 2. Cleveland Clinic — my.clevelandclinic.org/health/diseases/9886-illness-anxiety-disorder · 3. American Psychological Association (APA) · 4. Oxford Health NHS — oxfordhealth.nhs.uk/ohspic/problems/health-anxiety |

### 5. Phobias (general) 🟢 *(cluster: Anxiety & Panic)*

| Heading | Content |
| --- | --- |
| **What it is** | A strong, unreasonable fear of one specific thing, animal, or situation that leads to avoiding it completely. |
| **Why it occurs** | Often comes from a scary past experience, learning fear from a parent or friend, or genetics — not always one clear cause. |
| **Signs (text/voice)** | Sudden panic when the topic comes up; voice becomes tight; strong urge to leave or avoid a place; refuses to talk or think about the trigger. |
| **Triggers** | Being near the feared thing or situation (spiders, heights, flying, needles) — even just thinking about it can cause panic. |
| **Thought pattern** | "I'm going to die if I see it." "I can't escape." "Everyone will see me panic." |
| **Self-view / Behavior / Social pattern** | Feels unable to control their reaction; plans life around avoiding the trigger; may feel embarrassed about the fear; may miss important events. |
| **Best-fit activities (2–4 + why)** | **Breathing (Box Breathing)** — manages the sudden physical panic. **Grounding 5-4-3-2-1** — pulls the brain out of the fear loop and into the present. |
| **How AI should respond** | Never describe or dwell on the feared thing in detail, and don't say things like "it's just a spider!" Stay calm and reassuring, treat the fear as real, and guide slow breathing until it passes, instead of arguing logically. |
| **App UI / Visual Design** | **Exposure Ladder tool** — a step-by-step visual chart for small, safe steps toward facing the fear. **Panic Button** for fast breathing/grounding access. |
| **Sources used** | 1. NHS — nhs.uk/mental-health/conditions/phobias/overview · 2. NIMH — nimh.nih.gov/health/publications/phobias-and-phobia-related-disorders · 3. Cleveland Clinic — my.clevelandclinic.org/health/diseases/24757-phobias · 4. Mind — mind.org.uk/information-support/types-of-mental-health-problems/phobias |

### 6. Depression 🟢 *(cluster: Mood)*

| Heading | Content |
| --- | --- |
| **What it is** | Ongoing low mood, loss of interest, and heavy tiredness that makes normal life feel like walking through mud. It's more than just "feeling sad" for a day. |
| **Why it occurs** | No single cause — usually a mix of brain chemistry, family history, hard life events (a death, losing a job, illness), and long-term stress, which changes how the brain handles energy and mood. |
| **Signs (text/voice)** | Voice sounds flat, tired, or monotone; short, low-effort replies; talks about hopelessness or losing interest in things they used to love; says "empty" or "tired all the time." |
| **Triggers** | Loss, a big life change, ongoing stress, poor sleep, feeling alone, winter months, or a run of small setbacks piling up. |
| **Thought pattern** | Turning one bad thing into "everything is bad": "What's the point?" "I'm a burden." "Nothing will ever get better." "I'm too tired to try." |
| **Self-view / Behavior / Social pattern** | Sees themselves as worthless or "broken"; pulls away from people and hobbies; stops taking care of themselves and chores; sleeps or eats too much or too little. |
| **Best-fit activities (2–4 + why)** | **Mindful Walking** — gentle movement that doesn't need much energy. **Seeing life more positively** — tiny, manageable gratitude, never forced happiness. **Release tension** — physical relief for a heavy body. |
| **How AI should respond** | Warm, low-pressure, patient. Never say "just smile" or "just think positive." Notice the exhaustion, watch closely for any language about wanting to give up and act on it right away, and praise tiny wins ("you got out of bed today — that matters"). |
| **Screening signal** | 🟦 **PHQ-9** — tracked silently in the background, never shown as a test. *Example tasks:* "what's one small thing you're looking forward to this week?" · "how did you sleep last night?" A flat "nothing" or low-effort answer, repeated over days, quietly builds the signal. If the self-harm signal ever shows up, straight to the crisis flow — no delay. |
| **App UI / Visual Design** | **Low-Energy Mode** — soft colors, minimal text, large buttons. **Micro-Activities** — 30-second tasks like "take one sip of water" or "touch something soft." |
| **Sources used** | 1. NHS — nhs.uk/mental-health/conditions/depression-in-adults/causes · 2. World Health Organization (WHO) — Depression · 3. NHS inform — nhsinform.scot/illnesses-and-conditions/mental-health/depression · 4. Oxford Health NHS guide |

### 7. Self-Image 🟢 *(cluster: Self-Image & Self-Blame)*

| Heading | Content |
| --- | --- |
| **What it is** | How a person sees and describes themselves. When it's negative, it can feel like looking into a funhouse mirror that only shows flaws. |
| **Why it occurs** | Built up over time from childhood, how caregivers responded to them, past bullying, or comparing themselves to unrealistic standards, including social media. |
| **Signs (text/voice)** | Puts themselves down often; uses harsh words about how they look or act; compares themselves badly to others; brushes off compliments. |
| **Triggers** | Social media, criticism, looking in the mirror, seeing photos of themselves, failure or setbacks. |
| **Thought pattern** | Fixed, harsh labels: "I'm ugly." "I'm not good at anything." "Everyone else has it figured out except me." |
| **Self-view / Behavior / Social pattern** | Sees themselves through a harsh, narrow lens shaped by the past; puts themselves down; avoids photos or social events; may look for reassurance but not believe it, or try too hard to be perfect. |
| **Best-fit activities (2–4 + why)** | **Accepting emotions without judgement** — stops the shame spiral about feeling bad. **Seeing life more positively** — shifts focus from flaws to strengths. **Cognitive Reframing** — gently questions the harsh self-label itself. |
| **How AI should respond** | Point out real strengths the person has already shown in conversation, not empty compliments ("you're great!" can feel dismissive). Gently question negative self-talk without arguing, and help them notice things about themselves beyond looks. |
| **App UI / Visual Design** | **Strengths Journal** — daily prompt: "what's one thing you did well today?" **Mirror Exercise** — guided audio for positive self-talk. |
| **Sources used** | 1. Mind — mind.org.uk/information-support/types-of-mental-health-problems/self-esteem · 2. Counselling Directory — counselling-directory.org.uk/self-image-and-self-esteem · 3. Psychology Today — Self-Image · 4. Oxfordshire Mind — oxfordshiremind.org.uk |

### 8. Blaming (self-blame) 🟢 *(cluster: Self-Image & Self-Blame)*

| Heading | Content |
| --- | --- |
| **What it is** | Blaming yourself too much for bad things, even ones that were completely outside your control. |
| **Why it occurs** | An unhelpful thinking habit learned in childhood, or a way of coping with stress — blaming yourself can feel more "fixable" than accepting that a bad thing just happened randomly. |
| **Signs (text/voice)** | Says "it's my fault" a lot; over-apologizes; takes the blame for other people's mistakes or bad moods; says "I should have known better." |
| **Triggers** | Conflict, a small mistake, someone else being upset, a plan going wrong. |
| **Thought pattern** | Turning one event into a permanent flaw: "it's all my fault," "if I had just done X, this wouldn't have happened," "I always ruin things." |
| **Self-view / Behavior / Social pattern** | "I'm the problem" — ongoing guilt and shame; over-apologizes, tries too hard to please others, finds it hard to set boundaries or say what they need. |
| **Best-fit activities (2–4 + why)** | **Accepting emotions without judgement** — separates guilt from the actual facts. **Release tension** — lets go of the physical weight of guilt. **Cognitive Reframing / Journaling** — helps look at the facts more clearly. |
| **How AI should respond** | Gently question the "it's all my fault" thinking without arguing the feeling away. Ask "would you blame a friend for this?" and help them see the difference between taking responsibility and taking *all* the blame. |
| **App UI / Visual Design** | **Fact-Checker tool** — a simple flow: "what happened?" → "what was really my part?" → "what was out of my control?" with a pie chart showing shared responsibility. |
| **Sources used** | 1. Psychology Today — Chronic self-blame · 2. Psychology Tools — psychologytools.com/resource/self-blame · 3. American Psychological Association (APA) — Cognitive distortions · 4. PMC — pmc.ncbi.nlm.nih.gov/articles/PMC4573463 |

### 9. Intimacy 🟢 *(cluster: Relationships & Life-Stage)*

| Heading | Content |
| --- | --- |
| **What it is** | Trouble getting close to people, emotionally or physically. It feels genuinely scary to let someone see the real you. |
| **Why it occurs** | Often comes from how safe closeness felt growing up, or from past rejection or betrayal — the brain learns that getting close means danger or pain. |
| **Signs (text/voice)** | Keeps conversations surface-level; pulls away when a relationship gets deeper; struggles to share feelings; says they feel "too much" or "not enough" for a partner. |
| **Triggers** | A partner wanting more commitment, physical touch, sharing feelings, conflict, or being fully "seen" by someone. |
| **Thought pattern** | "If they really knew me, they'd leave." "I don't need anyone." "It's safer to keep my distance." |
| **Self-view / Behavior / Social pattern** | Believes they're not worth loving, or will get hurt anyway; avoids being vulnerable; creates distance; ends relationships early; feels lonely but pushes people away. |
| **Best-fit activities (2–4 + why)** | **Accepting interdependence** — reframes connection as a strength, not a weakness. **Body Scan** — helps notice where tension shows up when they feel vulnerable. |
| **How AI should respond** | Don't push them to "open up" faster than they're ready. Say that closeness can feel unsafe even when nothing is wrong right now, remind them intimacy takes time, and encourage small, safe steps. |
| **App UI / Visual Design** | **Connection Ladder** — visual steps for slowly building trust. **Vulnerability Prompts** — gentle, low-stakes questions to practice sharing feelings. |
| **Sources used** | 1. Psychology Today — Fear of intimacy and closeness in relationships · 2. Attachment Project — attachmentproject.com/psychology/fear-of-intimacy · 3. American Psychological Association (APA) — Attachment theory · 4. PsychCentral — Afraid of getting close to someone |

### 10. Life Changes 🟢 *(cluster: Relationships & Life-Stage)*

| Heading | Content |
| --- | --- |
| **What it is** | Stress and upset caused by big life changes — moving, a new job, a relationship change, retiring, becoming a parent — even good changes count. |
| **Why it occurs** | Big changes disrupt routine and identity — the mind has to let go of the old and adapt to the new, which takes real effort even if the change is positive. |
| **Signs (text/voice)** | Says they feel unsure about the future, "unmoored," or tired; struggles to settle into a new routine; mentions missing "the old days." |
| **Triggers** | A recent or upcoming big change — moving, a new job, a relationship shift, graduating, retiring — expected or sudden. |
| **Thought pattern** | "I don't know who I am now." "I made a huge mistake." "I can't handle this much change." |
| **Self-view / Behavior / Social pattern** | May feel a short-term loss of identity or control; feels ungrounded; sleep issues or irritability; leans more on close relationships, or pulls back while adjusting. |
| **Best-fit activities (2–4 + why)** | **Mindful Walking** — helps ground the body in the present. **Transitions in a day** — builds small routines and a sense of control. **Breathing (Box Breathing)** — calms the body when overwhelmed. |
| **How AI should respond** | Say that transitions — even good ones — are genuinely stressful, and it's okay to miss the old life while adjusting to the new. Help break the change into smaller steps, instead of looking at the whole thing at once. |
| **Screening signal** | 🟩 **PSS** — tracked silently in the background, never shown as a test. *Example tasks:* "did today feel manageable, or like things piled up?" · "did today feel in your control, or out of your hands?" Builds a picture over time. |
| **App UI / Visual Design** | **Transition Tracker** — a visual timeline of progress through the change. **Routine Builder** — drag-and-drop tool for a new daily schedule. |
| **Sources used** | 1. Psychology Today — 8 ways to cope with life transitions · 2. Tandem Psychology — Strategies for navigating life's transitions · 3. American Psychological Association (APA) — Life changes and stress · 4. Mind — Coping with change |

### 11. Procrastination 🟢 *(cluster: Thought Loops & Behavioral)*

| Heading | Content |
| --- | --- |
| **What it is** | Putting off an important task even though you know it will cause problems later. It's not laziness — it's about managing hard feelings. |
| **Why it occurs** | The task brings up bad feelings (boredom, anxiety, fear of failing), so the brain picks a quick mood-fix (like scrolling) over the long-term goal — it's not really about time management. |
| **Signs (text/voice)** | Talks about rushing at the last minute; guilt about unfinished tasks; says "I work better under pressure" or "I'll do it later"; feels stuck looking at a to-do list. |
| **Triggers** | Big, unclear tasks; fear of doing it wrong; tasks tied to fear of judgment; feeling overwhelmed. |
| **Thought pattern** | "It has to be perfect or there's no point starting." "I'm just lazy." |
| **Self-view / Behavior / Social pattern** | May call themselves "lazy," which adds shame and makes the avoiding worse; delays starting, gets distracted, rushes at the last minute; may hide how behind they are. |
| **Best-fit activities (2–4 + why)** | **Transitions in a day** — breaks the day into small, doable chunks. **Allowing mistakes** — reduces the perfectionism causing the freeze. **Notice 3 Things** — breaks the avoiding pattern before returning to the task. |
| **How AI should respond** | Don't lecture about time management — gently name the feeling behind the avoiding. Remove the shame, explain this is about feelings not laziness, and help find a tiny first step (like "just open the document"). |
| **App UI / Visual Design** | **Micro-Task Timer** — a 5-minute timer just to *start*. **Forgiveness Button** — tapped when they procrastinate, gives a kind message instead of guilt. |
| **Sources used** | 1. American Psychological Association (APA) — Speaking of Psychology: Why We Procrastinate · 2. Psychology Today — Procrastination · 3. Association for Psychological Science — The science behind procrastination · 4. APA GradPsych |

### 12. Anger Management 🟢 *(cluster: Thought Loops & Behavioral)*

| Heading | Content |
| --- | --- |
| **What it is** | Trouble managing and expressing anger in a healthy way, leading to outbursts or conflict — like a volcano inside that erupts over small things. |
| **Why it occurs** | A normal feeling that becomes a problem when someone hasn't learned to notice or manage it — often hiding hurt, fear, or feeling powerless, sometimes learned from family growing up. |
| **Signs (text/voice)** | Voice gets loud or sharp; harsh language; talks about snapping at others or getting frustrated over small things; physical tension when discussing it. |
| **Triggers** | Feeling disrespected, unfair treatment, being interrupted or ignored, traffic, stress piling up, feeling out of control. |
| **Thought pattern** | Thoughts that make the anger bigger: "they did this on purpose," "this is completely unfair," "I have every right to be this angry." |
| **Self-view / Behavior / Social pattern** | May feel justified in the moment, guilty afterward; raised voice, silent treatment; clenched jaw or fists; can strain relationships. |
| **Best-fit activities (2–4 + why)** | **Breathing (Box Breathing)** — cools the physical heat of anger. **Release tension** — a safe physical outlet. **STOP Skill** — a quick pause before reacting. |
| **How AI should respond** | Never argue back or add to it. Stay calm, say the anger makes sense ("it makes sense you're frustrated"), help slow the physical response first, and only talk about the trigger once they're calmer. |
| **App UI / Visual Design** | **Anger Thermometer** — a visual 1–10 scale to watch anger rising. **Safe Release Zone** — audio guides for physical release ("squeeze your fists tight... now release"). |
| **Sources used** | 1. NHS — Anger · 2. Mind — Anger · 3. American Psychological Association (APA) — Controlling anger · 4. NHS inform — self-help guide for problems with anger |

### 13. Asperger's Syndrome 🟢 *(cluster: Identity & Neurodivergence)*

| Heading | Content |
| --- | --- |
| **What it is** | An older term for a form of autism without language or thinking delays, now part of Autism Spectrum Disorder. It's a different way of communicating and processing the world, not something to "fix." |
| **Why it occurs** | Something the person is born with, not caused by upbringing — it runs in families and shows up early in life. |
| **Signs (text/voice)** | Very direct, literal way of talking; deep focus on specific interests; may miss sarcasm or unwritten social rules; voice may sound flat or formal. |
| **Triggers** | Sudden changes to routine, too much noise/light/crowds, unclear social situations. |
| **Thought pattern** | Takes words very literally; can feel confused or anxious around unclear or unspoken rules — "why don't people just say what they mean?" |
| **Self-view / Behavior / Social pattern** | May feel "different," sometimes leading to low self-esteem if unsupported; likes routine and predictability; deeply into specific interests; may feel overloaded by too much sensory input. |
| **Best-fit activities (2–4 + why)** | **Notice 3 Things** — clear, concrete, sense-based rather than abstract feeling-talk. **Transitions in a day** — helps with routine changes. **Body Scan** — spots sensory overload early. |
| **How AI should respond** | Be clear and literal — avoid idioms, sarcasm, or vague hints. Don't assume distress just because their tone or expression looks different; respect how they describe their own experience; give clear, step-by-step guidance. |
| **App UI / Visual Design** | **Routine Visualizer** — clear, visual schedules. **Sensory Menu** — settings to change app colors, sounds, and notifications to avoid overload. |
| **Sources used** | 1. Healthline — Asperger syndrome · 2. Harley Therapy — Signs of Asperger's in adults · 3. National Autistic Society · 4. American Psychological Association (APA) — Autism Spectrum Disorder |

### 14. Sleep / Insomnia 🟢 *(cluster: Physical & Somatic)*

| Heading | Content |
| --- | --- |
| **What it is** | Regular trouble falling asleep, staying asleep, or waking too early, which makes the daytime hard. |
| **Why it occurs** | Often caused by stress or anxiety, poor sleep habits, an irregular schedule, caffeine/alcohol, or the brain linking bed with staying awake — worrying about sleep makes it worse. |
| **Signs (text/voice)** | Sounds very tired, groggy, or irritable; mentions lying awake for hours; frustration about not sleeping. |
| **Triggers** | Stress, big life events, screens before bed, an irregular sleep schedule, caffeine late in the day. |
| **Thought pattern** | "If I don't sleep tonight, tomorrow will be ruined." "Why can't I just turn my brain off?" |
| **Self-view / Behavior / Social pattern** | May feel out of control of their own body; checks the clock repeatedly; uses screens in bed; naps at odd times to make up for it; poor sleep can strain relationships and make evening plans harder. |
| **Best-fit activities (2–4 + why)** | **Settling into sleep** — a guided wind-down routine. **Breathing (Box Breathing)** — calms the body for sleep. **Calming the mind** — stops racing thoughts. |
| **How AI should respond** | Don't say "just relax" or push them to sleep (that adds more anxiety). Offer a gentle wind-down step, say that occasional poor sleep is normal, and suggest seeing a doctor if it's lasted 3+ months. |
| **App UI / Visual Design** | **Sleep Sanctuary Mode** — app turns dark blue/black, plays sleep sounds. **Wind-Down Timer** — a gentle reminder to put the phone away 30 minutes before bed. |
| **Sources used** | 1. NHS — Insomnia · 2. NHS inform — Insomnia · 3. Patient.info — Insomnia and poor sleep · 4. Sleep Foundation |

### 15. Fear of Global Instability 🟢 *(cluster: Existential & Occupational)*

| Heading | Content |
| --- | --- |
| **What it is** | Ongoing worry about world events — war, climate change, the economy — things mostly outside the person's control. Sometimes called "eco-anxiety" or "doomscrolling." |
| **Why it occurs** | A reasonable reaction to real, ongoing problems in the world, made bigger by constant news and social media — this keeps feeding the brain "danger" signals it can't fight or run from. |
| **Signs (text/voice)** | Keeps bringing up news headlines; feels powerless about the future; says "what's the point of planning if the world is ending?" |
| **Triggers** | Breaking news, social media feeds, political talk, climate reports. |
| **Thought pattern** | "The world is falling apart." "I can't protect my family." "There's nothing I can do, so what's the point." |
| **Self-view / Behavior / Social pattern** | May feel small against huge problems; checks the news too much, or avoids it completely; may pull back from planning ahead; may struggle to talk about this with people who don't share the same worry. |
| **Best-fit activities (2–4 + why)** | **Accepting emotions without judgement** — the fear is real, so this validates it. **Notice 3 Things** — pulls focus from global chaos to local, present safety. **Mindful Walking** — reconnects with the physical, present world. |
| **How AI should respond** | Say the worry is reasonable, not silly — don't argue the facts. Gently guide toward what's in their control (community, small local actions, self-care) instead of what's not. |
| **App UI / Visual Design** | **News Detox Tracker** — tracks time spent away from news apps. **Circle of Control tool** — a visual diagram sorting worries into "I can control" vs. "I cannot control." |
| **Sources used** | 1. Psychology Today — Worrying for the world · 2. UNICEF — What is eco-anxiety · 3. American Psychological Association (APA) — Eco-anxiety and climate change · 4. PMC — Eco-anxiety review |

### 16. Working from Home 🟢 *(cluster: Existential & Occupational)*

| Heading | Content |
| --- | --- |
| **What it is** | The stress, loneliness, or blurred lines between work and rest that come with working from home — hard to "switch off" when the office is the living room. |
| **Why it occurs** | Losing the normal structure and people-contact an office gives; hard to psychologically "close" the workday; feeling pressure to always be "on" to prove they're working. |
| **Signs (text/voice)** | Says they can't switch off after work, feel lonely; mentions working late or "I haven't left the house in days"; sounds burnt out. |
| **Triggers** | Notifications late at night, eating lunch at the desk, no natural light, feeling guilty for taking a break. |
| **Thought pattern** | "I should always be available/working." "I'm so lonely." "I can never truly relax." |
| **Self-view / Behavior / Social pattern** | May feel guilty resting; works past normal hours, skips breaks, moves less during the day; feels rusty socially; less contact with colleagues can add to loneliness. |
| **Best-fit activities (2–4 + why)** | **Transitions in a day** — builds a clear line between work and home. **Mindful Walking** — gets them out of the house and moving. **Accepting interdependence** — fights the loneliness. |
| **How AI should respond** | Say this is a real, common struggle — not just "you need better work-life balance." Help find one clear boundary (a set finish time, a walk that marks the end of the day), and encourage physically leaving the workspace at day's end. |
| **Screening signal** | 🟩 **PSS** — tracked silently in the background, never shown as a test. *Example tasks:* "did you manage to switch off after work today?" · "how in control did today feel?" Small, casual check-ins build the signal quietly. |
| **App UI / Visual Design** | **Virtual Commute** — a 5-minute audio guide to mentally "walk" from work to home. **Focus/Break Timer** — Pomodoro-style with stretch reminders. |
| **Sources used** | 1. HSE (UK) — Lone working, stress and other factors · 2. Acas — Health, safety and wellbeing when working from home · 3. American Psychological Association (APA) — Remote work and mental health · 4. Mind — Working from home |

### 17. Tradepeople & Contractors 🟢 *(cluster: Existential & Occupational)*

| Heading | Content |
| --- | --- |
| **What it is** | The specific stress that comes with physical, project-based, or self-employed trade work — unsure income, physical toll, and demanding clients, all at once. |
| **Why it occurs** | Money pressure (materials, cash flow), hard physical work leading to chronic pain, clients cancelling or paying late, and a work culture where talking about mental health is often looked down on. |
| **Signs (text/voice)** | Sounds physically worn out; worries about the next job; frustrated with clients or weather delays; reluctant to admit they're struggling. |
| **Triggers** | Rising costs, unpaid invoices, tight deadlines, a client cancelling, bad weather, equipment breaking, working alone. |
| **Thought pattern** | "I should be able to handle this myself." "If I don't work, I don't eat." "My body is falling apart." |
| **Self-view / Behavior / Social pattern** | Self-reliance is tied closely to who they are, making it hard to ask for help; pushes through exhaustion instead of stopping; often works alone with little wellbeing support around them. |
| **Best-fit activities (2–4 + why)** | **Release tension** — important for physical laborers. **Body Scan** — spots physical strain before it becomes an injury. **Settling into sleep** — helps a worn-out body actually rest. |
| **How AI should respond** | Keep the tone practical, not clinical — this group rarely uses formal support, so make reaching out feel normal without over-explaining. Acknowledge the physical and money side of the work, keep advice short and useful (they're busy). |
| **Screening signal** | 🟩 **PSS** — tracked silently in the background, never shown as a test. *Example tasks:* "how's the workload feeling this week — manageable or piling up?" · "did today feel like you were on top of things?" Kept casual and practical, matching how this group actually talks. |
| **App UI / Visual Design** | **Physical Recovery Menu** — quick 2-minute stretches for specific trades. **Client Boundary Scripts** — ready-made texts about hours and payments. |
| **Sources used** | 1. Mind — Mental health at work · 2. Brabners — Mental health and stress in UK construction · 3. Logic4Training — Mental health in the trades · 4. Trade Direct Insurance — Impact of mental health on UK trades |

### 18. Vaccine-related Anxiety 🟢 *(cluster: Existential & Occupational)*

| Heading | Content |
| --- | --- |
| **What it is** | Fear or worry about vaccines or the act of being vaccinated — from mild worry to a strong fear of needles. |
| **Why it occurs** | Linked to general anxiety, a fear of needles/injections, distrust of medical systems, or hearing conflicting information. |
| **Signs (text/voice)** | Strong fear of needles; asks endless questions about side effects; dreads an appointment, or avoids medical appointments altogether. |
| **Triggers** | Seeing a needle, booking an appointment, reading about side effects online, being pushed to get vaccinated. |
| **Thought pattern** | Too much focus on rare side effects — "what if I have a bad reaction?" "I can't handle the pain." |
| **Self-view / Behavior / Social pattern** | May feel embarrassed or defensive about the fear; avoids doctors, delays vaccination; may faint or panic near medical equipment; may avoid talking about it due to stigma. |
| **Best-fit activities (2–4 + why)** | **Breathing (Box Breathing)** — stops fainting and calms panic. **Grounding 5-4-3-2-1** — distracts the brain during the injection itself. **STOP Skill** — a moment to pause before the panic builds. |
| **How AI should respond** | Don't argue for or against vaccination — that's a decision for the person and their doctor. Focus only on managing the fear, and offer practical tips (looking away, tensing leg muscles). |
| **App UI / Visual Design** | **Needle Phobia Toolkit** — audio distractions during injections. **Applied Tension Guide** — a visual guide on tensing muscles to prevent fainting. |
| **Sources used** | 1. NHS UK — Needle phobia · 2. CDC — Vaccine anxiety · 3. PMC — pmc.ncbi.nlm.nih.gov/articles/PMC9233868 · 4. Immunize Nevada |

---

## 2. 🧩 Personality Profiles

*Ten background patterns the AI quietly scores in the background during a conversation — never shown to the user. They only shape tone, pace, and which activities get suggested. Javeria owns all 10; these are the 2 fully written up so far.*

### 19. The Ruminator / Overthinker

| Heading | Content |
| --- | --- |
| **What it is** | Someone whose brain is like a broken record — replaying conversations, decisions, and mistakes over and over, without reaching an answer. |
| **Core traits** | Analytical, detail-focused, hard on themselves; can't let a topic go; gets stuck overthinking; needs certainty; struggles to decide because they keep re-checking their options. |
| **Why it forms** | Often linked to perfectionism, low self-esteem, or unresolved stress — the mind treats an unfinished worry as a problem it still needs to solve, thinking if it analyzes enough, it will find the "perfect" answer or avoid a future mistake. Often starts after a painful experience they feel they "should have seen coming." |
| **Shows up in conversation as** | Long, circular messages about the same thing; "I keep thinking about...", "what if I had...", "I can't stop replaying"; asking the same question different ways; trouble ending the conversation. |
| **Prone to which disorders** | Depression, Anxiety, Overthinking (as its own issue), OCD, Procrastination, Insomnia (racing thoughts at night). |
| **Best-fit activity style** | Short, structured, interrupt-the-loop tools, not open-ended reflection. Grounding and body-based activities work better than talking the thought through more. Not journaling (they'll overthink that too). Rotate between **Notice 3 Things**, **Grounding 5-4-3-2-1**, **Box Breathing**, and **Mindful Walking** — fast, clear, hard to overanalyze. |
| **AI adaptation notes** | Don't ask them to analyze the thought further — that feeds the loop. Keep replies short and clear; give one suggestion, not ten (they'll analyze all ten). Gently interrupt: "I notice you're going in circles — let's pause and try something different." Validate once, then move to the present moment. |
| **Sources used** | 1. APA Dictionary of Psychology — dictionary.apa.org/rumination · 2. Psychiatry.org (APA) — Rumination: a cycle of negative thinking · 3. Healthline — How to stop ruminating · 4. Psychology Today — Rumination |

### 20. The Numb / Low-Activation

| Heading | Content |
| --- | --- |
| **What it is** | Someone who feels emotionally flat, disconnected, or "switched off" — like watching life through a foggy window. Low energy, low reaction, hard to feel pleasure. Nothing feels good or bad — just nothing. |
| **Core traits** | Low energy, seems distant, slow to respond, seems indifferent, very little emotional expression; describes feelings as "nothing" rather than sad or angry; flat tone even for hard events. |
| **Why it forms** | Usually a protective response — the brain's emotion system dials down after a lot of pain or stress, like a circuit breaker tripping to stop overload, common after depression, trauma, or burnout. |
| **Shows up in conversation as** | Very short answers ("ok," "fine," "idk"); long delays before replying; flat tone, no emojis; "I don't really feel anything." |
| **Prone to which disorders** | Depression, PTSD, Compassion Fatigue, Burnout, Grief (numbness stage). |
| **Best-fit activity style** | Tiny, low-effort, sense-based activities that slowly bring back feeling and engagement. Gentle invitations, not demands, focused on body feelings rather than emotions — avoid intense or emotionally heavy techniques early on. Best starting set: **Mindful Eating**, **Release Tension**, **Mindful Walking**, and **Accepting Emotions Without Judgement** — all low-effort and sense-based. Add **Seeing Life More Positively** only once some engagement has come back. |
| **AI adaptation notes** | Don't rush them to "feel more," and don't treat the numbness as something to fix right away — it's often the mind protecting itself. Don't use overly cheerful language ("great job!" feels fake); don't push for emotional talk. Use warm, low-pressure invitations ("would it be okay to try...?") and celebrate tiny wins. |
| **Sources used** | 1. Talkiatry — Why do I feel so emotionally numb · 2. PMC (veterans anhedonia study) — pmc.ncbi.nlm.nih.gov/articles/PMC5912443 · 3. Mind — Emotional numbness · 4. Sunlight Recovery — Emotional numbness and anhedonia |

---

## 3. 🌿 Coping Activities

*Each activity below has a step-by-step AI Avatar Script — the exact, slow lines the AI speaks out loud to guide the person, the way a real human coach would: greet → one instruction → pause → next instruction → pause → gentle close.*

### 21. Accepting Emotions Without Judgement

| Heading | Content |
| --- | --- |
| **What it is** | Noticing and naming a feeling without calling it good or bad — like watching clouds pass in the sky. You see them, but you don't grab them or push them away. |
| **Why we use it (mechanism)** | Fighting or resisting a feeling adds a second layer of hurt on top of the first one. Accepting it as it is takes away that extra pain and frees up energy for a useful next step. |
| **Best-fit disorders** | Grief 🚩, Blaming, Depression, Sleep/Insomnia, Anxiety, Anger Management, Fear of Global Instability, Vaccine-related Anxiety. |
| **Best-fit personalities** | The Numb / Low-Activation (gentle re-entry to feeling); The Ruminator / Overthinker (interrupts analysis with simple noticing). |
| **When NOT to use it** | Not a replacement for professional help in an active crisis — if the person is very distressed, unsafe, or reliving a trauma, move to the Crisis Flow / safety steps instead. |
| **AI Avatar Script** | "Let's pause together for a moment." [pause] "Whatever you're feeling right now — let it be here, without pushing it away." [pause] "If it helps, say to yourself: 'I feel ___, and that's okay.'" [pause] "You don't need to fix it right now. Just notice it, like a cloud passing by." [pause] "Take one slow breath as you let that feeling sit with you." |
| **App Screen-by-Screen Design** | **Screen 1:** "Name the feeling" — emotion wheel to tap. **Screen 2:** "Where is it in your body?" — tap a body outline. **Screen 3:** "Just watch it" — a 60-second timer with a floating cloud. **Screen 4:** "Release or keep" — user chooses to let the cloud float away or keep watching. |
| **Sources used** | 1. Palo Alto University — Radical acceptance with DBT · 2. DBT Self Help — Radical acceptance: turning the mind · 3. Greater Good Science Center — Acceptance · 4. Clearview Treatment — DBT skills: radical acceptance |

### 22. Mindful Walking

| Heading | Content |
| --- | --- |
| **What it is** | Walking at a normal pace while paying full attention to your movement and your surroundings, instead of walking on autopilot — meditation while moving. |
| **Why we use it (mechanism)** | Combines light movement with paying attention to now; research shows it can reduce stress and mild anxiety/depression, giving the mind something real to hold onto instead of spiraling in thought. |
| **Best-fit disorders** | Depression, Life Changes, Working from Home, Fear of Global Instability. |
| **Best-fit personalities** | The Ruminator / Overthinker (movement + senses breaks the thought loop); The Numb / Low-Activation. |
| **When NOT to use it** | Not ideal during acute panic (sitting and grounding is better), an unsafe environment, or if the person can't walk safely — offer a seated option instead. |
| **AI Avatar Script** | "Let's take a mindful walk together — start walking at your normal pace." [pause] "Notice your feet touching the ground — heel, then toe." [pause] "Notice one sound around you right now." [pause] "Notice the air on your skin as you move." [pause] "Keep walking, and every time your mind wanders, gently bring it back to your steps." |
| **App Screen-by-Screen Design** | **Screen 1:** Audio starts — "stand up and find a safe place to walk." **Screen 2:** A calm step-counter (not competitive). **Screen 3:** Prompts every 30 seconds — "notice the color of the sky," "feel your left foot fall." **Screen 4:** "How does your body feel after moving?" |
| **Sources used** | 1. Cleveland Clinic — health.clevelandclinic.org/walking-meditation · 2. Mindful.org — 6 ways to get the benefits of mindful walking · 3. SIY Leadership Institute — Mindful walk benefits · 4. Mindfulness.com — Mindful walking |

### 23. Seeing Life More Positively

| Heading | Content |
| --- | --- |
| **What it is** | Noticing and naming one good or manageable thing, without denying the hard parts of everything else. It's not about ignoring the bad — it's training the brain to also notice the good. |
| **Why we use it (mechanism)** | Gratitude practice is linked to better mood and less overthinking, because it points attention toward what's stable and okay, instead of only the stressful part. Over time, it can make noticing the good more automatic. |
| **Best-fit disorders** | Self-Image, Life Changes, Fear of Global Instability, Grief 🚩, Depression. |
| **Best-fit personalities** | The Ruminator / Overthinker (breaks the negative loop); The Numb / Low-Activation (small, low-effort re-engagement). |
| **When NOT to use it** | Never use this to brush off real pain ("just look on the bright side!") — always listen and validate first, and only offer this once the person feels heard. Skip during acute grief or trauma; keep it gentle and optional. |
| **AI Avatar Script** | "Let's find one good thing from today — it can be small." [pause] "Maybe a warm cup of tea, a message from a friend, or five quiet minutes." [pause] "Say it to yourself: 'I'm grateful for ___.'" [pause] "Notice how it feels in your body as you say it." |
| **App Screen-by-Screen Design** | **Screen 1:** "Daily Spark" — "what is one tiny good thing that happened today?" **Screen 2:** User types or records voice. **Screen 3:** "Spark Jar" — saved as a glowing light in a digital jar. **Screen 4:** "Review" — on bad days, open the jar to see past sparks. |
| **Sources used** | 1. My Pacific Health — Mindful gratitude · 2. Samphire Neuroscience — Mental health exercises · 3. American Psychological Association (APA) — Positive psychology · 4. Psychology Today — Gratitude practice |

### 24. Mindful Eating

| Heading | Content |
| --- | --- |
| **What it is** | Eating slowly with full attention to taste, texture, smell, and hunger cues, instead of eating on autopilot — turning a routine act into a grounding moment. |
| **Why we use it (mechanism)** | The brain takes about 20 minutes to register fullness; eating mindfully helps people notice hunger/fullness cues earlier, and it uses all five senses to bring the brain into the present. Linked to less stress, anxiety, and overeating. |
| **Best-fit disorders** | Self-Image (when linked to food guilt), Anxiety, Depression, general stress-eating. |
| **Best-fit personalities** | The Numb / Low-Activation (rebuilds sense-engagement); The Ruminator / Overthinker (a real anchor to focus on). |
| **When NOT to use it** | Do not use if the person shows signs of disordered eating (like anorexia/bulimia) — focusing on food could make things worse. Route to a proper eating-disorder pathway instead, and only use under professional guidance in those cases. |
| **AI Avatar Script** | "Before you eat, take one breath and look at your food." [pause] "Notice the colours and the smell." [pause] "Take one bite, and chew slowly — count to ten if that helps." [pause] "Notice the taste and texture before your next bite." [pause] "Keep this slower pace for a few more bites." |
| **App Screen-by-Screen Design** | **Screen 1:** "Choose a small snack." **Screen 2:** Audio guide — "look at the color, smell it, place it on your tongue, don't chew yet." **Screen 3:** "Chew slowly, notice the texture." **Screen 4:** "Swallow — how does your body feel?" |
| **Sources used** | 1. Harvard Health — 8 steps to mindful eating · 2. Harvard T.H. Chan School — How to practice mindful eating · 3. Harvard Health — Overeating: mindfulness exercises may help · 4. Mind — Mindful eating |

### 25. Notice 3 Things

| Heading | Content |
| --- | --- |
| **What it is** | A quick grounding exercise — a short version of the 5-4-3-2-1 technique — that uses the senses to bring attention back to the present. Takes about 30 seconds. |
| **The full 5-4-3-2-1 version (for when more time is needed):** | Name 5 things you can see · 4 things you can feel/touch · 3 things you can hear · 2 things you can smell · 1 thing you can taste. Best for panic, feeling spaced-out, or overthinking spirals. |
| **Why we use it (mechanism)** | Paying attention to the senses and anxious overthinking compete for the same limited attention — so using the senses on purpose pulls focus away from racing thoughts and into the present. This calms the fight-or-flight response. |
| **Best-fit disorders** | Health Anxiety, Anxiety, Fear of Global Instability, Working from Home, Domestic Violence 🚨 (as a quiet option). |
| **Best-fit personalities** | The Ruminator / Overthinker (interrupts thought loops fast). |
| **When NOT to use it** | If someone is badly dissociating, in a crisis, or in a genuinely unsafe/loud environment — go carefully and put safety and real support first. |
| **AI Avatar Script (short version)** | "Let's ground ourselves for a moment." [pause] "Look around and tell me three things you can see." [pause] "Now notice two things you can hear." [pause] "Now one thing you can feel — your feet on the floor, or your hands in your lap." [pause] "Good. You're here, right now." |
| **App Screen-by-Screen Design** | **Screen 1:** Big button — "Ground Me Now." **Screen 2:** Card 1, eye icon — "name 3 things you SEE." **Screen 3:** Card 2, ear icon — "name 3 things you HEAR." **Screen 4:** Card 3, hand icon — "name 3 things you FEEL." **Screen 5:** "You are here. You are safe." *(see Chart 3 below)* |
| **Sources used** | 1. TherapistAid — Grounding techniques article · 2. PsychCentral — Using the five senses for anxiety relief · 3. URMC Rochester — 54321 coping technique · 4. Clearwater Free Clinic — 5 grounding techniques |

### 26. Release Tension / Accept & Release Emotions

| Heading | Content |
| --- | --- |
| **What it is** | A physical practice of tensing a muscle group for a few seconds, then fully letting go — this is Progressive Muscle Relaxation (PMR). A longer version pairs this with naming and consciously letting go of a feeling too. |
| **Why we use it (mechanism)** | The body can't stay physically tense and mentally calm at the same time. Stress gets stored in the body as tension; tensing a muscle on purpose and then dropping it below its normal resting level tells the brain "it's safe now," and this helps release emotional tension too. Practicing this repeatedly also lowers everyday muscle tension over time — one of the physical drivers of anxiety. |
| **Best-fit disorders** | Anger Management, Sleep/Insomnia, Anxiety, Tradepeople & Contractors (short, practical stress relief). |
| **Best-fit personalities** | The Numb / Low-Activation (rebuilds body awareness); The Ruminator / Overthinker; works for anyone with physical tension. |
| **When NOT to use it** | Skip the tensing part for anyone with an injury, recent surgery, or pain condition — use the breathing/naming half only, or switch to gentle stretching. |
| **AI Avatar Script (short version)** | "Let's release some tension together." [pause] "Tense your shoulders up toward your ears — hold for three seconds." [pause] "Now let them drop and relax completely." [pause] "Notice the difference between tense and relaxed." [pause] "Take one slow breath out as you let the rest of the tension go." |
| **Full head-to-toe version** | Go through each muscle group one at a time (feet, calves, thighs, stomach, hands, arms, shoulders, face) — tense for about 5 seconds, then release fully, noticing the contrast each time, before moving to the next group. |
| **App Screen-by-Screen Design** | **Screen 1:** "Where are you holding tension?" — tap a body map (jaw, shoulders, hands, stomach). **Screen 2:** Audio — "squeeze your [body part] tight, 3... 2... 1... hold." **Screen 3:** A tight red knot on screen. **Screen 4:** "Release" — the knot dissolves into soft blue waves. **Screen 5:** "How does that area feel now?" |
| **Sources used** | 1. Cleveland Clinic — Progressive muscle relaxation (PMR) · 2. PositivePsychology.com — Progressive muscle relaxation (PMR) · 3. PMC — Systematic review, ncbi.nlm.nih.gov/pmc/articles/PMC12195441 · 4. Manhattan CBT — DBT radical acceptance |

### 27. Breathing (Box Breathing 4-4-4-4)

| Heading | Content |
| --- | --- |
| **What it is** | A slow, controlled breathing pattern used across almost every anxiety-related entry above — it's the fastest way to calm a racing body. |
| **Why we use it (mechanism)** | A slow, controlled exhale switches on the body's calming system (the vagus nerve), which directly works against the "fight or flight" reaction driving the panic. This lowers heart rate within minutes and is usually the quickest way to stop a panic attack from getting worse. |
| **Best-fit disorders** | Anxiety, Health Anxiety, Phobias, Vaccine-related Anxiety, Anger Management, Life Changes, Domestic Violence 🚨 (quiet, no screen needed). |
| **Best-fit personalities** | Works for almost everyone in the moment; especially good for The Ruminator / Overthinker as a fast pattern-interrupt. |
| **When NOT to use it** | If breathing itself feels distressing (some trauma responses), switch to a sense-based grounding activity like Notice 3 Things instead. |
| **AI Avatar Script** | "Let's breathe together, slowly." [pause] "Breathe in for four seconds." [pause] "Hold it for four seconds." [pause] "Breathe out slowly for four seconds." [pause] "Hold again for four seconds — let's do that a few more times." |
| **App UI / Visual Design** | A large, soft circle that grows over 4 seconds (inhale), stays still for 4 seconds (hold), and shrinks over 6 seconds (exhale), with the words "breathe in... hold... exhale" inside it, over a calm nature background (see Chart 2 below). Gentle vibration at each change. |
| **Sources used** | 1. NHS — nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress · 2. Mind — mind.org.uk/information-support/tips-for-everyday-living/relaxation/relaxation-exercises · 3. American Psychological Association (APA) — Breathing and the nervous system · 4. Healthline — Box breathing benefits |

### 28. Cognitive Reframing / Thought Records

| Heading | Content |
| --- | --- |
| **What it is** | Writing down a hard thought, naming the unhelpful thinking pattern in it, and coming up with a fairer, more balanced way to see it. |
| **Why we use it (mechanism)** | Anxious and low moods are often kept going by automatic, unfair thoughts (always expecting the worst, assuming what others think, all-or-nothing thinking). Writing the thought down and questioning it breaks the automatic pattern and creates space to look at it more clearly. This is the core idea behind CBT. |
| **Best-fit disorders** | Self-Image, Blaming, Depression, Anxiety, Procrastination. |
| **Best-fit personalities** | The Ruminator / Overthinker (gives the overthinking somewhere useful to go); works less well for The Numb / Low-Activation until some engagement has returned. |
| **When NOT to use it** | Don't use during acute crisis or when someone can barely function — this needs enough calm and energy to reflect; use grounding activities first. |
| **AI Avatar Script** | "Let's look at that thought together." [pause] "What's the thought, exactly, in your own words?" [pause] "If a friend told you this thought, what would you say to them?" [pause] "Is there a kinder, more balanced way to see it?" |
| **App UI / Visual Design** | A simple 3-step card: "What's the thought?" → "What's the unhelpful pattern in it?" → "What's a fairer way to see it?" — saved so the AI can look back on it next session. |
| **Sources used** | 1. NHS — nhs.uk/mental-health/talking-therapies-medicine-treatments/talking-therapies-and-counselling/cognitive-behavioural-therapy-cbt · 2. Mind — mind.org.uk/information-support/drugs-and-treatments/cognitive-behavioural-therapy-cbt · 3. American Psychological Association (APA) — What is cognitive behavioral therapy · 4. Psychology Today — Cognitive distortions |

### 29. STOP Skill (panic-specific pause)

| Heading | Content |
| --- | --- |
| **What it is** | A very short pause-and-reset skill for the moment panic or a strong reaction starts to build. |
| **Why we use it (mechanism)** | Panic and anger build through automatic reactions. Forcing a short, deliberate pause before reacting breaks the automatic pattern before it escalates further. |
| **Steps** | **S** — Stop. **T** — Take a step back. **O** — Observe your thoughts, feelings, and surroundings. **P** — Proceed, but mindfully. |
| **Best-fit disorders** | Anxiety, Phobias, Vaccine-related Anxiety, Anger Management. |
| **Best-fit personalities** | Especially good for The Ruminator / Overthinker and anyone reacting fast in the moment. |
| **When NOT to use it** | Not enough on its own for a full panic attack or crisis — pair it with Box Breathing or Notice 3 Things, and use the Crisis Flow if things are more serious. |
| **AI Avatar Script** | "Let's stop for a second." [pause] "Take a small step back from what's happening." [pause] "Just notice — what are you thinking, feeling, and seeing around you right now?" [pause] "Okay. Now let's move forward gently, one small step at a time." |
| **Sources used** | 1. TherapistAid — STOP skill worksheet · 2. Psychology Today — DBT distress tolerance skills · 3. NHS Talking Therapies — Managing panic |

---

## 4. 🎨 Visual Chart & UI Mockups (For Dev Team)

*Conceptual layouts for the UI/UX team to build, matched to the reference mockups already shared alongside this document.*

### Chart 1 — The Anxiety Cycle (Educational Screen)

![Anxiety Cycle diagram](assets/chart1_anxietycycle.jpg)

A clean, circular flowchart with 4 soft-colored boxes: **Trigger → Thought → Body Feeling → Behavior →** (back to Trigger). The user taps the point where they feel stuck, and the app suggests a matching tool — e.g. tapping "Body Feeling" suggests **Breathing**.

### Chart 2 — Breathing Exercise Screen (Core Feature)

![Breathing exercise screen](assets/chart2_breathing.jpg)

A large, soft blue circle grows and shrinks in the middle, with the words "Breathe in through nose... hold... exhale" inside it, over a calm, blurred nature scene. The circle grows over 4 seconds (inhale), holds for 4 seconds, shrinks over 6 seconds (exhale), with a gentle vibration at each change.

### Chart 3 — Notice 3 Things (Grounding Screen)

![Notice 3 Things screen](assets/chart3_notice3things.jpg)

Three large, soft, rounded cards side by side: an eye icon for "See," an ear icon for "Hear," a hand icon for "Feel." Tapping a card opens it for voice or text input, with a progress bar showing 1/3, 2/3, 3/3.

### Chart 4 — Grief Memory Garden (Support Screen)

![Grief Memory Garden screen](assets/chart4_griefcandle.jpg)

A calm, soft-lit digital garden with a glowing virtual candle in the middle and the words "Light a candle for your loved one," in soft lavender and blue tones. "Add Memory" and "Share Light" buttons sit below. Tapping the candle makes the flame flicker gently; memories the user types appear as glowing fireflies in the garden.
