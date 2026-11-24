import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/purchase_type_entity.dart';
import '../../domain/entities/sales_type_entity.dart';
import '../../domain/entities/uom_entity.dart';
import '../../domain/entities/per_unit_entity.dart';
import '../../domain/entities/item_group_entity.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/hsn_code_entity.dart';
import '../../domain/entities/masters_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryController extends ChangeNotifier {
  final InventoryRepository repository;

  InventoryController({required this.repository});

  int _selectedSubTab = 0;
  int get selectedSubTab => _selectedSubTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<PartyEntity> _parties = [];
  List<PartyEntity> get parties => _parties;

  List<PurchaseTypeEntity> _purchaseTypes = [];
  List<PurchaseTypeEntity> get purchaseTypes => _purchaseTypes;

  List<SalesTypeEntity> _salesTypes = [];
  List<SalesTypeEntity> get salesTypes => _salesTypes;

  List<ItemGroupEntity> _itemGroups = [];
  List<ItemGroupEntity> get itemGroups => _itemGroups;

  List<UomEntity> _uoms = [];
  List<UomEntity> get uoms => _uoms;

  List<PerUnitEntity> _perUnits = [];
  List<PerUnitEntity> get perUnits => _perUnits;

  List<ItemEntity> _items = [];
  List<ItemEntity> get items => _items;

  List<HsnCodeEntity> _hsnCodes = [];
  List<HsnCodeEntity> get hsnCodes => _hsnCodes;

  List<GodownEntity> _godowns = [];
  List<GodownEntity> get godowns => _godowns;

  MastersEntity _masters = const MastersEntity();
  MastersEntity get masters => _masters;

  void setSubTab(int index) {
    _selectedSubTab = index;
    _searchQuery = '';
    notifyListeners();
    fetchCurrentTabData();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchCurrentTabData();
  }

  Future<void> fetchMasters() async {
    try {
      _masters = await repository.getMasters();
      _parties = _masters.parties;
      _purchaseTypes = _masters.purchaseTypes;
      _salesTypes = _masters.salesTypes;
      _itemGroups = _masters.itemGroups;
      _uoms = _masters.uoms;
      _perUnits = _masters.perUnits;
      _items = _masters.items;
      _godowns = _masters.godowns;
      _hsnCodes = _masters.hsnCodes;
      notifyListeners();
      AppLogger().i('Loaded masters successfully', tag: 'InventoryCtrl');
    } catch (e) {
      AppLogger().e('Failed to load masters: $e', tag: 'InventoryCtrl');
    }
  }

  Future<void> fetchCurrentTabData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (_selectedSubTab) {
        case 0:
          _parties = await repository.getParties(search: _searchQuery);
          break;
        case 1:
          _purchaseTypes = await repository.getPurchaseTypes(search: _searchQuery);
          break;
        case 2:
          _salesTypes = await repository.getSalesTypes(search: _searchQuery);
          break;
        case 3:
          _itemGroups = await repository.getItemGroups(search: _searchQuery);
          break;
        case 4:
          _items = await repository.getItems(search: _searchQuery);
          break;
        case 5:
          _uoms = await repository.getUoms(search: _searchQuery);
          break;
        case 6:
          _perUnits = await repository.getPerUnits(search: _searchQuery);
          break;
        case 7:
          _hsnCodes = await repository.getHsnCodes(search: _searchQuery);
          break;
      }
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error loading inventory tab $_selectedSubTab: $e', tag: 'InventoryCtrl');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Party CRUD
  Future<bool> createParty({
    required String name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool isActive = true,
  }) async {
    try {
      await repository.createParty(
        name: name,
        partyCode: partyCode,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        gstin: gstin,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateParty(String id, {
    String? name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool? isActive,
  }) async {
    try {
      await repository.updateParty(
        id,
        name: name,
        partyCode: partyCode,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        gstin: gstin,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteParty(String id) async {
    try {
      await repository.deleteParty(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Purchase Type CRUD
  Future<bool> createPurchaseType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    try {
      await repository.createPurchaseType(
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePurchaseType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    try {
      await repository.updatePurchaseType(
        id,
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePurchaseType(String id) async {
    try {
      await repository.deletePurchaseType(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sales Type CRUD
  Future<bool> createSalesType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    try {
      await repository.createSalesType(
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSalesType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    try {
      await repository.updateSalesType(
        id,
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSalesType(String id) async {
    try {
      await repository.deleteSalesType(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // UOM CRUD
  Future<bool> createUom({
    required String name,
    required String symbol,
    String? description,
    bool isActive = true,
  }) async {
    try {
      await repository.createUom(
        name: name,
        symbol: symbol,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUom(String id, {
    String? name,
    String? symbol,
    String? description,
    bool? isActive,
  }) async {
    try {
      await repository.updateUom(
        id,
        name: name,
        symbol: symbol,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUom(String id) async {
    try {
      await repository.deleteUom(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Per Unit CRUD
  Future<bool> createPerUnit({
    required String name,
    required String symbol,
    double multiplier = 1.0,
    String? description,
    bool isActive = true,
  }) async {
    try {
      await repository.createPerUnit(
        name: name,
        symbol: symbol,
        multiplier: multiplier,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePerUnit(String id, {
    String? name,
    String? symbol,
    double? multiplier,
    String? description,
    bool? isActive,
  }) async {
    try {
      await repository.updatePerUnit(
        id,
        name: name,
        symbol: symbol,
        multiplier: multiplier,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePerUnit(String id) async {
    try {
      await repository.deletePerUnit(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Item Group CRUD
  Future<bool> createItemGroup({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    try {
      await repository.createItemGroup(
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItemGroup(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    try {
      await repository.updateItemGroup(
        id,
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItemGroup(String id) async {
    try {
      await repository.deleteItemGroup(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Item CRUD
  Future<bool> createItem({
    required String name,
    String? itemCode,
    String? itemGroupId,
    String? description,
    required String defaultUomId,
    required String defaultPerId,
    String? hsnCodeId,
    String? hsnCode,
    double standardRate = 0.0,
    double openingStock = 0.0,
    bool isActive = true,
  }) async {
    try {
      await repository.createItem(
        name: name,
        itemCode: itemCode,
        itemGroupId: itemGroupId,
        description: description,
        defaultUomId: defaultUomId,
        defaultPerId: defaultPerId,
        hsnCodeId: hsnCodeId,
        hsnCode: hsnCode,
        standardRate: standardRate,
        openingStock: openingStock,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(String id, {
    String? name,
    String? itemCode,
    String? itemGroupId,
    String? description,
    String? defaultUomId,
    String? defaultPerId,
    String? hsnCodeId,
    String? hsnCode,
    double? standardRate,
    bool? isActive,
  }) async {
    try {
      await repository.updateItem(
        id,
        name: name,
        itemCode: itemCode,
        itemGroupId: itemGroupId,
        description: description,
        defaultUomId: defaultUomId,
        defaultPerId: defaultPerId,
        hsnCodeId: hsnCodeId,
        hsnCode: hsnCode,
        standardRate: standardRate,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await repository.deleteItem(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // HSN Code CRUD
  Future<bool> createHsnCode({
    required String hsnCode,
    String? description,
    double gstRate = 5.0,
    bool isActive = true,
  }) async {
    try {
      await repository.createHsnCode(
        hsnCode: hsnCode,
        description: description,
        gstRate: gstRate,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHsnCode(String id, {
    String? hsnCode,
    String? description,
    double? gstRate,
    bool? isActive,
  }) async {
    try {
      await repository.updateHsnCode(
        id,
        hsnCode: hsnCode,
        description: description,
        gstRate: gstRate,
        isActive: isActive,
      );
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHsnCode(String id) async {
    try {
      await repository.deleteHsnCode(id);
      await fetchCurrentTabData();
      fetchMasters();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
