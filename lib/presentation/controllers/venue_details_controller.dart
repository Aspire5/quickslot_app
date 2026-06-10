import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/models/slot_model.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../shared/dialogs/custom_dialog.dart';

class VenueDetailsController extends GetxController {
  final VenueRepository _venueRepository;
  final BookingRepository _bookingRepository;

  VenueDetailsController(this._venueRepository, this._bookingRepository);

  final Rxn<VenueModel> venue = Rxn<VenueModel>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  final RxList<SlotModel> slots = <SlotModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBooking = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Fetch venue from arguments
    if (Get.arguments is VenueModel) {
      venue.value = Get.arguments as VenueModel;
      loadSlots();
    } else {
      errorMessage.value = 'Invalid venue arguments';
    }
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
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
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
    isBooking.value = true;
    try {
      await _bookingRepository.createBooking(slot.id);
      
      // Show Success Snack
      CustomDialog.showSnackBar(
        title: 'Booking Confirmed!',
        message: 'You have successfully booked this court slot.',
      );

      // Reload slots to show new booking state
      await loadSlots();
    } catch (e) {
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
        CustomDialog.showSnackBar(
          title: 'Booking Failed',
          message: errorMsg.replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      isBooking.value = false;
    }
  }
}
