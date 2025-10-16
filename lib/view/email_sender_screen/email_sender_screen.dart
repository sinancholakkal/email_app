import 'package:email_app/model/email_oprion_model.dart';
import 'package:email_app/state/send_email_bloc/send_email_bloc.dart';
import 'package:email_app/view/email_sender_screen/widget/emai_senter_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailSenderScreen extends StatefulWidget {
  const EmailSenderScreen({super.key});

  @override
  State<EmailSenderScreen> createState() => _EmailSenderScreenState();
}

class _EmailSenderScreenState extends State<EmailSenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final showCcNotifier = ValueNotifier<bool>(false);
  final _ccController = TextEditingController();
  final showBccNotifier = ValueNotifier<bool>(false);
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  
 

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // Future<void> _sendEmail() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isSending = true;
  //     });

  //     // Simulate sending email
  //     await Future.delayed(const Duration(seconds: 2));

  //     if (mounted) {
  //       setState(() {
  //         _isSending = false;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Text('Email sent successfully!'),
  //             ],
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       );

  //       Navigator.pop(context);
  //     }
  //   }
  // }

  // void _showDiscardDialog() {
  //   if (_toController.text.isEmpty &&
  //       _subjectController.text.isEmpty &&
  //       _bodyController.text.isEmpty) {
  //     Navigator.pop(context);
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       title: const Text('Discard draft?'),
  //       content: const Text(
  //         'This email will not be saved and all changes will be lost.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context); // Close dialog
  //             Navigator.pop(context); // Close email sender screen
  //           },
  //           child: const Text(
  //             'Discard',
  //             style: TextStyle(color: Colors.red),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    return EmailSenderView(
      
      formKey: _formKey,
      toController: _toController,
      ccController: _ccController,
      bccController: _bccController,
      subjectController: _subjectController,
      bodyController: _bodyController,
      showCcNotifier: showCcNotifier,
      showBccNotifier: showBccNotifier,
      onSend: (){
        if(_formKey.currentState?.validate() ?? false){
          context.read<SendEmailBloc>().add(SendIngEmailEvent(mailOptionModel: MailOptionModel(
            body: _bodyController.text,
            subject: _subjectController.text,
            recipients: [_toController.text],
            ccRecipients: [_ccController.text],
            bccRecipients: [_bccController.text],
          )));
          clearControllers();
        }
      },
    );
  }
  void clearControllers(){
    _toController.clear();
    _ccController.clear();
    _bccController.clear();
    _subjectController.clear();
    _bodyController.clear();
    showCcNotifier.value = false;
    showBccNotifier.value = false;
  }

}