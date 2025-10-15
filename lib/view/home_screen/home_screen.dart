import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/state/auth_bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Email> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadDummyEmails();
  }

  void _loadDummyEmails() {
    _emails = [
      Email(
        id: '1',
        threadId: 'thread1',
        snippet: 'Hey! Just wanted to follow up on our meeting yesterday...',
        from: 'john.smith@company.com',
        to: 'me@gmail.com',
        subject: 'Follow up on yesterday\'s meeting',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        body: 'Hey! Just wanted to follow up on our meeting yesterday. I think we made some great progress on the project. Let me know if you have any questions about the next steps.',
        isHtml: false,
        labelIds: ['INBOX'],
      ),
      Email(
        id: '2',
        threadId: 'thread2',
        snippet: 'Your order #12345 has been shipped and is on its way...',
        from: 'orders@amazon.com',
        to: 'me@gmail.com',
        subject: 'Your order has been shipped!',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        body: 'Your order #12345 has been shipped and is on its way. Expected delivery: Tomorrow. Track your package with the tracking number: ABC123XYZ',
        isHtml: false,
        labelIds: ['INBOX'],
      ),
      Email(
        id: '3',
        threadId: 'thread3',
        snippet: 'Welcome to Netflix! Start watching thousands of movies...',
        from: 'info@netflix.com',
        to: 'me@gmail.com',
        subject: 'Welcome to Netflix',
        date: DateTime.now().subtract(const Duration(days: 1)),
        body: 'Welcome to Netflix! Start watching thousands of movies and TV shows. Your first month is free. Enjoy unlimited entertainment on all your devices.',
        isHtml: true,
        labelIds: ['INBOX', 'PROMOTIONS'],
      ),
      Email(
        id: '4',
        threadId: 'thread4',
        snippet: 'Your weekly summary: 15 tasks completed, 3 pending...',
        from: 'noreply@todoist.com',
        to: 'me@gmail.com',
        subject: 'Weekly Summary - Great work!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        body: 'Your weekly summary: 15 tasks completed, 3 pending. You had a productive week! Keep up the great work and maintain your momentum.',
        isHtml: false,
        labelIds: ['INBOX'],
      ),
      Email(
        id: '5',
        threadId: 'thread5',
        snippet: 'Security alert: New sign-in from Windows device...',
        from: 'no-reply@accounts.google.com',
        to: 'me@gmail.com',
        subject: 'Security Alert - New Device Sign-in',
        date: DateTime.now().subtract(const Duration(days: 3)),
        body: 'Security alert: New sign-in from Windows device in New York, USA. If this was you, you can ignore this email. If not, please secure your account immediately.',
        isHtml: false,
        labelIds: ['INBOX', 'IMPORTANT'],
      ),
      Email(
        id: '6',
        threadId: 'thread6',
        snippet: 'Don\'t miss out! 50% off all summer collection items...',
        from: 'sales@fashion.com',
        to: 'me@gmail.com',
        subject: '🔥 Summer Sale - 50% OFF Everything!',
        date: DateTime.now().subtract(const Duration(days: 5)),
        body: 'Don\'t miss out! 50% off all summer collection items. Limited time offer. Shop now and upgrade your wardrobe with the latest trends. Free shipping on orders over \$50.',
        isHtml: true,
        labelIds: ['INBOX', 'PROMOTIONS'],
      ),
      Email(
        id: '7',
        threadId: 'thread7',
        snippet: 'Your subscription will renew on Oct 20, 2025...',
        from: 'billing@spotify.com',
        to: 'me@gmail.com',
        subject: 'Spotify Premium - Payment Reminder',
        date: DateTime.now().subtract(const Duration(days: 7)),
        body: 'Your subscription will renew on Oct 20, 2025. Your payment method ending in 4242 will be charged \$9.99. Enjoy uninterrupted music streaming.',
        isHtml: false,
        labelIds: ['INBOX'],
      ),
      Email(
        id: '8',
        threadId: 'thread8',
        snippet: 'Congratulations! You\'ve been selected for an interview...',
        from: 'careers@techcorp.com',
        to: 'me@gmail.com',
        subject: 'Interview Invitation - Senior Developer Position',
        date: DateTime.now().subtract(const Duration(days: 10)),
        body: 'Congratulations! You\'ve been selected for an interview for the Senior Developer position. We were impressed with your application and would love to discuss this opportunity further. Please reply with your availability.',
        isHtml: false,
        labelIds: ['INBOX', 'IMPORTANT'],
      ),
    ];
    setState(() {});
  }

  Future<void> _refreshEmails() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    _loadDummyEmails();
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    final name = email.split('@').first;
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _getEmailPreview(String body) {
    if (body.isEmpty) return 'No content';
    final cleanBody = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleanBody.length > 100 
        ? '${cleanBody.substring(0, 100)}...' 
        : cleanBody;
  }

  Color _getAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[email.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is GoogleSignOutSuccess) {
          context.go("/login");
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: Text(
            'Inbox',
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: theme.appBarTheme.foregroundColor),
              onPressed: () {
                // Search functionality
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: theme.appBarTheme.foregroundColor),
              onPressed: () {
                // Filter functionality
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: theme.appBarTheme.foregroundColor),
              onPressed: () {
                context.read<AuthBloc>().add(GoogleSignOutEvent());
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshEmails,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No emails',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your inbox is empty',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _emails.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[800],
      ),
      itemBuilder: (context, index) {
        final email = _emails[index];
        return _buildEmailItem(email);
      },
    );
  }

  Widget _buildEmailItem(Email email) {
    final senderEmail = email.from;
    final initials = _getInitials(senderEmail);
    final avatarColor = _getAvatarColor(senderEmail);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        onTap: () {
          // Navigate to email detail
          log('Tapped email: ${email.subject}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Email content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            senderEmail.split('@').first,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(email.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.subject.isEmpty ? 'No Subject' : email.subject,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEmailPreview(email.body),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Star icon
              IconButton(
                icon: Icon(
                  Icons.star_border,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // Star functionality
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
