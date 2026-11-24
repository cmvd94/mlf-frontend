import '../../domain/entities/debit_note_entity.dart';

class DebitNoteItemModel extends DebitNoteItemEntity {
  const DebitNoteItemModel({
    super.id,
    required super.godownStockId,
    required super.itemId,
    required super.itemName,
    super.itemCode,
    required super.godownId,
    super.godownName,
    super.godownCode,
    super.companyGodownId,
    super.companyGodownName,
    super.companyGodownCode,
    super.dcNo,
    super.lotNo,
    required super.uomId,
    required super.uomSymbol,
    required super.uomQuantity,
    required super.actualQuantity,
    required super.billedQuantity,
    super.quantity,
    required super.rate,
    required super.perId,
    required super.perSymbol,
    required super.amount,
  });

  factory DebitNoteItemModel.fromJson(Map<String, dynamic> json) {
    final itemData = json['itemId'];
    final godownData = json['godownId'];
    final companyGodownData = json['companyGodownId'];
    final uomData = json['uomId'];
    final perData = json['perId'];
    final stockData = json['godownStockId'];

    final stockIdStr = stockData is Map
        ? stockData['_id']?.toString() ?? ''
        : stockData?.toString() ?? '';

    final actualQty = json['actualQuantity'] != null
        ? (json['actualQuantity'] as num).toDouble()
        : (json['quantity'] != null ? (json['quantity'] as num).toDouble() : 0.0);

    final billedQty = json['billedQuantity'] != null
        ? (json['billedQuantity'] as num).toDouble()
        : actualQty;

    return DebitNoteItemModel(
      id: json['_id']?.toString(),
      godownStockId: stockIdStr,
      itemId: itemData is Map ? itemData['_id']?.toString() ?? '' : itemData?.toString() ?? '',
      itemName: itemData is Map ? itemData['name']?.toString() ?? '' : '',
      itemCode: itemData is Map ? itemData['itemCode']?.toString() ?? '' : '',
      godownId: godownData is Map ? godownData['_id']?.toString() ?? '' : godownData?.toString() ?? '',
      godownName: godownData is Map ? godownData['name']?.toString() ?? '' : '',
      godownCode: godownData is Map ? godownData['godownId']?.toString() ?? '' : '',
      companyGodownId: companyGodownData is Map ? companyGodownData['_id']?.toString() ?? '' : companyGodownData?.toString(),
      companyGodownName: companyGodownData is Map ? companyGodownData['name']?.toString() ?? '' : '',
      companyGodownCode: companyGodownData is Map ? companyGodownData['godownId']?.toString() ?? '' : '',
      dcNo: json['dcNo']?.toString() ?? (stockData is Map ? stockData['dcNo']?.toString() ?? '' : ''),
      lotNo: json['lotNo']?.toString() ?? (stockData is Map ? stockData['lotNo']?.toString() ?? '' : ''),
      uomId: uomData is Map ? uomData['_id']?.toString() ?? '' : uomData?.toString() ?? '',
      uomSymbol: uomData is Map
          ? uomData['symbol']?.toString() ?? uomData['name']?.toString() ?? ''
          : '',
      uomQuantity: json['uomQuantity'] != null ? (json['uomQuantity'] as num).toDouble() : 1.0,
      actualQuantity: actualQty,
      billedQuantity: billedQty,
      quantity: actualQty,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : 0.0,
      perId: perData is Map ? perData['_id']?.toString() ?? '' : perData?.toString() ?? '',
      perSymbol: perData is Map
          ? perData['symbol']?.toString() ?? perData['name']?.toString() ?? ''
          : '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
    );
  }
}

class DebitNoteModel extends DebitNoteEntity {
  const DebitNoteModel({
    required super.id,
    required super.debitNoteNumber,
    required super.date,
    super.salesTypeId,
    super.salesTypeName,
    super.salesTypeCode,
    required super.partyId,
    required super.partyName,
    super.partyCode,
    super.dcNo,
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
    super.totalQuantity,
    super.notes,
    super.narration,
    super.createdByName,
    super.createdAt,
  });

  factory DebitNoteModel.fromJson(Map<String, dynamic> json) {
    final typeData = json['salesTypeId'];
    final partyData = json['partyId'];
    final companyGodownData = json['companyGodownId'];
    final createdByData = json['createdBy'];

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => DebitNoteItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DebitNoteModel(
      id: json['_id']?.toString() ?? '',
      debitNoteNumber: json['debitNoteNumber']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      salesTypeId: typeData is Map ? typeData['_id']?.toString() ?? '' : typeData?.toString() ?? '',
      salesTypeName: typeData is Map ? typeData['name']?.toString() ?? '' : '',
      salesTypeCode: typeData is Map ? typeData['code']?.toString() ?? '' : '',
      partyId: partyData is Map ? partyData['_id']?.toString() ?? '' : partyData?.toString() ?? '',
      partyName: partyData is Map ? partyData['name']?.toString() ?? '' : '',
      partyCode: partyData is Map ? partyData['partyCode']?.toString() ?? '' : '',
      dcNo: json['dcNo']?.toString() ?? '',
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
          : (json['totalQuantity'] != null ? (json['totalQuantity'] as num).toDouble() : 0.0),
      totalBilledQuantity: json['totalBilledQuantity'] != null
          ? (json['totalBilledQuantity'] as num).toDouble()
          : 0.0,
      totalQuantity: json['totalQuantity'] != null
          ? (json['totalQuantity'] as num).toDouble()
          : (json['totalActualQuantity'] != null ? (json['totalActualQuantity'] as num).toDouble() : 0.0),
      notes: json['notes']?.toString() ?? '',
      narration: json['narration']?.toString() ?? json['notes']?.toString() ?? '',
      createdByName: createdByData is Map
          ? createdByData['name']?.toString() ?? ''
          : createdByData?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
