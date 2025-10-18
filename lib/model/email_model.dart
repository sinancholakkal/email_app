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
}