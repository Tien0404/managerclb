import 'dart:convert';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/join_request_model.dart';
import 'package:http/http.dart' as http;
import 'ApiService.dart';
import 'package:flutter/foundation.dart';

class JoinRequestService {
  // Lấy tất cả join requests theo club_id
  Future<List<JoinRequest>> getClubRequests(int clubId) async {
    try {
      final url = ApiService.getUrl('/join-requests/club/$clubId');
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => JoinRequest.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load club requests: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getClubRequests: $e');
      }
      rethrow;
    }
  }

  // Lấy tất cả join requests theo event_id
  Future<List<JoinRequest>> getEventRequests(int eventId) async {
    try {
      final url = ApiService.getUrl('/join-requests/event/$eventId');
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => JoinRequest.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load event requests: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getEventRequests: $e');
      }
      rethrow;
    }
  }

  // Lấy tất cả join requests của một user
  Future<List<JoinRequest>> getUserRequests(int userId) async {
    try {
      final url = ApiService.getUrl('/join-requests/user/$userId');
      print('DEBUG getUserRequests URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      print('DEBUG getUserRequests Response status: ${response.statusCode}');
      print('DEBUG getUserRequests Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Xử lý từng phần tử để tránh lỗi khi parse
        List<JoinRequest> requests = [];
        for (var item in data) {
          try {
            requests.add(JoinRequest.fromJson(item));
          } catch (e) {
            print('Error parsing request: $e for data: $item');
            // Bỏ qua phần tử lỗi
          }
        }

        return requests;
      } else {
        print('Failed to load user requests: ${response.reasonPhrase}');
        return []; // Trả về danh sách rỗng thay vì throw exception
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getUserRequests: $e');
      }
      return []; // Trả về danh sách rỗng thay vì throw exception
    }
  }

  // Tạo yêu cầu tham gia mới
  Future<Map<String, dynamic>> createJoinRequest({
    required int userId,
    required String type,
    int? clubId,
    int? eventId,
    String? message,
    String status = 'request',
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'user_id': userId,
        'type': type,
        'message': message,
        'status': status,
      };

      if (type == 'club') {
        requestData['club_id'] = clubId;
      } else {
        requestData['event_id'] = eventId;
      }

      final url = ApiService.getUrl('/join-requests');

      // Log request để debug
      print('Creating join request with data: ${jsonEncode(requestData)}');

      final result = await ApiService.post(
        url,
        body: requestData,
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error in createJoinRequest: $e');
      }
      rethrow;
    }
  }

  // Lấy chi tiết một join request
  Future<JoinRequest> getJoinRequest(int id) async {
    try {
      final url = ApiService.getUrl('/join-requests/$id');
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return JoinRequest.fromJson(data);
      } else {
        throw Exception(
            'Failed to load join request: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getJoinRequest: $e');
      }
      rethrow;
    }
  }

  // Cập nhật trạng thái yêu cầu
  Future<Map<String, dynamic>> updateJoinRequest(
    int id, {
    required String status,
    String? responseMessage,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status,
      };

      if (responseMessage != null) {
        updateData['response_message'] = responseMessage;
      }

      final url = ApiService.getUrl('/join-requests/$id');
      final result = await ApiService.patch(
        url,
        body: updateData,
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateJoinRequest: $e');
      }
      rethrow;
    }
  }

  // Xóa một join request
  Future<bool> deleteJoinRequest(int id) async {
    try {
      final url = ApiService.getUrl('/join-requests/$id');
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete join request: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in deleteJoinRequest: $e');
      }
      rethrow;
    }
  }

  // Kiểm tra trạng thái tham gia club
  Future<Map<String, dynamic>> checkClubStatus(int userId, int clubId) async {
    try {
      final url =
          ApiService.getUrl('/join-requests/check-club/$userId/$clubId');
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to check club status: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in checkClubStatus: $e');
      }
      rethrow;
    }
  }

  // Kiểm tra trạng thái tham gia event
  Future<Map<String, dynamic>> checkEventStatus(int userId, int eventId) async {
    try {
      final url =
          ApiService.getUrl('/join-requests/check-event/$userId/$eventId');
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to check event status: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in checkEventStatus: $e');
      }
      rethrow;
    }
  }

  // Lấy danh sách các câu lạc bộ mà người dùng đã tham gia
  Future<List<Club>> getUserClubs(int userId) async {
    try {
      final url = ApiService.getUrl('/join-requests/user/$userId/clubs');
      print('DEBUG getUserClubs URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      print('DEBUG getUserClubs Response status: ${response.statusCode}');
      print('DEBUG getUserClubs Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Xử lý từng phần tử để tránh lỗi khi parse
        List<Club> clubs = [];
        for (var item in data) {
          try {
            clubs.add(Club.fromJson(item));
          } catch (e) {
            print('Error parsing club: $e for data: $item');
            // Bỏ qua phần tử lỗi
          }
        }

        return clubs;
      } else {
        print('Failed to load user clubs: ${response.reasonPhrase}');
        return []; // Trả về danh sách rỗng thay vì throw exception
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getUserClubs: $e');
      }
      return []; // Trả về danh sách rỗng thay vì throw exception
    }
  }

  // Lấy danh sách các sự kiện mà người dùng đã đăng ký tham gia
  Future<List<Event>> getUserEvents(int userId) async {
    try {
      final url = ApiService.getUrl('/join-requests/user/$userId/events');
      print('DEBUG getUserEvents URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.defaultHeaders,
      );

      print('DEBUG getUserEvents Response status: ${response.statusCode}');
      print('DEBUG getUserEvents Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Xử lý từng phần tử để tránh lỗi khi parse
        List<Event> events = [];
        for (var item in data) {
          try {
            events.add(Event.fromJson(item));
          } catch (e) {
            print('Error parsing event: $e for data: $item');
            // Bỏ qua phần tử lỗi
          }
        }

        return events;
      } else {
        print('Failed to load user events: ${response.reasonPhrase}');
        return []; // Trả về danh sách rỗng thay vì throw exception
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getUserEvents: $e');
      }
      return []; // Trả về danh sách rỗng thay vì throw exception
    }
  }
}
