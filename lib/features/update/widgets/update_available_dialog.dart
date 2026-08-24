import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/app_update_info.dart';

/// Prompts the user that a newer GoLazy build is available, with a button
/// that starts the download-and-install flow.
class UpdateAvailableDialog extends StatefulWidget {
  const UpdateAvailableDialog({
    super.key,
    required this.update,
    required this.onUpdate,
  });

  final AppUpdateInfo update;
  final Future<void> Function() onUpdate;

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  bool _isUpdating = false;

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);
    try {
      await widget.onUpdate();
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primarySurface,
        child: Icon(Icons.system_update_alt, color: AppColors.primary),
      ),
      title: const Text('Update available'),
      content: Text(
        'GoLazy ${widget.update.version} is ready to install.'
        '${widget.update.releaseNotes?.trim().isNotEmpty == true ? '\n\n${widget.update.releaseNotes!.trim()}' : ''}',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _handleUpdate,
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.textOnPrimary),
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
