import '../../domain/entities/available_stock_entity.dart';

class AvailableStockModel extends AvailableStockEntity {
  const AvailableStockModel({
    required super.godownStockId,
    required super.godownId,
    required super.godownName,
    super.godownCode,
    super.companyGodownId,
    super.companyGodownName,
    super.companyGodownCode,
    required super.itemId,
    required super.itemName,
    super.itemCode,
    super.dcNo,
    super.lotNo,
    super.batchNo,
    required super.currentStock,
    super.rate,
    super.amount,
    super.uomId,
    super.uomName,
    super.uomSymbol,
    super.uomQuantity,
    super.perId,
    super.perName,
    super.perSymbol,
    super.perMultiplier,
  });

  factory AvailableStockModel.fromJson(Map<String, dynamic> json) {
    final godownData = json['godownId'];
    final companyGodownData = json['companyGodownId'];
    final itemData = json['itemId'];
    final uomData = json['uomId'];
    final perData = json['perId'];

    final godownIdStr = godownData is Map
        ? (godownData['_id']?.toString() ?? '')
        : (json['godownId'] ?? '').toString();
    final godownNameStr = json['godownName'] != null
        ? json['godownName'].toString()
        : (godownData is Map ? (godownData['name']?.toString() ?? 'Unknown Godown') : 'Unknown Godown');
    final godownCodeStr = json['godownCode'] != null
        ? json['godownCode'].toString()
        : (godownData is Map ? (godownData['godownId']?.toString() ?? godownData['code']?.toString() ?? '') : '');

    final companyGodownIdStr = companyGodownData is Map
        ? (companyGodownData['_id']?.toString() ?? '')
        : (json['companyGodownId'] ?? '').toString();
    final companyGodownNameStr = json['companyGodownName'] != null
        ? json['companyGodownName'].toString()
        : (companyGodownData is Map ? (companyGodownData['name']?.toString() ?? '') : '');
    final companyGodownCodeStr = json['companyGodownCode'] != null
        ? json['companyGodownCode'].toString()
        : (companyGodownData is Map ? (companyGodownData['godownId']?.toString() ?? '') : '');

    final itemIdStr = itemData is Map
        ? (itemData['_id']?.toString() ?? '')
        : (json['itemId'] ?? '').toString();
    final itemNameStr = json['itemName'] != null
        ? json['itemName'].toString()
        : (itemData is Map ? (itemData['name']?.toString() ?? 'Unknown Item') : 'Unknown Item');
    final itemCodeStr = json['itemCode'] != null
        ? json['itemCode'].toString()
        : (itemData is Map ? (itemData['itemCode']?.toString() ?? '') : '');

    final uomIdStr = uomData is Map
        ? (uomData['_id']?.toString() ?? '')
        : (json['uomId'] ?? '').toString();
    final uomNameStr = json['uomName'] != null
        ? json['uomName'].toString()
        : (uomData is Map ? (uomData['name']?.toString() ?? '') : '');
    final uomSymbolStr = json['uomSymbol'] != null
        ? json['uomSymbol'].toString()
        : (uomData is Map ? (uomData['symbol']?.toString() ?? uomData['name']?.toString() ?? '') : '');

    final perIdStr = perData is Map
        ? (perData['_id']?.toString() ?? '')
        : (json['perId'] ?? '').toString();
    final perNameStr = json['perName'] != null
        ? json['perName'].toString()
        : (perData is Map ? (perData['name']?.toString() ?? '') : '');
    final perSymbolStr = json['perSymbol'] != null
        ? json['perSymbol'].toString()
        : (perData is Map ? (perData['symbol']?.toString() ?? perData['name']?.toString() ?? '') : '');
    final perMultiplierVal = (json['perMultiplier'] as num?)?.toDouble() ??
        (perData is Map && perData['multiplier'] != null
            ? (perData['multiplier'] as num).toDouble()
            : 1.0);

    return AvailableStockModel(
      godownStockId: (json['godownStockId'] ?? json['_id'] ?? '').toString(),
      godownId: godownIdStr,
      godownName: godownNameStr,
      godownCode: godownCodeStr,
      companyGodownId: companyGodownIdStr,
      companyGodownName: companyGodownNameStr,
      companyGodownCode: companyGodownCodeStr,
      itemId: itemIdStr,
      itemName: itemNameStr,
      itemCode: itemCodeStr,
      dcNo: (json['dcNo'] ?? json['batchNo'] ?? '').toString(),
      lotNo: (json['lotNo'] ?? '').toString(),
      batchNo: (json['dcNo'] ?? json['batchNo'] ?? '').toString(),
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      uomId: uomIdStr,
      uomName: uomNameStr,
      uomSymbol: uomSymbolStr,
      uomQuantity: (json['uomQuantity'] as num?)?.toDouble() ?? 1.0,
      perId: perIdStr,
      perName: perNameStr,
      perSymbol: perSymbolStr,
      perMultiplier: perMultiplierVal,
    );
  }
}
