import 'package:flutter/material.dart';

enum GodownType {
  companyGodown('company godown', 'Company Godown'),
  jobworkGodown('jobwork godown', 'Jobwork Godown');

  final String value;
  final String label;

  const GodownType(this.value, this.label);

  static GodownType fromString(String? type) {
    if (type == null) return GodownType.companyGodown;
    for (final t in GodownType.values) {
      if (t.value.toLowerCase() == type.toLowerCase() ||
          t.name.toLowerCase() == type.toLowerCase()) {
        return t;
      }
    }
    return GodownType.companyGodown;
  }
}

class AssignedAdminEntity {
  final String id;
  final String name;
  final String employeeId;
  final String phoneNumber;
  final String email;
  final String role;

  const AssignedAdminEntity({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.phoneNumber,
    required this.email,
    required this.role,
  });

  String get displayName => '$name ($employeeId)';
}

class GodownEntity {
  final String id;
  final String godownId;
  final String name;
  final GodownType type;
  final String? description;
  final String country;
  final String zone;
  final String state;
  final String district;
  final String pincode;
  final String address;
  final String gstin;
  final String phoneNumber;

  // Assigned Admins
  final AssignedAdminEntity? godownManager;
  final List<AssignedAdminEntity> supervisors;
  final List<AssignedAdminEntity> assistants;
  final AssignedAdminEntity? billingUser;

  final bool isActive;
  final bool isDeleted;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GodownEntity({
    required this.id,
    required this.godownId,
    required this.name,
    required this.type,
    this.description,
    required this.country,
    required this.zone,
    required this.state,
    required this.district,
    required this.pincode,
    this.address = '',
    this.gstin = '',
    this.phoneNumber = '',
    this.godownManager,
    this.supervisors = const [],
    this.assistants = const [],
    this.billingUser,
    this.isActive = true,
    this.isDeleted = false,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  String get displayLocation => '$district, $state ($pincode)';
  String get fullHierarchy => '$country > $zone > $state > $district ($pincode)';

  int get totalStaffCount {
    int count = 0;
    if (godownManager != null) count++;
    count += supervisors.length;
    count += assistants.length;
    if (billingUser != null) count++;
    return count;
  }

  Color get typeColor {
    switch (type) {
      case GodownType.companyGodown:
        return const Color(0xFF1E88E5); // Blue
      case GodownType.jobworkGodown:
        return const Color(0xFF8E24AA); // Purple
    }
  }

  GodownEntity copyWith({
    String? id,
    String? godownId,
    String? name,
    GodownType? type,
    String? description,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
    AssignedAdminEntity? godownManager,
    List<AssignedAdminEntity>? supervisors,
    List<AssignedAdminEntity>? assistants,
    AssignedAdminEntity? billingUser,
    bool? isActive,
    bool? isDeleted,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GodownEntity(
      id: id ?? this.id,
      godownId: godownId ?? this.godownId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      country: country ?? this.country,
      zone: zone ?? this.zone,
      state: state ?? this.state,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      godownManager: godownManager ?? this.godownManager,
      supervisors: supervisors ?? this.supervisors,
      assistants: assistants ?? this.assistants,
      billingUser: billingUser ?? this.billingUser,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
