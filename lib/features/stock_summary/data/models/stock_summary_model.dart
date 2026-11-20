import 'package:mlf_frontend/features/stock_summary/domain/entities/stock_summary_entity.dart';

class StockSummaryBatchModel extends StockSummaryBatchEntity {
  const StockSummaryBatchModel({
    required super.batchNo,
    required super.godownId,
    required super.godownName,
    super.godownCode,
    required super.particulars,
    required super.quantity,
    required super.rate,
    required super.value,
    required super.formattedQuantity,
    required super.formattedRate,
    required super.formattedValue,
    required super.uom,
  });

  factory StockSummaryBatchModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryBatchModel(
      batchNo: json['batchNo']?.toString() ?? '',
      godownId: json['godownId']?.toString() ?? '',
      godownName: json['godownName']?.toString() ?? 'Godown',
      godownCode: json['godownCode']?.toString(),
      particulars: json['particulars']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      formattedQuantity: json['formattedQuantity']?.toString() ?? '0.000',
      formattedRate: json['formattedRate']?.toString() ?? '0.00',
      formattedValue: json['formattedValue']?.toString() ?? '0.00',
      uom: json['uom']?.toString() ?? 'kg',
    );
  }
}

class StockSummaryItemModel extends StockSummaryItemEntity {
  const StockSummaryItemModel({
    required super.itemId,
    required super.itemName,
    required super.itemCode,
    super.groupId,
    super.groupName,
    required super.uom,
    required super.quantity,
    required super.averageRate,
    required super.totalValue,
    required super.formattedQuantity,
    required super.formattedRate,
    required super.formattedValue,
    required super.batchesCount,
    required super.batches,
  });

  factory StockSummaryItemModel.fromJson(Map<String, dynamic> json) {
    final rawBatches = json['batches'] as List<dynamic>? ?? [];
    final batchesList = rawBatches
        .map<StockSummaryBatchEntity>((b) => StockSummaryBatchModel.fromJson(b as Map<String, dynamic>))
        .toList();

    return StockSummaryItemModel(
      itemId: json['itemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      itemCode: json['itemCode']?.toString() ?? '',
      groupId: json['groupId']?.toString(),
      groupName: json['groupName']?.toString(),
      uom: json['uom']?.toString() ?? 'kg',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      formattedQuantity: json['formattedQuantity']?.toString() ?? '0.000',
      formattedRate: json['formattedRate']?.toString() ?? '0.00',
      formattedValue: json['formattedValue']?.toString() ?? '0.00',
      batchesCount: (json['batchesCount'] as num?)?.toInt() ?? batchesList.length,
      batches: batchesList,
    );
  }
}

class StockSummaryGroupModel extends StockSummaryGroupEntity {
  const StockSummaryGroupModel({
    required super.groupId,
    required super.groupName,
    super.groupCode,
    required super.uom,
    required super.totalQuantity,
    required super.averageRate,
    required super.totalValue,
    required super.formattedQuantity,
    required super.formattedRate,
    required super.formattedValue,
    required super.itemsCount,
    required super.items,
  });

  factory StockSummaryGroupModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map<StockSummaryItemEntity>((i) => StockSummaryItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return StockSummaryGroupModel(
      groupId: json['groupId']?.toString() ?? '',
      groupName: json['groupName']?.toString() ?? '',
      groupCode: json['groupCode']?.toString(),
      uom: json['uom']?.toString() ?? 'kg',
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0.0,
      averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      formattedQuantity: json['formattedQuantity']?.toString() ?? '0.000',
      formattedRate: json['formattedRate']?.toString() ?? '0.00',
      formattedValue: json['formattedValue']?.toString() ?? '0.00',
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? itemsList.length,
      items: itemsList,
    );
  }
}

class StockSummaryGrandTotalModel extends StockSummaryGrandTotalEntity {
  const StockSummaryGrandTotalModel({
    required super.totalQuantity,
    required super.averageRate,
    required super.totalValue,
    required super.formattedQuantity,
    required super.formattedRate,
    required super.formattedValue,
    required super.groupsCount,
    required super.itemsCount,
  });

  factory StockSummaryGrandTotalModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryGrandTotalModel(
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0.0,
      averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      formattedQuantity: json['formattedQuantity']?.toString() ?? '0.000 kg',
      formattedRate: json['formattedRate']?.toString() ?? '0.00',
      formattedValue: json['formattedValue']?.toString() ?? '0.00',
      groupsCount: (json['groupsCount'] as num?)?.toInt() ?? 0,
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockSummaryPeriodModel extends StockSummaryPeriodEntity {
  const StockSummaryPeriodModel({
    super.startDate,
    super.endDate,
    required super.formattedPeriod,
  });

  factory StockSummaryPeriodModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryPeriodModel(
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      formattedPeriod: json['formattedPeriod']?.toString() ?? '',
    );
  }
}

class StockSummaryFilterModel extends StockSummaryFilterEntity {
  const StockSummaryFilterModel({
    super.godownId,
    super.godownName,
  });

  factory StockSummaryFilterModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryFilterModel(
      godownId: json['godownId']?.toString(),
      godownName: json['godownName']?.toString(),
    );
  }
}

class StockSummaryModel extends StockSummaryEntity {
  const StockSummaryModel({
    required super.companyName,
    required super.period,
    required super.godownFilter,
    required super.groups,
    required super.grandTotal,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'] as List<dynamic>? ?? [];
    final groupsList = rawGroups
        .map<StockSummaryGroupEntity>((g) => StockSummaryGroupModel.fromJson(g as Map<String, dynamic>))
        .toList();

    return StockSummaryModel(
      companyName: json['companyName']?.toString() ?? 'ML Fabric',
      period: StockSummaryPeriodModel.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      godownFilter: StockSummaryFilterModel.fromJson(
        (json['godownFilter'] as Map<String, dynamic>?) ?? {},
      ),
      groups: groupsList,
      grandTotal: StockSummaryGrandTotalModel.fromJson(
        (json['grandTotal'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
