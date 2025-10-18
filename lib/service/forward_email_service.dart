import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:email_app/model/email_model.dart';
import 'token_service.dart';

class ForwardEmailService {
  Future<bool> forwardEmail({
    required Email originalEmail,
    required String forwardBody,
    required String currentUserEmail,
    required List<String> toRecipients,
    List<String>? ccRecipients,
  }) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) {
      log("Cannot forward: Access Token is null.");
      return false;
    }

    // Validate recipients
    if (toRecipients.isEmpty) {
      log("Cannot forward: No recipients provided.");
      return false;
    }

    final String forwardSubject = originalEmail.subject.toLowerCase().startsWith('fwd:')
        ? originalEmail.subject
        : 'Fwd: ${originalEmail.subject}';

    // Format the forward body with original message
    final String htmlForwardBody = forwardBody.trim().replaceAll('\n', '<br>');
    final String formattedOriginalMessage = """
<br><br>
---------- Forwarded message ---------<br>
From: ${_extractName(originalEmail.from)} &lt;${_extractEmailAddress(originalEmail.from)}&gt;<br>
Date: ${originalEmail.date.toLocal()}<br>
Subject: ${originalEmail.subject}<br>
To: ${originalEmail.to}<br>
${originalEmail.ccHeader != null && originalEmail.ccHeader!.isNotEmpty ? 'Cc: ${originalEmail.ccHeader}<br>' : ''}
<br>
${originalEmail.isHtml ? originalEmail.body : originalEmail.body.replaceAll('\n', '<br>')}
""";

    final String fullForwardBody = htmlForwardBody + formattedOriginalMessage;

    // Build raw email
    final String toHeader = toRecipients.join(', ');
    final String ccHeader = ccRecipients != null && ccRecipients.isNotEmpty
        ? '\nCc: ${ccRecipients.join(', ')}'
        : '';

    final String rawEmail = """
Content-Type: text/html; charset="UTF-8"
MIME-Version: 1.0
To: $toHeader$ccHeader
From: $currentUserEmail
Subject: $forwardSubject

$fullForwardBody
""";

    final String encodedRawEmail = base64Url
        .encode(utf8.encode(rawEmail))
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');

    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/messages/send',
    );
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'raw': encodedRawEmail,
        // Note: Forwarded emails start a new thread, so we don't include threadId
      }),
    );

    if (response.statusCode == 200) {
      log('Forward sent successfully.');
      return true;
    } else if (response.statusCode == 401) {
      log("Access Token Expired (401) while forwarding email.");
      return false;
    } else {
      log('Failed to forward email. Status: ${response.statusCode}');
      log('Response: ${response.body}');
      return false;
    }
  }

  String _extractEmailAddress(String field) {
    if (field.isEmpty) return '';
    final emailMatch = RegExp(r'<([^>]+)>').firstMatch(field);
    if (emailMatch != null) {
      return emailMatch.group(1)!.trim();
    }
    if (field.contains('@')) {
      return field.replaceAll('"', '').trim();
    }
    return '';
  }

  String _extractName(String fromField) {
    if (fromField.isEmpty) return '';
    final nameMatch = RegExp(r'^"?([^"<]+)"?\s*<').firstMatch(fromField);
    if (nameMatch != null) {
      return nameMatch.group(1)!.trim();
    }
    if (fromField.contains('@')) {
      return fromField.split('@').first.trim();
    }
    return fromField.trim();
  }

  List<String> parseEmailAddresses(String input) {
    if (input.isEmpty) return [];
    
    final List<String> emails = [];
    final parts = input.split(RegExp(r'[,;]'));
    
    for (String part in parts) {
      String trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      
      String email = _extractEmailAddress(trimmed);
      if (email.isEmpty && trimmed.contains('@')) {
        email = trimmed;
      }
      
      if (email.isNotEmpty && _isValidEmail(email)) {
        emails.add(email);
      }
    }
    
    return emails;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

