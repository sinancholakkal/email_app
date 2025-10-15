class Email {
  /// The unique, permanent ID for this specific email message.
  /// Example: "199e64fac84258f3"
  final String id;

  /// The ID of the conversation thread this email belongs to.
  /// All replies to an email will share the same threadId.
  final String threadId;

  /// A short, plain-text summary or preview of the email's content.
  /// Example: "Cuvette Tech Dear Muhammed, Hope you are doing well..."
  final String snippet;

  /// The sender's information, typically their name and email address.
  /// Example: "\"Placement Team | Cuvette\" <team@cuvette.tech>"
  final String from;

  /// The primary recipient's email address.
  final String to;

  /// The title or subject line of the email.
  /// Example: "Data Science | Congrats Harish - Placed at 6.2 LPA Salary"
  final String subject;

  /// The date and time when the email was received by the server.
  final DateTime date;

  /// The full, decoded content of the email message.
  /// This can be plain text or HTML.
  final String body;

  /// A flag to indicate if the 'body' string contains HTML markup.
  /// This is useful for knowing whether to render it as plain text or in a web view.
  final bool isHtml;

  /// A list of labels applied to this email by the user or system.
  /// Examples: ["INBOX", "STARRED", "CATEGORY_PROMOTIONS"]
  final List<String> labelIds;

  /// A flag to indicate if the email is unread.
  final bool isUnread;

  Email({
    required this.id,
    required this.threadId,
    required this.snippet,
    required this.from,
    required this.to,
    required this.subject,
    required this.date,
    required this.body,
    this.isHtml = false,
    this.labelIds = const [],
    this.isUnread = false,
  });
}