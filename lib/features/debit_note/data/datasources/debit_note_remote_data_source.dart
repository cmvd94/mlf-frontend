import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/debit_note_model.dart';
import '../../../stock_transfer/data/models/available_stock_model.dart';

abstract class DebitNoteRemoteDataSource {
  Future<({List<DebitNoteModel> debitNotes, int totalCount, int totalPages, int currentPage})> getDebitNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  });

  Future<DebitNoteModel> getDebitNoteById(String id, {String? token});

  Future<DebitNoteModel> createDebitNote(Map<String, dynamic> body, {String? token});

  Future<DebitNoteModel> updateDebitNote(String id, Map<String, dynamic> body, {String? token});

  Future<void> deleteDebitNote(String id, {String? token});

  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? token,
  });
}

class DebitNoteRemoteDataSourceImpl implements DebitNoteRemoteDataSource {
  final ApiClient apiClient;

  DebitNoteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<DebitNoteModel> debitNotes, int totalCount, int totalPages, int currentPage})> getDebitNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
    };

    final response = await apiClient.get(
      ApiEndpoints.getDebitNoteList,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final list = (data['debitNotes'] as List<dynamic>? ?? [])
        .map((e) => DebitNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final totalCount = (pagination['totalCount'] as num?)?.toInt() ?? list.length;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    final currentPage = (pagination['currentPage'] as num?)?.toInt() ?? page;

    return (
      debitNotes: list,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  Future<DebitNoteModel> getDebitNoteById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getDebitNoteById(id),
      token: token,
    );
    return DebitNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<DebitNoteModel> createDebitNote(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createDebitNote,
      body: body,
      token: token,
    );
    return DebitNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<DebitNoteModel> updateDebitNote(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(
      ApiEndpoints.updateDebitNote(id),
      body: body,
      token: token,
    );
    return DebitNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDebitNote(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteDebitNote(id),
      token: token,
    );
  }

  @override
  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (itemId != null && itemId.isNotEmpty) 'itemId': itemId,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await apiClient.get(
      ApiEndpoints.availableStockForDebitNote,
      queryParams: queryParams,
      token: token,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList.map((e) => AvailableStockModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
