  String getInitials(String email) {
    if (email.isEmpty) return '?';
    final name = email.split('@').first;
    if (name.isEmpty) return '?';
    if(name[0] == '"') return name[1].toUpperCase();
    return name[0].toUpperCase();
  }

String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays == 0) {
    // --- START OF CHANGES ---
    
    // Get hour (0-23)
    int hour = timestamp.hour; 
    final String minute = timestamp.minute.toString().padLeft(2, '0');
    
    // Determine AM or PM
    final String suffix = hour >= 12 ? 'pm' : 'am';
    
    // Convert to 12-hour format (1-12)
    int hour12 = hour % 12;
    if (hour12 == 0) {
      hour12 = 12; // Midnight (0) and Noon (12) should both be 12
    }
    
    return '$hour12:$minute $suffix';
    // --- END OF CHANGES ---

  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

    String getEmailPreview(String body) {
    if (body.isEmpty) return 'No content';
    final cleanBody = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleanBody.length > 100
        ? '${cleanBody.substring(0, 100)}...'
        : cleanBody;
  }