
import '../models/exercise_models.dart';

/// Grounding (5-4-3-2-1 senses technique) with multi-language narration.
final List<ExerciseStep> groundingSteps = [
  ExerciseStep(
    label: {
      AppLang.en: 'Settle & Breathe',
      AppLang.ur: 'بیٹھیں اور سانس لیں',
      AppLang.urRoman: 'Baithein aur Saans Lein',
      AppLang.pa: 'ਬੈਠੋ ਅਤੇ ਸਾਹ ਲਵੋ',
    },
    text: {
      AppLang.en:
      'Welcome. Find a comfortable position, feet flat on the ground, back supported. Take a slow breath in through your nose for four counts... one, two, three, four... and release it gently through your mouth. This is the 5-4-3-2-1 technique — a simple way to bring your mind back to the present moment by noticing the world around you. There is nothing to fix, nothing to force. Just notice. Let\'s begin together, one more breath in... and out.',
      AppLang.ur:
      'خوش آمدید۔ آرام دہ حالت میں بیٹھیں، پاؤں زمین پر سیدھے، کمر کا سہارا لیں۔ ناک سے چار گنتی تک آہستہ سانس لیں... ایک، دو، تین، چار... اور منہ سے آہستہ سے چھوڑ دیں۔ یہ 5-4-3-2-1 تکنیک ہے — اپنے ارد گرد کی دنیا پر توجہ دے کر ذہن کو حال میں واپس لانے کا آسان طریقہ۔ کچھ ٹھیک کرنا نہیں، کچھ زبردستی نہیں۔ بس محسوس کریں۔ آئیے ساتھ شروع کریں، ایک اور سانس اندر... اور باہر۔',
      AppLang.urRoman:
      'Khush aamdeed. Aaram deh position mein baithein, paon zameen par seedhe, kamar ka sahara lein. Naak se chaar ginti tak aahista saans lein... aik, do, teen, chaar... aur mun se aahista se chor dein. Yeh 5-4-3-2-1 technique hai — apne ird-gird ki duniya par tawajjo de kar zehn ko haal mein wapas laane ka aasan tareeqa. Kuch theek karna nahi, kuch zabardasti nahi. Bas mehsoos karein. Aayein saath shuru karein, aik aur saans andar... aur bahar.',
      AppLang.pa:
      'ਜੀ ਆਇਆਂ ਨੂੰ। ਆਰਾਮਦਾਇਕ ਸਥਿਤੀ ਵਿੱਚ ਬੈਠੋ, ਪੈਰ ਜ਼ਮੀਨ \'ਤੇ ਸਿੱਧੇ, ਪਿੱਠ ਦਾ ਸਹਾਰਾ ਲਵੋ। ਨੱਕ ਰਾਹੀਂ ਚਾਰ ਗਿਣਤੀ ਤੱਕ ਹੌਲੀ ਸਾਹ ਲਵੋ... ਇੱਕ, ਦੋ, ਤਿੰਨ, ਚਾਰ... ਅਤੇ ਮੂੰਹ ਰਾਹੀਂ ਹੌਲੀ ਨਾਲ ਛੱਡ ਦਿਓ। ਇਹ 5-4-3-2-1 ਤਕਨੀਕ ਹੈ — ਆਪਣੇ ਆਲੇ-ਦੁਆਲੇ ਦੀ ਦੁਨੀਆ \'ਤੇ ਧਿਆਨ ਦੇ ਕੇ ਮਨ ਨੂੰ ਵਰਤਮਾਨ ਵਿੱਚ ਵਾਪਸ ਲਿਆਉਣ ਦਾ ਸੌਖਾ ਤਰੀਕਾ। ਕੁਝ ਠੀਕ ਨਹੀਂ ਕਰਨਾ, ਕੁਝ ਜ਼ਬਰਦਸਤੀ ਨਹੀਂ। ਬੱਸ ਮਹਿਸੂਸ ਕਰੋ। ਆਓ ਨਾਲ ਸ਼ੁਰੂ ਕਰੀਏ, ਇੱਕ ਹੋਰ ਸਾਹ ਅੰਦਰ... ਅਤੇ ਬਾਹਰ।',
    },
    duration: const Duration(milliseconds: 22000),
    activeNodes: const [],
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'See & Hear',
      AppLang.ur: 'دیکھیں اور سنیں',
      AppLang.urRoman: 'Dekhein aur Sunein',
      AppLang.pa: 'ਦੇਖੋ ਅਤੇ ਸੁਣੋ',
    },
    text: {
      AppLang.en:
      'Look slowly around you and silently name five things you can see. Notice their shapes, their colors, the way light falls on them. Take your time with each one. Now bring your attention to sound. Name four things you can hear right now — near or far, loud or quiet. You don\'t need to judge them, just notice them arriving and passing. Let each sound remind you that you are here, right now, safe in this moment.',
      AppLang.ur:
      'آہستہ سے اردگرد دیکھیں اور خاموشی سے پانچ چیزوں کا نام لیں جو آپ دیکھ سکتے ہیں۔ ان کی شکلیں، رنگ، روشنی کا انداز محسوس کریں۔ ہر ایک پر وقت لیں۔ اب توجہ آواز پر لائیں۔ چار چیزوں کا نام لیں جو آپ ابھی سن سکتے ہیں — قریب یا دور، اونچی یا دھیمی۔ انہیں جانچنا نہیں، بس محسوس کریں۔ ہر آواز آپ کو یاد دلائے کہ آپ یہاں ہیں، اس لمحے میں محفوظ۔',
      AppLang.urRoman:
      'Aahista se ird-gird dekhein aur khamoshi se paanch cheezon ka naam lein jo aap dekh sakte hain. Unki shaklein, rang, roshni ka andaz mehsoos karein. Har aik par waqt lein. Ab tawajjo aawaaz par layein. Chaar cheezon ka naam lein jo aap abhi sun sakte hain — qareeb ya door, oonchi ya dheemi. Unhein jaanchna nahi, bas mehsoos karein. Har aawaaz aap ko yaad dilaye ke aap yahan hain, is lamhay mein mehfooz.',
      AppLang.pa:
      'ਹੌਲੀ ਨਾਲ ਆਲੇ-ਦੁਆਲੇ ਦੇਖੋ ਅਤੇ ਚੁੱਪ ਨਾਲ ਪੰਜ ਚੀਜ਼ਾਂ ਦਾ ਨਾਮ ਲਵੋ ਜੋ ਤੁਸੀਂ ਦੇਖ ਸਕਦੇ ਹੋ। ਉਨ੍ਹਾਂ ਦੀਆਂ ਸ਼ਕਲਾਂ, ਰੰਗ, ਰੌਸ਼ਨੀ ਦਾ ਅੰਦਾਜ਼ ਮਹਿਸੂਸ ਕਰੋ। ਹਰ ਇੱਕ \'ਤੇ ਸਮਾਂ ਲਵੋ। ਹੁਣ ਧਿਆਨ ਆਵਾਜ਼ \'ਤੇ ਲਿਆਓ। ਚਾਰ ਚੀਜ਼ਾਂ ਦਾ ਨਾਮ ਲਵੋ ਜੋ ਤੁਸੀਂ ਹੁਣੇ ਸੁਣ ਸਕਦੇ ਹੋ — ਨੇੜੇ ਜਾਂ ਦੂਰ, ਉੱਚੀ ਜਾਂ ਧੀਮੀ। ਉਨ੍ਹਾਂ ਨੂੰ ਪਰਖਣਾ ਨਹੀਂ, ਬੱਸ ਮਹਿਸੂਸ ਕਰੋ। ਹਰ ਆਵਾਜ਼ ਤੁਹਾਨੂੰ ਯਾਦ ਦਿਵਾਵੇ ਕਿ ਤੁਸੀਂ ਇੱਥੇ ਹੋ, ਇਸ ਪਲ ਵਿੱਚ ਸੁਰੱਖਿਅਤ।',
    },
    duration: const Duration(milliseconds: 30000),
    activeNodes: const ['sight', 'sound'],
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Touch, Smell & Taste',
      AppLang.ur: 'چھوئیں، سونگھیں اور چکھیں',
      AppLang.urRoman: 'Chhuein, Soonghein aur Chakhein',
      AppLang.pa: 'ਛੂਹੋ, ਸੁੰਘੋ ਅਤੇ ਚੱਖੋ',
    },
    text: {
      AppLang.en:
      'Now notice three things you can touch or feel — the texture of your clothing, the surface beneath your hands, the temperature of the air on your skin. Next, notice two things you can smell, even if it\'s simply the neutral scent of the room. Finally, notice one thing you can taste — a lingering flavor, or simply the inside of your mouth. With each sense you name, you are anchoring yourself more fully into this present moment.',
      AppLang.ur:
      'اب تین چیزیں محسوس کریں جو آپ چھو سکتے ہیں — اپنے کپڑوں کی بناوٹ، ہاتھوں کے نیچے کی سطح، ہوا کا درجہ حرارت جلد پر۔ پھر دو چیزیں سونگھیں، چاہے صرف کمرے کی عام بو ہی ہو۔ آخر میں ایک چیز چکھیں — کوئی باقی ذائقہ یا بس منہ کے اندر کا احساس۔ ہر حسی تجربے کے ساتھ آپ اپنے آپ کو اس لمحے میں مضبوطی سے جوڑ رہے ہیں۔',
      AppLang.urRoman:
      'Ab teen cheezein mehsoos karein jo aap chhoo sakte hain — apne kapron ki banawat, hathon ke neeche ki satah, hawa ka darja hararat jild par. Phir do cheezein soonghein, chahay sirf kamre ki aam boo hi ho. Aakhir mein aik cheez chakhein — koi baqi zaiqa ya bas mun ke andar ka ehsaas. Har hiasi tajurbe ke saath aap apne aap ko is lamhay mein mazbooti se jor rahe hain.',
      AppLang.pa:
      'ਹੁਣ ਤਿੰਨ ਚੀਜ਼ਾਂ ਮਹਿਸੂਸ ਕਰੋ ਜੋ ਤੁਸੀਂ ਛੂਹ ਸਕਦੇ ਹੋ — ਆਪਣੇ ਕੱਪੜਿਆਂ ਦੀ ਬਣਾਵਟ, ਹੱਥਾਂ ਹੇਠ ਦੀ ਸਤ੍ਹਾ, ਹਵਾ ਦਾ ਤਾਪਮਾਨ ਚਮੜੀ \'ਤੇ। ਫਿਰ ਦੋ ਚੀਜ਼ਾਂ ਸੁੰਘੋ, ਭਾਵੇਂ ਸਿਰਫ਼ ਕਮਰੇ ਦੀ ਆਮ ਮਹਿਕ ਹੀ ਹੋਵੇ। ਅੰਤ ਵਿੱਚ ਇੱਕ ਚੀਜ਼ ਚੱਖੋ — ਕੋਈ ਬਾਕੀ ਸਵਾਦ ਜਾਂ ਬੱਸ ਮੂੰਹ ਦੇ ਅੰਦਰ ਦਾ ਅਹਿਸਾਸ। ਹਰ ਇੰਦਰੀ ਤਜ਼ਰਬੇ ਨਾਲ ਤੁਸੀਂ ਆਪਣੇ ਆਪ ਨੂੰ ਇਸ ਪਲ ਵਿੱਚ ਮਜ਼ਬੂਤੀ ਨਾਲ ਜੋੜ ਰਹੇ ਹੋ।',
    },
    duration: const Duration(milliseconds: 30000),
    activeNodes: const ['touch', 'smell', 'taste'],
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Completion',
      AppLang.ur: 'تکمیل',
      AppLang.urRoman: 'Mukammal',
      AppLang.pa: 'ਸੰਪੂਰਨਤਾ',
    },
    text: {
      AppLang.en:
      'Beautifully done. Take one more slow breath in... and out. Notice how much more present and settled you feel, connected to the room around you instead of your racing thoughts. Whenever your mind starts to spin, you can return to this simple practice — five things you see, four you hear, three you touch, two you smell, one you taste. Carry this steadiness with you.',
      AppLang.ur:
      'بہت خوب۔ ایک اور آہستہ سانس اندر لیں... اور باہر۔ محسوس کریں کہ آپ کتنا زیادہ حاضر اور settled ہیں، دوڑتے خیالات کی بجائے اپنے اردگرد سے جڑے ہوئے۔ جب بھی ذہن گھومنے لگے، اس آسان طریقے پر واپس آ سکتے ہیں — پانچ چیزیں دیکھیں، چار سنیں، تین چھوئیں، دو سونگھیں، ایک چکھیں۔ اس مستقل مزاجی کو اپنے ساتھ رکھیں۔',
      AppLang.urRoman:
      'Bohat khoob. Aik aur aahista saans andar lein... aur bahar. Mehsoos karein ke aap kitna zyada haazir aur settled hain, daurte khayalat ki bajaye apne ird-gird se jure huay. Jab bhi zehn ghoomne lage, is aasan tareeqe par wapas aa sakte hain — paanch cheezein dekhein, chaar sunein, teen chhuein, do soonghein, aik chakhein. Is mustaqil mizaji ko apne saath rakhein.',
      AppLang.pa:
      'ਬਹੁਤ ਵਧੀਆ। ਇੱਕ ਹੋਰ ਹੌਲੀ ਸਾਹ ਅੰਦਰ ਲਵੋ... ਅਤੇ ਬਾਹਰ। ਮਹਿਸੂਸ ਕਰੋ ਕਿ ਤੁਸੀਂ ਕਿੰਨਾ ਜ਼ਿਆਦਾ ਮੌਜੂਦ ਅਤੇ ਸਥਿਰ ਹੋ, ਦੌੜਦੇ ਵਿਚਾਰਾਂ ਦੀ ਬਜਾਏ ਆਪਣੇ ਆਲੇ-ਦੁਆਲੇ ਨਾਲ ਜੁੜੇ ਹੋਏ। ਜਦੋਂ ਵੀ ਮਨ ਘੁੰਮਣ ਲੱਗੇ, ਇਸ ਸੌਖੇ ਤਰੀਕੇ \'ਤੇ ਵਾਪਸ ਆ ਸਕਦੇ ਹੋ — ਪੰਜ ਚੀਜ਼ਾਂ ਦੇਖੋ, ਚਾਰ ਸੁਣੋ, ਤਿੰਨ ਛੂਹੋ, ਦੋ ਸੁੰਘੋ, ਇੱਕ ਚੱਖੋ। ਇਸ ਸਥਿਰਤਾ ਨੂੰ ਆਪਣੇ ਨਾਲ ਰੱਖੋ।',
    },
    duration: const Duration(milliseconds: 16000),
    activeNodes: const [],
  ),
];

final groundingCompletion = CompletionConfig(
  title: 'Grounded & Present',
  subtitleBuilder: (n) => 'You reconnected with the present moment through $n senses.\nWell done — you are here, and you are safe.',
  unitLabel: 'SENSES ENGAGED',
  unitCount: 5,
  chartTitle: 'Awareness by Sense',
  chartRows: const [
    CompletionStat('Sight', 90),
    CompletionStat('Sound', 85),
    CompletionStat('Touch', 82),
    CompletionStat('Smell', 74),
    CompletionStat('Taste', 70),
  ],
);
