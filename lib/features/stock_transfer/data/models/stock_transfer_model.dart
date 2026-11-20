import '../../domain/entities/stock_transfer_entity.dart';

class StockTransferSourceItemModel extends StockTransferSourceItemEntity {
  const StockTransferSourceItemModel({
    required super.godownStockId,
    required super.itemId,
    super.itemName,
    super.itemCode,
    required super.godownId,
    super.godownName,
    super.batchNo,
    required super.quantity,
    super.rate,
    super.amount,
    super.uomId,
    super.uomSymbol,
    super.uomQuantity,
  });

  factory StockTransferSourceItemModel.fromJson(Map<String, dynamic> json) {
    final itemObj = json['itemId'] is Map ? json['itemId'] as Map<String, dynamic> : null;
    final godownObj = json['godownId'] is Map ? json['godownId'] as Map<String, dynamic> : null;
    final uomObj = json['uomId'] is Map ? json['uomId'] as Map<String, dynamic> : null;

    final itemIdStr = (itemObj != null ? itemObj['_id'] : json['itemId'])?.toString() ?? '';
    final godownIdStr = (godownObj != null ? godownObj['_id'] : json['godownId'])?.toString() ?? '';
    final uomIdStr = (uomObj != null ? uomObj['_id'] : json['uomId'])?.toString() ?? '';

    return StockTransferSourceItemModel(
      godownStockId: (json['godownStockId'] ?? '').toString(),
      itemId: itemIdStr,
      itemName: (itemObj?['name'] ?? json['itemName'] ?? 'Item').toString(),
      itemCode: (itemObj?['itemCode'] ?? json['itemCode'] ?? '').toString(),
      godownId: godownIdStr,
      godownName: (godownObj?['name'] ?? json['godownName'] ?? 'Godown').toString(),
      batchNo: (json['batchNo'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      uomId: uomIdStr,
      uomSymbol: (uomObj?['symbol'] ?? json['uomSymbol'] ?? '').toString(),
      uomQuantity: (json['uomQuantity'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class StockTransferDestinationItemModel extends StockTransferDestinationItemEntity {
  const StockTransferDestinationItemModel({
    required super.itemId,
    super.itemName,
    super.itemCode,
    required super.godownId,
    super.godownName,
    required super.batchNo,
    required super.quantity,
    super.rate,
    super.amount,
    super.uomId,
    super.uomSymbol,
    super.uomQuantity,
    super.destinationGodownStockId,
  });

  factory StockTransferDestinationItemModel.fromJson(Map<String, dynamic> json) {
    final itemObj = json['itemId'] is Map ? json['itemId'] as Map<String, dynamic> : null;
    final godownObj = json['godownId'] is Map ? json['godownId'] as Map<String, dynamic> : null;
    final uomObj = json['uomId'] is Map ? json['uomId'] as Map<String, dynamic> : null;

    final itemIdStr = (itemObj != null ? itemObj['_id'] : json['itemId'])?.toString() ?? '';
    final godownIdStr = (godownObj != null ? godownObj['_id'] : json['godownId'])?.toString() ?? '';
    final uomIdStr = (uomObj != null ? uomObj['_id'] : json['uomId'])?.toString() ?? '';

    return StockTransferDestinationItemModel(
      itemId: itemIdStr,
      itemName: (itemObj?['name'] ?? json['itemName'] ?? 'Item').toString(),
      itemCode: (itemObj?['itemCode'] ?? json['itemCode'] ?? '').toString(),
      godownId: godownIdStr,
      godownName: (godownObj?['name'] ?? json['godownName'] ?? 'Godown').toString(),
      batchNo: (json['batchNo'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      uomId: uomIdStr,
      uomSymbol: (uomObj?['symbol'] ?? json['uomSymbol'] ?? '').toString(),
      uomQuantity: (json['uomQuantity'] as num?)?.toDouble() ?? 1.0,
      destinationGodownStockId: json['destinationGodownStockId']?.toString(),
    );
  }
}

class StockTransferModel extends StockTransferEntity {
  const StockTransferModel({
    required super.id,
    required super.transferNumber,
    required super.date,
    required super.sourceItems,
    required super.destinationItems,
    super.totalSourceQuantity,
    super.totalSourceAmount,
    super.totalDestinationQuantity,
    super.totalDestinationAmount,
    super.narration,
    super.createdByName,
    super.createdAt,
  });

  factory StockTransferModel.fromJson(Map<String, dynamic> json) {
    final srcList = (json['sourceItems'] as List?)
            ?.map((e) => StockTransferSourceItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final destList = (json['destinationItems'] as List?)
            ?.map((e) => StockTransferDestinationItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime parsedDate;
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final createdByObj = json['createdBy'] is Map ? json['createdBy'] as Map<String, dynamic> : null;
    final createdByName = createdByObj?['name']?.toString() ?? '';

    return StockTransferModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      transferNumber: (json['transferNumber'] ?? '').toString(),
      date: parsedDate,
      sourceItems: srcList,
      destinationItems: destList,
      totalSourceQuantity: (json['totalSourceQuantity'] as num?)?.toDouble() ?? 0.0,
      totalSourceAmount: (json['totalSourceAmount'] as num?)?.toDouble() ?? 0.0,
      totalDestinationQuantity: (json['totalDestinationQuantity'] as num?)?.toDouble() ?? 0.0,
      totalDestinationAmount: (json['totalDestinationAmount'] as num?)?.toDouble() ?? 0.0,
      narration: (json['narration'] ?? '').toString(),
      createdByName: createdByName,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
