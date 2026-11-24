import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/credit_note_model.dart';

abstract class CreditNoteRemoteDataSource {
  Future<({List<CreditNoteModel> creditNotes, int totalCount, int totalPages, int currentPage})> getCreditNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  });

  Future<CreditNoteModel> getCreditNoteById(String id, {String? token});

  Future<CreditNoteModel> createCreditNote(Map<String, dynamic> body, {String? token});

  Future<CreditNoteModel> updateCreditNote(String id, Map<String, dynamic> body, {String? token});

  Future<void> deleteCreditNote(String id, {String? token});
}

class CreditNoteRemoteDataSourceImpl implements CreditNoteRemoteDataSource {
  final ApiClient apiClient;

  CreditNoteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<CreditNoteModel> creditNotes, int totalCount, int totalPages, int currentPage})> getCreditNotes({
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
      ApiEndpoints.getCreditNoteList,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final list = (data['creditNotes'] as List<dynamic>? ?? [])
        .map((e) => CreditNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final totalCount = (pagination['totalCount'] as num?)?.toInt() ?? list.length;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    final currentPage = (pagination['currentPage'] as num?)?.toInt() ?? page;

    return (
      creditNotes: list,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  Future<CreditNoteModel> getCreditNoteById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getCreditNoteById(id),
      token: token,
    );
    return CreditNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<CreditNoteModel> createCreditNote(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createCreditNote,
      body: body,
      token: token,
    );
    return CreditNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<CreditNoteModel> updateCreditNote(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(
      ApiEndpoints.updateCreditNote(id),
      body: body,
      token: token,
    );
    return CreditNoteModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCreditNote(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteCreditNote(id),
      token: token,
    );
  }
}
