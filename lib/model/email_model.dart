class Email {
  final String id;
  final String threadId;
  final String snippet;
  final String from;
  final String to;
  final String subject;
  final DateTime date;
  final String body;
  final bool isHtml;
  final List<String> labelIds;
  final bool isUnread;
  final bool isStarred;
  final String? messageIdHeader;  
  final String? referencesHeader; 
  final String? ccHeader;
  
  Email({
    this.messageIdHeader,
    this.referencesHeader,
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
    this.isStarred = false,
    this.ccHeader,
  });

  Email copyWith({
    String? id,
    String? threadId,
    String? snippet,
    String? from,
    String? to,
    String? subject,
    DateTime? date,
    String? body,
    bool? isHtml,
    List<String>? labelIds,
    bool? isUnread,
    bool? isStarred,
    String? messageIdHeader,
    String? referencesHeader,
    String? ccHeader,
  }) {
    return Email(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      snippet: snippet ?? this.snippet,
      from: from ?? this.from,
      to: to ?? this.to,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      body: body ?? this.body,
      isHtml: isHtml ?? this.isHtml,
      labelIds: labelIds ?? this.labelIds,
      isUnread: isUnread ?? this.isUnread,
      isStarred: isStarred ?? this.isStarred,
      messageIdHeader: messageIdHeader ?? this.messageIdHeader,
      referencesHeader: referencesHeader ?? this.referencesHeader,
      ccHeader: ccHeader ?? this.ccHeader,
    );
  }
}