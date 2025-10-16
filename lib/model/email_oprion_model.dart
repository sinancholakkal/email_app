import 'package:flutter/foundation.dart';

class MailOptionModel {
  final String body;
  final String subject;
  final List<String> recipients;
  final bool isHTML;
  final List<String> bccRecipients;
  final List<String> ccRecipients;
  final List<String> attachments;

  const MailOptionModel({
    required this.body,
    required this.subject,
    this.recipients = const [],
    this.isHTML = false,
    this.bccRecipients = const [],
    this.ccRecipients = const [],
    this.attachments = const [],
  });

  MailOptionModel copyWith({
    String? body,
    String? subject,
    List<String>? recipients,
    bool? isHTML,
    List<String>? bccRecipients,
    List<String>? ccRecipients,
    List<String>? attachments,
  }) {
    return MailOptionModel(
      body: body ?? this.body,
      subject: subject ?? this.subject,
      recipients: recipients ?? this.recipients,
      isHTML: isHTML ?? this.isHTML,
      bccRecipients: bccRecipients ?? this.bccRecipients,
      ccRecipients: ccRecipients ?? this.ccRecipients,
      attachments: attachments ?? this.attachments,
    );
  }

 

  @override
  String toString() {
    return 'MailOptions(subject: $subject, recipients: $recipients, isHTML: $isHTML)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MailOptionModel &&
      other.body == body &&
      other.subject == subject &&
      listEquals(other.recipients, recipients) &&
      other.isHTML == isHTML &&
      listEquals(other.bccRecipients, bccRecipients) &&
      listEquals(other.ccRecipients, ccRecipients) &&
      listEquals(other.attachments, attachments);
  }

  @override
  int get hashCode {
    return body.hashCode ^
      subject.hashCode ^
      recipients.hashCode ^
      isHTML.hashCode ^
      bccRecipients.hashCode ^
      ccRecipients.hashCode ^
      attachments.hashCode;
  }
}