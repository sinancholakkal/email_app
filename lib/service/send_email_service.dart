import 'dart:developer';

import 'package:email_app/model/email_oprion_model.dart'; // Your model path
import 'package:flutter_mailer/flutter_mailer.dart';

class SendEmailService {
  /// Sends an email and returns a human-readable string status.
  Future<String> sendEmail(MailOptionModel mailOptionModel) async {
    final MailOptions mailOptions = MailOptions(
      body: mailOptionModel.body,
      subject: mailOptionModel.subject,
      recipients: mailOptionModel.recipients,
      isHTML: mailOptionModel.isHTML,
      bccRecipients: mailOptionModel.bccRecipients,
      ccRecipients: mailOptionModel.ccRecipients,
      attachments: mailOptionModel.attachments,
    );

    try {
      // Get the response from the mailer
      final MailerResponse response = await FlutterMailer.send(mailOptions);

      // Use the switch statement to determine the result message
      String platformResponse;
      switch (response) {
        case MailerResponse.saved:
          platformResponse = 'mail was saved to draft';
          break;
        case MailerResponse.sent:
          platformResponse = 'mail was sent';
          break;
        case MailerResponse.cancelled:
          platformResponse = 'mail was cancelled';
          break;
        case MailerResponse.android:
          platformResponse = 'mail action completed';
          break;
        default:
          platformResponse = 'unknown';
          break;
      }
      log(response.name);
      log("============================================");
      // Return the string message
      return platformResponse;
      
    } catch (e) {

      throw Exception(e);
    }
  }
}