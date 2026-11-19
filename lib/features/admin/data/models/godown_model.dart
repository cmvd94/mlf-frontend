import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/godown_list_entity.dart';

class AssignedAdminModel extends AssignedAdminEntity {
  const AssignedAdminModel({
    required super.id,
    required super.name,
    required super.employeeId,
    required super.phoneNumber,
    required super.email,
    required super.role,
  });

  factory AssignedAdminModel.fromJson(Map<String, dynamic> json) {
    return AssignedAdminModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'employeeId': employeeId,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
    };
  }
}

class GodownModel extends GodownEntity {
  const GodownModel({
    required super.id,
    required super.godownId,
    required super.name,
    required super.type,
    super.description,
    required super.country,
    required super.zone,
    required super.state,
    required super.district,
    required super.pincode,
    super.godownManager,
    super.supervisors,
    super.assistants,
    super.billingUser,
    super.isActive,
    super.isDeleted,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
  });

  factory GodownModel.fromJson(Map<String, dynamic> json) {
    AssignedAdminModel? manager;
    if (json['godownManager'] != null && json['godownManager'] is Map) {
      manager = AssignedAdminModel.fromJson(
        Map<String, dynamic>.from(json['godownManager']),
      );
    }

    AssignedAdminModel? billing;
    if (json['billingUser'] != null && json['billingUser'] is Map) {
      billing = AssignedAdminModel.fromJson(
        Map<String, dynamic>.from(json['billingUser']),
      );
    }

    List<AssignedAdminModel> sups = [];
    if (json['supervisor'] != null && json['supervisor'] is List) {
      sups = (json['supervisor'] as List)
          .whereType<Map>()
          .map((item) => AssignedAdminModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<AssignedAdminModel> assts = [];
    if (json['assistant'] != null && json['assistant'] is List) {
      assts = (json['assistant'] as List)
          .whereType<Map>()
          .map((item) => AssignedAdminModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        return null;
      }
    }

    return GodownModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      godownId: json['godownId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: GodownType.fromString(json['type']?.toString()),
      description: json['description']?.toString(),
      country: json['country']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      godownManager: manager,
      supervisors: sups,
      assistants: assts,
      billingUser: billing,
      isActive: json['isActive'] == true,
      isDeleted: json['isDeleted'] == true,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  static Map<String, dynamic> toCreatePayload({
    required String name,
    String? godownId,
    required GodownType type,
    String? description,
    required String country,
    required String zone,
    required String state,
    required String district,
    required String pincode,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool isActive = true,
  }) {
    final map = <String, dynamic>{
      'name': name.trim(),
      'type': type.value,
      'country': country.trim(),
      'zone': zone.trim(),
      'state': state.trim(),
      'district': district.trim(),
      'pincode': pincode.trim(),
      'isActive': isActive,
    };

    if (godownId != null && godownId.trim().isNotEmpty) {
      map['godownId'] = godownId.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      map['description'] = description.trim();
    }

    // Jobwork godown does not require admin user assigning (all four fields)
    if (type != GodownType.jobworkGodown) {
      if (godownManagerId != null && godownManagerId.isNotEmpty) {
        map['godownManagerId'] = godownManagerId;
      }
      if (supervisorId != null && supervisorId.isNotEmpty) {
        map['supervisorId'] = supervisorId;
      }
      if (assistantId != null && assistantId.isNotEmpty) {
        map['assistantId'] = assistantId;
      }
      if (billingUserId != null && billingUserId.isNotEmpty) {
        map['billingUserId'] = billingUserId;
      }
    }

    return map;
  }

  static Map<String, dynamic> toUpdatePayload({
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    bool? isActive,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
  }) {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name.trim();
    if (godownId != null) map['godownId'] = godownId.trim();
    if (type != null) map['type'] = type.value;
    if (description != null) map['description'] = description.trim();
    if (isActive != null) map['isActive'] = isActive;

    // Jobwork godown does not require admin user assigning (all four fields)
    if (type == GodownType.jobworkGodown) {
      map['godownManagerId'] = null;
      map['supervisorId'] = <String>[];
      map['assistantId'] = <String>[];
      map['billingUserId'] = null;
    } else {
      if (godownManagerId != null) {
        map['godownManagerId'] = godownManagerId.isEmpty ? null : godownManagerId;
      }
      if (supervisorId != null) {
        map['supervisorId'] = supervisorId;
      }
      if (assistantId != null) {
        map['assistantId'] = assistantId;
      }
      if (billingUserId != null) {
        map['billingUserId'] = billingUserId.isEmpty ? null : billingUserId;
      }
    }

    return map;
  }
}

class GodownListModel extends GodownListEntity {
  const GodownListModel({
    required super.godowns,
    required super.pagination,
  });

  factory GodownListModel.fromJson(Map<String, dynamic> json) {
    final rawGodowns = (json['godowns'] as List?) ?? [];
    final godowns = rawGodowns
        .whereType<Map>()
        .map((item) => GodownModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final rawPagination = json['pagination'] as Map? ?? {};
    final pagination = GodownPaginationEntity(
      currentPage: rawPagination['currentPage'] is int
          ? rawPagination['currentPage']
          : int.tryParse(rawPagination['currentPage']?.toString() ?? '1') ?? 1,
      totalPages: rawPagination['totalPages'] is int
          ? rawPagination['totalPages']
          : int.tryParse(rawPagination['totalPages']?.toString() ?? '1') ?? 1,
      totalCount: rawPagination['totalCount'] is int
          ? rawPagination['totalCount']
          : int.tryParse(rawPagination['totalCount']?.toString() ?? '0') ?? 0,
      limit: rawPagination['limit'] is int
          ? rawPagination['limit']
          : int.tryParse(rawPagination['limit']?.toString() ?? '10') ?? 10,
    );

    return GodownListModel(
      godowns: godowns,
      pagination: pagination,
    );
  }
}
