import 'package:autism_screener/models/mchat_question.dart';

class MchatQuestions {
  static const List<MchatQuestion> questions = [
    MchatQuestion(
      id: 1,
      question: "هل يستمتع طفلك بأن يتم هزه على ركبتيك أو أن يقفز على ركبتيك؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 2,
      question: "هل يهتم طفلك بالأطفال الآخرين؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 3,
      question: "هل يحب طفلك التسلق على الأشياء، مثل تسلق السلالم؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 4,
      question: "هل يستمتع طفلك بلعب الاستغماية أو الغميضة؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 5,
      question:
          "هل يتظاهر طفلك أحياناً، على سبيل المثال، بأنه يتحدث في التليفون أو يرعى دمية أو يتظاهر بأشياء أخرى؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 6,
      question: "هل يستخدم طفلك إصبع السبابة للإشارة، لطلب شيء ما؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 7,
      question:
          "هل يستخدم طفلك إصبع السبابة للإشارة، للإشارة إلى اهتمامه بشيء ما؟",
      isCritical: true,
      followUpQuestion:
          "هل يشير طفلك إلى الأشياء التي تثير اهتمامه للفت انتباهك إليها؟",
    ),
    MchatQuestion(
      id: 8,
      question:
          "هل يستطيع طفلك أن يلعب بشكل صحيح بالألعاب الصغيرة (مثل السيارات أو المكعبات) دون أن يضعها في فمه، أو يحركها بلا هدف، أو يسقطها؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 9,
      question: "هل يحضر طفلك لك أشياء ليريك إياها؟",
      isCritical: false,
      followUpQuestion:
          "هل يحضر طفلك أشياء ليشاركك فيها وليس فقط للحصول على المساعدة؟",
    ),
    MchatQuestion(
      id: 10,
      question: "هل ينظر طفلك إليك في العينين لأكثر من ثانية أو ثانيتين؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 11,
      question:
          "هل يبدو طفلك حساساً جداً للضوضاء (على سبيل المثال، يغطي أذنيه)؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 12,
      question: "هل يبتسم طفلك استجابة لوجهك أو ابتسامتك؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 13,
      question:
          "هل يقلد طفلك حركاتك؟ (على سبيل المثال، إذا قمت بعمل وجه، هل يقلده؟)",
      isCritical: false,
      followUpQuestion: "هل يقلد طفلك ما تفعله، مثل التصفيق أو إصدار أصوات؟",
    ),
    MchatQuestion(
      id: 14,
      question: "هل يستجيب طفلك إذا ناديته باسمه؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 15,
      question:
          "إذا أشرت إلى لعبة في الجانب الآخر من الغرفة، هل ينظر طفلك إليها؟",
      isCritical: false,
      followUpQuestion: "هل يتبع طفلك عندما تشير إلى شيء ما؟",
    ),
    MchatQuestion(id: 16, question: "هل يمشي طفلك؟", isCritical: false),
    MchatQuestion(
      id: 17,
      question: "هل ينظر طفلك إلى الأشياء التي تنظر إليها؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 18,
      question: "هل يقوم طفلك بحركات غريبة بأصابعه بالقرب من وجهه؟",
      isCritical: false,
    ),
    MchatQuestion(
      id: 19,
      question: "هل يحاول طفلك أن يلفت انتباهك إلى نشاطه الخاص؟",
      isCritical: false,
      followUpQuestion: "هل يحاول طفلك جذب انتباهك إلى الأشياء التي يفعلها؟",
    ),
    MchatQuestion(
      id: 20,
      question: "هل تساءلت يوماً إذا كان طفلك أصم؟",
      isCritical: true,
      followUpQuestion: "هل تقلق من أن طفلك قد يعاني من مشاكل في السمع؟",
    ),
  ];

  static MchatQuestion getQuestion(int id) {
    return questions.firstWhere((q) => q.id == id);
  }

  static List<MchatQuestion> getCriticalQuestions() {
    return questions.where((q) => q.isCritical).toList();
  }

  static List<MchatQuestion> getNonCriticalQuestions() {
    return questions.where((q) => !q.isCritical).toList();
  }
}
