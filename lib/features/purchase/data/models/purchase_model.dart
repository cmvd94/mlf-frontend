import '../../domain/entities/purchase_entity.dart';

class PurchaseItemModel extends PurchaseItemEntity {
  const PurchaseItemModel({
    required super.itemId,
    required super.itemName,
    super.itemCode,
    super.itemStock,
    required super.godownId,
    super.godownName,
    super.godownCode,
    super.batchNo,
    required super.uomId,
    required super.uomSymbol,
    required super.uomQuantity,
    required super.actualQuantity,
    required super.billedQuantity,
    required super.rate,
    required super.perId,
    required super.perSymbol,
    required super.amount,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemId'];
    final godownData = json['godownId'];
    final uomData = json['uomId'];
    final perData = json['perId'];

    return PurchaseItemModel(
      itemId: itemData is Map ? itemData['_id']?.toString() ?? '' : itemData?.toString() ?? '',
      itemName: itemData is Map ? itemData['name']?.toString() ?? '' : '',
      itemCode: itemData is Map ? itemData['itemCode']?.toString() ?? '' : '',
      itemStock: itemData is Map && itemData['currentStock'] != null
          ? (itemData['currentStock'] as num).toDouble()
          : 0.0,
      godownId: godownData is Map
          ? godownData['_id']?.toString() ?? ''
          : godownData?.toString() ?? '',
      godownName: godownData is Map ? godownData['name']?.toString() ?? '' : '',
      godownCode: godownData is Map ? godownData['godownId']?.toString() ?? '' : '',
      batchNo: json['batchNo']?.toString() ?? json['lotNo']?.toString() ?? '',
      uomId: uomData is Map ? uomData['_id']?.toString() ?? '' : uomData?.toString() ?? '',
      uomSymbol: uomData is Map
          ? uomData['symbol']?.toString() ?? uomData['name']?.toString() ?? ''
          : '',
      uomQuantity: json['uomQuantity'] != null
          ? (json['uomQuantity'] as num).toDouble()
          : (json['actualQuantity'] as num?)?.toDouble() ?? 1.0,
      actualQuantity: json['actualQuantity'] != null
          ? (json['actualQuantity'] as num).toDouble()
          : 0.0,
      billedQuantity: json['billedQuantity'] != null
          ? (json['billedQuantity'] as num).toDouble()
          : 0.0,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : 0.0,
      perId: perData is Map ? perData['_id']?.toString() ?? '' : perData?.toString() ?? '',
      perSymbol: perData is Map
          ? perData['symbol']?.toString() ?? perData['name']?.toString() ?? ''
          : '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
    );
  }
}

class PurchaseModel extends PurchaseEntity {
  const PurchaseModel({
    required super.id,
    required super.purchaseNumber,
    required super.date,
    required super.partyId,
    required super.partyName,
    super.partyCode,
    required super.purchaseTypeId,
    required super.purchaseTypeName,
    super.godownId,
    super.godownName,
    super.godownCode,
    super.items,
    super.subTotal,
    super.isGstBill,
    super.gstPercentage,
    super.gstAmount,
    super.totalAmount,
    super.totalActualQuantity,
    super.totalBilledQuantity,
    super.notes,
    super.createdByName,
    super.createdAt,
    super.itemId,
    super.itemName,
    super.itemCode,
    super.itemStock,
    super.uomId,
    super.uomSymbol,
    super.uomQuantity,
    super.actualQuantity,
    super.billedQuantity,
    super.rate,
    super.perId,
    super.perSymbol,
    super.amount,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final partyData = json['partyId'];
    final typeData = json['purchaseTypeId'];
    final rootGodownData = json['godownId'];
    final createdByData = json['createdBy'];

    final rawItems = json['items'];
    final List<PurchaseItemModel> items = [];
    if (rawItems is List && rawItems.isNotEmpty) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          // If individual item doesn't have godownId populated, inherit from root
          if (it['godownId'] == null && rootGodownData != null) {
            it['godownId'] = rootGodownData;
          }
          items.add(PurchaseItemModel.fromJson(it));
        } else if (it is Map) {
          final map = Map<String, dynamic>.from(it);
          if (map['godownId'] == null && rootGodownData != null) {
            map['godownId'] = rootGodownData;
          }
          items.add(PurchaseItemModel.fromJson(map));
        }
      }
    } else if (json['itemId'] != null) {
      // Legacy single-item record fallback
      final itemData = json['itemId'];
      final uomData = json['uomId'];
      final perData = json['perId'];
      items.add(PurchaseItemModel(
        itemId: itemData is Map ? itemData['_id']?.toString() ?? '' : itemData?.toString() ?? '',
        itemName: itemData is Map ? itemData['name']?.toString() ?? '' : '',
        itemCode: itemData is Map ? itemData['itemCode']?.toString() ?? '' : '',
        itemStock: itemData is Map && itemData['currentStock'] != null
            ? (itemData['currentStock'] as num).toDouble()
            : 0.0,
        godownId: rootGodownData is Map
            ? rootGodownData['_id']?.toString() ?? ''
            : rootGodownData?.toString() ?? '',
        godownName: rootGodownData is Map ? rootGodownData['name']?.toString() ?? '' : '',
        godownCode: rootGodownData is Map ? rootGodownData['godownId']?.toString() ?? '' : '',
        batchNo: json['batchNo']?.toString() ?? json['lotNo']?.toString() ?? '',
        uomId: uomData is Map ? uomData['_id']?.toString() ?? '' : uomData?.toString() ?? '',
        uomSymbol: uomData is Map
            ? uomData['symbol']?.toString() ?? uomData['name']?.toString() ?? ''
            : '',
        uomQuantity: json['uomQuantity'] != null
            ? (json['uomQuantity'] as num).toDouble()
            : (json['actualQuantity'] as num?)?.toDouble() ?? 1.0,
        actualQuantity: json['actualQuantity'] != null
            ? (json['actualQuantity'] as num).toDouble()
            : 0.0,
        billedQuantity: json['billedQuantity'] != null
            ? (json['billedQuantity'] as num).toDouble()
            : 0.0,
        rate: json['rate'] != null ? (json['rate'] as num).toDouble() : 0.0,
        perId: perData is Map ? perData['_id']?.toString() ?? '' : perData?.toString() ?? '',
        perSymbol: perData is Map
            ? perData['symbol']?.toString() ?? perData['name']?.toString() ?? ''
            : '',
        amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      ));
    }

