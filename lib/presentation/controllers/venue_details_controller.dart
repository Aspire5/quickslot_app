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

  // Get reactive count of available future slots
  int get availableSlotsCount {
    return slots.where((s) {
      final rxSlot = slotRxMap[s.id]?.value ?? s;
      return !rxSlot.isBooked && !rxSlot.isExpired;
    }).length;
  }

  // Load slots for venue and date
  Future<void> loadSlots({bool isSilent = false}) async {
    if (venue.value == null) return;

    if (!isSilent) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    try {
      final list = await _venueRepository.getVenueSlots(venue.value!.id, dateStr);
      _updateSlotsList(list);
    } catch (e) {
      if (!isSilent) {
        if (e is NoInternetException) {
          errorMessage.value = e.message;
        } else {
          errorMessage.value = e.toString().replaceAll('Exception: ', '');
        }
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
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

      // Reload slots silently to show new booking state without layout rebuild
      await loadSlots(isSilent: true);
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
      _updateSlotsList(list);
    } catch (_) {
      // Silently ignore polling errors to keep background updates smooth
    }
  }

  void _updateSlotsList(List<SlotModel> newList) {
    // Check if the structure (IDs and length) is the same
    bool structureMatches = slots.length == newList.length;
    if (structureMatches) {
      for (int i = 0; i < slots.length; i++) {
        if (slots[i].id != newList[i].id) {
          structureMatches = false;
          break;
        }
      }
    }

    if (!structureMatches) {
      // Structure changed or initial load, assign all to rebuild grid structure
      slots.assignAll(newList);
    }

    // Update individual reactive slots
    for (final slot in newList) {
      if (slotRxMap.containsKey(slot.id)) {
        if (!_areSlotsEqual(slotRxMap[slot.id]!.value, slot)) {
          slotRxMap[slot.id]!.value = slot;
        }
      } else {
        slotRxMap[slot.id] = slot.obs;
      }
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
