import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  // Authentication
  Future<Response> login(String username, String password) async {
    return await _dioClient.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  // Venues
  Future<Response> getVenues() async {
    return await _dioClient.get(ApiEndpoints.venues);
  }

  // Slots
  Future<Response> getVenueSlots(String venueId, String dateStr) async {
    return await _dioClient.get(
      '${ApiEndpoints.venues}/$venueId/slots',
      queryParameters: {'date': dateStr},
    );
  }

  // Bookings
  Future<Response> createBooking(String slotId) async {
    return await _dioClient.post(
      ApiEndpoints.bookings,
      data: {'slotId': slotId},
    );
  }

  Future<Response> cancelBooking(String bookingId) async {
    return await _dioClient.dio.delete('${ApiEndpoints.bookings}/$bookingId');
  }

  Future<Response> getUserBookings(String userId) async {
    return await _dioClient.get('${ApiEndpoints.users}/$userId/bookings');
  }

  Future<Response> getUserProfile(String userId) async {
    return await _dioClient.get('${ApiEndpoints.users}/$userId');
  }
}
