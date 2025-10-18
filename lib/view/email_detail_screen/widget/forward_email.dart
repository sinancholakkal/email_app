import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/model/user_service.dart';
import 'package:email_app/service/forward_email_service.dart';
import 'package:flutter/material.dart';

class ForwardEmailScreen extends StatefulWidget {
  final Email email;

  const ForwardEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<ForwardEmailScreen> createState() => _ForwardEmailScreenState();
}

class _ForwardEmailScreenState extends State<ForwardEmailScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _toFocusNode = FocusNode();
  final FocusNode _ccFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();
  
  bool _isSending = false;
  bool _showCc = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _toFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _messageController.dispose();
    _toFocusNode.dispose();
    _ccFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendForward() async {
    final forwardService = ForwardEmailService();
    
    // Validate recipients
    if (_toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one recipient'),
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
      
      if (currentUserEmail == null) {
        throw Exception('User email not found');
      }

      // Parse recipients
      final toRecipients = forwardService.parseEmailAddresses(_toController.text);
      final ccRecipients = _showCc ? forwardService.parseEmailAddresses(_ccController.text) : null;

      if (toRecipients.isEmpty) {
        throw Exception('No valid email addresses found in To field');
      }

      log('Forwarding to: ${toRecipients.join(", ")}');
      if (ccRecipients != null && ccRecipients.isNotEmpty) {
        log('CC: ${ccRecipients.join(", ")}');
      }

      final success = await forwardService.forwardEmail(
        originalEmail: widget.email,
        forwardBody: _messageController.text.trim().replaceAll('\n', '<br>'),
        currentUserEmail: currentUserEmail,
        toRecipients: toRecipients,
        ccRecipients: ccRecipients,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Email forwarded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to forward email');
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
                child: Text('Failed to forward: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _sendForward,
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
            if (_toController.text.trim().isNotEmpty || 
                _messageController.text.trim().isNotEmpty) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Forward',
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
              onPressed: _sendForward,
              tooltip: 'Send',
              color: Colors.blue[600],
            ),
        ],
      ),
      body: Column(
        children: [
          // Recipients Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            child: Column(
              children: [
                // To field
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
                      child: TextField(
                        controller: _toController,
                        focusNode: _toFocusNode,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'recipient@example.com',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showCc ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _showCc = !_showCc;
                        });
                      },
                      tooltip: 'Add Cc',
                    ),
                  ],
                ),
                
                // Cc field (conditional)
                if (_showCc) ...[
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Cc',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _ccController,
                          focusNode: _ccFocusNode,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'cc@example.com',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                // Subject (read-only)
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
                        _getForwardSubject(),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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

          // Message Compose Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add a message (optional)...',
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

  String _getForwardSubject() {
    final subject = widget.email.subject;
    if (subject.toLowerCase().startsWith('fwd:')) {
      return subject;
    }
    return 'Fwd: $subject';
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard forward?'),
        content: const Text(
          'Are you sure you want to discard this forward? Your changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close forward screen
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

