import 'search.dart';
import 'package:firebase_ai/firebase_ai.dart';


// class CyCullState extends ChangeNotifier { should extend changeNotifier
class CyCullState {
  bool isThinking = false;
  bool errorResponse = false;
  String response = "";
  List chatHistory = [];
  String _query = "";

  void updateQuery(String query) {
    _query = query;
    // notifyListeners();
  }

  void handleUserQuery() async {
    errorResponse = false;
    String context = getContext(_query);
    chatHistory.add({'role': 'user', 'content': _query});

    // ignore: experimental_member_use
    final model = FirebaseAI.googleAI().templateGenerativeModel();

    try {
      isThinking = true;
      // notifyListeners();

      // ignore: experimental_member_use
      final responseStream = model.generateContentStream(
        "woden-template",
        inputs: {'clientSnippets': context, 'userQuery': _query},
      );

      response = "";

      await for (final content in responseStream) {
        if (content.text != null) {
          response += (content.text ?? "");
          // notifyListeners();
        }
      }
      isThinking = false;
      chatHistory.add({'role': 'assistant', 'content': response});
      // notifyListeners();
    } catch (e) {
      isThinking = false;
      errorResponse = true;
      // notifyListeners();
    }
  }

}
