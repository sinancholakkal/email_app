import 'package:flutter/material.dart';

class EmailSenderScreen extends StatefulWidget {
  const EmailSenderScreen({super.key});

  @override
  State<EmailSenderScreen> createState() => _EmailSenderScreenState();
}

class _EmailSenderScreenState extends State<EmailSenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  
  final _showCcNotifier = ValueNotifier<bool>(false);
  final _showBccNotifier = ValueNotifier<bool>(false);
  bool _isSending = false;

  @override
  void dispose() {
    _showCcNotifier.dispose();
    _showBccNotifier.dispose();
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      // Simulate sending email
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Email sent successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  void _showDiscardDialog() {
    if (_toController.text.isEmpty &&
        _subjectController.text.isEmpty &&
        _bodyController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Discard draft?'),
        content: const Text(
          'This email will not be saved and all changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close email sender screen
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        _showDiscardDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.close, color: theme.appBarTheme.foregroundColor),
            onPressed: _showDiscardDialog,
          ),
          title: Text(
            'Compose',
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: Icon(Icons.attach_file, color: theme.appBarTheme.foregroundColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Attachment feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            if (!_isSending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: _sendEmail,
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
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               // To field
               ValueListenableBuilder<bool>(
                 valueListenable: _showCcNotifier,
                 builder: (context, showCc, _) {
                   return ValueListenableBuilder<bool>(
                     valueListenable: _showBccNotifier,
                     builder: (context, showBcc, _) {
                       return _buildInputField(
                         controller: _toController,
                         label: 'To',
                         hint: 'recipient@example.com',
                         keyboardType: TextInputType.emailAddress,
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Please enter recipient email';
                           }
                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                                 onPressed: () => _showCcNotifier.value = true,
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
                                 onPressed: () => _showBccNotifier.value = true,
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
                 valueListenable: _showCcNotifier,
                 builder: (context, showCc, _) {
                   if (!showCc) return const SizedBox.shrink();
                   return Column(
                     children: [
                       const SizedBox(height: 12),
                       _buildInputField(
                         controller: _ccController,
                         label: 'Cc',
                         hint: 'cc@example.com',
                         keyboardType: TextInputType.emailAddress,
                         isDark: isDark,
                         suffixIcon: IconButton(
                           icon: const Icon(Icons.close, size: 20),
                           onPressed: () {
                             _showCcNotifier.value = false;
                             _ccController.clear();
                           },
                         ),
                       ),
                     ],
                   );
                 },
               ),

               // Bcc field (conditional)
               ValueListenableBuilder<bool>(
                 valueListenable: _showBccNotifier,
                 builder: (context, showBcc, _) {
                   if (!showBcc) return const SizedBox.shrink();
                   return Column(
                     children: [
                       const SizedBox(height: 12),
                       _buildInputField(
                         controller: _bccController,
                         label: 'Bcc',
                         hint: 'bcc@example.com',
                         keyboardType: TextInputType.emailAddress,
                         isDark: isDark,
                         suffixIcon: IconButton(
                           icon: const Icon(Icons.close, size: 20),
                           onPressed: () {
                             _showBccNotifier.value = false;
                             _bccController.clear();
                           },
                         ),
                       ),
                     ],
                   );
                 },
               ),

              const SizedBox(height: 12),

              // Subject field
              _buildInputField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'Email subject',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject';
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
                   color: isDark 
                       ? const Color(0xFF2C2C2C)
                       : Colors.grey[100],
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: TextFormField(
                   controller: _bodyController,
                   maxLines: null,
                   minLines: 16,
                   keyboardType: TextInputType.multiline,
                   style: TextStyle(
                     fontSize: 16,
                     color: isDark ? Colors.white : Colors.black87,
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

              const SizedBox(height: 24),

              // Additional options
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildOptionChip(
                    context,
                    icon: Icons.format_bold,
                    label: 'Bold',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildOptionChip(
                    context,
                    icon: Icons.format_italic,
                    label: 'Italic',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildOptionChip(
                    context,
                    icon: Icons.link,
                    label: 'Link',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildOptionChip(
                    context,
                    icon: Icons.image,
                    label: 'Image',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
                ValueListenableBuilder(valueListenable: _showBccNotifier, builder:(context, value, child) {
                  if(value){
                    return SizedBox(height: 35,);
                  }
                  return const SizedBox.shrink();
                }, ),
              const SizedBox(height:  32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildOptionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label formatting coming soon'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}