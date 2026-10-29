import 'attendance_model.dart';

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }
}

class HistoryResponseModel {
  final List<AttendanceRecord> data;
  final PaginationMeta? meta;
  final String? message;

  HistoryResponseModel({
    required this.data,
    this.meta,
    this.message,
  });

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final items = rawList
        .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    return HistoryResponseModel(
      data: items,
      meta: json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

