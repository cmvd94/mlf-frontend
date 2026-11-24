import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final AdminUserEntity user;
  final AdminController controller;

  const DeleteConfirmDialog({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
          SizedBox(width: 8),
          Text('Delete Admin User', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete admin user "${user.name}" (${user.employeeId})?',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'This will soft-delete the user and terminate all active sessions.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: controller.isActionLoading
                  ? null
                  : () async {
                      try {
                        final success = await controller.deleteUser(user.id);
                        if (context.mounted) {
                          if (success) {
                            Navigator.of(context).pop(true);
                          } else if (controller.errorMessage != null) {
                            AppNotification.showError(context, controller.errorMessage!);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppNotification.showError(context, 'Failed to delete user: $e');
                        }
                      }
                    },
              child: controller.isActionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Delete'),
            );
          },
        ),
      ],
    );
  }
}
