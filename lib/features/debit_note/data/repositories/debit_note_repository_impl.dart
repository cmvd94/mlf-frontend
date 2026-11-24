import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/debit_note_entity.dart';
import '../../domain/repositories/debit_note_repository.dart';
import '../datasources/debit_note_remote_data_source.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

class DebitNoteRepositoryImpl implements DebitNoteRepository {
  final DebitNoteRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  DebitNoteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<({List<DebitNoteEntity> debitNotes, int totalCount, int totalPages, int currentPage})> getDebitNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getDebitNotes(
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
  Future<DebitNoteEntity> getDebitNoteById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getDebitNoteById(id, token: token);
  }

  @override
  Future<DebitNoteEntity> createDebitNote(DebitNoteCreateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.createDebitNote(input.toJson(), token: token);
  }

  @override
  Future<DebitNoteEntity> updateDebitNote(String id, DebitNoteUpdateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.updateDebitNote(id, input.toJson(), token: token);
  }

  @override
  Future<void> deleteDebitNote(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteDebitNote(id, token: token);
  }

  @override
  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getAvailableStocks(
      godownId: godownId,
      itemId: itemId,
      search: search,
      token: token,
    );
  }
}
