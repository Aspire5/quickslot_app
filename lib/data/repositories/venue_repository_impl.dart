import '../../domain/models/venue_model.dart';
import '../../domain/models/slot_model.dart';
import '../../domain/repositories/venue_repository.dart';
import '../services/api_service.dart';

class VenueRepositoryImpl implements VenueRepository {
  final ApiService _apiService;

  VenueRepositoryImpl(this._apiService);

  @override
  Future<List<VenueModel>> getVenues() async {
    final response = await _apiService.getVenues();
    final responseData = response.data;
    if (responseData != null && responseData['success'] == true) {
      final list = responseData['data'] as List<dynamic>;
      return list.map((item) => VenueModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(responseData?['message'] ?? 'Failed to load venues');
    }
  }

  @override
  Future<List<SlotModel>> getVenueSlots(String venueId, String dateStr) async {
    final response = await _apiService.getVenueSlots(venueId, dateStr);
    final responseData = response.data;
    if (responseData != null && responseData['success'] == true) {
      final data = responseData['data'] as Map<String, dynamic>;
      final list = data['slots'] as List<dynamic>;
      return list.map((item) => SlotModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(responseData?['message'] ?? 'Failed to load slots');
    }
  }
}
