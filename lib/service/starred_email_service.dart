import 'dart:convert';
import 'dart:developer';

import 'package:email_app/service/token_service.dart';
import 'package:http/http.dart' as http;

class StarredEmailService {
  Future<void> toggleStarStatus(String messageId, bool shouldStar) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) return;

    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId/modify',
    );

    // Determine whether to add or remove the label
    final Map<String, List<String>> body;
    if (shouldStar) {
      body = {
        'addLabelIds': ['STARRED'],
      };
    } else {
      body = {
        'removeLabelIds': ['STARRED'],
      };
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      log('Successfully updated star status for email $messageId.');
    } else {
      log('Failed to update star status. Status: ${response.statusCode}');
    }
  }
}
