class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String type;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.type,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json, String type) {
    final rawOptions = json['options'] is List
        ? List<dynamic>.from(json['options'])
        : json['choices'] is List
            ? List<dynamic>.from(json['choices'])
            : const <dynamic>[];

    final options = rawOptions
        .map((item) => item.toString())
        .toList();

    final correct = (json['correctAnswer'] ?? json['answer'] ?? json['correct_answer'] ?? '')
        .toString();

    final explanation = (json['explanation'] ?? '')
        .toString();

    return QuizQuestion(
      question: (json['question'] ?? json['prompt'] ?? 'Question').toString(),
      options: options,
      correctAnswer: correct,
      explanation: explanation,
      type: type,
    );
  }
}

class GeneratedQuestionSet {
  final List<QuizQuestion> mcq;
  final List<QuizQuestion> creative;
  final List<QuizQuestion> short;

  const GeneratedQuestionSet({
    this.mcq = const [],
    this.creative = const [],
    this.short = const [],
  });

  factory GeneratedQuestionSet.fromJson(Map<String, dynamic> json) {
    final mcqList = (json['mcq'] as List? ?? [])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>, 'MCQ'))
        .toList();

    final creativeList = (json['creative'] as List? ?? [])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>, 'Creative'))
        .toList();

    final shortList = (json['short'] as List? ?? [])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>, 'Short'))
        .toList();

    return GeneratedQuestionSet(
      mcq: mcqList,
      creative: creativeList,
      short: shortList,
    );
  }

  static GeneratedQuestionSet get demo => GeneratedQuestionSet(
        mcq: [
          QuizQuestion(
            question: 'পৃথিবীর উপরিভাগের মূল উপাদান কী?',
            options: ['জল', 'বাতাস', 'মাটি', 'চাঁদ'],
            correctAnswer: 'মাটি',
            explanation: 'পৃথিবীর মাটি একটি গুরুত্বপূর্ণ অংশ, যা উদ্ভিদ বৃদ্ধিতে সহায়তা করে।',
            type: 'MCQ',
          ),
          QuizQuestion(
            question: 'শ্রেণির সৃষ্টিশীল চিন্তায় কী প্রয়োজন?',
            options: ['অল্প পড়া', 'ভালো ধারণা', 'শুধু উত্তর', 'কোনোটিই নয়'],
            correctAnswer: 'ভালো ধারণা',
            explanation: 'সৃজনশীল প্রশ্নে ধারণা, বিশ্লেষণ ও নিজস্ব ভাষা ব্যবহারের প্রয়োজন হয়।',
            type: 'MCQ',
          ),
        ],
        creative: [
          QuizQuestion(
            question: 'একটি দিনের সুন্দর অভিজ্ঞতা বর্ণনা করো যেখানে তুমি প্রকৃতিতে ঘুরে এসেছো।',
            options: const [],
            correctAnswer: 'উদ্দীপকের আলোকে নিজের ভাষায় উত্তর লিখুন।',
            explanation: 'এই ধরনের প্রশ্নে নিজের অভিজ্ঞতা, অনুভূতি ও বর্ণনা থাকতে হবে।',
            type: 'Creative',
          ),
        ],
        short: [
          QuizQuestion(
            question: 'বিজ্ঞান কী?',
            options: const [],
            correctAnswer: 'বিজ্ঞান হলো প্রকৃতি ও পৃথিবীর নিয়ম বুঝতে ব্যবহৃত পদ্ধতি।',
            explanation: 'সংক্ষিপ্ত উত্তরটি সঠিক ও স্পষ্ট হওয়া উচিত।',
            type: 'Short',
          ),
        ],
      );
}
