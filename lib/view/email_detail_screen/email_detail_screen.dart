import 'dart:developer';

import 'package:email_app/constants/app_colors.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/model/user_service.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/service/replay_email_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmailDetailScreen extends StatefulWidget {
  final Email email;

  const EmailDetailScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    EmailService().markEmailAsRead(widget.email.id);
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            log('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildHtmlContent());
  }

  String _buildHtmlContent() {
    final email = widget.email;
    
    // Create a complete HTML document with proper styling
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          line-height: 1.6;
          margin: 0;
          padding: 20px;
          background-color: #ffffff;
          color: #333333;
        }
        
        .email-header {
          border-bottom: 1px solid #e0e0e0;
          padding-bottom: 20px;
          margin-bottom: 20px;
        }
        
        .email-subject {
          font-size: 24px;
          font-weight: 600;
          color: #1a1a1a;
          margin-bottom: 16px;
        }
        
        .email-meta {
          display: flex;
          flex-wrap: wrap;
          gap: 20px;
          font-size: 14px;
          color: #666666;
        }
        
        .email-from {
          font-weight: 500;
          color: #1a1a1a;
        }
        
        .email-date {
          color: #666666;
        }
        
        .email-body {
          font-size: 16px;
          line-height: 1.6;
        }
        
        .email-body p {
          margin-bottom: 16px;
        }
        
        .email-body h1, .email-body h2, .email-body h3 {
          color: #1a1a1a;
          margin-top: 24px;
          margin-bottom: 16px;
        }
        
        .email-body a {
          color: #1a73e8;
          text-decoration: none;
        }
        
        .email-body a:hover {
          text-decoration: underline;
        }
        
        .email-body img {
          max-width: 100%;
          height: auto;
          border-radius: 8px;
          margin: 16px 0;
        }
        
        .email-body blockquote {
          border-left: 4px solid #1a73e8;
          padding-left: 16px;
          margin: 16px 0;
          background-color: #f8f9fa;
          padding: 16px;
          border-radius: 4px;
        }
        
        .email-body code {
          background-color: #f1f3f4;
          padding: 2px 6px;
          border-radius: 4px;
          font-family: 'Courier New', monospace;
          font-size: 14px;
        }
        
        .email-body pre {
          background-color: #f1f3f4;
          padding: 16px;
          border-radius: 8px;
          overflow-x: auto;
          font-family: 'Courier New', monospace;
          font-size: 14px;
        }
        
        .email-body table {
          width: 100%;
          border-collapse: collapse;
          margin: 16px 0;
        }
        
        .email-body th, .email-body td {
          border: 1px solid #e0e0e0;
          padding: 12px;
          text-align: left;
        }
        
        .email-body th {
          background-color: #f8f9fa;
          font-weight: 600;
        }
        
        .loading {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 200px;
          font-size: 16px;
          color: #666666;
        }
        
        .error {
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          height: 200px;
          color: #d93025;
          text-align: center;
        }
        
        @media (prefers-color-scheme: dark) {
          body {
            background-color: #1a1a1a;
            color: #e8eaed;
          }
          
          .email-subject {
            color: #e8eaed;
          }
          
          .email-from {
            color: #e8eaed;
          }
          
          .email-body h1, .email-body h2, .email-body h3 {
            color: #e8eaed;
          }
          
          .email-body blockquote {
            background-color: #2d2d2d;
          }
          
          .email-body code, .email-body pre {
            background-color: #2d2d2d;
          }
          
          .email-body th {
            background-color: #2d2d2d;
          }
        }
      </style>
    </head>
    <body>
      <div class="email-header">
        <div class="email-subject">${_escapeHtml(email.subject.isEmpty ? 'No Subject' : email.subject)}</div>
        <div class="email-meta">
          <div class="email-from">From: ${_escapeHtml(email.from)}</div>
          <div class="email-date">${_formatDate(email.date)}</div>
        </div>
      </div>
      
      <div class="email-body">
        ${email.body.isEmpty ? '<p><em>This email has no content.</em></p>' : email.body}
      </div>
    </body>
    </html>
    ''';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
      return '$weekday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.email.subject.isEmpty ? 'No Subject' : widget.email.subject,
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              _initializeWebView();
            },
          ),
          IconButton(
            icon: Icon(Icons.reply, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              _showReplyDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.star_border, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              _toggleStar();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.appBarTheme.foregroundColor),
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'forward',
                child: Row(
                  children: [
                    Icon(Icons.forward, size: 20),
                    SizedBox(width: 12),
                    Text('Forward'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive, size: 20),
                    SizedBox(width: 12),
                    Text('Archive'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Email header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.getEmailAvatarColor(widget.email.from),
                  child: Text(
                    _getInitials(widget.email.from),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _extractName(widget.email.from),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _extractEmail(widget.email.from),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDateShort(widget.email.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // WebView content
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: WebViewWidget(controller: _controller)),
                
                // Loading indicator
                if (_isLoading)
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading email content...',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Error state
                if (_hasError)
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load email content',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try refreshing the page',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _initializeWebView();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: () => _showReplyDialog(),
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.reply_all_rounded,
              label: 'Reply All',
              onTap: () => _showReplyAllDialog(),
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.forward_rounded,
              label: 'Forward',
              onTap: () => _showForwardDialog(),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    final name = email.split('@').first;
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  String _extractName(String fromField) {
    final nameMatch = RegExp(r'^"?([^"<]+)"?\s*<').firstMatch(fromField);
    if (nameMatch != null) {
      return nameMatch.group(1)!.trim();
    }
    return fromField.split('@').first;
  }

  String _extractEmail(String fromField) {
    final emailMatch = RegExp(r'<([^>]+)>').firstMatch(fromField);
    if (emailMatch != null) {
      return emailMatch.group(1)!;
    }
    return fromField;
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      return weekday;
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.blue[400],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReplyEmailScreen(
          email: widget.email,
          isReplyAll: false,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showReplyAllDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReplyEmailScreen(
          email: widget.email,
          isReplyAll: true,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showForwardDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forward functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleStar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starred email')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'forward':
        _showForwardDialog();
        break;
      case 'archive':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email archived')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to inbox
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Reply Email Screen Widget
class ReplyEmailScreen extends StatefulWidget {
  final Email email;
  final bool isReplyAll;

  const ReplyEmailScreen({
    super.key,
    required this.email,
    this.isReplyAll = false,
  });

  @override
  State<ReplyEmailScreen> createState() => _ReplyEmailScreenState();
}

class _ReplyEmailScreenState extends State<ReplyEmailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a reply message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final userService = UserService();
      final currentUserEmail = userService.userEmail;
      log('currentUserEmail: $currentUserEmail');
      log("to email: ${widget.email.from}");
      if (currentUserEmail == null) {
        throw Exception('User email not found');
      }

      final success = await ReplayEmailService().replyToEmail(
        originalEmail: widget.email,
        replyBody: _replyController.text.trim().replaceAll('\n', '<br>'),
        currentUserEmail: currentUserEmail,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Reply sent successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to send reply');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to send reply: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _sendReply,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (_replyController.text.trim().isNotEmpty) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.isReplyAll ? 'Reply All' : 'Reply',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: _sendReply,
              tooltip: 'Send',
              color: Colors.blue[600],
            ),
        ],
      ),
      body: Column(
        children: [
          // Simple Header - To and Subject
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'To',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _extractEmail(widget.email.from),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getReplySubject(),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Large Compose Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _replyController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your reply...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReplySubject() {
    final subject = widget.email.subject;
    if (subject.toLowerCase().startsWith('re:')) {
      return subject;
    }
    return 'Re: $subject';
  }

  String _extractEmail(String fromField) {
    final emailMatch = RegExp(r'<([^>]+)>').firstMatch(fromField);
    if (emailMatch != null) {
      return emailMatch.group(1)!;
    }
    return fromField;
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard reply?'),
        content: const Text(
          'Are you sure you want to discard this reply? Your changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close reply screen
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
