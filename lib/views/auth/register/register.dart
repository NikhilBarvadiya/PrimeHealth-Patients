import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/auth/register/register_ctrl.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterCtrl>(
      init: RegisterCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundWhite,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _buildHeaderSection(context),
                      const SizedBox(height: 32),
                      _buildRegistrationForm(ctrl, context),
                      const SizedBox(height: 24),
                      _buildTermsAgreement(context),
                      const SizedBox(height: 24),
                      _buildLocationStatus(ctrl),
                      const SizedBox(height: 24),
                      Obx(() => _buildRegisterButton(ctrl, context)),
                      const SizedBox(height: 24),
                      _buildLoginRedirect(context, ctrl),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildBackButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Join Prime Health',
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account and start your health journey',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 20),
        _buildNameField(ctrl, context),
        const SizedBox(height: 16),
        _buildEmailField(ctrl, context),
        const SizedBox(height: 16),
        _buildPasswordField(ctrl, context),
        const SizedBox(height: 16),
        _buildMobileField(ctrl, context),
        const SizedBox(height: 24),
        _buildSectionHeader('Location Information'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildCityField(ctrl, context)),
            const SizedBox(width: 12),
            Expanded(child: _buildStateField(ctrl, context)),
          ],
        ),
        const SizedBox(height: 16),
        _buildAddressField(ctrl, context),
      ],
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
    );
  }

  Widget _buildNameField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.nameCtrl,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.person_2_rounded, color: AppTheme.textSecondary, size: 22),
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'patient@primehealth.com',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.email_rounded, color: AppTheme.textSecondary, size: 22),
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return TextFormField(
            controller: ctrl.passwordCtrl,
            obscureText: !ctrl.isPasswordVisible.value,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
              prefixIcon: Icon(Icons.lock_rounded, color: AppTheme.textSecondary, size: 22),
              suffixIcon: IconButton(
                onPressed: ctrl.togglePasswordVisibility,
                icon: Icon(ctrl.isPasswordVisible.value ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppTheme.textSecondary, size: 22),
              ),
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMobileField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.mobileCtrl,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 10,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.textSecondary, size: 22),
            counterText: '',
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCityField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.cityCtrl,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your city',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.location_city_rounded, color: AppTheme.textSecondary, size: 22),
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStateField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.stateCtrl,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your state',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.map_rounded, color: AppTheme.textSecondary, size: 22),
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Address',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.addressCtrl,
          textInputAction: TextInputAction.done,
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your complete address',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.home_rounded, color: AppTheme.textSecondary, size: 22),
            filled: true,
            fillColor: AppTheme.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, size: 20, color: AppTheme.primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, height: 1.4),
                children: [
                  const TextSpan(text: 'By creating an account, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '. Your health data is protected with end-to-end encryption.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus(RegisterCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getStatusColor(ctrl).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getStatusColor(ctrl).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_getStatusIcon(ctrl), color: _getStatusColor(ctrl), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(ctrl),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(ctrl.locationStatus.value, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            if (ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied'))
              TextButton(
                onPressed: ctrl.retryLocation,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RegisterCtrl ctrl) {
    if (ctrl.locationStatus.value.contains('successfully')) {
      return AppTheme.successGreen;
    } else if (ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')) {
      return AppTheme.emergencyRed;
    } else {
      return AppTheme.warningAmber;
    }
  }

  IconData _getStatusIcon(RegisterCtrl ctrl) {
    if (ctrl.locationStatus.value.contains('successfully')) {
      return Icons.check_circle_rounded;
    } else if (ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')) {
      return Icons.error_outline_rounded;
    } else {
      return Icons.location_searching_rounded;
    }
  }

  String _getStatusTitle(RegisterCtrl ctrl) {
    if (ctrl.isGettingLocation.value) {
      return 'Getting Location...';
    } else if (ctrl.locationStatus.value.contains('successfully')) {
      return 'Location Found';
    } else if (ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')) {
      return 'Location Error';
    } else {
      return 'Location Status';
    }
  }

  Widget _buildRegisterButton(RegisterCtrl ctrl, BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: ctrl.isLoading.value ? null : ctrl.register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: ctrl.isLoading.value
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8))))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Account',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginRedirect(BuildContext context, RegisterCtrl ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
        ),
        GestureDetector(
          onTap: ctrl.goToLogin,
          child: Text(
            'Sign In',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      height: 45,
      width: 45,
      margin: const EdgeInsets.all(20),
      child: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: const Color(0xFF111827),
      ),
    );
  }
}
