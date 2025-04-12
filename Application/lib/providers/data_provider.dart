import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/repositories/club_repository.dart';
import 'dart:developer' as developer;

class DataProvider with ChangeNotifier {
  final ClubRepository _clubRepository = ClubRepository();
  Timer? _refreshTimer;
  List<Map<String, dynamic>> _clubs = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DataProvider() {
    startAutoRefresh();
  }

  void startAutoRefresh() {
    // Fetch immediately
    fetchClubs();

    // Then set up timer for periodic fetches
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchClubs();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> fetchClubs() async {
    try {
      _isLoading = true;
      notifyListeners();

      developer.log('Fetching clubs from server...', name: 'DataProvider');
      final clubs = await _clubRepository.getClubs(forceRefresh: true);

      _clubs = clubs;
      _error = null;
    } catch (e) {
      developer.log('Error fetching clubs: $e', name: 'DataProvider');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
