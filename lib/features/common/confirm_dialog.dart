import 'package:flutter/material.dart';

/// Диалог подтверждения необратимого действия.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Удалить',
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Удалить',
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
}
