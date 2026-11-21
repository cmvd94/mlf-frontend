class PurchaseItemEntity {
  final String? godownStockId;
  final String itemId;
  final String itemName;
  final String itemCode;
  final double itemStock;
  final String godownId;
  final String godownName;
  final String godownCode;
  final String? companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final String batchNo;
  final String uomId;
  final String uomSymbol;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double rate;
  final String perId;
  final String perSymbol;
  final double amount;

  const PurchaseItemEntity({
    this.godownStockId,
    required this.itemId,
    required this.itemName,
    this.itemCode = '',
    this.itemStock = 0.0,
    required this.godownId,
    this.godownName = '',
    this.godownCode = '',
    this.companyGodownId,
    this.companyGodownName = '',
    this.companyGodownCode = '',
    this.batchNo = '',
    required this.uomId,
    required this.uomSymbol,
    required this.uomQuantity,
    required this.actualQuantity,
    required this.billedQuantity,
    required this.rate,
    required this.perId,
    required this.perSymbol,
    required this.amount,
  });
}

class PurchaseItemInput {
  final String? godownStockId;
  final String itemId;
  final String godownId;
  final String? companyGodownId;
  final String batchNo;
  final String uomId;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double rate;
  final String perId;

  const PurchaseItemInput({
    this.godownStockId,
    required this.itemId,
    required this.godownId,
    this.companyGodownId,
    this.batchNo = '',
    required this.uomId,
    required this.uomQuantity,
    required this.actualQuantity,
    required this.billedQuantity,
    required this.rate,
    required this.perId,
  });

  Map<String, dynamic> toJson() => {
    if (godownStockId != null && godownStockId!.isNotEmpty) 'godownStockId': godownStockId,
    'itemId': itemId,
    'godownId': godownId,
    if (companyGodownId != null && companyGodownId!.isNotEmpty) 'companyGodownId': companyGodownId,
    'batchNo': batchNo,
    'uomId': uomId,
    'uomQuantity': uomQuantity,
    'actualQuantity': actualQuantity,
    'billedQuantity': billedQuantity,
    'rate': rate,
    'perId': perId,
  };
}

class PurchaseEntity {
  final String id;
  final String purchaseNumber;
  final DateTime date;
  final String partyId;
  final String partyName;
  final String partyCode;
  final String purchaseTypeId;
  final String purchaseTypeName;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final List<PurchaseItemEntity> items;
  final double subTotal;
  final bool isGstBill;
  final double gstPercentage;
  final double gstAmount;
  final double totalAmount;
  final double totalActualQuantity;
  final double totalBilledQuantity;
  final String notes;
  final String createdByName;
  final DateTime? createdAt;

  final String _legacyGodownId;
  final String _legacyGodownName;
  final String _legacyGodownCode;
  final String _legacyItemId;
  final String _legacyBatchNo;
  final String _legacyItemName;
  final String _legacyItemCode;
  final double _legacyItemStock;
  final String _legacyUomId;
  final String _legacyUomSymbol;
  final double _legacyUomQuantity;
  final double _legacyActualQuantity;
  final double _legacyBilledQuantity;
  final double _legacyRate;
  final String _legacyPerId;
  final String _legacyPerSymbol;
  final double _legacyAmount;

  const PurchaseEntity({
    required this.id,
    required this.purchaseNumber,
    required this.date,
    required this.partyId,
    required this.partyName,
    this.partyCode = '',
    required this.purchaseTypeId,
    required this.purchaseTypeName,
    this.companyGodownId = '',
    this.companyGodownName = '',
    this.companyGodownCode = '',
    String godownId = '',
    String godownName = '',
    String godownCode = '',
    this.items = const [],
    this.subTotal = 0.0,
    this.isGstBill = false,
    this.gstPercentage = 0.0,
    this.gstAmount = 0.0,
    this.totalAmount = 0.0,
    this.totalActualQuantity = 0.0,
    this.totalBilledQuantity = 0.0,
    this.notes = '',
    this.createdByName = '',
    this.createdAt,
    String itemId = '',
    String batchNo = '',
    String itemName = '',
    String itemCode = '',
    double itemStock = 0.0,
    String uomId = '',
    String uomSymbol = '',
    double uomQuantity = 0.0,
    double actualQuantity = 0.0,
    double billedQuantity = 0.0,
    double rate = 0.0,
    String perId = '',
    String perSymbol = '',
    double amount = 0.0,
  })  : _legacyGodownId = godownId,
        _legacyGodownName = godownName,
        _legacyGodownCode = godownCode,
        _legacyItemId = itemId,
        _legacyBatchNo = batchNo,
        _legacyItemName = itemName,
        _legacyItemCode = itemCode,
        _legacyItemStock = itemStock,
        _legacyUomId = uomId,
        _legacyUomSymbol = uomSymbol,
        _legacyUomQuantity = uomQuantity,
        _legacyActualQuantity = actualQuantity,
        _legacyBilledQuantity = billedQuantity,
        _legacyRate = rate,
        _legacyPerId = perId,
        _legacyPerSymbol = perSymbol,
        _legacyAmount = amount;

  String get godownId => items.isNotEmpty && items.first.godownId.isNotEmpty
      ? items.first.godownId
      : _legacyGodownId;

  String get godownName => items.isNotEmpty && items.first.godownName.isNotEmpty
      ? items.first.godownName
      : _legacyGodownName;

  String get godownCode => items.isNotEmpty && items.first.godownCode.isNotEmpty
      ? items.first.godownCode
      : _legacyGodownCode;

  String get itemId => items.isNotEmpty ? items.first.itemId : _legacyItemId;
  String get batchNo => items.isNotEmpty ? items.first.batchNo : _legacyBatchNo;
  String get itemName => items.isNotEmpty ? items.first.itemName : _legacyItemName;
  String get itemCode => items.isNotEmpty ? items.first.itemCode : _legacyItemCode;
  double get itemStock => items.isNotEmpty ? items.first.itemStock : _legacyItemStock;
  String get uomId => items.isNotEmpty ? items.first.uomId : _legacyUomId;
  String get uomSymbol => items.isNotEmpty ? items.first.uomSymbol : _legacyUomSymbol;
  double get uomQuantity => items.isNotEmpty ? items.first.uomQuantity : _legacyUomQuantity;
  double get actualQuantity => items.isNotEmpty
      ? items.first.actualQuantity
      : (_legacyActualQuantity != 0.0 ? _legacyActualQuantity : totalActualQuantity);
  double get billedQuantity => items.isNotEmpty
      ? items.first.billedQuantity
      : (_legacyBilledQuantity != 0.0 ? _legacyBilledQuantity : totalBilledQuantity);
  double get rate => items.isNotEmpty ? items.first.rate : _legacyRate;
  String get perId => items.isNotEmpty ? items.first.perId : _legacyPerId;
  String get perSymbol => items.isNotEmpty ? items.first.perSymbol : _legacyPerSymbol;
  double get amount => totalAmount != 0.0 ? totalAmount : _legacyAmount;
}

class PurchasePaginationEntity {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PurchasePaginationEntity({
    this.currentPage = 1,
    this.totalPages = 0,
    this.totalCount = 0,
    this.limit = 20,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });
}

class PurchaseListResultEntity {
  final List<PurchaseEntity> purchases;
  final PurchasePaginationEntity pagination;

  const PurchaseListResultEntity({
    required this.purchases,
    required this.pagination,
  });
}
