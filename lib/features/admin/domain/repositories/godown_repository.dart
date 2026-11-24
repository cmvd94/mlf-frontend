import '../entities/godown_entity.dart';
import '../entities/godown_list_entity.dart';

abstract class GodownRepository {
  Future<GodownListEntity> getGodowns({
    int page = 1,
    int limit = 10,
    String? search,
    GodownType? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
  });

  Future<GodownEntity> getGodownById(String id);

  Future<String> createGodown({
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
  });

  Future<void> updateGodown({
    required String id,
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    bool? isActive,
    String? godownManagerId,
    bool clearGodownManager = false,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool clearBillingUser = false,
  });

  Future<void> updateGodownIsActive({
    required List<String> godownIds,
    required bool isActive,
  });

  Future<void> deleteGodown(String id);

  Future<List<AssignedAdminEntity>> getEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
  });
}
