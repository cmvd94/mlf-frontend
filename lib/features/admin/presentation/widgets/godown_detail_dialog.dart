import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/godown_entity.dart';

class GodownDetailDialog extends StatelessWidget {
  final GodownEntity godown;

  const GodownDetailDialog({super.key, required this.godown});

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStaffSection(String title, List<AssignedAdminEntity> staffList, {Color? color}) {
    if (staffList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: staffList.map((admin) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (color ?? AppColors.primary).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: color ?? AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    admin.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color ?? AppColors.primaryDark,
                    ),
                  ),
                  if (admin.phoneNumber.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• ${admin.phoneNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: godown.typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warehouse,
                      color: godown.typeColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          godown.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: godown.isActive
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: godown.isActive
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: godown.isActive
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          godown.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: godown.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Scrollable Details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: General Info
                      const Text(
                        'General Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Godown Type', godown.type.label,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: godown.typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              godown.type == GodownType.companyGodown
                                  ? 'Company'
                                  : 'Jobwork',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: godown.typeColor,
                              ),
                            ),
                          )),
                      if (godown.description != null &&
                          godown.description!.isNotEmpty)
                        _buildInfoRow('Description', godown.description!),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Section: Regional Scope
                      const Text(
                        'Regional Scope & Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Country', godown.country),
                      _buildInfoRow('Zone', godown.zone),
                      _buildInfoRow('State', godown.state),
                      _buildInfoRow('District', godown.district),
                      _buildInfoRow('Pincode', godown.pincode),
                      if (godown.address.isNotEmpty)
                        _buildInfoRow('Address', godown.address),
                      if (godown.gstin.isNotEmpty)
                        _buildInfoRow('GSTIN / GST Details', godown.gstin),
                      if (godown.phoneNumber.isNotEmpty)
                        _buildInfoRow('Phone Number', godown.phoneNumber),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Section: Assigned Staff
                      if (godown.type == GodownType.jobworkGodown) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 20, color: Colors.amber.shade900),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Jobwork Godown: Admin user assigning is not required for jobwork facilities.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Assigned Management & Staff',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${godown.totalStaffCount} Assigned',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (godown.godownManager != null)
                          _buildStaffSection(
                            'Godown Manager (Single)',
                            [godown.godownManager!],
                            color: Colors.indigo,
                          )
                        else
                          _buildInfoRow('Godown Manager', 'Not Assigned'),

                        if (godown.billingUser != null)
                          _buildStaffSection(
                            'Billing User (Single)',
                            [godown.billingUser!],
                            color: Colors.teal,
                          )
                        else
                          _buildInfoRow('Billing User', 'Not Assigned'),

                        if (godown.supervisors.isNotEmpty)
                          _buildStaffSection(
                            'Supervisors (${godown.supervisors.length})',
                            godown.supervisors,
                            color: Colors.blue,
                          )
                        else
                          _buildInfoRow('Supervisors', 'None'),

                        if (godown.assistants.isNotEmpty)
                          _buildStaffSection(
                            'Assistants (${godown.assistants.length})',
                            godown.assistants,
                            color: Colors.amber.shade900,
                          )
                        else
                          _buildInfoRow('Assistants', 'None'),
                      ],

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Audit timestamps
                      if (godown.createdBy != null)
                        _buildInfoRow('Created By', godown.createdBy!),
                      if (godown.createdAt != null)
                        _buildInfoRow(
                          'Created At',
                          godown.createdAt!.toLocal().toString().split('.')[0],
                        ),
                      if (godown.updatedAt != null)
                        _buildInfoRow(
                          'Last Updated',
                          godown.updatedAt!.toLocal().toString().split('.')[0],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
