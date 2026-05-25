import '../config/api_config.dart';
import 'api_service.dart';

class AIOutfitSuggestion {
  final String outfitName, description, stylingTip, occasion, colorPalette, emoji;
  final List<AISuggestedItem> items;
  AIOutfitSuggestion({required this.outfitName, required this.description,
      required this.items, required this.stylingTip, required this.occasion,
      required this.colorPalette, required this.emoji});

  factory AIOutfitSuggestion.fromMap(Map<String, dynamic> map) => AIOutfitSuggestion(
    outfitName: map['outfitName'] ?? 'AI Curated Look',
    description: map['description'] ?? '',
    emoji: map['emoji'] ?? '✨',
    colorPalette: map['colorPalette'] ?? '',
    stylingTip: map['stylingTip'] ?? '',
    occasion: map['occasion'] ?? 'Casual',
    items: (map['items'] as List? ?? []).map((i) => AISuggestedItem.fromMap(i)).toList(),
  );
}

class AISuggestedItem {
  final String name, category, description, colorHint;
  AISuggestedItem({required this.name, required this.category,
      required this.description, required this.colorHint});

  factory AISuggestedItem.fromMap(Map<String, dynamic> map) => AISuggestedItem(
    name: map['name'] ?? '', category: map['category'] ?? '',
    description: map['description'] ?? '', colorHint: map['colorHint'] ?? '',
  );
}

class AIService {
  Future<AIOutfitSuggestion> generateOutfit({
    required String occasion, String? colorPreference, String? season, String? userMessage,
  }) async {
    try {
      final body = <String, dynamic>{'occasion': occasion};
      if (colorPreference != null && colorPreference.isNotEmpty) body['colorPreference'] = colorPreference;
      if (season != null && season.isNotEmpty) body['season'] = season;
      if (userMessage != null && userMessage.isNotEmpty) body['userMessage'] = userMessage;

      final data = await ApiService.post(ApiConfig.aiGenerate, body);
      if (data['success'] == true && data['suggestion'] != null) {
        return AIOutfitSuggestion.fromMap(data['suggestion']);
      }
      throw Exception(data['message'] ?? 'AI generation failed');
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }
}
