class StockSummaryBatchEntity {
  final String dcNo;
  final String lotNo;
  String get batchNo => dcNo;
  final String godownId;
  final String godownName;
  final String? godownCode;
  final String? date;
  final String formattedDate;
  final String particulars;
  final double uomQuantity;
  final String formattedUomQuantity;
  final double quantity;
  final double rate;
  final double value;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final String uom;
  final String uomSymbol;
  final String perSymbol;

  const StockSummaryBatchEntity({
    String dcNo = '',
    this.lotNo = '',
    String batchNo = '',
    required this.godownId,
    required this.godownName,
    this.godownCode,
    this.date,
    this.formattedDate = '-',
    required this.particulars,
    this.uomQuantity = 0.0,
    this.formattedUomQuantity = '',
    required this.quantity,
    required this.rate,
    required this.value,
    required this.formattedQuantity,
    required this.formattedRate,
    required this.formattedValue,
    required this.uom,
    this.uomSymbol = '',
    this.perSymbol = '',
  }) : dcNo = dcNo != '' ? dcNo : batchNo;

  String get displayParticulars {
    if (particulars.isNotEmpty) {
      final pLower = particulars.toLowerCase();
      // If particulars already has explicit dc or lot labels, return it as-is
      if (pLower.contains('dc') || pLower.contains('lot')) {
        return particulars;
      }
      // If particulars doesn't have labels (e.g. legacy/unlabelled "godownName 3 3"), format it cleanly:
      final dc = dcNo.trim().isNotEmpty ? dcNo.trim() : (batchNo.trim().isNotEmpty ? batchNo.trim() : '');
      final lot = lotNo.trim();
      final parts = <String>[
        godownName,
        if (dc.isNotEmpty) 'DC No: $dc',
        if (lot.isNotEmpty) 'Lot No: $lot',
      ];
      final joined = parts.where((p) => p.isNotEmpty).join(' ');
      if (joined.isNotEmpty) return joined;
      return particulars;
    }
    final dc = dcNo.trim().isNotEmpty ? dcNo.trim() : (batchNo.trim().isNotEmpty ? batchNo.trim() : '');
    final lot = lotNo.trim();
    final parts = <String>[
      godownName,
      if (dc.isNotEmpty) 'DC No: $dc',
      if (lot.isNotEmpty) 'Lot No: $lot',
    ];
    return parts.where((p) => p.isNotEmpty).join(' ');
  }
}

class StockSummaryItemEntity {
  final String itemId;
  final String itemName;
  final String itemCode;
  final String? groupId;
  final String? groupName;
  final String uom;
  final double uomQuantity;
  final String formattedUomQuantity;
  final String uomSymbol;
  final String perSymbol;
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
    this.uomQuantity = 0.0,
    this.formattedUomQuantity = '',
    this.uomSymbol = '',
    this.perSymbol = '',
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
  final double totalUomQuantity;
  final String formattedUomQuantity;
  final String uomSymbol;
  final String perSymbol;
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
    this.totalUomQuantity = 0.0,
    this.formattedUomQuantity = '',
    this.uomSymbol = '',
    this.perSymbol = '',
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
  final double totalUomQuantity;
  final String formattedUomQuantity;
  final double averageRate;
  final double totalValue;
  final String formattedQuantity;
  final String formattedRate;
  final String formattedValue;
  final int groupsCount;
  final int itemsCount;

  const StockSummaryGrandTotalEntity({
    required this.totalQuantity,
    this.totalUomQuantity = 0.0,
    this.formattedUomQuantity = '',
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
