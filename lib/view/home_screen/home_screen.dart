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
    final isDark = theme.brightness == Brightness.dark;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is GoogleSignOutSuccess) {
          context.go("/login");
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _refreshEmails,
          child: CustomScrollView(
            slivers: [
              // Custom curved header
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.blue[900]!,
                                Colors.blue[700]!,
                              ]
                            : [
                                Colors.blue[600]!,
                                Colors.blue[400]!,
                              ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hello there 👋',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Your Inbox',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _buildHeaderButton(
                                        icon: Icons.search,
                                        onTap: () {
                                          // Search functionality
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      _buildHeaderButton(
                                        icon: Icons.logout,
                                        onTap: () {
                                          context.read<AuthBloc>().add(GoogleSignOutEvent());
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Email count badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_emails.length} Messages',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Email list
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                sliver: _buildEmailList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailList() {
    if (_emails.isEmpty) {
      return SliverFillRemaining(
        child: Center(
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
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final email = _emails[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _buildEmailCard(email, index),
          );
        },
        childCount: _emails.length,
      ),
    );
  }

  Widget _buildEmailCard(Email email, int index) {
    final senderEmail = email.from;
    final initials = _getInitials(senderEmail);
    final avatarColor = _getAvatarColor(senderEmail);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              log('Tapped email: ${email.subject}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Avatar with badge
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  avatarColor,
                                  avatarColor.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: avatarColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (email.labelIds.contains('IMPORTANT'))
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.priority_high,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Email content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    senderEmail.split('@').first,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? Colors.blue[900]!.withOpacity(0.3)
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatTimestamp(email.date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.blue[300] : Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email.subject.isEmpty ? 'No Subject' : email.subject,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[300] : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getEmailPreview(email.body),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons row
                  Row(
                    children: [
                      // Labels
                      if (email.labelIds.contains('PROMOTIONS'))
                        _buildLabel('Promotions', Colors.orange, isDark),
                      const Spacer(),
                      _buildActionButton(
                        icon: Icons.reply_rounded,
                        isDark: isDark,
                        onTap: () {
                          log('Reply to: ${email.subject}');
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.archive_rounded,
                        isDark: isDark,
                        onTap: () {
                          log('Archive: ${email.subject}');
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.star_border_rounded,
                        isDark: isDark,
                        onTap: () {
                          log('Star: ${email.subject}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withOpacity(0.9) : color.withOpacity(1.0),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark 
          ? Colors.grey[800]!.withOpacity(0.5)
          : Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
