import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/auth/otp_verification/otp_verification_ctrl.dart';

class OtpVerification extends StatelessWidget {
  final String mobileNo;
  final String patientId;

  const OtpVerification({super.key, required this.mobileNo, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerificationCtrl>(
      init: OtpVerificationCtrl(mobileNo: mobileNo, patientId: patientId),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundWhite,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const SizedBox(height: 32),
                  _buildHeaderSection(context),
                  const SizedBox(height: 48),
                  _buildOtpForm(ctrl, context),
                  const SizedBox(height: 24),
                  _buildVerifyButton(ctrl, context),
                  const SizedBox(height: 32),
                  _buildResendOtp(ctrl, context),
                  const SizedBox(height: 32),
                  _buildSecurityNote(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Get.close(1),
        style: IconButton.styleFrom(backgroundColor: AppTheme.backgroundLight, padding: const EdgeInsets.all(12)),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textPrimary),
      ),
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
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryLight, AppTheme.primaryTeal]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 28),
          Text(
            'OTP Verification',
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 4-digit code sent to your mobile',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(OtpVerificationCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 56,
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey.shade50),
              child: TextField(
                controller: ctrl.otpControllers[index],
                focusNode: ctrl.focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                obscureText: true,
                obscuringCharacter: '●',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                onChanged: (value) => ctrl.onOtpChanged(value, index),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _buildMobileNumberText(ctrl),
      ],
    );
  }

  Widget _buildMobileNumberText(OtpVerificationCtrl ctrl) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          children: [
            const TextSpan(text: 'Code sent to '),
            TextSpan(
              text: ctrl.mobileNo,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyButton(OtpVerificationCtrl ctrl, BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : ctrl.verifyOtp,
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
                    const Icon(Icons.verified_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Verify OTP',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildResendOtp(OtpVerificationCtrl ctrl, BuildContext context) {
    return Column(
      children: [
        Text("Didn't receive the code?", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Obx(() {
          return ctrl.canResend.value
              ? TextButton.icon(
                  onPressed: () => ctrl.resendOtp(),
                  icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary, size: 20),
                  label: Text(
                    'Resend Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.orange.shade600, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Resend in ${ctrl.timerSeconds}s',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                );
        }),
      ],
    );
  }

  Widget _buildSecurityNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: AppTheme.primaryTeal, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'OTP is valid for 10 minutes. Do not share it with anyone.',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
