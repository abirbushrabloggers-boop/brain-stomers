class AppConfig {
  static const String apiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );

  static const String model = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'openai/gpt-4o-mini',
  );

  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
}
