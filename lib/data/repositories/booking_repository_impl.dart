import '../../domain/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/network/dio_client.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  BookingRepositoryImpl(this._apiService, this._storageService);

  @override
  Future<BookingModel> createBooking(String slotId) async {
    try {
      final response = await _apiService.createBooking(slotId);
      final responseData = response.data;
      if (responseData != null && responseData['success'] == true) {
        return BookingModel.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(responseData?['message'] ?? 'Failed to book slot');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        throw Exception('CONFLICT: Slot has already been booked by another user.');
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final response = await _apiService.cancelBooking(bookingId);
    final responseData = response.data;
    if (responseData == null || responseData['success'] != true) {
      throw Exception(responseData?['message'] ?? 'Failed to cancel booking');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await getCachedBookings();
      if (cached != null) {
        // Run refresh in background to update cache, but return cached immediately
        _refreshBookingsInBackground(userId);
        return cached;
      }
    }

    final response = await _apiService.getUserBookings(userId);
    final responseData = response.data;
    if (responseData != null && responseData['success'] == true) {
      final list = responseData['data'] as List<dynamic>;
      
      // Save to cache
      await _storageService.saveBookingsCache(list);

      return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(responseData?['message'] ?? 'Failed to load bookings');
    }
  }

  Future<void> _refreshBookingsInBackground(String userId) async {
    try {
      final response = await _apiService.getUserBookings(userId);
      final responseData = response.data;
      if (responseData != null && responseData['success'] == true) {
        final list = responseData['data'] as List<dynamic>;
        await _storageService.saveBookingsCache(list);
      }
    } catch (_) {
      // Silently ignore background refresh errors
    }
  }

  @override
  Future<List<BookingModel>?> getCachedBookings() async {
    final list = _storageService.getBookingsCache();
    if (list != null) {
      return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return null;
  }
}
