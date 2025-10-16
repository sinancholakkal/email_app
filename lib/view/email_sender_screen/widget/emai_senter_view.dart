import 'package:email_app/constants/app_colors.dart';
import 'package:email_app/view/widgets/custom_inputfield.dart';
import 'package:flutter/material.dart';

class EmailSenderView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController toController;
  final TextEditingController ccController;
  final TextEditingController bccController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;
  final ValueNotifier<bool> showCcNotifier;
  final ValueNotifier<bool> showBccNotifier;
  final VoidCallback onSend;
 

  const EmailSenderView({
    super.key,
    required this.formKey,
    required this.toController,
    required this.ccController,
    required this.bccController,
    required this.subjectController,
    required this.bodyController,
    required this.showCcNotifier,
    required this.showBccNotifier,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,

        title: Text(
          'Compose',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
        
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // To field
            ValueListenableBuilder<bool>(
              valueListenable: showCcNotifier,
              builder: (context, showCc, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: showBccNotifier,
                  builder: (context, showBcc, _) {
                    return CustomInputField(
                      controller: toController,
                      label: 'To',
                      hint: 'recipient@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter recipient email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      isDark: isDark,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!showCc)
                            TextButton(
                              onPressed: () => showCcNotifier.value = true,
                              child: Text(
                                'Cc',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[400],
                                ),
                              ),
                            ),
                          if (!showBcc)
                            TextButton(
                              onPressed: () => showBccNotifier.value = true,
                              child: Text(
                                'Bcc',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[400],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // Cc field (conditional)
            ValueListenableBuilder<bool>(
              valueListenable: showCcNotifier,
              builder: (context, showCc, _) {
                if (!showCc) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: CustomInputField(
                    controller: ccController,
                    label: 'Cc',
                    hint: 'cc@example.com',
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        showCcNotifier.value = false;
                        ccController.clear();
                      },
                    ),
                  ),
                );
              },
            ),

            // Bcc field (conditional)
            ValueListenableBuilder<bool>(
              valueListenable: showBccNotifier,
              builder: (context, showBcc, _) {
                if (!showBcc) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: CustomInputField(
                    controller: bccController,
                    label: 'Bcc',
                    hint: 'bcc@example.com',
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        showBccNotifier.value = false;
                        bccController.clear();
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Subject field
            CustomInputField(
              controller: subjectController,
              label: 'Subject',
              hint: 'Email subject',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Divider
            Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              height: 24,
            ),

            // Body field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: bodyController,
                maxLines: null,
                minLines: 19,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.kwhite : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Compose your email...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email content';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
          
            ValueListenableBuilder(
              valueListenable: showBccNotifier,
              builder: (context, value, child) {
                if (value) {
                  return SizedBox(height: 100);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
