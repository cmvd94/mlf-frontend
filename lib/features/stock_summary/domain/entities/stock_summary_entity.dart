class StockSummaryBatchEntity {
  final String batchNo;
  final String godownId;
  final String godownName;
  final String? godownCode;
  final String particulars;
  final double quantity;
  final double rate;
  final double value;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final String uom;

  const StockSummaryBatchEntity({
    required this.batchNo,
    required this.godownId,
    required this.godownName,
    this.godownCode,
    required this.particulars,
    required this.quantity,
    required this.rate,
    required this.value,
    required this.formattedQuantity,
    required this.formattedRate,
    required this.formattedValue,
    required this.uom,
  });
}

class StockSummaryItemEntity {
  final String itemId;
  final String itemName;
  final String itemCode;
  final String? groupId;
  final String? groupName;
  final String uom;
  final double quantity;
  final double averageRate;
  final double totalValue;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final int batchesCount;
  final List<StockSummaryBatchEntity> batches;

  const StockSummaryItemEntity({
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    this.groupId,
    this.groupName,
    required this.uom,
    required this.quantity,
    required this.averageRate,
    required this.totalValue,
    required this.formattedQuantity,
    required this.formattedRate,
    required this.formattedValue,
    required this.batchesCount,
    required this.batches,
  });
}

class StockSummaryGroupEntity {
  final String groupId;
  final String groupName;
  final String? groupCode;
  final String uom;
  final double totalQuantity;
  final double averageRate;
  final double totalValue;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final int itemsCount;
  final List<StockSummaryItemEntity> items;

  const StockSummaryGroupEntity({
    required this.groupId,
    required this.groupName,
    this.groupCode,
    required this.uom,
    required this.totalQuantity,
    required this.averageRate,
    required this.totalValue,
    required this.formattedQuantity,
    required this.formattedRate,
    required this.formattedValue,
    required this.itemsCount,
    required this.items,
  });
}

class StockSummaryGrandTotalEntity {
  final double totalQuantity;
  final double averageRate;
  final double totalValue;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final int groupsCount;
  final int itemsCount;

  const StockSummaryGrandTotalEntity({
    required this.totalQuantity,
    required this.averageRate,
    required this.totalValue,
    required this.formattedQuantity,
    required this.formattedRate,
    required this.formattedValue,
    required this.groupsCount,
    required this.itemsCount,
  });
}

class StockSummaryPeriodEntity {
  final String? startDate;
  final String? endDate;
  final String formattedPeriod;

  const StockSummaryPeriodEntity({
    this.startDate,
    this.endDate,
    required this.formattedPeriod,
  });
}

class StockSummaryFilterEntity {
  final String? godownId;
  final String? godownName;

  const StockSummaryFilterEntity({
    this.godownId,
    this.godownName,
  });
}

class StockSummaryEntity {
  final String companyName;
  final StockSummaryPeriodEntity period;
  final StockSummaryFilterEntity godownFilter;
  final List<StockSummaryGroupEntity> groups;
  final StockSummaryGrandTotalEntity grandTotal;

  const StockSummaryEntity({
    required this.companyName,
    required this.period,
    required this.godownFilter,
    required this.groups,
    required this.grandTotal,
  });
}
