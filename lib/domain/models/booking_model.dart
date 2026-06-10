import 'slot_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String slotId;
  final DateTime createdAt;
  final SlotModel? slot;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.createdAt,
    this.slot,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      slotId: json['slotId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      slot: json['slot'] != null ? SlotModel.fromJson(json['slot'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'slotId': slotId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      if (slot != null) 'slot': slot!.toJson(),
    };
  }
}
