import 'dart:developer';

import 'package:email_app/constants/app_colors.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/state/email_bloc/email_bloc.dart';
import 'package:email_app/state/sended_email_bloc/sended_email_bloc.dart';
import 'package:email_app/state/starred_bloc/starred_bloc.dart';
import 'package:email_app/view/home_screen/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BuildEmaiCard extends StatelessWidget {
  const BuildEmaiCard({
    super.key,
    required this.email,
    required this.index,
    this.enableAnimation = true,
    required this.starredType,
  });
  final StarredType starredType;
  final Email email;
  final int index;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final senderEmail = email.from;
    final initials = getInitials(senderEmail);
    final avatarColor = AppColors.getEmailAvatarColor(senderEmail);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    ValueNotifier<bool> isStarred = ValueNotifier(email.isStarred);

    // Only animate first few items, or if explicitly enabled
    final shouldAnimate = enableAnimation && index < 5;

    if (!shouldAnimate) {
      // No animation for better performance
      return _buildCardContent(
        context,
        isDark,
        senderEmail,
        initials,
        avatarColor,
        isStarred,
      );
    }

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200 + (index * 30)), // Faster animation
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)), // Reduced movement
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildCardContent(
        context,
        isDark,
        senderEmail,
        initials,
        avatarColor,
        isStarred,
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    bool isDark,
    String senderEmail,
    String initials,
    Color avatarColor,
    ValueNotifier<bool> isStarred,
  ) {
    return Container(
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
            context.push('/email_detail', extra: email);
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
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
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
                                  //Sender Email-----------
                                  senderEmail.split('@').first,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: email.isUnread == false
                                        ? Colors.grey
                                        : isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.blue[900]!.withOpacity(0.3)
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  //Date-----------
                                  formatTimestamp(email.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.blue[300]
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          //Subject-----------
                          Text(
                            email.subject.isEmpty
                                ? 'No Subject'
                                : email.subject,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: email.isUnread == false
                                  ? Colors.grey
                                  : isDark
                                  ? Colors.grey[300]
                                  : Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Text(
                          //   getEmailPreview(email.body),
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: isDark
                          //         ? Colors.grey[500]
                          //         : Colors.grey[600],
                          //     height: 1.4,
                          //   ),
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
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
                    //Stared==================
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: isStarred,
                      builder: (context, value, child) {
                        return _buildActionButton(
                          icon: value
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          isDark: isDark,
                          onTap: () {
                            isStarred.value = !value;
                            if (starredType == StarredType.fromStar) {
                              context.read<StarredBloc>().add(
                                ToggleStarEvent(
                                  messageId: email.id,
                                  shouldStar: isStarred.value,
                                ),
                              );
                            }else if(starredType == StarredType.fromHome){
                              context.read<EmailBloc>().add(
                                IstarrEventHome(
                                  messageId: email.id,
                                  shouldStar: isStarred.value,
                                ),
                              );
                            }else if(starredType == StarredType.fromSend){
                              context.read<SendedEmailBloc>().add(
                                IstarrEventSended(
                                  messageId: email.id,
                                  shouldStar: isStarred.value,
                                ),
                              );
                            }
                            log('Star: ${email.subject}');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
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
        border: Border.all(color: color.withOpacity(0.4), width: 1),
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
      color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[200],
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

enum StarredType { fromStar, fromHome, fromSend,}
