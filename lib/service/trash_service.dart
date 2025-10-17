
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'token_service.dart'; // Make sure this path is correct

class TrashService {


/// Moves a specific email to the trash.
Future<bool> trashEmail(String messageId) async {
  final accessToken = await TokenService().getAccessToken();
  if (accessToken == null) return false;

  // Gmail API endpoint to move a message to trash
  final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId/trash');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    log('Successfully moved email $messageId to trash.');
    return true; // Indicate success
  } else {
    log('Failed to trash email. Status: ${response.statusCode}');
    log('Response: ${response.body}');
    return false; // Indicate failure
  }
}
}