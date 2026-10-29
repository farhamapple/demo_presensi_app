import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';
import '../models/login_response_model.dart';
import '../models/office_location_model.dart';
import 'storage_service.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.errors,
  });
}

class ApiService {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ??
        'https://demo-presensi.farham.my.id/api/v1';
  }

  static Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static String _extractErrorMessage(
      int statusCode, Map<String, dynamic> responseData) {
    String errorMessage = responseData['message'] as String? ??
        'Terjadi kesalahan (Kode: $statusCode)';

    if (responseData['errors'] is Map<String, dynamic>) {
      final errMap = responseData['errors'] as Map<String, dynamic>;
      final List<String> errorList = [];
      errMap.forEach((_, value) {
        if (value is List) {
          errorList.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          errorList.add(value);
        }
      });
      if (errorList.isNotEmpty) {
        errorMessage = errorList.join('\n');
      }
    }
    return errorMessage;
  }

  // 1. Auth: Login
  static Future<ApiResponse<LoginResponseModel>> login({
    required String identifier,
    required String password,
    String? deviceName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final body = jsonEncode({
        'identifier': identifier,
        'password': password,
        'device_name': deviceName ?? 'Flutter Mobile App',
      });

      final response = await http.post(
        url,
        headers: await _getHeaders(withAuth: false),
        body: body,
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final loginResponse = LoginResponseModel.fromJson(responseData);
        return ApiResponse(
          isSuccess: true,
          data: loginResponse,
          message: loginResponse.message ?? 'Login berhasil',
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: _extractErrorMessage(response.statusCode, responseData),
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal terhubung ke server: $e',
      );
    }
  }

  // 2. Office Locations: GET /office-locations
  static Future<ApiResponse<List<OfficeLocationModel>>> getOfficeLocations() async {
    try {
      final url = Uri.parse('$baseUrl/office-locations');
      final response = await http.get(
        url,
        headers: await _getHeaders(withAuth: true),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final rawList = responseData['data'] as List<dynamic>? ?? [];
        final locations = rawList
            .map((item) =>
                OfficeLocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          isSuccess: true,
          data: locations,
          message: responseData['message'] as String?,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: _extractErrorMessage(response.statusCode, responseData),
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal mengambil data lokasi kantor: $e',
      );
    }
  }

  // 3. Attendance: GET /attendance/today
  static Future<ApiResponse<TodayAttendanceResponse>> getTodayAttendance() async {
    try {
      final url = Uri.parse('$baseUrl/attendance/today');
      final response = await http.get(
        url,
        headers: await _getHeaders(withAuth: true),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final todayData = TodayAttendanceResponse.fromJson(responseData);
        return ApiResponse(
          isSuccess: true,
          data: todayData,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: _extractErrorMessage(response.statusCode, responseData),
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal mengambil status presensi hari ini: $e',
      );
    }
  }

  // 4. Attendance: POST /attendance/check-in
  static Future<ApiResponse<AttendanceRecord>> checkIn({
    required int officeLocationId,
    required double latitude,
    required double longitude,
    String? deviceName,
    String? deviceId,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/attendance/check-in');
      final body = jsonEncode({
        'office_location_id': officeLocationId,
        'latitude': latitude,
        'longitude': longitude,
        'device_name': deviceName ?? 'Flutter Mobile App',
        'device_id': deviceId ?? 'flutter-device-01',
        'notes': notes ?? 'Hadir tepat waktu',
      });

      final response = await http.post(
        url,
        headers: await _getHeaders(withAuth: true),
        body: body,
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final record = responseData['data'] is Map<String, dynamic>
            ? AttendanceRecord.fromJson(
                responseData['data'] as Map<String, dynamic>)
            : null;
        return ApiResponse(
          isSuccess: true,
          data: record,
          message: responseData['message'] as String? ?? 'Presensi masuk berhasil',
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: _extractErrorMessage(response.statusCode, responseData),
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal mengirim presensi masuk: $e',
      );
    }
  }

  // 5. Attendance: POST /attendance/check-out
  static Future<ApiResponse<AttendanceRecord>> checkOut({
    required double latitude,
    required double longitude,
    String? deviceName,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/attendance/check-out');
      final body = jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'device_name': deviceName ?? 'Flutter Mobile App',
        'notes': notes ?? 'Selesai jam kerja harian',
      });

      final response = await http.post(
        url,
        headers: await _getHeaders(withAuth: true),
        body: body,
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final record = responseData['data'] is Map<String, dynamic>
            ? AttendanceRecord.fromJson(
                responseData['data'] as Map<String, dynamic>)
            : null;
        return ApiResponse(
          isSuccess: true,
          data: record,
          message:
              responseData['message'] as String? ?? 'Presensi pulang berhasil',
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: _extractErrorMessage(response.statusCode, responseData),
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal mengirim presensi pulang: $e',
      );
    }
  }
}