    final double totalAmount = json['totalAmount'] != null
        ? (json['totalAmount'] as num).toDouble()
        : (json['amount'] != null
            ? (json['amount'] as num).toDouble()
            : items.fold<double>(0.0, (sum, i) => sum + i.amount));

    final double subTotal = json['subTotal'] != null
        ? (json['subTotal'] as num).toDouble()
        : items.fold<double>(0.0, (sum, i) => sum + i.amount);

    final bool isGstBill = json['isGstBill'] == true;
    final double gstPercentage = (json['gstPercentage'] as num?)?.toDouble() ?? 0.0;
    final double gstAmount = (json['gstAmount'] as num?)?.toDouble() ?? 0.0;

    final double totalActualQty = json['totalActualQuantity'] != null
        ? (json['totalActualQuantity'] as num).toDouble()
        : (json['actualQuantity'] != null
            ? (json['actualQuantity'] as num).toDouble()
            : items.fold<double>(0.0, (sum, i) => sum + i.actualQuantity));

    final double totalBilledQty = json['totalBilledQuantity'] != null
        ? (json['totalBilledQuantity'] as num).toDouble()
        : (json['billedQuantity'] != null
            ? (json['billedQuantity'] as num).toDouble()
            : items.fold<double>(0.0, (sum, i) => sum + i.billedQuantity));

    final firstGodownId = items.isNotEmpty && items.first.godownId.isNotEmpty
        ? items.first.godownId
        : (rootGodownData is Map ? rootGodownData['_id']?.toString() ?? '' : rootGodownData?.toString() ?? '');

    final firstGodownName = items.isNotEmpty && items.first.godownName.isNotEmpty
        ? items.first.godownName
        : (rootGodownData is Map ? rootGodownData['name']?.toString() ?? '' : '');

    final firstGodownCode = items.isNotEmpty && items.first.godownCode.isNotEmpty
        ? items.first.godownCode
        : (rootGodownData is Map ? rootGodownData['godownId']?.toString() ?? '' : '');

