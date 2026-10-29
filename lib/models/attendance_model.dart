class AttendanceStatus {
  final String value;
  final String label;
  final String color;

  AttendanceStatus({
    required this.value,
    required this.label,
    required this.color,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      color: json['color'] as String? ?? 'info',
    );
  }
}

class AttendanceRecord {
  final int? id;
  final String? date;
  final String? checkInAt;
  final String? checkOutAt;
  final double? distanceMeters;
  final AttendanceStatus? status;
  final String? notes;

  AttendanceRecord({
    this.id,
    this.date,
    this.checkInAt,
    this.checkOutAt,
    this.distanceMeters,
    this.status,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int?,
      date: json['date'] as String?,
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      status: json['status'] is Map<String, dynamic>
          ? AttendanceStatus.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

class TodayAttendanceResponse {
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final AttendanceRecord? data;

  TodayAttendanceResponse({
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    this.data,
  });

  factory TodayAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceResponse(
      hasCheckedIn: json['has_checked_in'] as bool? ?? false,
      hasCheckedOut: json['has_checked_out'] as bool? ?? false,
      data: json['data'] is Map<String, dynamic>
          ? AttendanceRecord.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

