import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/question_models.dart';

class AiService {
  final http.Client _client = http.Client();

  Future<String> askQuestion({
    required String question,
    String? context,
    String? imagePath,
  }) async {
    final query = question.trim();
    if (query.isEmpty) {
      return 'দয়া করে আপনার প্রশ্নটি লিখুন।';
    }

    if (AppConfig.apiKey.isEmpty) {
      return _fallbackAnswer(query);
    }

    try {
      final body = {
        'model': AppConfig.model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a Bangla study assistant for school students. Answer in simple Bangla. Keep the answer clear, concise, and helpful.',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'Question: $query\n\nContext: ${context ?? 'No extra context'}\n\nAnswer in simple Bangla.',
              },
              if (imagePath != null)
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,${base64Encode(await File(imagePath).readAsBytes())}',
                  }
                },
            ],
          },
        ],
      };

      final response = await _client.post(
        Uri.parse(AppConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.apiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://brain-stomers.app',
          'X-Title': 'Brain Stomers',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final content = decoded['choices']?[0]?['message']?['content'];

        if (content is List) {
          final text = content
              .map((e) => e is Map ? (e['text'] ?? '') : '')
              .join();
          return text.isNotEmpty ? text : _fallbackAnswer(query);
        }

        if (content is String && content.isNotEmpty) {
          return content;
        }
      }
    } catch (_) {
      return _fallbackAnswer(query);
    }

    return _fallbackAnswer(query);
  }

  Future<GeneratedQuestionSet> generateQuestionsFromImage({
    required String imagePath,
    required String classLevel,
    required String difficulty,
    required int count,
  }) async {
    if (AppConfig.apiKey.isEmpty) {
      return GeneratedQuestionSet.demo;
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return GeneratedQuestionSet.demo;
      }

      final base64Image = base64Encode(await file.readAsBytes());
      final prompt = '''
Create study questions from this textbook image.
Return ONLY valid JSON with three keys: "mcq", "creative", and "short".

Rules:
- "mcq" should be an array of objects with question, options, correctAnswer, explanation.
- "creative" should be an array of objects with question, correctAnswer, explanation.
- "short" should be an array of objects with question, correctAnswer, explanation.
- Use Bangla language.
- Class level: $classLevel
- Difficulty: $difficulty
- Number of questions: $count
- Keep answers educational and age-appropriate.
''';

      final response = await _client.post(
        Uri.parse(AppConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.apiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://brain-stomers.app',
          'X-Title': 'Brain Stomers',
        },
        body: jsonEncode({
          'model': AppConfig.model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return GeneratedQuestionSet.demo;
      }

      final decoded = jsonDecode(response.body);
      final rawContent = decoded['choices']?[0]?['message']?['content'];
      String contentText = rawContent is String
          ? rawContent
          : rawContent is List
              ? rawContent
                  .map((e) => e is Map ? (e['text'] ?? '') : '')
                  .join('')
              : '';

      if (contentText.isEmpty) {
        return GeneratedQuestionSet.demo;
      }

      contentText = _stripMarkdown(contentText);
      final parsed = jsonDecode(contentText);
      if (parsed is Map<String, dynamic>) {
        return GeneratedQuestionSet.fromJson(parsed);
      }
    } catch (_) {
      return GeneratedQuestionSet.demo;
    }

    return GeneratedQuestionSet.demo;
  }

  String _fallbackAnswer(String question) {
    if (question.toLowerCase().contains('বিজ্ঞান') ||
        question.toLowerCase().contains('science')) {
      return 'বিজ্ঞান হলো প্রকৃতি, বস্তু এবং ঘটনার নিয়ম জানতে শেখার পদ্ধতি। আপনি সহজ ভাষায় বলতে পারেন: বিজ্ঞান এমন একটি জ্ঞান যেখানে আমরা পর্যবেক্ষণ, পরীক্ষা, এবং বিশ্লেষণের মাধ্যমে বুঝি কীভাবে জগৎ কাজ করে।';
    }

    if (question.toLowerCase().contains('গণিত') ||
        question.toLowerCase().contains('math')) {
      return 'গণিত হলো সংখ্যা, আকার, সম্পর্ক ও সমস্যা সমাধানের বিজ্ঞান। সহজভাবে বললে, গণিত আমাদের চিন্তাভাবনা, pattern খুঁজে বের করতে এবং প্রতিদিনের সমস্যার সমাধান করতে সাহায্য করে।';
    }

    if (question.toLowerCase().contains('বাংলা') ||
        question.toLowerCase().contains('bangla')) {
      return 'বাংলা ভাষা ও সাহিত্য পড়তে গিয়ে শব্দ, বাক্য, ভাব ও ভাষার সৌন্দর্য বুঝতে হয়। লেখার সময় সঠিক বর্ণ, বাক্য গঠন এবং অর্থের দিকে নজর দিতে হবে।';
    }

    return 'আপনার প্রশ্নের উত্তর খুঁজতে আমি একটি সহজ, শিক্ষামূলক ব্যাখ্যা দিতে পারি। প্রথমে বিষয়টি চিহ্নিত করুন, তারপর মূল ধারণা, উদাহরণ ও সংক্ষিপ্ত ব্যাখ্যা দিয়ে উত্তর সাজান।';
  }

  String _stripMarkdown(String input) {
    var cleaned = input.trim();
    final fenceRegex = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true);
    final match = fenceRegex.firstMatch(cleaned);
    if (match != null) {
      cleaned = match.group(1) ?? cleaned;
    }
    return cleaned;
  }
}
