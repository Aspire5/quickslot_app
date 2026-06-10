import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/loaders/custom_loader.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QuickSlot Home',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CustomLoader(message: 'Loading user details...'),
              );
            }

            if (controller.errorMessage.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      controller.errorMessage.value!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: 'Retry',
                      onPressed: () => controller.fetchUserProfile(),
                    ),
                  ],
                ),
              );
            }

            final user = controller.user.value;
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No user data found.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: 'Fetch Profile',
                      onPressed: () => controller.fetchUserProfile(),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 40.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomButton(
                    text: 'Refresh Profile',
                    onPressed: () => controller.fetchUserProfile(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
