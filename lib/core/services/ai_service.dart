class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Map<String, String> _keywordMap = {
    // Technology
    'coding': 'Technology',
    'programming': 'Technology',
    'software': 'Technology',
    'web': 'Technology',
    'app': 'Technology',
    'flutter': 'Technology',
    'dart': 'Technology',
    'python': 'Technology',
    'js': 'Technology',
    'javascript': 'Technology',
    'java': 'Technology',
    'dev': 'Technology',
    'cloud': 'Technology',
    'ai': 'Technology',
    'database': 'Technology',
    
    // Creative Arts
    'design': 'Creative Arts',
    'ui': 'Creative Arts',
    'ux': 'Creative Arts',
    'drawing': 'Creative Arts',
    'painting': 'Creative Arts',
    'music': 'Creative Arts',
    'guitar': 'Creative Arts',
    'piano': 'Creative Arts',
    'photography': 'Creative Arts',
    'video': 'Creative Arts',
    'editing': 'Creative Arts',
    'dance': 'Creative Arts',
    
    // Business
    'marketing': 'Business',
    'sales': 'Business',
    'management': 'Business',
    'startup': 'Business',
    'finance': 'Business',
    'accounting': 'Business',
    'investing': 'Business',
    'strategy': 'Business',
    
    // Languages
    'english': 'Languages',
    'spanish': 'Languages',
    'french': 'Languages',
    'german': 'Languages',
    'chinese': 'Languages',
    'japanese': 'Languages',
    'language': 'Languages',
    
    // Lifestyle
    'cooking': 'Lifestyle',
    'baking': 'Lifestyle',
    'fitness': 'Lifestyle',
    'yoga': 'Lifestyle',
    'gym': 'Lifestyle',
    'meditation': 'Lifestyle',
    'travel': 'Lifestyle',
    'gardening': 'Lifestyle',
  };

  /// Suggests a category for a given skill name.
  /// This is currently a keyword-based heuristic but can be upgraded to an LLM call.
  Future<String> suggestCategory(String skillName) async {
    // Simulate network delay for AI processing
    await Future.delayed(const Duration(milliseconds: 300));
    
    final normalized = skillName.toLowerCase();
    
    // Check for direct matches or contains logic
    for (final entry in _keywordMap.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return 'General';
  }
}
