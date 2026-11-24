import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/credit_note_entity.dart';
import '../../domain/repositories/credit_note_repository.dart';
import '../datasources/credit_note_remote_data_source.dart';

class CreditNoteRepositoryImpl implements CreditNoteRepository {
  final CreditNoteRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  CreditNoteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<({List<CreditNoteEntity> creditNotes, int totalCount, int totalPages, int currentPage})> getCreditNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getCreditNotes(
      page: page,
      limit: limit,
      search: search,
      partyId: partyId,
      godownId: godownId,
      fromDate: fromDate,
      toDate: toDate,
      token: token,
    );
  }

  @override
  Future<CreditNoteEntity> getCreditNoteById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getCreditNoteById(id, token: token);
  }

  @override
  Future<CreditNoteEntity> createCreditNote(CreditNoteCreateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.createCreditNote(input.toJson(), token: token);
  }

  @override
  Future<CreditNoteEntity> updateCreditNote(String id, CreditNoteUpdateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.updateCreditNote(id, input.toJson(), token: token);
  }

  @override
  Future<void> deleteCreditNote(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteCreditNote(id, token: token);
  }
}
