import '../../domain/entities/credit_note_entity.dart';

class CreditNoteItemModel extends CreditNoteItemEntity {
  const CreditNoteItemModel({
    super.godownStockId,
    required super.itemId,
    required super.itemName,
    super.itemCode,
    super.itemStock,
    required super.godownId,
    super.godownName,
    super.godownCode,
    super.companyGodownId,
    super.companyGodownName,
    super.companyGodownCode,
    super.dcNo,
    super.lotNo,
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

  factory CreditNoteItemModel.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemId'];
    final godownData = json['godownId'];
    final companyGodownData = json['companyGodownId'];
    final uomData = json['uomId'];
    final perData = json['perId'];
    final stockData = json['godownStockId'];

    final stockIdStr = stockData is Map
        ? stockData['_id']?.toString() ?? ''
        : stockData?.toString() ?? '';

    return CreditNoteItemModel(
      godownStockId: stockIdStr.isNotEmpty ? stockIdStr : null,
      itemId: itemData is Map ? itemData['_id']?.toString() ?? '' : itemData?.toString() ?? '',
      itemName: itemData is Map ? itemData['name']?.toString() ?? '' : '',
      itemCode: itemData is Map ? itemData['itemCode']?.toString() ?? '' : '',
      itemStock: itemData is Map ? (itemData['currentStock'] as num?)?.toDouble() ?? 0.0 : 0.0,
      godownId: godownData is Map ? godownData['_id']?.toString() ?? '' : godownData?.toString() ?? '',
      godownName: godownData is Map ? godownData['name']?.toString() ?? '' : '',
      godownCode: godownData is Map ? godownData['godownId']?.toString() ?? '' : '',
      companyGodownId: companyGodownData is Map ? companyGodownData['_id']?.toString() ?? '' : companyGodownData?.toString(),
      companyGodownName: companyGodownData is Map ? companyGodownData['name']?.toString() ?? '' : '',
      companyGodownCode: companyGodownData is Map ? companyGodownData['godownId']?.toString() ?? '' : '',
      dcNo: json['dcNo']?.toString() ?? json['batchNo']?.toString() ?? '',
      lotNo: json['lotNo']?.toString() ?? '',
      batchNo: json['dcNo']?.toString() ?? json['batchNo']?.toString() ?? '',
      uomId: uomData is Map ? uomData['_id']?.toString() ?? '' : uomData?.toString() ?? '',
      uomSymbol: uomData is Map
          ? uomData['symbol']?.toString() ?? uomData['name']?.toString() ?? ''
          : '',
      uomQuantity: json['uomQuantity'] != null ? (json['uomQuantity'] as num).toDouble() : 1.0,
      actualQuantity: json['actualQuantity'] != null ? (json['actualQuantity'] as num).toDouble() : 0.0,
      billedQuantity: json['billedQuantity'] != null ? (json['billedQuantity'] as num).toDouble() : 0.0,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : 0.0,
      perId: perData is Map ? perData['_id']?.toString() ?? '' : perData?.toString() ?? '',
      perSymbol: perData is Map
          ? perData['symbol']?.toString() ?? perData['name']?.toString() ?? ''
          : '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
    );
  }
}

class CreditNoteModel extends CreditNoteEntity {
  const CreditNoteModel({
    required super.id,
    required super.creditNoteNumber,
    required super.date,
    required super.partyId,
    required super.partyName,
    super.partyCode,
    super.purchaseTypeId,
    super.purchaseTypeName,
    super.companyGodownId,
    super.companyGodownName,
    super.companyGodownCode,
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
  });

  factory CreditNoteModel.fromJson(Map<String, dynamic> json) {
    final partyData = json['partyId'];
    final typeData = json['purchaseTypeId'];
    final companyGodownData = json['companyGodownId'];
    final createdByData = json['createdBy'];

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => CreditNoteItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CreditNoteModel(
      id: json['_id']?.toString() ?? '',
      creditNoteNumber: json['creditNoteNumber']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      partyId: partyData is Map ? partyData['_id']?.toString() ?? '' : partyData?.toString() ?? '',
      partyName: partyData is Map ? partyData['name']?.toString() ?? '' : '',
      partyCode: partyData is Map ? partyData['partyCode']?.toString() ?? '' : '',
      purchaseTypeId: typeData is Map ? typeData['_id']?.toString() ?? '' : typeData?.toString() ?? '',
      purchaseTypeName: typeData is Map ? typeData['name']?.toString() ?? '' : '',
      companyGodownId: companyGodownData is Map
          ? companyGodownData['_id']?.toString() ?? ''
          : companyGodownData?.toString() ?? '',
      companyGodownName: companyGodownData is Map ? companyGodownData['name']?.toString() ?? '' : '',
      companyGodownCode: companyGodownData is Map ? companyGodownData['godownId']?.toString() ?? '' : '',
      items: items,
      subTotal: json['subTotal'] != null ? (json['subTotal'] as num).toDouble() : 0.0,
      isGstBill: json['isGstBill'] == true,
      gstPercentage: json['gstPercentage'] != null ? (json['gstPercentage'] as num).toDouble() : 0.0,
      gstAmount: json['gstAmount'] != null ? (json['gstAmount'] as num).toDouble() : 0.0,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : 0.0,
      totalActualQuantity: json['totalActualQuantity'] != null
          ? (json['totalActualQuantity'] as num).toDouble()
          : 0.0,
      totalBilledQuantity: json['totalBilledQuantity'] != null
          ? (json['totalBilledQuantity'] as num).toDouble()
          : 0.0,
      notes: json['notes']?.toString() ?? '',
      createdByName: createdByData is Map
          ? createdByData['name']?.toString() ?? ''
          : createdByData?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
