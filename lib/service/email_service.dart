// import 'dart:convert';
// import 'dart:developer';
// import 'package:email_app/service/token_service.dart';
// import 'package:http/http.dart' as http;

// class EmailService {
//   // This function uses the token to fetch user info from Google's API
//   Future<void> fetchProfileInfo() async {
//     final accessToken = await TokenService().getAccessToken();
//     // 1. The URL for the user info API
//     final url = Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo');

//     // 2. Make a GET request with the token in the Authorization header
//     final response = await http.get(
//       url,
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );

//     // 3. Check if the request was successful
//     if (response.statusCode == 200) {
//       // Decode the JSON response
//       final Map<String, dynamic> userInfo = jsonDecode(response.body);

//       // Extract the email and other details
//       final String email = userInfo['email'];
//       final String name = userInfo['name'];
//       final String pictureUrl = userInfo['picture'];

//       log('Email fetched from API: $email');
//       log('Name fetched from API: $name');
//       log('Picture URL: $pictureUrl');
//     } else {
//       log('API request failed with status: ${response.statusCode}');
//       log('Response body: ${response.body}');
//     }
//   }

//   Future<void> fetchUserEmails() async {
//     final accessToken = await TokenService().getAccessToken();
//     // 1. The URL for the Gmail API to list messages
//     final url = Uri.parse(
//       'https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=10',
//     );

//     // 2. Make a GET request with the token in the Authorization header
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     // 3. Check if the request was successful
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);

//       // The API returns a list of 'messages', each with an 'id'
//       final List<dynamic> messages = data['messages'] ?? [];

//       if (messages.isNotEmpty) {
//         log('Successfully fetched ${messages.length} email IDs.');
//         for (var message in messages) {
//           log(message.toString());
//           // This is NOT the email content, just a unique ID for each email
//           log('Email ID: ${message['id']}');
//           fetchEmailDetails(accessToken!, message['id']);
//         }

//         // --- NEXT STEP ---
//         // You would now take one of these IDs and make another API call
//         // to get the full content (sender, subject, body) of that specific email.
//       } else {
//         log('No emails found in the inbox.');
//       }
//     } else {
//       log('Failed to fetch emails. Status: ${response.statusCode}');
//       log('Response: ${response.body}');
//     }
//   }



// /// Fetches and decodes the full content of a single email.
// Future<void> fetchEmailDetails(String accessToken, String messageId) async {
//   final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = jsonDecode(response.body);
//     final payload = data['payload'];
//     final List<dynamic> headers = payload['headers'];

//     String? subject;
//     String? date;

//     // 1. GET SUBJECT AND DATE
//     for (var header in headers) {
//       if (header['name'] == 'Subject') {
//         subject = header['value'];
//       } else if (header['name'] == 'Date') {
//         date = header['value'];
//       }
//     }

//     // 2. GET THE BODY
//     String? body;
//     if (payload['parts'] != null) {
//       // Find the plain text part of the email
//       final part = payload['parts'].firstWhere(
//         (part) => part['mimeType'] == 'text/plain',
//         orElse: () => null, // Return null if not found
//       );

//       if (part != null) {
//         // The body data is Base64 encoded
//         final String encodedBody = part['body']['data'];
        
//         // Decode the Base64 string
//         final List<int> decodedBytes = base64Url.decode(encodedBody);
        
//         // Convert the decoded bytes to a readable string
//         body = utf8.decode(decodedBytes);
//       }
//     } else if (payload['body'] != null && payload['body']['data'] != null) {
//       // For simple emails without multiple parts
//       final String encodedBody = payload['body']['data'];
//       body = utf8.decode(base64Url.decode(encodedBody));
//     }


//     log('--- ✅ Email Details Fetched ---');
//     log('Subject: $subject');
//     log('Time: $date');
//     log('Body Snippet: ${body?.toString()}...'); // Print first 100 chars
//   } else {
//     log('Failed to fetch email details. Status: ${response.statusCode}');
//     log('Response: ${response.body}');
//   }
// }
// }


import 'dart:convert';
import 'dart:developer';
import 'package:email_app/model/email_model.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart'; // Assuming you have this service

class EmailService {
  // 1. CHANGE: The main function now returns a list of Email objects.
  // It fetches the inbox and then gets the details for each message.
  Future<List<Email>> fetchInboxEmails({int maxResults = 10}) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) {
      log("Access Token is null. Cannot fetch emails.");
      return []; // Return an empty list if there's no token
    }

    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$maxResults',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> messages = data['messages'] ?? [];

      // 2. CHANGE: Efficiently fetch all email details concurrently.
      final List<Future<Email?>> emailFutures = messages
          .map((message) => fetchEmailDetails(accessToken, message['id']))
          .toList();

      // Wait for all the individual email fetches to complete.
      final List<Email?> emailsWithNulls = await Future.wait(emailFutures);

      // Filter out any emails that might have failed to fetch.
      return emailsWithNulls.whereType<Email>().toList();
    } else {
      log('Failed to fetch email IDs. Status: ${response.statusCode}');
      log('Response: ${response.body}');
      return []; // Return an empty list on failure
    }
  }

  // 4. CHANGE: This now returns a single Email object or null if it fails.
  // It's used by the main fetchInboxEmails function.
  Future<Email?> fetchEmailDetails(String accessToken, String messageId) async {
    final url = Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Use the new private helper to do the parsing
      return _parseEmailDetailsFromJson(data);
    } else {
      log('Failed to fetch details for message ID $messageId. Status: ${response.statusCode}');
      return null;
    }
  }

  // 3. NEW: A private helper to parse the JSON into an Email model.
  // This keeps your code clean and reuses the parsing logic you created.
  Email _parseEmailDetailsFromJson(Map<String, dynamic> jsonData) {
    final String id = jsonData['id'] ?? '';
    final String threadId = jsonData['threadId'] ?? '';
    final String snippet = jsonData['snippet'] ?? '';

    final payload = jsonData['payload'] as Map<String, dynamic>;
    final headers = payload['headers'] as List<dynamic>;

    String from = '';
    String subject = '';
    String dateStr = '';

    for (var header in headers) {
      final name = header['name']?.toLowerCase();
      if (name == 'from') from = header['value'] ?? '';
      if (name == 'subject') subject = header['value'] ?? '';
      if (name == 'date') dateStr = header['value'] ?? '';
    }

    String decodedBody = '';
    bool isHtml = false;
    
    // Logic to find and decode the body
    if (payload.containsKey('parts')) {
        final parts = payload['parts'] as List;
        final textPart = parts.firstWhere(
            (part) => part['mimeType'] == 'text/plain',
            orElse: () => parts.firstWhere(
                (part) => part['mimeType'] == 'text/html',
                orElse: () => null,
            ),
        );

        if (textPart != null) {
            final encodedBody = textPart['body']['data'];
            isHtml = textPart['mimeType'] == 'text/html';
            if (encodedBody != null) {
                decodedBody = utf8.decode(base64Url.decode(encodedBody));
            }
        }
    } else if (payload.containsKey('body') && payload['body']['data'] != null) {
        final encodedBody = payload['body']['data'];
        isHtml = payload['mimeType'] == 'text/html';
        decodedBody = utf8.decode(base64Url.decode(encodedBody));
    }


    final DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();

    return Email(
      id: id,
      threadId: threadId,
      snippet: snippet,
      from: from,
      to: '', // You can add logic to parse the 'To' header if needed
      subject: subject,
      date: date,
      body: decodedBody,
      isHtml: isHtml,
    );
  }
}