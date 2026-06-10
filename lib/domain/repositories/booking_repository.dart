import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<BookingModel> createBooking(String slotId);
  Future<void> cancelBooking(String bookingId);
  Future<List<BookingModel>> getUserBookings(String userId, {bool forceRefresh = false});
  Future<List<BookingModel>?> getCachedBookings();
}
