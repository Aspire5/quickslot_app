import '../models/venue_model.dart';
import '../models/slot_model.dart';

abstract class VenueRepository {
  Future<List<VenueModel>> getVenues();
  Future<List<SlotModel>> getVenueSlots(String venueId, String dateStr);
}
