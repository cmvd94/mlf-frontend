import 'godown_entity.dart';

class GodownPaginationEntity {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  const GodownPaginationEntity({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });

  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;
}

class GodownListEntity {
  final List<GodownEntity> godowns;
  final GodownPaginationEntity pagination;

  const GodownListEntity({
    required this.godowns,
    required this.pagination,
  });
}
