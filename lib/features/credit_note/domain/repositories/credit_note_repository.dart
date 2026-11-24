import '../entities/credit_note_entity.dart';

abstract class CreditNoteRepository {
  Future<({List<CreditNoteEntity> creditNotes, int totalCount, int totalPages, int currentPage})> getCreditNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  });

  Future<CreditNoteEntity> getCreditNoteById(String id);

  Future<CreditNoteEntity> createCreditNote(CreditNoteCreateInput input);

  Future<CreditNoteEntity> updateCreditNote(String id, CreditNoteUpdateInput input);

  Future<void> deleteCreditNote(String id);
}
