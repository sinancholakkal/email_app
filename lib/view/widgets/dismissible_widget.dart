
import 'package:email_app/model/email_model.dart';
import 'package:email_app/view/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';

class DismissibleWidget extends StatelessWidget {
  const DismissibleWidget({
    super.key,
    required this.email,
    required this.onDelete,
    required this.child,
  });
  final VoidCallback onDelete;
  final Email email;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(email.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        // Optional: Show confirmation dialog
        return await deleteDialog(context, onDelete);
      },
      child: child,
    );
  }

  
}
