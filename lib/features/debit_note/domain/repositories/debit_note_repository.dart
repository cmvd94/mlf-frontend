import '../entities/debit_note_entity.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

abstract class DebitNoteRepository {
  Future<({List<DebitNoteEntity> debitNotes, int totalCount, int totalPages, int currentPage})> getDebitNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  });

  Future<DebitNoteEntity> getDebitNoteById(String id);

  Future<DebitNoteEntity> createDebitNote(DebitNoteCreateInput input);

  Future<DebitNoteEntity> updateDebitNote(String id, DebitNoteUpdateInput input);

  Future<void> deleteDebitNote(String id);

  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  });
}
