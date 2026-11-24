class CreditNoteItemEntity {
  final String? id;
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
  final String dcNo;
  final String lotNo;
  String get batchNo => dcNo;
  final String uomId;
  final String uomSymbol;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double rate;
  final String perId;
  final String perSymbol;
  final double amount;

  const CreditNoteItemEntity({
    this.id,
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
    this.dcNo = '',
    this.lotNo = '',
    String batchNo = '',
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

class CreditNoteItemInput {
  final String? godownStockId;
  final String itemId;
  final String godownId;
  final String? companyGodownId;
  final String dcNo;
  final String lotNo;
  String get batchNo => dcNo;
  final String uomId;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double rate;
  final String perId;

  const CreditNoteItemInput({
    this.godownStockId,
    required this.itemId,
    required this.godownId,
    this.companyGodownId,
    this.dcNo = '',
    this.lotNo = '',
    String batchNo = '',
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
    'dcNo': dcNo.isNotEmpty ? dcNo : batchNo,
    'lotNo': lotNo,
    'batchNo': dcNo.isNotEmpty ? dcNo : batchNo,
    'uomId': uomId,
    'uomQuantity': uomQuantity,
    'actualQuantity': actualQuantity,
    'billedQuantity': billedQuantity,
    'rate': rate,
    'perId': perId,
  };
}

class CreditNoteEntity {
  final String id;
  final String creditNoteNumber;
  final DateTime date;
  final String partyId;
  final String partyName;
  final String partyCode;
  final String purchaseTypeId;
  final String purchaseTypeName;
  final String purchaseTypeCode;
  String get creditNoteTypeId => purchaseTypeId;
  String get creditNoteTypeName => purchaseTypeName;
  String get creditNoteTypeCode => purchaseTypeCode;
  final String dcNo;
  final String narration;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final List<CreditNoteItemEntity> items;
  final double subTotal;
  final bool isGstBill;
  final double gstPercentage;
  final double gstAmount;
  final double totalAmount;
  final double totalActualQuantity;
  final double totalBilledQuantity;
  final double totalQuantity;
  final String notes;
  final String createdByName;
  final DateTime? createdAt;

  const CreditNoteEntity({
    required this.id,
    required this.creditNoteNumber,
    required this.date,
    required this.partyId,
    required this.partyName,
    this.partyCode = '',
    String purchaseTypeId = '',
    String purchaseTypeName = '',
    String purchaseTypeCode = '',
    String? creditNoteTypeId,
    String? creditNoteTypeName,
    String? creditNoteTypeCode,
    this.dcNo = '',
    this.narration = '',
    this.companyGodownId = '',
    this.companyGodownName = '',
    this.companyGodownCode = '',
    this.items = const [],
    this.subTotal = 0.0,
    this.isGstBill = false,
    this.gstPercentage = 0.0,
    this.gstAmount = 0.0,
    this.totalAmount = 0.0,
    this.totalActualQuantity = 0.0,
    this.totalBilledQuantity = 0.0,
    this.totalQuantity = 0.0,
    this.notes = '',
    this.createdByName = '',
    this.createdAt,
  })  : purchaseTypeId = creditNoteTypeId ?? purchaseTypeId,
        purchaseTypeName = creditNoteTypeName ?? purchaseTypeName,
        purchaseTypeCode = creditNoteTypeCode ?? purchaseTypeCode;
}

typedef CreditNoteItemCreateInput = CreditNoteItemInput;

class CreditNoteCreateInput {
  final DateTime date;
  final String partyId;
  final String? purchaseTypeId;
  final String? creditNoteTypeId;
  final String companyGodownId;
  final List<CreditNoteItemInput> items;
  final bool isGstBill;
  final double? gstPercentage;
  final String? notes;

  const CreditNoteCreateInput({
    required this.date,
    required this.partyId,
    this.purchaseTypeId,
    this.creditNoteTypeId,
    required this.companyGodownId,
    required this.items,
    this.isGstBill = false,
    this.gstPercentage,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().split('T').first,
    'partyId': partyId,
    if (purchaseTypeId != null && purchaseTypeId!.isNotEmpty) 'purchaseTypeId': purchaseTypeId,
    if (creditNoteTypeId != null && creditNoteTypeId!.isNotEmpty) 'creditNoteTypeId': creditNoteTypeId,
    'companyGodownId': companyGodownId,
    'items': items.map((i) => i.toJson()).toList(),
    'isGstBill': isGstBill,
    if (gstPercentage != null) 'gstPercentage': gstPercentage,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class CreditNoteUpdateInput {
  final DateTime? date;
  final String? partyId;
  final String? purchaseTypeId;
  final String? creditNoteTypeId;
  final String? companyGodownId;
  final List<CreditNoteItemInput>? items;
  final bool? isGstBill;
  final double? gstPercentage;
  final String? notes;

  const CreditNoteUpdateInput({
    this.date,
    this.partyId,
    this.purchaseTypeId,
    this.creditNoteTypeId,
    this.companyGodownId,
    this.items,
    this.isGstBill,
    this.gstPercentage,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (date != null) 'date': date!.toIso8601String().split('T').first,
    if (partyId != null) 'partyId': partyId,
    if (purchaseTypeId != null) 'purchaseTypeId': purchaseTypeId,
    if (creditNoteTypeId != null) 'creditNoteTypeId': creditNoteTypeId,
    if (companyGodownId != null && companyGodownId!.isNotEmpty) 'companyGodownId': companyGodownId,
    if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    if (isGstBill != null) 'isGstBill': isGstBill,
    if (gstPercentage != null) 'gstPercentage': gstPercentage,
    if (notes != null) 'notes': notes,
  };
}
