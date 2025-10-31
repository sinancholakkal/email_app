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
import 'package:url_launcher/url_launcher.dart';

class EmailDetailScreen extends StatefulWidget {
  final String emailId;
  final Email? email;

  const EmailDetailScreen({
    super.key,
    required this.emailId,
    this.email,
  });

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  WebViewController? _controller;
  bool _isWebViewLoading = true;
  bool _hasWebViewError = false;
  ValueNotifier<bool> isStar = ValueNotifier(false);
  String? _currentEmailId;

  @override
  void initState() {
    super.initState();
    // Fetch email details when screen initializes
    context.read<EmailDetailsBloc>().add(
      FetchEmailDetailsEvent(emailId: widget.email?.threadId??widget.emailId),
    );
    // If the caller passed a partial/full Email object, initialize the WebView
    // immediately with that content so the UI appears responsive while the
    // details bloc fetches the canonical/latest content in background.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (widget.email != null && _controller == null) {
        _initializeWebView(widget.email!, isDark);
        isStar.value = widget.email!.isStarred;
      }
    });
  }

  void _initializeWebView(Email email, bool isDark) {
    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)  // Disable zooming to prevent some render issues
      ..setNavigationDelegate(
        NavigationDelegate(
          // Intercept navigation requests so we can handle non-http schemes
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            try {
              final uri = Uri.parse(url);
              final scheme = uri.scheme.toLowerCase();

              // Allow normal web links to load in the WebView
              if (scheme == 'http' || scheme == 'https') {
                return NavigationDecision.navigate;
              }

              // Handle common external schemes by launching the appropriate app
              if (scheme == 'mailto' || scheme == 'tel' || scheme == 'sms' || scheme == 'geo') {
                // Launch externally; prevent WebView navigation
                launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }

              // Data URIs can be displayed in the WebView
              if (scheme == 'data') {
                return NavigationDecision.navigate;
              }

              // Block or handle other unknown schemes (cid:, intent:, javascript:, etc.)
              log('Blocked navigation to unsupported scheme: $scheme -> $url');
              return NavigationDecision.prevent;
            } catch (e) {
              log('Invalid navigation URL: $url ($e)');
              return NavigationDecision.prevent;
            }
          },

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
            // Ignore some benign errors that occur when pages include
            // non-http(s) schemes (intent:, cid:, mailto: in resources, etc.)
            final desc = error.description.toLowerCase();
            if (desc.contains('net::err_blocked_by_orb') ||
                desc.contains('err_blocked_by_orb')) {
              log('WebView ORB Error (ignored): ${error.url}');
              return;
            }

            // Ignore unknown URL scheme errors (these are common when email
            // HTML contains cid:, intent:, or other non-web schemes used by
            // mail clients). We prevent showing the full error UI for these.
            if (desc.contains('err_unknown_url_scheme') || desc.contains('unknown_url_scheme')) {
              log('WebView unknown url scheme (ignored): ${error.url} - ${error.description}');
              return;
            }
            
            // Ignore cleartext errors, as we've enabled cleartext traffic
            if (desc.contains('err_cleartext_not_permitted')) {
              log('WebView cleartext not permitted (ignored): ${error.url}');
              return;
            }

            // For any other, more serious error, set the error state.
            log('WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _isWebViewLoading = false;
                _hasWebViewError = true;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_buildHtmlContent(email, isDark));
    _currentEmailId = email.id;
  }
  

  String _buildHtmlContent(Email email, bool isDark) {
    // Dark mode colors
    final bgColor = isDark ? '#1a1a1a' : '#ffffff';
    final textColor = isDark ? '#e8eaed' : '#333333';
    final headerColor = isDark ? '#e8eaed' : '#1a1a1a';
    final metaColor = isDark ? '#b3b3b3' : '#666666';
    final borderColor = isDark ? '#404040' : '#e0e0e0';
    
    return '''
    <!DOCTYPE html> 
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
      <script>
        // Force dark mode on dynamically loaded content
        const observer = new MutationObserver((mutations) => {
          mutations.forEach((mutation) => {
            if (mutation.addedNodes) {
              mutation.addedNodes.forEach((node) => {
                if (node.nodeType === 1) { // ELEMENT_NODE
                  enforceStyles(node);
                }
              });
            }
          });
        });
        
        function enforceStyles(element) {
          if (element.style) {
            element.style.backgroundColor = 'transparent';
            element.style.color = '${textColor}';
          }
          if (element.tagName === 'IMG') {
            element.style.filter = '${isDark ? 'brightness(0.8)' : 'none'}';
          }
          if (element.children) {
            Array.from(element.children).forEach(enforceStyles);
          }
        }
        
        // Start observing when DOM is ready
        document.addEventListener('DOMContentLoaded', () => {
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
          enforceStyles(document.body);
        });
document.addEventListener("DOMContentLoaded", () => {
        const body = document.body;
        
        // This line centers the content
        body.style.margin = "0 auto"; 
        
        // This line is good
        body.style.overflowX = "hidden";

        // I HAVE REMOVED body.style.width and body.style.maxWidth
        // They were preventing the centering.
        
        // This part for tables is great, keep it
        const tables = body.getElementsByTagName("table");
        for (let i = 0; i < tables.length; i++) {
          tables[i].style.width = "100%";
          tables[i].style.maxWidth = "100%";
        }
      });

      </script>
      <style>
        /* Reset all backgrounds and colors */
        * {
          background: none !important;
          color: inherit !important;
        }
        
        /* Base styles */
        :root {
          color-scheme: ${isDark ? 'dark' : 'light'};
        }
        
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
          line-height: 1.6 !important;
          margin: 0;
          padding: 20px !important;
          background-color: $bgColor !important;
          color: $textColor !important;
          word-wrap: break-word !important;
          overflow-wrap: break-word !important;
        }
        
        /* Generic element styles */
        div, p, span, td, th, li, h1, h2, h3, h4, h5, h6 {
          color: $textColor !important;
          background-color: transparent !important;
        }
        
        /* Tables */
        table, tr, td, th {
          border-color: $borderColor !important;
          background-color: transparent !important;
        }
        
        /* Override all possible background colors */
        [style*="background"], [bgcolor], [style*="background-color"] {
          background-color: transparent !important;
        }
        
        /* Links */
        a {
          color: #5B9EFF !important;
          text-decoration: none !important;
        }
        
        a:hover {
          text-decoration: underline !important;
        }
        
        /* Images */
        img {
          opacity: ${isDark ? '0.8' : '1'} !important;
          filter: ${isDark ? 'brightness(0.8)' : 'none'} !important;
        }
        
        /* Quotes and code blocks */
        blockquote, pre, code {
          background-color: ${isDark ? '#2d2d2d' : '#f5f5f5'} !important;
          border-color: $borderColor !important;
          color: $textColor !important;
        }
        
        /* Email-specific elements */
        .email-header {
          border-bottom: 1px solid $borderColor !important;
          padding-bottom: 20px !important;
          margin-bottom: 20px !important;
        }
        
        .email-subject {
          font-size: 30px !important;
          font-weight: 600 !important;
          color: $headerColor !important;
          margin-bottom: 16px !important;
        }
        
        .email-meta {
          display: flex !important;
          flex-wrap: wrap !important;
          gap: 20px !important;
          font-size: 18px !important;
          color: $metaColor !important;
        }
        
        .email-body {
          font-size: 30px !important;
          line-height: 1.6 !important;
        }
        
        /* Force text contrast */
        * {
          text-shadow: none !important;
        }
        
        /* Handle dynamic content */
        iframe {
          filter: ${isDark ? 'invert(1) hue-rotate(180deg)' : 'none'} !important;
        }
        
        
   
        
        .email-body th {
          background-color: ${isDark ? '#2d2d2d' : '#f8f9fa'};
          font-weight: 600;
        }
        
        /* Force text visibility - comprehensive selector to override email styles */
        .email-body * {
          color: $textColor !important;
          background-color: transparent !important;
          opacity: 1 !important;
          text-shadow: none !important;
        }

        /* Center all email content */
html, body {
  margin: 0 auto !important;
  max-width: 100% !important;
  text-align: left !important;
  zoom: 0.75 !important; /* adjust zoom level if needed (0.8–1.0) */
}

/* Ensure all inner containers fit screen width */
.email-body table,
.email-body div,
.email-body p {
  margin: 0 auto !important;
  max-width: 100% !important;
  width: auto !important;
}
        
        /* Override inline styles on all text elements */
        .email-body div,
        .email-body p,
        .email-body span,
        .email-body td,
        .email-body th,
        .email-body tr,
        .email-body li,
        .email-body ul,
        .email-body ol,
        .email-body font,
        .email-body strong,
        .email-body b,
        .email-body em,
        .email-body i,
        .email-body u,
        .email-body h1,
        .email-body h2,
        .email-body h3,
        .email-body h4,
        .email-body h5,
        .email-body h6,
        .email-body label,
        .email-body small,
        .email-body text,
        .email-body tbody,
        .email-body thead,
        .email-body tfoot {
          color: $textColor !important;
        }
        
        /* Keep links visible but distinct */
        .email-body a {
          color: #1a73e8 !important;
          text-decoration: none !important;
        }
        
        .email-body a:hover {
          text-decoration: underline !important;
        }
        
        /* Ensure images remain visible */
        .email-body img {
          opacity: 1 !important;
          filter: none !important;
          max-width: 100% !important;
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
        ${email.body.isEmpty ? '<p><em>This email has no content.</em></p>' : _sanitizeHtml(email.body)}
      </div>
    </body>
    </html>
    ''';
  }

  String _sanitizeHtml(String html) {
    if (html.isEmpty) return html;
    var out = html;
    // Neutralize common unsupported schemes that appear in email HTML.
    // We handle common literal patterns to avoid complex regex pitfalls.
    final schemes = ['cid', 'intent', 'javascript', 'vbscript'];
    for (final s in schemes) {
      out = out.replaceAll('src="${s}:', 'src="#"');
      out = out.replaceAll("src='${s}:", "src='#'");
      out = out.replaceAll('href="${s}:', 'href="#"');
      out = out.replaceAll("href='${s}:", "href='#'");

      // Uppercase variants sometimes occur in email HTML
      final S = s.toUpperCase();
      out = out.replaceAll('src="${S}:', 'src="#"');
      out = out.replaceAll("src='${S}:", "src='#'");
      out = out.replaceAll('href="${S}:', 'href="#"');
      out = out.replaceAll("href='${S}:", "href='#'");
    }

    return out;
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
                     // _initializeWebView(state.email, isDark);
                       context.read<EmailDetailsBloc>().add(
      FetchEmailDetailsEvent(emailId: widget.email?.threadId??widget.emailId));
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
                        FetchEmailDetailsEvent(emailId: widget.email?.threadId??widget.emailId),
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
              _initializeWebView(email, isDark);
              isStar.value = email.isStarred;
            } else if (_currentEmailId != email.id) {
              _controller!.loadHtmlString(_buildHtmlContent(email, isDark));
              _currentEmailId = email.id;
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
                          color: isDark ? const Color(0xFF1a1a1a) : Colors.white,
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
                                    _initializeWebView(email, isDark);
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
    if(name[0] == '"') return name[1].toUpperCase();
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