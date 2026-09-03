
import '../models/exercise_models.dart';

/// Box Breathing (4-4-4-4 pattern) with multi-language narration.
final List<ExerciseStep> boxBreathingSteps = [
  ExerciseStep(
    label: {
      AppLang.en: 'Prepare',
      AppLang.ur: 'تیاری',
      AppLang.urRoman: 'Tayyari',
      AppLang.pa: 'ਤਿਆਰੀ',
    },
    text: {
      AppLang.en:
      'Welcome to box breathing, a technique used by athletes and even Navy SEALs to calm the nervous system in moments of stress. Sit comfortably with your back straight, shoulders relaxed, hands resting gently in your lap. We will breathe in a square pattern — inhale for four counts, hold for four, exhale for four, hold for four. Let\'s take one easy breath together to settle in before we begin the pattern.',
      AppLang.ur:
      'باکس بریتھنگ میں خوش آمدید۔ یہ وہ تکنیک ہے جو کھلاڑی اور فوجی بھی، تناؤ کے لمحوں میں، اپنے اعصاب کو پرسکون کرنے کے لیے استعمال کرتے ہیں۔ آرام سے بیٹھ جائیں... کمر سیدھی رکھیں، کندھے ڈھیلے چھوڑ دیں، اور ہاتھ گود پر آرام سے رکھ لیں۔ ہم سانس کا ایک چوکور آہنگ اپنائیں گے... چار گنتی تک سانس اندر، چار گنتی روکی رکھیں، چار گنتی تک باہر، اور پھر چار گنتی دوبارہ روکی رکھیں۔ شروع کرنے سے پہلے، آئیے ایک آسان سا سانس ساتھ لے لیتے ہیں۔',
      AppLang.urRoman:
      'Box breathing mein khush aamdeed, yeh aik aisi technique hai jo athletes aur military bhi stress ke lamhat mein nervous system ko pur-sukoon karne ke liye istemal karte hain. Aaram se baithein, kamar seedhi, shoulders dheele, hath god mein rakhein. Hum square pattern mein saans lein ge — chaar ginti tak saans andar, chaar tak rukein, chaar tak bahar, chaar tak rukein. Shuru karne se pehle aik aasan saans saath lein.',
      AppLang.pa:
      'ਬਾਕਸ ਸਾਹ ਲੈਣ ਵਿੱਚ ਜੀ ਆਇਆਂ ਨੂੰ, ਇਹ ਇੱਕ ਅਜਿਹੀ ਤਕਨੀਕ ਹੈ ਜੋ ਖਿਡਾਰੀ ਅਤੇ ਫੌਜੀ ਵੀ ਤਣਾਅ ਦੇ ਪਲਾਂ ਵਿੱਚ ਨਸ ਪ੍ਰਣਾਲੀ ਨੂੰ ਸ਼ਾਂਤ ਕਰਨ ਲਈ ਵਰਤਦੇ ਹਨ। ਆਰਾਮ ਨਾਲ ਬੈਠੋ, ਪਿੱਠ ਸਿੱਧੀ, ਮੋਢੇ ਢਿੱਲੇ, ਹੱਥ ਗੋਦ ਵਿੱਚ ਰੱਖੋ। ਅਸੀਂ ਵਰਗ ਢੰਗ ਨਾਲ ਸਾਹ ਲਵਾਂਗੇ — ਚਾਰ ਗਿਣਤੀ ਤੱਕ ਸਾਹ ਅੰਦਰ, ਚਾਰ ਤੱਕ ਰੋਕੋ, ਚਾਰ ਤੱਕ ਬਾਹਰ, ਚਾਰ ਤੱਕ ਰੋਕੋ। ਸ਼ੁਰੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਇੱਕ ਸੌਖਾ ਸਾਹ ਨਾਲ ਲਈਏ।',
    },
    duration: const Duration(milliseconds: 20000),
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Find the Rhythm',
      AppLang.ur: 'تال پکڑیں',
      AppLang.urRoman: 'Taal Pakrein',
      AppLang.pa: 'ਤਾਲ ਫੜੋ',
    },
    text: {
      AppLang.en:
      'Now begin the box. Inhale slowly through your nose... two, three, four. Hold gently at the top... two, three, four. Exhale slowly through your mouth... two, three, four. Hold at the bottom, empty and still... two, three, four. Follow the glowing dot as it traces each side of the square — let it set your pace rather than your thoughts.',
      AppLang.ur:
      'اب باکس شروع کریں۔ ناک سے آہستہ آہستہ سانس اندر لیں... دو، تین، چار۔ اوپر آ کر، نرمی سے، سانس روکی رکھیں... دو، تین، چار۔ منہ سے، آہستہ آہستہ، سانس باہر چھوڑیں... دو، تین، چار۔ نیچے آ کر سانس روکی رکھیں... بالکل خالی، بالکل ساکن... دو، تین، چار۔ چمکتے ہوئے نقطے کو دیکھتے رہیں، جو مربع کی ہر سائیڈ پر آہستہ سے چلتا ہے۔ اپنی رفتار اسی کے حوالے کر دیں۔',
      AppLang.urRoman:
      'Ab box shuru karein. Naak se aahista saans andar lein... do, teen, chaar. Oopar narami se rukein... do, teen, chaar. Mun se aahista saans bahar nikalein... do, teen, chaar. Neeche rukein, khaali aur saakin... do, teen, chaar. Chamakte dot ka peecha karein jo square ke har pehlu par chalta hai — usay apni raftaar tay karne dein.',
      AppLang.pa:
      'ਹੁਣ ਬਾਕਸ ਸ਼ੁਰੂ ਕਰੋ। ਨੱਕ ਰਾਹੀਂ ਹੌਲੀ ਸਾਹ ਅੰਦਰ ਲਵੋ... ਦੋ, ਤਿੰਨ, ਚਾਰ। ਉੱਪਰ ਨਰਮੀ ਨਾਲ ਰੋਕੋ... ਦੋ, ਤਿੰਨ, ਚਾਰ। ਮੂੰਹ ਰਾਹੀਂ ਹੌਲੀ ਸਾਹ ਬਾਹਰ ਕੱਢੋ... ਦੋ, ਤਿੰਨ, ਚਾਰ। ਹੇਠਾਂ ਰੋਕੋ, ਖਾਲੀ ਅਤੇ ਸਥਿਰ... ਦੋ, ਤਿੰਨ, ਚਾਰ। ਚਮਕਦੇ ਬਿੰਦੂ ਦਾ ਪਿੱਛਾ ਕਰੋ ਜੋ ਵਰਗ ਦੇ ਹਰ ਪਾਸੇ ਚੱਲਦਾ ਹੈ — ਇਸਨੂੰ ਆਪਣੀ ਗਤੀ ਤੈਅ ਕਰਨ ਦਿਓ।',
    },
    duration: const Duration(milliseconds: 32000),
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Continue the Box',
      AppLang.ur: 'جاری رکھیں',
      AppLang.urRoman: 'Jaari Rakhein',
      AppLang.pa: 'ਜਾਰੀ ਰੱਖੋ',
    },
    text: {
      AppLang.en:
      'Keep following the pattern — inhale, hold, exhale, hold, each for four steady counts. With every lap around the square, notice your heart rate settling, your mind growing quieter. If a thought pulls your attention away, that\'s completely normal — simply return to the rhythm of the square. You are training your body to find calm on command.',
      AppLang.ur:
      'اسی آہنگ پر چلتے رہیں... سانس اندر، روکیں، باہر، روکیں... ہر مرحلہ چار مستقل گنتی کا۔ مربع کے ہر چکر کے ساتھ محسوس کریں کہ دل کی دھڑکن آہستہ آہستہ پرسکون ہو رہی ہے، اور ذہن خاموش ہوتا جا رہا ہے۔ اگر کوئی خیال توجہ ہٹا لے، تو کوئی بات نہیں، یہ بالکل عام ہے... بس نرمی سے، مربع کی تال پر واپس آ جائیں۔ یاد رکھیں، آپ اپنے جسم کو حکم پر سکون پانے کی عادت سکھا رہے ہیں۔',
      AppLang.urRoman:
      'Pattern par chalte rahein — saans andar, rukein, bahar, rukein, har aik chaar mustaqil ginti tak. Square ke har chakkar ke saath mehsoos karein ke dil ki dharkan settle ho rahi hai, zehn khamosh ho raha hai. Agar koi khayal tawajjo hataye toh yeh bilkul normal hai — bas square ki taal par wapas aa jayein. Aap apne jism ko hukm par sukoon sikha rahe hain.',
      AppLang.pa:
      'ਪੈਟਰਨ \'ਤੇ ਚੱਲਦੇ ਰਹੋ — ਸਾਹ ਅੰਦਰ, ਰੋਕੋ, ਬਾਹਰ, ਰੋਕੋ, ਹਰ ਇੱਕ ਚਾਰ ਸਥਿਰ ਗਿਣਤੀ ਤੱਕ। ਵਰਗ ਦੇ ਹਰ ਚੱਕਰ ਨਾਲ ਮਹਿਸੂਸ ਕਰੋ ਕਿ ਦਿਲ ਦੀ ਧੜਕਣ ਸਥਿਰ ਹੋ ਰਹੀ ਹੈ, ਮਨ ਸ਼ਾਂਤ ਹੋ ਰਿਹਾ ਹੈ। ਜੇ ਕੋਈ ਵਿਚਾਰ ਧਿਆਨ ਹਟਾਵੇ ਤਾਂ ਇਹ ਬਿਲਕੁਲ ਆਮ ਗੱਲ ਹੈ — ਬੱਸ ਵਰਗ ਦੀ ਤਾਲ \'ਤੇ ਵਾਪਸ ਆ ਜਾਓ। ਤੁਸੀਂ ਆਪਣੇ ਸਰੀਰ ਨੂੰ ਹੁਕਮ \'ਤੇ ਸ਼ਾਂਤੀ ਸਿਖਾ ਰਹੇ ਹੋ।',
    },
    duration: const Duration(milliseconds: 32000),
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
      'Wonderful work. Let your breath return to its natural rhythm, no longer counted, just easy and free. Notice the steadiness you\'ve built — a tool you can use anywhere, anytime you need to find your center. When you\'re ready, gently open your eyes and carry this calm forward.',
      AppLang.ur:
      'بہت خوب۔ اب اپنی سانس کو اس کی قدرتی تال پر واپس آنے دیں... نہ کوئی گنتی، نہ کوئی کوشش۔ بس آسان، اور آزاد۔ ایک لمحے کے لیے محسوس کریں... آپ نے اپنے اندر کتنا سکون اور ٹھہراؤ پیدا کر لیا ہے۔ یہ ایک ایسی صلاحیت ہے جو آپ کہیں بھی، کسی بھی وقت، اپنے ساتھ استعمال کر سکتے ہیں۔ جب تیار محسوس ہوں، آہستہ سے آنکھیں کھولیں... اور اس سکون کو، اسی آرام دہ رفتار کے ساتھ، اپنے دن میں آگے لے کر چلیں۔',
      AppLang.urRoman:
      'Bohat khoob. Apni saans ko uski qudrati taal par wapas aane dein, ab ginti nahi, bas aasan aur azaad. Jo mustaqil mizaji aap ne banayi hai usay mehsoos karein — yeh aik aisa tool hai jo aap kahin bhi, kisi bhi waqt istemal kar sakte hain. Jab tayyar hon, aahista se ankhen kholein aur is sukoon ko aage le kar chalein.',
      AppLang.pa:
      'ਬਹੁਤ ਵਧੀਆ। ਆਪਣੇ ਸਾਹ ਨੂੰ ਆਪਣੀ ਕੁਦਰਤੀ ਤਾਲ \'ਤੇ ਵਾਪਸ ਆਉਣ ਦਿਓ, ਹੁਣ ਗਿਣਤੀ ਨਹੀਂ, ਬੱਸ ਸੌਖਾ ਅਤੇ ਆਜ਼ਾਦ। ਜੋ ਸਥਿਰਤਾ ਤੁਸੀਂ ਬਣਾਈ ਹੈ ਉਸਨੂੰ ਮਹਿਸੂਸ ਕਰੋ — ਇਹ ਇੱਕ ਅਜਿਹਾ ਸਾਧਨ ਹੈ ਜੋ ਤੁਸੀਂ ਕਿਤੇ ਵੀ, ਕਿਸੇ ਵੀ ਸਮੇਂ ਵਰਤ ਸਕਦੇ ਹੋ। ਜਦੋਂ ਤਿਆਰ ਹੋਵੋ, ਹੌਲੀ ਨਾਲ ਅੱਖਾਂ ਖੋਲ੍ਹੋ ਅਤੇ ਇਸ ਸ਼ਾਂਤੀ ਨੂੰ ਅੱਗੇ ਲੈ ਕੇ ਚੱਲੋ।',
    },
    duration: const Duration(milliseconds: 16000),
  ),
];

final boxBreathingCompletion = CompletionConfig(
  title: 'Breath Steadied',
  subtitleBuilder: (n) => 'You completed $n calming breath phases in rhythm.\nYour nervous system thanks you.',
  unitLabel: 'PHASES PACED',
  unitCount: 4,
  chartTitle: 'Calm by Breath Phase',
  chartRows: const [
    CompletionStat('Inhale', 86),
    CompletionStat('Hold', 80),
    CompletionStat('Exhale', 91),
    CompletionStat('Hold', 79),
  ],
);
