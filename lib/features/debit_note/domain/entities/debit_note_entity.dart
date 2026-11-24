class DebitNoteItemEntity {
  final String? id;
  final String godownStockId;
  final String itemId;
  final String itemName;
  final String itemCode;
  final String godownId;
  final String godownName;
  final String godownCode;
  final String? companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final String dcNo;
  final String lotNo;
  final String uomId;
  final String uomSymbol;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double quantity; // Alias/fallback
  final double rate;
  final String perId;
  final String perSymbol;
  final double amount;

  const DebitNoteItemEntity({
    this.id,
    required this.godownStockId,
    required this.itemId,
    required this.itemName,
    this.itemCode = '',
    required this.godownId,
    this.godownName = '',
    this.godownCode = '',
    this.companyGodownId,
    this.companyGodownName = '',
    this.companyGodownCode = '',
    this.dcNo = '',
    this.lotNo = '',
    required this.uomId,
    required this.uomSymbol,
    required this.uomQuantity,
    required this.actualQuantity,
    required this.billedQuantity,
    double? quantity,
    required this.rate,
    required this.perId,
    required this.perSymbol,
    required this.amount,
  }) : quantity = quantity ?? actualQuantity;
}

class DebitNoteItemInput {
  final String godownStockId;
  final String? itemId;
  final String? godownId;
  final String? companyGodownId;
  final String dcNo;
  final String lotNo;
  final String? uomId;
  final double uomQuantity;
  final double actualQuantity;
  final double billedQuantity;
  final double quantity;
  final double rate;
  final String? perId;

  const DebitNoteItemInput({
    required this.godownStockId,
    this.itemId,
    this.godownId,
    this.companyGodownId,
    this.dcNo = '',
    this.lotNo = '',
    this.uomId,
    this.uomQuantity = 1.0,
    required this.actualQuantity,
    required this.billedQuantity,
    double? quantity,
    required this.rate,
    this.perId,
  }) : quantity = quantity ?? actualQuantity;

  Map<String, dynamic> toJson() => {
    'godownStockId': godownStockId,
    if (itemId != null && itemId!.isNotEmpty) 'itemId': itemId,
    if (godownId != null && godownId!.isNotEmpty) 'godownId': godownId,
    if (companyGodownId != null && companyGodownId!.isNotEmpty) 'companyGodownId': companyGodownId,
    if (dcNo.isNotEmpty) 'dcNo': dcNo,
    if (lotNo.isNotEmpty) 'lotNo': lotNo,
    if (uomId != null && uomId!.isNotEmpty) 'uomId': uomId,
    'uomQuantity': uomQuantity,
    'actualQuantity': actualQuantity,
    'billedQuantity': billedQuantity,
    'quantity': actualQuantity,
    'rate': rate,
    if (perId != null && perId!.isNotEmpty) 'perId': perId,
  };
}

class DebitNoteEntity {
  final String id;
  final String debitNoteNumber;
  final DateTime date;
  final String salesTypeId;
  final String salesTypeName;
  final String salesTypeCode;
  String get debitNoteTypeId => salesTypeId;
  String get debitNoteTypeName => salesTypeName;
  String get debitNoteTypeCode => salesTypeCode;
  final String partyId;
  final String partyName;
  final String partyCode;
  final String dcNo;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final List<DebitNoteItemEntity> items;
  final double subTotal;
  final bool isGstBill;
  final double gstPercentage;
  final double gstAmount;
  final double totalAmount;
  final double totalActualQuantity;
  final double totalBilledQuantity;
  final double totalQuantity;
  final String notes;
  final String narration;
  final String createdByName;
  final DateTime? createdAt;

  const DebitNoteEntity({
    required this.id,
    required this.debitNoteNumber,
    required this.date,
    String salesTypeId = '',
    String salesTypeName = '',
    String salesTypeCode = '',
    String? debitNoteTypeId,
    String? debitNoteTypeName,
    String? debitNoteTypeCode,
    required this.partyId,
    required this.partyName,
    this.partyCode = '',
    this.dcNo = '',
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
    this.narration = '',
    this.createdByName = '',
    this.createdAt,
  })  : salesTypeId = debitNoteTypeId ?? salesTypeId,
        salesTypeName = debitNoteTypeName ?? salesTypeName,
        salesTypeCode = debitNoteTypeCode ?? salesTypeCode;
}

typedef DebitNoteItemCreateInput = DebitNoteItemInput;

class DebitNoteCreateInput {
  final DateTime date;
  final String? salesTypeId;
  final String? debitNoteTypeId;
  final String partyId;
  final String? dcNo;
  final String? companyGodownId;
  final List<DebitNoteItemInput> items;
  final bool isGstBill;
  final double? gstPercentage;
  final String? notes;
  final String? narration;

  const DebitNoteCreateInput({
    required this.date,
    this.salesTypeId,
    this.debitNoteTypeId,
    required this.partyId,
    this.dcNo,
    this.companyGodownId,
    required this.items,
    this.isGstBill = false,
    this.gstPercentage,
    this.notes,
    this.narration,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().split('T').first,
    if (salesTypeId != null && salesTypeId!.isNotEmpty) 'salesTypeId': salesTypeId,
    if (debitNoteTypeId != null && debitNoteTypeId!.isNotEmpty) 'debitNoteTypeId': debitNoteTypeId,
    'partyId': partyId,
    if (dcNo != null && dcNo!.isNotEmpty) 'dcNo': dcNo,
    if (companyGodownId != null && companyGodownId!.isNotEmpty) 'companyGodownId': companyGodownId,
    'items': items.map((i) => i.toJson()).toList(),
    'isGstBill': isGstBill,
    if (gstPercentage != null) 'gstPercentage': gstPercentage,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (narration != null && narration!.isNotEmpty) 'narration': narration,
  };
}

class DebitNoteUpdateInput {
  final DateTime? date;
  final String? salesTypeId;
  final String? debitNoteTypeId;
  final String? partyId;
  final String? dcNo;
  final String? companyGodownId;
  final List<DebitNoteItemInput>? items;
  final bool? isGstBill;
  final double? gstPercentage;
  final String? notes;
  final String? narration;

  const DebitNoteUpdateInput({
    this.date,
    this.salesTypeId,
    this.debitNoteTypeId,
    this.partyId,
    this.dcNo,
    this.companyGodownId,
    this.items,
    this.isGstBill,
    this.gstPercentage,
    this.notes,
    this.narration,
  });

  Map<String, dynamic> toJson() => {
    if (date != null) 'date': date!.toIso8601String().split('T').first,
    if (salesTypeId != null) 'salesTypeId': salesTypeId,
    if (debitNoteTypeId != null) 'debitNoteTypeId': debitNoteTypeId,
    if (partyId != null) 'partyId': partyId,
    if (dcNo != null) 'dcNo': dcNo,
    if (companyGodownId != null && companyGodownId!.isNotEmpty) 'companyGodownId': companyGodownId,
    if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    if (isGstBill != null) 'isGstBill': isGstBill,
    if (gstPercentage != null) 'gstPercentage': gstPercentage,
    if (notes != null) 'notes': notes,
    if (narration != null) 'narration': narration,
  };
}
