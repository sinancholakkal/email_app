import 'dart:developer';

import 'package:email_app/constants/app_colors.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/state/email_bloc/email_bloc.dart';
import 'package:email_app/state/email_details_bloc/email_details_bloc.dart';
import 'package:email_app/view/email_detail_screen/widget/forward_email.dart';
import 'package:email_app/view/email_detail_screen/widget/replay_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmailDetailScreen extends StatefulWidget {
  final String emailId;

  const EmailDetailScreen({
    super.key,
    required this.emailId,
  });

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  WebViewController? _controller;
  bool _isWebViewLoading = true;
  bool _hasWebViewError = false;
  ValueNotifier<bool> isStar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Fetch email details when screen initializes
    context.read<EmailDetailsBloc>().add(
      FetchEmailDetailsEvent(emailId: widget.emailId),
    );
  }

  void _initializeWebView(Email email) {
    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isWebViewLoading = true;
                _hasWebViewError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isWebViewLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isWebViewLoading = false;
                _hasWebViewError = true;
              });
            }
            log('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildHtmlContent(email));
  }
  

  String _buildHtmlContent(Email email) {
    
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
        title: BlocBuilder<EmailDetailsBloc, EmailDetailsState>(
          builder: (context, state) {
            if (state is EmailDetailsLoaded) {
              return Text(
                state.email.subject.isEmpty ? 'No Subject' : state.email.subject,
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }
            return Text(
              'Email',
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          BlocBuilder<EmailDetailsBloc, EmailDetailsState>(
            builder: (context, state) {
              if (state is! EmailDetailsLoaded) return const SizedBox.shrink();
              
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: theme.appBarTheme.foregroundColor),
                    onPressed: () {
                      _initializeWebView(state.email);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.reply, color: theme.appBarTheme.foregroundColor),
                    onPressed: () {
                      _showReplyDialog(state.email);
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: isStar,
                    builder: (context, value, child) {
                      return IconButton(
                        icon: Icon(
                          value ? Icons.star : Icons.star_border,
                          color: value ? Colors.yellow : theme.appBarTheme.foregroundColor,
                        ),
                        onPressed: () {
                          isStar.value = !value;
                          context.read<EmailDetailsBloc>().add(
                            IstarrEventEmailDetails(
                              messageId: state.email.id,
                              shouldStar: isStar.value,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: theme.appBarTheme.foregroundColor),
                    onSelected: (value) {
                      _handleMenuAction(value, state.email);
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
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<EmailDetailsBloc, EmailDetailsState>(
        builder: (context, state) {
          if (state is EmailDetailsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading email...',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is EmailDetailsError) {
            return Center(
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
                    'Failed to load email',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<EmailDetailsBloc>().add(
                        FetchEmailDetailsEvent(emailId: widget.emailId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EmailDetailsLoaded) {
            final email = state.email;
            
            // Initialize webview if not already done
            if (_controller == null) {
              _initializeWebView(email);
              isStar.value = email.isStarred;
            }

            return Column(
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
                        backgroundColor: AppColors.getEmailAvatarColor(email.from),
                        child: Text(
                          _getInitials(email.from),
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
                              _extractName(email.from),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _extractEmail(email.from),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDateShort(email.date),
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
                      if (_controller != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: WebViewWidget(controller: _controller!),
                        ),
                      
                      // Loading indicator
                      if (_isWebViewLoading)
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
                      if (_hasWebViewError)
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
                                    _initializeWebView(email);
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
      
      // Bottom action bar
      bottomNavigationBar: BlocBuilder<EmailDetailsBloc, EmailDetailsState>(
        builder: (context, state) {
          if (state is! EmailDetailsLoaded) return const SizedBox.shrink();
          
          return Container(
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
                  onTap: () => _showReplyDialog(state.email),
                  isDark: isDark,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.reply_all_rounded,
                  label: 'Reply All',
                  onTap: () => _showReplyAllDialog(state.email),
                  isDark: isDark,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.forward_rounded,
                  label: 'Forward',
                  onTap: () => _showForwardDialog(state.email),
                  isDark: isDark,
                ),
              ],
            ),
          );
        },
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

  void _showReplyDialog(Email email) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReplyEmailScreen(
          email: email,
          isReplyAll: false,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showReplyAllDialog(Email email) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReplyEmailScreen(
          email: email,
          isReplyAll: true,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showForwardDialog(Email email) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForwardEmailScreen(
          email: email,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleMenuAction(String action, Email? email) {
    switch (action) {
      case 'forward':
        if (email != null) _showForwardDialog(email);
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
              context.read<EmailBloc>().add(TrashEmailEvent(messageId: widget.emailId));
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
