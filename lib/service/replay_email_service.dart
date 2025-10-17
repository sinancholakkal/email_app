// Add these imports to your service file
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode, base64Url, utf8
import 'dart:developer';
import 'package:email_app/model/email_model.dart'; // Ensure path is correct
import 'token_service.dart'; // Ensure path is correct

class ReplayEmailService {
  // Or your specific ReplyEmailService

  // --- Add this function ---
  /// Sends a reply to a specific email as HTML.
  ///
  /// Requires the [originalEmail] object (which must contain messageIdHeader and referencesHeader),
  /// the [replyBody] text written by the user, and the [currentUserEmail].
  Future<bool> replyToEmail({
    required Email originalEmail,
    required String replyBody,
    required String currentUserEmail,
  }) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) {
      log("Cannot reply: Access Token is null.");
      return false;
    }

    // --- 1. Get Reply Headers (using headers stored in the model) ---
    final String originalMessageIdHeader =
        originalEmail.messageIdHeader ?? '<>'; // Use stored header
    final String originalReferencesHeader =
        originalEmail.referencesHeader ?? ''; // Use stored header
    final String originalSubject = originalEmail.subject;
    final String replyToAddress = _extractEmailAddress(originalEmail.from);

    // --- 2. Construct Reply Headers ---
    final String replySubject = originalSubject.toLowerCase().startsWith('re:')
        ? originalSubject
        : 'Re: $originalSubject';
    final String references = originalReferencesHeader.isEmpty
        ? originalMessageIdHeader
        : '$originalReferencesHeader $originalMessageIdHeader';

    // --- 3. Format the Reply Body (as HTML) ---
    final String htmlReplyBody = replyBody.trim().replaceAll('\n', '<br>');
    // Basic HTML quoting
    final String formattedOriginalBody =
        """
<br><br>
<div style="border-left: 1px solid #ccc; margin-left: 5px; padding-left: 10px; color: #666;">
On ${originalEmail.date.toLocal()}, ${_extractName(originalEmail.from)} wrote:<br>
${originalEmail.isHtml ? originalEmail.body : originalEmail.body.replaceAll('\n', '<br>')}
</div>
""";

    final String fullReplyBody = htmlReplyBody + formattedOriginalBody;

    // --- 4. Construct the Raw MIME Email (as HTML) ---
    final String rawEmail =
        """
Content-Type: text/html; charset="UTF-8"
MIME-Version: 1.0
To: $replyToAddress
From: $currentUserEmail
Subject: $replySubject
In-Reply-To: $originalMessageIdHeader
References: $references

$fullReplyBody
""";

    // --- 5. Base64URL Encode ---
    // Ensure padding is removed and characters are URL-safe
    final String encodedRawEmail = base64Url
        .encode(utf8.encode(rawEmail))
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');

    // --- 6. Send via API ---
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
        'threadId': originalEmail.threadId, // Keep it in the same thread
      }),
    );

    // --- 7. Handle Response ---
    if (response.statusCode == 200) {
      log('Reply sent successfully.');
      return true;
    } else if (response.statusCode == 401) {
      log("Access Token Expired (401) while sending reply.");
      // Consider triggering re-authentication here
      return false;
    } else {
      log('Failed to send reply. Status: ${response.statusCode}');
      log('Response: ${response.body}');
      return false;
    }
  }

  // --- Required Helper Methods ---

  /// Extracts email address from "Name <email@addr.com>" format.
  String _extractEmailAddress(String field) {
    final emailMatch = RegExp(r'<([^>]+)>').firstMatch(field);
    return emailMatch?.group(1) ?? field.trim();
  }

  /// Extracts display name from "Name <email@addr.com>" format.
  String _extractName(String fromField) {
    final nameMatch = RegExp(r'^"?([^"<]+)"?\s*<').firstMatch(fromField);
    // If no display name found in quotes/brackets, return the part before '@'
    return nameMatch?.group(1)?.trim() ?? fromField.split('@').first;
  }
} // End of class
