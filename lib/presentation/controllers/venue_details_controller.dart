import 'dart:async';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/models/slot_model.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../shared/dialogs/custom_dialog.dart';
import '../../core/network/dio_client.dart';
import 'dashboard_controller.dart';

class VenueDetailsController extends GetxController {
  final VenueRepository _venueRepository;
  final BookingRepository _bookingRepository;

  VenueDetailsController(this._venueRepository, this._bookingRepository);

  final Rxn<VenueModel> venue = Rxn<VenueModel>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  final RxList<SlotModel> slots = <SlotModel>[].obs;
  final RxMap<String, Rx<SlotModel>> slotRxMap = <String, Rx<SlotModel>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isBooking = false.obs;
  final RxnString errorMessage = RxnString();
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    // Fetch venue from arguments
    if (Get.arguments is VenueModel) {
      venue.value = Get.arguments as VenueModel;
      loadSlots().then((_) => startPolling());
    } else {
      errorMessage.value = 'Invalid venue arguments';
    }
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }

  // Generate date list: today + next 6 days (7 days total)
  List<DateTime> get availableDates {
    final today = DateTime.now();
    return List.generate(7, (index) {
      return DateTime(today.year, today.month, today.day + index);
    });
  }

  // Load slots for venue and date
  Future<void> loadSlots() async {
    if (venue.value == null) return;

    isLoading.value = true;
    errorMessage.value = null;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    try {
      final list = await _venueRepository.getVenueSlots(venue.value!.id, dateStr);
      slots.assignAll(list);
      
      // Update Rx mappings
      for (final slot in list) {
        if (slotRxMap.containsKey(slot.id)) {
          slotRxMap[slot.id]!.value = slot;
        } else {
          slotRxMap[slot.id] = slot.obs;
        }
      }
    } catch (e) {
      if (e is NoInternetException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Select Date
  void selectDate(DateTime date) {
    selectedDate.value = date;
    loadSlots();
  }

  // Book a slot
  Future<void> bookSlot(SlotModel slot) async {
    if (isBooking.value) return; // double-click protection
    isBooking.value = true;
    try {
      await _bookingRepository.createBooking(slot.id);
      
      Get.back(); // close confirmation bottom sheet on success

      // Show Success Snack
      CustomDialog.showSnackBar(
        title: 'Booking Confirmed!',
        message: 'You have successfully booked this court slot.',
      );

      // Set dirty flag to reload bookings list on next visit to Dashboard tab
      try {
        Get.find<DashboardController>().setNeedsRefresh();
      } catch (_) {
        // Safe fallback for testing environment where DashboardController might not be initialized
      }

      // Reload slots to show new booking state
      await loadSlots();
    } catch (e) {
      Get.back(); // close confirmation bottom sheet on error
      final errorMsg = e.toString();
      if (errorMsg.contains('CONFLICT')) {
        // Concurrency double booking conflict
        Get.defaultDialog(
          title: 'Slot Already Taken',
          middleText: 'Oh no! Another user booked this slot at the exact same time. The grid will refresh.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primary,
          onConfirm: () {
            Get.back();
            loadSlots(); // Auto-refresh grid
          },
        );
      } else {
        String finalMsg;
        if (e is NoInternetException) {
          finalMsg = e.message;
        } else {
          finalMsg = errorMsg.replaceAll('Exception: ', '');
        }
        CustomDialog.showSnackBar(
          title: 'Booking Failed',
          message: finalMsg,
          isError: true,
          );
        }
      } finally {
        isBooking.value = false;
      }
    }

  // Polling logic
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollSlots());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _pollSlots() async {
    if (venue.value == null || isLoading.value || isBooking.value) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    try {
      final list = await _venueRepository.getVenueSlots(venue.value!.id, dateStr);
      
      // Check if anything has changed
      bool hasChanges = false;
      if (list.length != slots.length) {
        hasChanges = true;
      } else {
        for (int i = 0; i < list.length; i++) {
          if (!_areSlotsEqual(list[i], slots[i])) {
            hasChanges = true;
            break;
          }
        }
      }

      if (hasChanges) {
        slots.assignAll(list);
        for (final slot in list) {
          if (slotRxMap.containsKey(slot.id)) {
            slotRxMap[slot.id]!.value = slot;
          } else {
            slotRxMap[slot.id] = slot.obs;
          }
        }
      }
    } catch (_) {
      // Silently ignore polling errors to keep background updates smooth
    }
  }

  bool _areSlotsEqual(SlotModel a, SlotModel b) {
    return a.id == b.id &&
        a.isBooked == b.isBooked &&
        a.startAt == b.startAt &&
        a.endAt == b.endAt &&
        a.venueId == b.venueId;
  }
}
