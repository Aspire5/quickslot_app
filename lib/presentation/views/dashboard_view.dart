import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/venue_model.dart';
import '../../domain/models/booking_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/loaders/custom_loader.dart';
import '../controllers/dashboard_controller.dart';
import '../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildVenuesTab(context, isDarkMode),
            _buildBookingsTab(context, isDarkMode),
            _buildProfileTab(context, isDarkMode),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            elevation: 0,
            backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black38,
            selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_tennis_rounded),
                activeIcon: Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
                label: 'Venues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                activeIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                label: 'My Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }

  // ──────────────────────────────────────────────────────────
  // Venues Tab
  // ──────────────────────────────────────────────────────────
  Widget _buildVenuesTab(BuildContext context, bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Venue',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchVenues(),
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isVenuesLoading.value && controller.venues.isEmpty) {
            return const Center(child: CustomLoader(message: 'Searching for venues...'));
          }

          if (controller.venuesError.value != null && controller.venues.isEmpty) {
            return _buildErrorState(
              context,
              message: controller.venuesError.value!,
              onRetry: controller.fetchVenues,
            );
          }

          if (controller.venues.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.search_off_rounded,
              title: 'No Venues Available',
              message: 'Check back later for available sports venues.',
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: controller.venues.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final venue = controller.venues[index];
              return _buildVenueCard(context, venue, isDarkMode);
            },
          );
        }),
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, VenueModel venue, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.primary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDarkMode ? 0.03 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(Routes.venueDetails, arguments: venue),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.r,
                              color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                venue.location ?? 'Unknown location',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    size: 24.r,
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
  // Bookings Tab
  // ──────────────────────────────────────────────────────────
  Widget _buildBookingsTab(BuildContext context, bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchBookings(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner Indicator
          Obx(() {
            if (controller.isOfflineMode.value) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                color: AppColors.warning.withValues(alpha: 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Offline Mode: Showing cached bookings.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchBookings(forceRefresh: true),
              color: AppColors.primary,
              child: Obx(() {
                if (controller.isBookingsLoading.value && controller.bookings.isEmpty) {
                  return const Center(child: CustomLoader(message: 'Fetching your bookings...'));
                }

                if (controller.bookingsError.value != null && controller.bookings.isEmpty) {
                  return _buildErrorState(
                    context,
                    message: controller.bookingsError.value!,
                    onRetry: () => controller.fetchBookings(forceRefresh: true),
                  );
                }

                if (controller.bookings.isEmpty) {
                  return _buildEmptyState(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'No Bookings Yet',
                    message: 'Reserve your first court slot on the Venues tab.',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: controller.bookings.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final booking = controller.bookings[index];
                    return _buildBookingCard(context, booking, isDarkMode);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, bool isDarkMode) {
    final slot = booking.slot;
    final venueName = slot?.venue?.name ?? 'Venue Details';
    final venueLoc = slot?.venue?.location ?? 'Sport Center';

    final dateStr = slot != null
        ? DateFormat('EEEE, MMM d, yyyy').format(slot.startAt)
        : 'Unknown Date';
    final timeStr = slot != null
        ? '${DateFormat('h:mm a').format(slot.startAt)} - ${DateFormat('h:mm a').format(slot.endAt)}'
        : 'Unknown Time';

    final isExpired = slot?.startAt.isBefore(DateTime.now()) ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.primary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDarkMode ? 0.03 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        venueLoc,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? Colors.grey.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    isExpired ? 'Completed' : 'Confirmed',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isExpired ? Colors.grey : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, thickness: 1),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            
            // Cancel Action
            if (!isExpired) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 38.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    foregroundColor: AppColors.error,
                  ),
                  onPressed: () => controller.cancelBooking(booking.id),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Profile Tab
  // ──────────────────────────────────────────────────────────
  Widget _buildProfileTab(BuildContext context, bool isDarkMode) {
    final profileUser = controller.user.value;
    final fullName = profileUser?.fullName ?? 'User Name';
    final username = profileUser?.username ?? 'username';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              
              // Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.surfaceDark.withValues(alpha: 0.6)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDarkMode ? 0.03 : 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48.r,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '@$username',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // Logout Button
              CustomButton(
                text: 'Sign Out',
                backgroundColor: AppColors.error,
                onPressed: controller.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Common States (Error / Empty)
  // ──────────────────────────────────────────────────────────
  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48.r,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load details',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Retry',
              width: 140.w,
              height: 40.h,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary.withValues(alpha: 0.3),
              size: 56.r,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
