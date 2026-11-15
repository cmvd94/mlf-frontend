import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../controllers/admin_controller.dart';

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
                      final success = await controller.deleteUser(user.id);
                      if (success && context.mounted) {
                        Navigator.of(context).pop(true);
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
