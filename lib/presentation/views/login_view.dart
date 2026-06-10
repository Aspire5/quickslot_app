import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/loaders/custom_loader.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    AppColors.backgroundDark,
                    const Color(0xFF151828),
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.backgroundLight,
                    const Color(0xFFE8EBFC),
                    AppColors.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  
                  // App Title / Brand
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.sports_tennis_rounded,
                          color: AppColors.primary,
                          size: 32.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'QuickSlot',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Hero Text
                  Text(
                    'Book Your\nGame Instantly',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                          color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sign in to reserve sports slots in seconds.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                  ),
                  SizedBox(height: 36.h),

                  // Login Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceDark.withValues(alpha: 0.7)
                          : AppColors.surfaceLight.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: isDarkMode ? 0.05 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        Obx(() {
                          if (controller.errorMessage.value == null) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20.r),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Username Field
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: controller.usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Enter username (e.g. john_doe)',
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 20.r),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Password Field
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(() => TextField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20.r),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20.r,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            )),
                        SizedBox(height: 30.h),

                        // Submit Button
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CustomLoader(message: 'Logging in securely...'),
                            );
                          }
                          return CustomButton(
                            text: 'Login',
                            onPressed: controller.login,
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Seeded Users / Quick Selection Header
                  Text(
                    'Quick Test Accounts',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDarkMode ? Colors.white70 : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Seeded Accounts List
                  Column(
                    children: [
                      _buildQuickLoginCard(
                        context,
                        name: 'John Doe (john_doe)',
                        subtitle: 'Primary booking account',
                        username: 'john_doe',
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(height: 10.h),
                      _buildQuickLoginCard(
                        context,
                        name: 'Jane Smith (jane_smith)',
                        subtitle: 'Second test account',
                        username: 'jane_smith',
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(height: 10.h),
                      _buildQuickLoginCard(
                        context,
                        name: 'Dev Tester (dev_tester)',
                        subtitle: 'Developer account',
                        username: 'dev_tester',
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginCard(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String username,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: () => controller.loginWithSeeded(username, 'password123'),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.surfaceDark.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                username.split('_').first[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}


