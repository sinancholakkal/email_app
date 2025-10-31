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
//     }
//   }
// }
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
import 'package:intl/intl.dart';
import 'token_service.dart'; // Assuming you have this service

class EmailService {
  final String nextPageToken = "";
  // 1. CHANGE: The main function now returns a list of Email objects.
  // It fetches the inbox and then gets the details for each message.
  // Future<Map<String, dynamic>> fetchInboxEmails({
  //   int maxResults = 10,
  //   String label = "",
  //   String nextPageToken = "",
  //   String query = "",
  // }) async {
  //   final accessToken = await TokenService().getAccessToken();
  //   if (accessToken == null) {
  //     log("Access Token is null. Cannot fetch emails.");
  //     return {}; // Return an empty list if there's no token
  //   }

  //   var urlString =
  //       'https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$maxResults';

  //   // 2. Add the label filter if it exists
  //   if (label.isNotEmpty) {
  //     urlString += '&labelIds=$label';
  //   }
  //   // 3. Add the page token for pagination if it exists
  //   if (nextPageToken.isNotEmpty) {
  //     urlString += '&pageToken=$nextPageToken';
  //   }
  //   if (query.isNotEmpty) {
  //   // Important: URL encode the query string to handle spaces and special characters
  //   urlString += '&q=${Uri.encodeQueryComponent(query)}';
  // }
  //   Uri url = Uri.parse(urlString);

  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = jsonDecode(response.body);
  //     final List<dynamic> messages = data['messages'] ?? [];
  //     nextPageToken = data['nextPageToken'] ?? "";

  //     // 2. CHANGE: Efficiently fetch all email details concurrently.
  //     final List<Future<Email?>> emailFutures = messages
  //         .map((message) => fetchEmailDetails(accessToken, message['id']))
  //         .toList();

  //     // Wait for all the individual email fetches to complete.
  //     final List<Email?> emailsWithNulls = await Future.wait(emailFutures);

  //     // Filter out any emails that might have failed to fetch.
  //     return {
  //       'emails': emailsWithNulls.whereType<Email>().toList(),
  //       'nextPageToken': nextPageToken,
  //     };
  //   } else {
  //     log('Failed to fetch email IDs. Status: ${response.statusCode}');
  //     log('Response: ${response.body}');
  //     return {}; // Return an empty list on failure
  //   }
  // }

