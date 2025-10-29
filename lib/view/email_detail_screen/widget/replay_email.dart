
// Reply Email Screen Widget
import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/model/user_service.dart';
import 'package:email_app/service/replay_email_service.dart';
import 'package:email_app/state/email_details_bloc/email_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      bool success;
      if(widget.isReplyAll){
        success = await ReplayEmailService().replyAllToEmail(
          originalEmail: widget.email,
          replyBody: _replyController.text.trim().replaceAll('\n', '<br>'),
          currentUserEmail: currentUserEmail,
        );
      }else{
       success = await ReplayEmailService().replyToEmail(
        originalEmail: widget.email,
        replyBody: _replyController.text.trim().replaceAll('\n', '<br>'),
        currentUserEmail: currentUserEmail,
      );
      }
      if (!mounted) return;

      if (success) {
         context.read<EmailDetailsBloc>().add(
      FetchEmailDetailsEvent(emailId: widget.email.threadId),
    );
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