    return PurchaseModel(
      id: json['_id']?.toString() ?? '',
      purchaseNumber: json['purchaseNumber']?.toString() ?? '',
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString())?.toLocal() ?? DateTime.now())
          : DateTime.now(),
      partyId: partyData is Map ? partyData['_id']?.toString() ?? '' : partyData?.toString() ?? '',
      partyName: partyData is Map ? partyData['name']?.toString() ?? '' : '',
      partyCode: partyData is Map ? partyData['partyCode']?.toString() ?? '' : '',
      purchaseTypeId: typeData is Map ? typeData['_id']?.toString() ?? '' : typeData?.toString() ?? '',
      purchaseTypeName: typeData is Map ? typeData['name']?.toString() ?? '' : '',
      godownId: firstGodownId,
      godownName: firstGodownName,
      godownCode: firstGodownCode,
      items: items,
      subTotal: subTotal,
      isGstBill: isGstBill,
      gstPercentage: gstPercentage,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      totalActualQuantity: totalActualQty,
      totalBilledQuantity: totalBilledQty,
      notes: json['notes']?.toString() ?? '',
      createdByName: createdByData is Map ? createdByData['name']?.toString() ?? '' : '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      itemId: items.isNotEmpty ? items.first.itemId : '',
      itemName: items.isNotEmpty ? items.first.itemName : '',
      itemCode: items.isNotEmpty ? items.first.itemCode : '',
      itemStock: items.isNotEmpty ? items.first.itemStock : 0.0,
      uomId: items.isNotEmpty ? items.first.uomId : '',
      uomSymbol: items.isNotEmpty ? items.first.uomSymbol : '',
      uomQuantity: items.isNotEmpty ? items.first.uomQuantity : 0.0,
      actualQuantity: totalActualQty,
      billedQuantity: totalBilledQty,
      rate: items.isNotEmpty ? items.first.rate : 0.0,
      perId: items.isNotEmpty ? items.first.perId : '',
      perSymbol: items.isNotEmpty ? items.first.perSymbol : '',
      amount: totalAmount,
    );
  }

  /// Follows aiGuide.txt: Send input values as is to backend
  static Map<String, dynamic> toCreatePayload({
    required DateTime date,
    required String partyId,
    required String purchaseTypeId,
    String? godownId,
    List<Map<String, dynamic>>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    // Optional legacy single-item parameters
    String? itemId,
    String? batchNo,
    String? uomId,
    double? uomQuantity,
    double? actualQuantity,
    double? billedQuantity,
    double? rate,
    String? perId,
  }) {
    final List<Map<String, dynamic>> itemsList = [];
    if (items != null && items.isNotEmpty) {
      itemsList.addAll(items);
    } else if (itemId != null) {
      itemsList.add({
        'itemId': itemId,
        'godownId': godownId ?? '',
        'batchNo': batchNo ?? '',
        'uomId': uomId ?? '',
        'uomQuantity': uomQuantity ?? actualQuantity ?? 1.0,
        'actualQuantity': actualQuantity ?? 0.0,
        'billedQuantity': billedQuantity ?? 0.0,
        'rate': rate ?? 0.0,
        'perId': perId ?? '',
      });
    }

    final String formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return {
      'date': formattedDate,
      'partyId': partyId,
      'purchaseTypeId': purchaseTypeId,
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      'items': itemsList,
      'isGstBill': isGstBill ?? false,
      if (isGstBill == true && gstPercentage != null) 'gstPercentage': gstPercentage,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (itemId != null) 'itemId': itemId,
      if (uomId != null) 'uomId': uomId,
      if (actualQuantity != null) 'actualQuantity': actualQuantity,
      if (billedQuantity != null) 'billedQuantity': billedQuantity,
      if (rate != null) 'rate': rate,
      if (perId != null) 'perId': perId,
    };
  }

  static Map<String, dynamic> toUpdatePayload({
    DateTime? date,
    String? partyId,
    String? purchaseTypeId,
    List<Map<String, dynamic>>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
  }) {
    final String? formattedDate = date != null
        ? '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : null;

    return {
      if (formattedDate != null) 'date': formattedDate,
      if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
      if (purchaseTypeId != null && purchaseTypeId.isNotEmpty)
        'purchaseTypeId': purchaseTypeId,
      if (items != null) 'items': items,
      if (isGstBill != null) 'isGstBill': isGstBill,
      if (gstPercentage != null) 'gstPercentage': gstPercentage,
      if (notes != null) 'notes': notes,
    };
  }
}

class PurchasePaginationModel extends PurchasePaginationEntity {
  const PurchasePaginationModel({
    super.currentPage = 1,
    super.totalPages = 0,
    super.totalCount = 0,
    super.limit = 20,
    super.hasNextPage = false,
    super.hasPreviousPage = false,
  });

  factory PurchasePaginationModel.fromJson(Map<String, dynamic> json) {
    return PurchasePaginationModel(
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPrevPage'] == true || json['hasPreviousPage'] == true,
    );
  }
}

class PurchaseListResultModel extends PurchaseListResultEntity {
  const PurchaseListResultModel({
    required super.purchases,
    required super.pagination,
  });

  factory PurchaseListResultModel.fromJson(Map<String, dynamic> json) {
    final rawPurchases = json['purchases'] as List<dynamic>? ?? [];
    final purchasesList = rawPurchases
        .map<PurchaseEntity>((p) => PurchaseModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawPagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PurchaseListResultModel(
      purchases: purchasesList,
      pagination: PurchasePaginationModel.fromJson(rawPagination),
    );
  }
}