  // // 4. CHANGE: This now returns a single Email object or null if it fails.
  // // It's used by the main fetchInboxEmails function.
  // Future<Email?> fetchEmailDetails(String accessToken, String messageId) async {
  //   final url = Uri.parse(
  //     'https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId',
  //   );
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = jsonDecode(response.body);
  //     // Use the new private helper to do the parsing
  //     return _parseEmailDetailsFromJson(data);
  //   } else {
  //     log(
  //       'Failed to fetch details for message ID $messageId. Status: ${response.statusCode}',
  //     );
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>> fetchInboxEmails({
    int maxResults = 6,
    String label = "",
    String nextPageToken = "",
    String query = "",
  }) async {
    final accessToken = await TokenService().getAccessToken();
    log("Access token fetched");
    if (accessToken == null) {
      log("Access Token is null. Cannot fetch threads.");
      return {'emails': <Email>[], 'nextPageToken': ''};
    }

    // --- THIS IS THE MAIN FIX ---
    // We now call the 'threads' endpoint
    var urlString =
        'https://gmail.googleapis.com/gmail/v1/users/me/threads?maxResults=$maxResults';
    // --- END OF MAIN FIX ---

    if (label.isNotEmpty) {
      urlString += '&labelIds=$label';
    }
    if (nextPageToken.isNotEmpty) {
      urlString += '&pageToken=$nextPageToken';
    }
    if (query.isNotEmpty) {
      urlString += '&q=${Uri.encodeQueryComponent(query)}';
    }
    Uri url = Uri.parse(urlString);
    log("Going to fetch call API for emails");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    log("fetched response=================");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // The response now contains 'threads', not 'messages'
      final List<dynamic> threads = data['threads'] ?? [];
      nextPageToken = data['nextPageToken'] ?? "";

      // 2. CHANGE: For each thread, fetch its details.
      // This new function will get the *latest* email from the thread.
      final List<Future<Email?>> emailFutures = threads
          .map((thread) => fetchEmailDetails(accessToken, thread['id']))
          .toList();

      final List<Email?> emailsWithNulls = await Future.wait(emailFutures);

      return {
        'emails': emailsWithNulls.whereType<Email>().toList(),
        'nextPageToken': nextPageToken,
      };
    } else {
      log('Failed to fetch thread IDs. Status: ${response.statusCode}');
      log('Response: ${response.body}');
      return {'emails': <Email>[], 'nextPageToken':''};
    }
  }

  // 2. CHANGE: This new function gets a THREAD, finds its LATEST message,
  // and parses that into your Email model.
  Future<Email?> fetchEmailDetails(String accessToken, String threadId) async {
    // final String fieldsToGet =
    //   'messages(id,threadId,snippet,internalDate,labelIds,payload/headers)';
    // Call the threads.get endpoint
    // final url = Uri.parse(
    //   'https://gmail.googleapis.com/gmail/v1/users/me/threads/$threadId?fields=$fieldsToGet',
    // );
    log("started to call get deails ========================");
    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/threads/$threadId',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    log("fetched thread response=================");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // A thread response contains a list of 'messages'.
      final List<dynamic> messages = data['messages'] ?? [];
      if (messages.isEmpty) {
        return null; // Should not happen, but good to check
      }

      // --- THIS IS THE KEY ---
      // Get the LAST message in the list, which is the newest one.
      final Map<String, dynamic> latestMessageJson = messages.last;
      // --- END OF KEY ---

      // Now, parse this latest message using your *existing* helper function
      // (I assume you have this function, based on your original code)
      return _parseEmailDetailsFromJson(latestMessageJson);
    } else {
      log(
        'Failed to fetch details for thread ID $threadId. Status: ${response.statusCode}',
      );
      return null;
    }
  }

  Future<void> markEmailAsRead(String messageId) async {
    final accessToken = await TokenService().getAccessToken();
    if (accessToken == null) return;

    final url = Uri.parse(
      'https://gmail.googleapis.com/gmail/v1/users/me/messages/$messageId/modify',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      // The body of the request tells the API which labels to remove.
      body: jsonEncode({
        'removeLabelIds': ['UNREAD'],
      }),
    );

    if (response.statusCode == 200) {
      log('Successfully marked email $messageId as read.');
    } else {
      log('Failed to mark email as read. Status: ${response.statusCode}');
    }
  }

  Email _parseEmailDetailsFromJson(Map<String, dynamic> jsonData) {
    final String id = jsonData['id'] ?? '';
    final String threadId = jsonData['threadId'] ?? '';
    final String snippet = jsonData['snippet'] ?? '';
    final List<String> labelIds = List<String>.from(jsonData['labelIds'] ?? []);
    final bool isUnread = labelIds.contains('UNREAD');
    final bool isStarred = labelIds.contains('STARRED');
    String? ccHeader;

    final payload = jsonData['payload'] as Map<String, dynamic>;
    final headers = payload['headers'] as List<dynamic>;
    String from = '', subject = '', dateStr = '', to = '';
    String? messageIdHeader, referencesHeader;

    for (var header in headers) {
      final name = header['name']?.toLowerCase();
      final value = header['value'] ?? '';
      switch (name) {
        case 'from':
          from = value;
          break;
        case 'subject':
          subject = value;
          break;
        case 'date':
          dateStr = value;
          break;
        case 'to':
          to = value;
          break;
        case 'message-id':
          messageIdHeader = value;
          break;
        case 'references':
          referencesHeader = value;
          break;
        case 'cc':
          ccHeader = value;
          break;
      }
    }

    String decodedBody = '';
    bool isHtml = false;
    // ... your existing body parsing logic ...
    if (payload.containsKey('parts')) {
      final parts = payload['parts'] as List;
      final htmlPart = parts.firstWhere(
        (p) => p['mimeType'] == 'text/html',
        orElse: () => null,
      );
      if (htmlPart != null && htmlPart['body']?['data'] != null) {
        isHtml = true;
        decodedBody = utf8.decode(base64Url.decode(htmlPart['body']['data']));
      } else {
        final plainPart = parts.firstWhere(
          (p) => p['mimeType'] == 'text/plain',
          orElse: () => null,
        );
        if (plainPart != null && plainPart['body']?['data'] != null) {
          isHtml = false;
          decodedBody = utf8.decode(
            base64Url.decode(plainPart['body']['data']),
          );
        }
      }
    } else if (payload.containsKey('body') &&
        payload['body']?['data'] != null) {
      isHtml = payload['mimeType'] == 'text/html';
      decodedBody = utf8.decode(base64Url.decode(payload['body']['data']));
    }
    
    log(dateStr);
    log(subject);
    final DateTime date = _parseDate(dateStr);
    log(date.toString());
    return Email(
      id: id,
      threadId: threadId,
      snippet: snippet,
      from: from,
      to: to,
      subject: subject,
      date: date,
      body: decodedBody,
      isHtml: isHtml,
      labelIds: labelIds,
      isUnread: isUnread,
      isStarred: isStarred,
      messageIdHeader: messageIdHeader,
      referencesHeader: referencesHeader,
      ccHeader: ccHeader,
    );
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime.now();

    try {
      // This format string matches your date: "Wed, 29 Oct 2025 11:08:17 +0000"
      // E,     -> Day of week (Wed,)
      // dd     -> Day in month (29)
      // MMM    -> Month name (Oct)
      // yyyy   -> Year (2025)
      // HH:mm:ss -> Time (11:08:17)
      // Z      -> Timezone (+0000)
      final format = DateFormat('E, dd MMM yyyy HH:mm:ss Z');

      // This will now correctly parse the string
      return format.parse(dateStr);
    } catch (e) {
      log("Error parsing date '$dateStr': $e");
      return DateTime.now(); // Fallback
    }
  }
}
