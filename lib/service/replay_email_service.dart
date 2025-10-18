
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:email_app/model/email_model.dart';
import 'token_service.dart'; 

class ReplayEmailService {
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

    final String originalMessageIdHeader =
        originalEmail.messageIdHeader ?? '<>';
    final String originalReferencesHeader =
        originalEmail.referencesHeader ?? '';
    final String originalSubject = originalEmail.subject;
    final String replyToAddress = _extractEmailAddress(originalEmail.from);

    
    final String replySubject = originalSubject.toLowerCase().startsWith('re:')
        ? originalSubject
        : 'Re: $originalSubject';
    final String references = originalReferencesHeader.isEmpty
        ? originalMessageIdHeader
        : '$originalReferencesHeader $originalMessageIdHeader';

  
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
        'threadId': originalEmail.threadId,
      }),
    );

    // --- 7. Handle Response ---
    if (response.statusCode == 200) {
      log('Reply sent successfully.');
      return true;
    } else if (response.statusCode == 401) {
      log("Access Token Expired (401) while sending reply.");
      return false;
    } else {
      log('Failed to send reply. Status: ${response.statusCode}');
      log('Response: ${response.body}');
      return false;
    }
  }


  /// Extracts email address from "Name <email@addr.com>" format.
  // String _extractEmailAddress(String field) {
  //   final emailMatch = RegExp(r'<([^>]+)>').firstMatch(field);
  //   return emailMatch?.group(1) ?? field.trim();
  // }

  Future<bool> replyAllToEmail({
    required Email originalEmail,
    required String replyBody,
    required String currentUserEmail,
  }) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) {
      log("Cannot Reply All: Access Token is null.");
      return false;
    }

    // --- 1. Gather ALL Recipients ---
    final String originalSender = _extractEmailAddress(originalEmail.from);
    final List<String> toRecipients = _parseAddresses(originalEmail.to); 
    final List<String> ccRecipients = _parseAddresses(originalEmail.ccHeader ?? '');

    // Use a Set to combine all recipients and automatically remove duplicates
    final Set<String> allRecipientsSet = {
      originalSender,
      ...toRecipients,
      ...ccRecipients,
    };

    allRecipientsSet.removeWhere(
        (email) => email.toLowerCase() == currentUserEmail.toLowerCase());
    List<String> finalRecipients = allRecipientsSet
        .where((email) => email.isNotEmpty && email.contains('@'))
        .toList();

    if (finalRecipients.isEmpty) {
        if (originalSender.isNotEmpty && originalSender.contains('@')) {
            finalRecipients.add(originalSender);
            log("WARNING: Reply All resulted in empty recipients after removing self. Defaulting to Reply (sending only to original sender: $originalSender).");
        } else {
            log("ERROR: Reply All recipient list empty AND original sender is invalid ('${originalEmail.from}'). Cannot send.");
            return false;
        }
    }

    final String replySubject = originalEmail.subject.toLowerCase().startsWith('re:')
        ? originalEmail.subject
        : 'Re: ${originalEmail.subject}';
    final String references = (originalEmail.referencesHeader?.isEmpty ?? true)
        ? originalEmail.messageIdHeader ?? '<>' // Fallback needed
        : '${originalEmail.referencesHeader} ${originalEmail.messageIdHeader}';

    final String replyToHeader = finalRecipients.join(', ');

    
    final String htmlReplyBody = replyBody.trim().replaceAll('\n', '<br>');
    final String formattedOriginalBody = """
<br><br>
<div style="border-left: 1px solid #ccc; margin-left: 5px; padding-left: 10px; color: #666;">
On ${originalEmail.date.toLocal()}, ${_extractName(originalEmail.from)} wrote:<br>
${originalEmail.isHtml ? originalEmail.body : originalEmail.body.replaceAll('\n', '<br>')}
</div>
"""; // Basic HTML quoting
    final String fullReplyBody = htmlReplyBody + formattedOriginalBody;


    final String rawEmail = """
Content-Type: text/html; charset="UTF-8"
MIME-Version: 1.0
To: $replyToHeader
From: $currentUserEmail
Subject: $replySubject
In-Reply-To: ${originalEmail.messageIdHeader ?? '<>'}
References: $references

$fullReplyBody
""";


    final String encodedRawEmail = base64Url.encode(utf8.encode(rawEmail)).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');

    final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/send');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'raw': encodedRawEmail,
        'threadId': originalEmail.threadId, 
      }),
    );

    if (response.statusCode == 200) {
      log('Reply All sent successfully.');
      return true;
    } else if (response.statusCode == 401) {
      log("Access Token Expired (401) while sending Reply All.");
      return false;
    } else {
      log('Failed to send Reply All. Status: ${response.statusCode}, Body: ${response.body}');
      return false;
    }
  }



  List<String> _parseAddresses(String headerValue) {
    if (headerValue.isEmpty) return [];


    final List<String> recipients = [];
    final parts = headerValue.split(',');

    for (String part in parts) {
      String trimmedPart = part.trim();
      if (trimmedPart.isNotEmpty) {
        // Extract email address using the existing helper
        String email = _extractEmailAddress(trimmedPart);
        if (email.isNotEmpty && email.contains('@')) {
          recipients.add(email);
        } else {
          log("Warning: Could not parse valid email from '$trimmedPart' in header '$headerValue'");
        }
      }
    }
    return recipients;
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
} 
