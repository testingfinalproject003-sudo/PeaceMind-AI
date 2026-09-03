
import '../models/exercise_models.dart';

/// Body Scan (PMR) content — copied verbatim from the original
/// pmr_body_scan_final.html TRANSLATIONS object. Nothing reworded.
final List<ExerciseStep> bodyScanSteps = [
  ExerciseStep(
    label: {
      AppLang.en: 'Breath & Grounding',
      AppLang.ur: 'سانس اور یکسوئی',
      AppLang.urRoman: 'Saans aur Grounding',
      AppLang.pa: 'ਸਾਹ ਅਤੇ ਧਿਆਨ',
    },
    text: {
      AppLang.en: 'Welcome. Close your eyes gently, or soften your gaze downward. Find a comfortable position, back straight, hands resting on your lap. Breathe in slowly through your nose for four counts... one, two, three, four... hold for a moment... and exhale slowly through your mouth for six counts, letting your shoulders drop. Imagine a warm golden light gently filling your chest with each breath, spreading calm through your whole body. Let\'s take one more slow breath together, in... and out. Feel yourself arriving fully in this moment.',
      AppLang.ur: 'خوش آمدید۔ اپنی آنکھیں آہستہ سے بند کر لیں، یا نظر نیچے نرم کر لیں۔ ایک آرام دہ حالت میں بیٹھیں، کمر سیدھی، ہاتھ گود میں رکھیں۔ ناک سے آہستہ سانس اندر لیں... ایک، دو، تین، چار... تھوڑی دیر روکیں... اور منہ سے آہستہ سانس باہر نکالیں، چھ گنتی تک، اور اپنے کندھے ڈھیلے چھوڑ دیں۔ تصور کریں کہ ایک گرم سنہری روشنی آپ کے سینے میں بھر رہی ہے، جو پورے جسم میں سکون پھیلا رہی ہے۔ آئیے ایک اور گہرا سانس لیں، اندر... اور باہر۔ اس لمحے میں مکمل طور پر موجود محسوس کریں۔',
      AppLang.urRoman: 'Khush aamdeed. Apni ankhen aahista se band kar lein, ya nazar neeche naram kar lein. Aaram deh position mein baithen, kamar seedhi, hath god mein. Naak se aahista saans andar lein... aik, do, teen, chaar... thori dair rukein... aur mun se aahista saans bahar nikalein, cheh tak ginte huay, aur shoulders dheele chor dein. Tasawwur karein aik garam sunehri roshni aapke seenay mein bhar rahi hai, jo pooray jism mein sukoon phela rahi hai. Aaeye aik aur gehra saans lein, andar... aur bahar. Is lamhay mein mukammal tor par maujood mehsoos karein.',
      AppLang.pa: 'ਜੀ ਆਇਆਂ ਨੂੰ। ਆਪਣੀਆਂ ਅੱਖਾਂ ਹੌਲੀ ਬੰਦ ਕਰੋ, ਜਾਂ ਨਜ਼ਰ ਨੂੰ ਨਰਮੀ ਨਾਲ ਹੇਠਾਂ ਕਰੋ। ਇੱਕ ਆਰਾਮਦਾਇਕ ਸਥਿਤੀ ਵਿੱਚ ਬੈਠੋ, ਪਿੱਠ ਸਿੱਧੀ, ਹੱਥ ਗੋਦ ਵਿੱਚ। ਨੱਕ ਰਾਹੀਂ ਹੌਲੀ ਸਾਹ ਅੰਦਰ ਲਵੋ... ਇੱਕ, ਦੋ, ਤਿੰਨ, ਚਾਰ... ਥੋੜ੍ਹਾ ਰੁਕੋ... ਅਤੇ ਮੂੰਹ ਰਾਹੀਂ ਹੌਲੀ ਸਾਹ ਬਾਹਰ ਕੱਢੋ, ਛੇ ਗਿਣਤੀ ਤੱਕ, ਮੋਢੇ ਢਿੱਲੇ ਛੱਡਦੇ ਹੋਏ। ਕਲਪਨਾ ਕਰੋ ਇੱਕ ਨਿੱਘੀ ਸੁਨਹਿਰੀ ਰੌਸ਼ਨੀ ਤੁਹਾਡੀ ਛਾਤੀ ਵਿੱਚ ਭਰ ਰਹੀ ਹੈ, ਪੂਰੇ ਸਰੀਰ ਵਿੱਚ ਸ਼ਾਂਤੀ ਫੈਲਾ ਰਹੀ ਹੈ। ਆਓ ਇੱਕ ਹੋਰ ਡੂੰਘਾ ਸਾਹ ਲਈਏ, ਅੰਦਰ... ਅਤੇ ਬਾਹਰ। ਇਸ ਪਲ ਵਿੱਚ ਪੂਰੀ ਤਰ੍ਹਾਂ ਮੌਜੂਦ ਮਹਿਸੂਸ ਕਰੋ।',
    },
    duration: const Duration(milliseconds: 24000),
    activeNodes: const ['n-chest'],
    eyesClosed: false,
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Shoulder Release',
      AppLang.ur: 'کندھوں کی نرمی',
      AppLang.urRoman: 'Shoulder Release',
      AppLang.pa: 'ਮੋਢੇ ਦੀ ਰਾਹਤ',
    },
    text: {
      AppLang.en: 'Now bring your attention to your shoulders and neck. Slowly raise your shoulders up toward your ears, feel the tension building... hold it for three, two, one... and let go completely. Feel the warmth spread as your shoulders drop, muscles going soft and heavy. Imagine any tightness melting away like ice under sunlight. Roll your neck gently side to side, breathing steadily. With every exhale, imagine tension leaving your body like a wave receding from the shore.',
      AppLang.ur: 'اب اپنی توجہ کندھوں اور گردن پر لائیں۔ آہستہ سے اپنے کندھے کانوں کی طرف اٹھائیں، تناؤ محسوس کریں... تین، دو، ایک تک روکیں... اور مکمل طور پر چھوڑ دیں۔ جیسے ہی کندھے نیچے آتے ہیں، ایک گرمائش پھیلتی محسوس کریں، پٹھے نرم اور بھاری ہوتے جا رہے ہیں۔ تصور کریں کہ ہر تناؤ دھوپ میں برف کی طرح پگھل رہا ہے۔ اپنی گردن کو آہستہ سے دائیں بائیں گھمائیں، مستقل سانس لیتے رہیں۔ ہر سانس چھوڑنے کے ساتھ، تصور کریں کہ تناؤ ایک لہر کی طرح ساحل سے دور ہو رہا ہے۔',
      AppLang.urRoman: 'Ab apni tawajjo shoulders aur gardan par layein. Aahista se apne shoulders kaanon ki taraf uthayein, tanao mehsoos karein... teen, do, aik tak rukein... aur mukammal tor par chor dein. Jese hi shoulders neeche aatay hain, aik garmahat phailti mehsoos karein, muscles naram aur bhari hotay ja rahay hain. Tasawwur karein har tanao dhoop mein barf ki tarah pighal raha hai. Apni gardan ko aahista se idhar udhar ghumayein, musalsal saans letay rahein. Har saans chornay ke sath, tasawwur karein tanao aik lehar ki tarah sahil se door ho raha hai.',
      AppLang.pa: 'ਹੁਣ ਆਪਣਾ ਧਿਆਨ ਮੋਢਿਆਂ ਅਤੇ ਗਰਦਨ ਵੱਲ ਲਿਆਓ। ਹੌਲੀ-ਹੌਲੀ ਆਪਣੇ ਮੋਢੇ ਕੰਨਾਂ ਵੱਲ ਚੁੱਕੋ, ਤਣਾਅ ਮਹਿਸੂਸ ਕਰੋ... ਤਿੰਨ, ਦੋ, ਇੱਕ ਤੱਕ ਰੁਕੋ... ਅਤੇ ਪੂਰੀ ਤਰ੍ਹਾਂ ਛੱਡ ਦਿਓ। ਜਿਵੇਂ ਹੀ ਮੋਢੇ ਹੇਠਾਂ ਆਉਂਦੇ ਹਨ, ਇੱਕ ਨਿੱਘ ਫੈਲਦੀ ਮਹਿਸੂਸ ਕਰੋ, ਮਾਸਪੇਸ਼ੀਆਂ ਨਰਮ ਅਤੇ ਭਾਰੀ ਹੁੰਦੀਆਂ ਜਾ ਰਹੀਆਂ ਹਨ। ਕਲਪਨਾ ਕਰੋ ਹਰ ਤਣਾਅ ਧੁੱਪ ਵਿੱਚ ਬਰਫ਼ ਵਾਂਗ ਪਿਘਲ ਰਿਹਾ ਹੈ। ਆਪਣੀ ਗਰਦਨ ਨੂੰ ਹੌਲੀ-ਹੌਲੀ ਏਧਰ-ਓਧਰ ਘੁਮਾਓ, ਲਗਾਤਾਰ ਸਾਹ ਲੈਂਦੇ ਰਹੋ। ਹਰ ਸਾਹ ਛੱਡਣ ਨਾਲ, ਕਲਪਨਾ ਕਰੋ ਤਣਾਅ ਇੱਕ ਲਹਿਰ ਵਾਂਗ ਕਿਨਾਰੇ ਤੋਂ ਦੂਰ ਹੋ ਰਿਹਾ ਹੈ।',
    },
    duration: const Duration(milliseconds: 26000),
    activeNodes: const ['n-neck', 'n-lsh', 'n-rsh'],
    eyesClosed: true,
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Full Body Scan',
      AppLang.ur: 'مکمل جسمانی اسکین',
      AppLang.urRoman: 'Full Body Scan',
      AppLang.pa: 'ਪੂਰਾ ਸਰੀਰ ਸਕੈਨ',
    },
    text: {
      AppLang.en: 'Keep your eyes closed and let your awareness travel slowly downward, like a soft beam of light moving through your body — from your neck, through your shoulders and elbows, into your chest and hips, down through your knees, all the way to your feet. As the light passes each area, imagine that muscle glowing warm, loosening, and releasing. Picture every point of tension dissolving into calm, gentle light. You are safe. You are relaxed. Let your whole body feel light and weightless.',
      AppLang.ur: 'اپنی آنکھیں بند رکھیں اور اپنی توجہ کو آہستہ آہستہ نیچے کی طرف لے جائیں، جیسے ایک نرم روشنی کی کرن آپ کے جسم میں سفر کر رہی ہو — گردن سے، کندھوں اور کہنیوں سے ہوتے ہوئے، سینے اور کولہوں میں، پھر گھٹنوں سے گزرتی ہوئی، آخر میں پیروں تک۔ جیسے ہی روشنی ہر حصے سے گزرتی ہے، تصور کریں وہ پٹھا گرم چمکتے ہوئے، ڈھیلا ہوتے ہوئے اور تناؤ چھوڑتے ہوئے محسوس ہو رہا ہے۔ تصور کریں کہ ہر تناؤ کا نقطہ نرم، پرسکون روشنی میں تحلیل ہو رہا ہے۔ آپ محفوظ ہیں۔ آپ پرسکون ہیں۔ اپنے پورے جسم کو ہلکا اور وزن سے خالی محسوس کریں۔',
      AppLang.urRoman: 'Apni ankhen band rakhein aur apni tawajjo ko aahista aahista neeche ki taraf le jayein, jese aik naram roshni ki kiran aapke jism mein safar kar rahi ho — gardan se, shoulders aur elbows se guzarti huay, seenay aur hips mein, phir knees se guzarti huay, aakhir mein feet tak. Jese hi roshni har hissay se guzarti hai, tasawwur karein wo muscle garam chamakte huay, dheela hotay huay aur tanao chorte huay mehsoos ho raha hai. Tasawwur karein har tanao ka nuqta naram, purskoon roshni mein tehleel ho raha hai. Aap mehfooz hain. Aap purskoon hain. Apne poore jism ko halka aur wazan se khali mehsoos karein.',
      AppLang.pa: 'ਆਪਣੀਆਂ ਅੱਖਾਂ ਬੰਦ ਰੱਖੋ ਅਤੇ ਆਪਣੇ ਧਿਆਨ ਨੂੰ ਹੌਲੀ-ਹੌਲੀ ਹੇਠਾਂ ਵੱਲ ਲੈ ਜਾਓ, ਜਿਵੇਂ ਇੱਕ ਨਰਮ ਰੌਸ਼ਨੀ ਦੀ ਕਿਰਨ ਤੁਹਾਡੇ ਸਰੀਰ ਵਿੱਚ ਸਫ਼ਰ ਕਰ ਰਹੀ ਹੋਵੇ — ਗਰਦਨ ਤੋਂ, ਮੋਢਿਆਂ ਅਤੇ ਕੂਹਣੀਆਂ ਤੋਂ ਹੁੰਦੇ ਹੋਏ, ਛਾਤੀ ਅਤੇ ਕੁੱਲ੍ਹਿਆਂ ਵਿੱਚ, ਫਿਰ ਗੋਡਿਆਂ ਤੋਂ ਲੰਘਦੇ ਹੋਏ, ਆਖਿਰ ਵਿੱਚ ਪੈਰਾਂ ਤੱਕ। ਜਿਵੇਂ ਹੀ ਰੌਸ਼ਨੀ ਹਰ ਹਿੱਸੇ ਤੋਂ ਲੰਘਦੀ ਹੈ, ਕਲਪਨਾ ਕਰੋ ਉਹ ਮਾਸਪੇਸ਼ੀ ਨਿੱਘੀ ਚਮਕਦੀ, ਢਿੱਲੀ ਹੁੰਦੀ ਅਤੇ ਤਣਾਅ ਛੱਡਦੀ ਮਹਿਸੂਸ ਹੋ ਰਹੀ ਹੈ। ਕਲਪਨਾ ਕਰੋ ਹਰ ਤਣਾਅ ਦਾ ਬਿੰਦੂ ਨਰਮ, ਸ਼ਾਂਤ ਰੌਸ਼ਨੀ ਵਿੱਚ ਘੁਲ ਰਿਹਾ ਹੈ। ਤੁਸੀਂ ਸੁਰੱਖਿਅਤ ਹੋ। ਤੁਸੀਂ ਸ਼ਾਂਤ ਹੋ। ਆਪਣੇ ਪੂਰੇ ਸਰੀਰ ਨੂੰ ਹਲਕਾ ਅਤੇ ਭਾਰ-ਰਹਿਤ ਮਹਿਸੂਸ ਕਰੋ।',
    },
    duration: const Duration(milliseconds: 32000),
    activeNodes: const ['n-neck', 'n-lsh', 'n-rsh', 'n-chest', 'n-lelbow', 'n-relbow', 'n-hip', 'n-lknee', 'n-rknee', 'n-lfoot', 'n-rfoot'],
    eyesClosed: true,
  ),
  ExerciseStep(
    label: {
      AppLang.en: 'Completion',
      AppLang.ur: 'تکمیل',
      AppLang.urRoman: 'Mukammal',
      AppLang.pa: 'ਸੰਪੂਰਨਤਾ',
    },
    text: {
      AppLang.en: 'Beautifully done. Take one more deep breath in... and slowly out. Notice how your body feels now — lighter, looser, calmer than before. When you\'re ready, gently open your eyes. Carry this sense of ease with you as you return to your day.',
      AppLang.ur: 'بہت خوب۔ ایک اور گہرا سانس اندر لیں... اور آہستہ سے باہر نکالیں۔ محسوس کریں کہ اب آپ کا جسم کیسا لگ رہا ہے — پہلے سے زیادہ ہلکا، ڈھیلا اور پرسکون۔ جب آپ تیار ہوں، آہستہ سے اپنی آنکھیں کھولیں۔ اس سکون کے احساس کو اپنے ساتھ لے کر اپنے دن میں واپس جائیں۔',
      AppLang.urRoman: 'Bohat khoob. Aik aur gehra saans andar lein... aur aahista se bahar nikalein. Mehsoos karein ke ab aapka jism kaisa lag raha hai — pehle se zyada halka, dheela aur purskoon. Jab aap tayyar hon, aahista se apni ankhen kholein. Is sukoon ke ehsaas ko apne sath le kar apne din mein wapas jayein.',
      AppLang.pa: 'ਬਹੁਤ ਵਧੀਆ। ਇੱਕ ਹੋਰ ਡੂੰਘਾ ਸਾਹ ਅੰਦਰ ਲਵੋ... ਅਤੇ ਹੌਲੀ-ਹੌਲੀ ਬਾਹਰ ਕੱਢੋ। ਮਹਿਸੂਸ ਕਰੋ ਹੁਣ ਤੁਹਾਡਾ ਸਰੀਰ ਕਿਵੇਂ ਲੱਗ ਰਿਹਾ ਹੈ — ਪਹਿਲਾਂ ਨਾਲੋਂ ਹਲਕਾ, ਢਿੱਲਾ ਅਤੇ ਸ਼ਾਂਤ। ਜਦੋਂ ਤੁਸੀਂ ਤਿਆਰ ਹੋਵੋ, ਹੌਲੀ-ਹੌਲੀ ਆਪਣੀਆਂ ਅੱਖਾਂ ਖੋਲ੍ਹੋ। ਇਸ ਸ਼ਾਂਤੀ ਦੇ ਅਹਿਸਾਸ ਨੂੰ ਆਪਣੇ ਨਾਲ ਲੈ ਕੇ ਆਪਣੇ ਦਿਨ ਵਿੱਚ ਵਾਪਸ ਜਾਓ।',
    },
    duration: const Duration(milliseconds: 16000),
    activeNodes: const [],
    eyesClosed: false,
  ),
];

final bodyScanCompletion = CompletionConfig(
  title: 'Session Complete!',
  subtitleBuilder: (n) => 'You released tension across $n muscle groups.\nBeautiful work — your body thanks you.',
  unitLabel: 'MUSCLES SCANNED',
  unitCount: 11,
  chartTitle: 'Tension Released by Region',
  chartRows: const [
    CompletionStat('Neck', 88),
    CompletionStat('Shoulders', 92),
    CompletionStat('Chest', 80),
    CompletionStat('Arms', 75),
    CompletionStat('Hips', 83),
    CompletionStat('Legs', 78),
  ],
);
