import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/config/env_config.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';

class EnvironmentBadge extends StatelessWidget {
  final bool showSwitchDialogOnTap;

  const EnvironmentBadge({
    super.key,
    this.showSwitchDialogOnTap = true,
  });

  Color _getEnvColor(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.local:
        return Colors.teal;
      case AppEnvironment.dev:
        return Colors.orange;
      case AppEnvironment.prod:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final envConfig = EnvConfig();

    return AnimatedBuilder(
      animation: envConfig,
      builder: (context, _) {
        final env = envConfig.environment;
        final color = _getEnvColor(env);
        final isCustom = envConfig.customBaseUrl != null;

        return InkWell(
          onTap: showSwitchDialogOnTap
              ? () => _showEnvironmentDialog(context, envConfig)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isCustom ? '${env.displayName} (Custom)' : env.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (showSwitchDialogOnTap) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: color),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnvironmentDialog(BuildContext context, EnvConfig envConfig) {
    final customUrlController =
        TextEditingController(text: envConfig.customBaseUrl ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.settings_ethernet, color: AppColors.primary),
              SizedBox(width: 8),
              Text('API Environment', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select the backend environment for API calls:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ...AppEnvironment.values.map((env) {
                  final isSelected = envConfig.environment == env &&
                      envConfig.customBaseUrl == null;
                  return RadioListTile<AppEnvironment>(
                    value: env,
                    groupValue: envConfig.customBaseUrl != null ? null : envConfig.environment,
                    title: Text(
                      env.displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      env.defaultBaseUrl,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    activeColor: _getEnvColor(env),
                    onChanged: (selectedEnv) {
                      if (selectedEnv != null) {
                        envConfig.setEnvironment(selectedEnv);
                        Navigator.pop(dialogCtx);
                      }
                    },
                  );
                }),
                const Divider(height: 24),
                const Text(
                  'Or use a Custom Base URL (e.g. testing with mobile device):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: customUrlController,
                  decoration: const InputDecoration(
                    hintText: 'http://192.168.1.5:5000/api/v1',
                    isDense: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link, size: 18),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          envConfig.setCustomBaseUrl('');
                          Navigator.pop(dialogCtx);
                        },
                        child: const Text('Reset to Preset'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (customUrlController.text.trim().isNotEmpty) {
                            envConfig.setCustomBaseUrl(customUrlController.text);
                          }
                          Navigator.pop(dialogCtx);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Active: ${envConfig.baseUrl}',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
