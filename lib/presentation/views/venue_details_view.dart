import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/slot_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/loaders/custom_loader.dart';
import '../controllers/venue_details_controller.dart';

class VenueDetailsView extends GetView<VenueDetailsController> {
  const VenueDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.venue.value?.name ?? 'Venue Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.venue.value == null) {
            return const Center(child: CustomLoader(message: 'Loading details...'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Header details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 16.r,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            controller.venue.value!.location ?? 'Sport Complex Center',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Date Picker Slider Label
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Horizontal Date Selector
              _buildDateSlider(isDarkMode),
              SizedBox(height: 20.h),

              // Slots List Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Obx(() {
                      final count = controller.slots.where((s) => !s.isBooked).length;
                      return Text(
                        '$count Free',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Slots Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CustomLoader(message: 'Searching slots...'));
                  }

                  if (controller.errorMessage.value != null) {
                    return _buildErrorState(
                      context,
                      message: controller.errorMessage.value!,
                      onRetry: controller.loadSlots,
                    );
                  }

                  if (controller.slots.isEmpty) {
                    return _buildEmptyState(
                      context,
                      title: 'No Slots Seeded',
                      message: 'There are no slots found for this date. Try selecting another date.',
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2.3,
                    ),
                    itemCount: controller.slots.length,
                    itemBuilder: (context, index) {
                      final slot = controller.slots[index];
                      return _buildSlotCard(context, slot, isDarkMode);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Date Selector Slider
  // ──────────────────────────────────────────────────────────
  Widget _buildDateSlider(bool isDarkMode) {
    return SizedBox(
      height: 76.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.availableDates.length,
        itemBuilder: (context, index) {
          final date = controller.availableDates[index];
          final isSelected = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value) ==
              DateFormat('yyyy-MM-dd').format(date);

          final dayName = DateFormat('E').format(date).toUpperCase();
          final dayNum = DateFormat('d').format(date);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: InkWell(
              onTap: () => controller.selectDate(date),
              borderRadius: BorderRadius.circular(16.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56.w,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        )
                      : null,
                  color: !isSelected
                      ? (isDarkMode
                          ? AppColors.surfaceDark.withValues(alpha: 0.5)
                          : Colors.white)
                      : null,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.primary.withValues(alpha: 0.08)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDarkMode ? Colors.white70 : AppColors.textSecondaryLight),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : (isDarkMode ? Colors.white : AppColors.textPrimaryLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Slot Card Builder
  // ──────────────────────────────────────────────────────────
  Widget _buildSlotCard(BuildContext context, SlotModel slot, bool isDarkMode) {
    final startStr = DateFormat('h:mm a').format(slot.startAt);
    final endStr = DateFormat('h:mm a').format(slot.endAt);

    if (slot.isBooked) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.surfaceDark.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$startStr - $endStr',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white30 : Colors.black26,
                decoration: TextDecoration.lineThrough,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Booked',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white30 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showBookingConfirmation(context, slot, isDarkMode),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$startStr - $endStr',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Show Booking Sheet Dialog
  // ──────────────────────────────────────────────────────────
  void _showBookingConfirmation(BuildContext context, SlotModel slot, bool isDarkMode) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(slot.startAt);
    final timeStr = '${DateFormat('h:mm a').format(slot.startAt)} - ${DateFormat('h:mm a').format(slot.endAt)}';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Confirm Slot Booking',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Review details below to complete reservation.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 20.h),

              // Venue details
              _buildDetailItem(
                Icons.sports_tennis_rounded,
                'Venue',
                controller.venue.value!.name,
                isDarkMode,
              ),
              SizedBox(height: 12.h),

              // Date details
              _buildDetailItem(
                Icons.calendar_today_rounded,
                'Selected Date',
                dateStr,
                isDarkMode,
              ),
              SizedBox(height: 12.h),

              // Time details
              _buildDetailItem(
                Icons.access_time_rounded,
                'Selected Time',
                timeStr,
                isDarkMode,
              ),
              SizedBox(height: 24.h),

              // Concurrency check note
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Slots are locked instantly. Double booking checks occur at database-level to guarantee fairness.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              Obx(() {
                if (controller.isBooking.value) {
                  return const Center(child: CustomLoader(message: 'Securing slot...'));
                }
                return CustomButton(
                  text: 'Book Slot Now',
                  onPressed: () {
                    Get.back(); // close bottom sheet
                    controller.bookSlot(slot); // trigger book
                  },
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      elevation: 0,
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDarkMode ? Colors.white30 : Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Common States (Error/Empty)
  Widget _buildErrorState(BuildContext context, {required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40.r),
            SizedBox(height: 12.h),
            Text(
              'Failed to search slots',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String title, required String message}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, color: AppColors.primary.withValues(alpha: 0.3), size: 48.r),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
