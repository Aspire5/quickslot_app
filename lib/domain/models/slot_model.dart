import 'venue_model.dart';

class SlotModel {
  final String id;
  final String venueId;
  final DateTime startAt;
  final DateTime endAt;
  final bool isBooked;
  final String? bookingId;
  final String? bookingUserId;
  final VenueModel? venue;

  const SlotModel({
    required this.id,
    required this.venueId,
    required this.startAt,
    required this.endAt,
    required this.isBooked,
    this.bookingId,
    this.bookingUserId,
    this.venue,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>?;
    final isBookedVal = json['isBooked'] as bool? ?? (booking != null);
    
    return SlotModel(
      id: json['id'] as String? ?? '',
      venueId: json['venueId'] as String? ?? '',
      startAt: DateTime.parse(json['startAt'] as String).toLocal() ,
      endAt: DateTime.parse(json['endAt'] as String).toLocal() ,
      isBooked: isBookedVal,
      bookingId: booking?['id'] as String?,
      bookingUserId: booking?['userId'] as String?,
      venue: json['venue'] != null ? VenueModel.fromJson(json['venue'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'isBooked': isBooked,
      if (bookingId != null || bookingUserId != null)
        'booking': {
          'id': bookingId,
          'userId': bookingUserId,
        },
      if (venue != null) 'venue': venue!.toJson(),
    };
  }
}
