class StockTransferSourceItemEntity {
  final String godownStockId;
  final String itemId;
  final String itemName;
  final String itemCode;
  final String godownId;
  final String godownName;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final String batchNo;
  final double quantity;
  final double rate;
  final double amount;
  final String uomId;
  final String uomSymbol;
  final double uomQuantity;

  const StockTransferSourceItemEntity({
    required this.godownStockId,
    required this.itemId,
    this.itemName = '',
    this.itemCode = '',
    required this.godownId,
    this.godownName = '',
    this.companyGodownId = '',
    this.companyGodownName = '',
    this.companyGodownCode = '',
    this.batchNo = '',
    required this.quantity,
    this.rate = 0.0,
    this.amount = 0.0,
    this.uomId = '',
    this.uomSymbol = '',
    this.uomQuantity = 1.0,
  });
}

class StockTransferDestinationItemEntity {
  final String itemId;
  final String itemName;
  final String itemCode;
  final String godownId;
  final String godownName;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final String batchNo;
  final double quantity;
  final double rate;
  final double amount;
  final String uomId;
  final String uomSymbol;
  final double uomQuantity;
  final String? destinationGodownStockId;

  const StockTransferDestinationItemEntity({
    required this.itemId,
    this.itemName = '',
    this.itemCode = '',
    required this.godownId,
    this.godownName = '',
    this.companyGodownId = '',
    this.companyGodownName = '',
    this.companyGodownCode = '',
    required this.batchNo,
    required this.quantity,
    this.rate = 0.0,
    this.amount = 0.0,
    this.uomId = '',
    this.uomSymbol = '',
    this.uomQuantity = 1.0,
    this.destinationGodownStockId,
  });
}

class StockTransferEntity {
  final String id;
  final String transferNumber;
  final DateTime date;
  final List<StockTransferSourceItemEntity> sourceItems;
  final List<StockTransferDestinationItemEntity> destinationItems;
  final double totalSourceQuantity;
  final double totalSourceAmount;
  final double totalDestinationQuantity;
  final double totalDestinationAmount;
  final String narration;
  final String createdByName;
  final DateTime? createdAt;

  const StockTransferEntity({
    required this.id,
    required this.transferNumber,
    required this.date,
    required this.sourceItems,
    required this.destinationItems,
    this.totalSourceQuantity = 0.0,
    this.totalSourceAmount = 0.0,
    this.totalDestinationQuantity = 0.0,
    this.totalDestinationAmount = 0.0,
    this.narration = '',
    this.createdByName = '',
    this.createdAt,
  });
}

class StockTransferPaginationEntity {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  const StockTransferPaginationEntity({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.limit = 20,
  });
}

class StockTransferListResultEntity {
  final List<StockTransferEntity> transfers;
  final StockTransferPaginationEntity pagination;

  const StockTransferListResultEntity({
    required this.transfers,
    required this.pagination,
  });
}

class CreateStockTransferSourceInput {
  final String godownStockId;
  final String? uomId;
  final double? uomQuantity;
  final double quantity;
  final double? rate;

  const CreateStockTransferSourceInput({
    required this.godownStockId,
    this.uomId,
    this.uomQuantity,
    required this.quantity,
    this.rate,
  });

  Map<String, dynamic> toJson() => {
        'godownStockId': godownStockId,
        if (uomId != null) 'uomId': uomId,
        if (uomQuantity != null) 'uomQuantity': uomQuantity,
        'quantity': quantity,
        if (rate != null) 'rate': rate,
      };
}

class CreateStockTransferDestinationInput {
  final String itemId;
  final String godownId;
  final String batchNo;
  final String? uomId;
  final double? uomQuantity;
  final double quantity;
  final double? rate;
  final String? perId;

  const CreateStockTransferDestinationInput({
    required this.itemId,
    required this.godownId,
    required this.batchNo,
    this.uomId,
    this.uomQuantity,
    required this.quantity,
    this.rate,
    this.perId,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'godownId': godownId,
        'batchNo': batchNo,
        if (uomId != null) 'uomId': uomId,
        if (uomQuantity != null) 'uomQuantity': uomQuantity,
        'quantity': quantity,
        if (rate != null) 'rate': rate,
        if (perId != null) 'perId': perId,
      };
}
