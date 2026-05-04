import 'rules.dart';

class GameRule {
  final String topic;
  final List<String> keywords;
  final String content;

  GameRule({
    required this.topic,
    required this.keywords,
    required this.content,
  });

  factory GameRule.fromJson(Map<String, dynamic> json) {
    return GameRule(
      topic: json['topic'],
      keywords: List<String>.from(json['keywords']),
      content: json['content'],
    );
  }
}

class RuleSearcher {
  /// Ranks rules based on how many keywords/topic words match the user query.
  List<String> findRelevantContext(String userQuery, List<GameRule> allRules) {
    String query = userQuery.toLowerCase();

    // Create a list of rules paired with a relevance score
    List<MapEntry<GameRule, int>> scoredRules =
        allRules.map((rule) {
          int score = 0;

          // Check if topic is mentioned (High weight)
          if (query.contains(rule.topic.toLowerCase())) {
            score += 10;
          }

          // Check for keyword matches (Medium weight)
          for (var keyword in rule.keywords) {
            if (query.contains(keyword.toLowerCase())) {
              score += 5;
            }
          }

          // Check content for specific terms (Low weight)
          // This helps catch context even if keywords aren't perfect.
          List<String> queryWords = query.split(' ');
          for (var word in queryWords) {
            if (word.length > 3 && rule.content.toLowerCase().contains(word)) {
              score += 1;
            }
          }

          return MapEntry(rule, score);
        }).toList();

    // Sort by score descending and remove zero-score results
    scoredRules.sort((a, b) => b.value.compareTo(a.value));

    // Take the top 3 most relevant sections to stay efficient
    return scoredRules
        .where((entry) => entry.value > 0)
        .take(3)
        .map((entry) => entry.key.content)
        .toList();
  }
}



String getContext(String userQuery) {
  RuleSearcher ruleSearcher = RuleSearcher();
  List<String> contextSnippets = ruleSearcher.findRelevantContext(
    userQuery,
    rules.map((rule) => GameRule.fromJson(rule)).toList(),
  );

  String context;

  if (contextSnippets.isNotEmpty) {
    context = contextSnippets.join("\n\n");
  } else {
    context = """
                No specific snippets found. Answer generally about CyCull.
                In CyCull: The Culling Game, players battle using unique Kits and resources to be the last one standing. Success requires resource management, luck, and good decision-making. The core objective is to deal damage and survive longer than your opponents,      
              """;
  }

  return context;
}
