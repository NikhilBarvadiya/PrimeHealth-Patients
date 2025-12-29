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
                      Obx(() => _buildStepperHeader(ctrl)),
                      const SizedBox(height: 24),
                      Obx(() => _buildCurrentStep(ctrl, context)),
                      const SizedBox(height: 24),
                      Obx(() => _buildStepperControls(ctrl, context)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildBackButton(ctrl),
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
              image: DecorationImage(image: AssetImage("assets/fg_logo.png")),
            ),
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

  Widget _buildStepperHeader(RegisterCtrl ctrl) {
    return Row(
      children: [
        _buildStepCircle(ctrl, 0, 'Personal'),
        _buildStepConnector(),
        _buildStepCircle(ctrl, 1, 'Location'),
        _buildStepConnector(),
        _buildStepCircle(ctrl, 2, 'Emergency'),
        _buildStepConnector(),
        _buildStepCircle(ctrl, 3, 'Medical'),
      ],
    );
  }

  Widget _buildStepCircle(RegisterCtrl ctrl, int step, String title) {
    final isActive = ctrl.currentStep.value == step;
    final isCompleted = ctrl.currentStep.value > step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive || isCompleted ? AppTheme.primaryTeal : AppTheme.backgroundWhite,
              shape: BoxShape.circle,
              border: Border.all(color: isActive || isCompleted ? AppTheme.primaryTeal : AppTheme.borderColor, width: 1),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppTheme.textSecondary),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: isActive || isCompleted ? AppTheme.primaryTeal : AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(height: 2, width: 16, color: AppTheme.borderColor, margin: const EdgeInsets.only(bottom: 16));
  }

  Widget _buildCurrentStep(RegisterCtrl ctrl, BuildContext context) {
    switch (ctrl.currentStep.value) {
      case 0:
        return _buildPersonalInfoStep(ctrl, context);
      case 1:
        return _buildLocationStep(ctrl, context);
      case 2:
        return _buildEmergencyStep(ctrl, context);
      case 3:
        return _buildMedicalStep(ctrl, context);
      default:
        return _buildPersonalInfoStep(ctrl, context);
    }
  }

  Widget _buildPersonalInfoStep(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 20),
        _buildNameField(ctrl, context),
        const SizedBox(height: 16),
        _buildEmailField(ctrl, context),
        const SizedBox(height: 16),
        _buildMobileField(ctrl, context),
        const SizedBox(height: 16),
        _buildDateOfBirthField(ctrl, context),
        const SizedBox(height: 16),
        _buildGenderField(ctrl, context),
      ],
    );
  }

  Widget _buildLocationStep(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Location Information'),
        const SizedBox(height: 10),
        Obx(() {
          return ElevatedButton.icon(
            onPressed: ctrl.getCurrentLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: ctrl.isLocationLoading.value == true
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                : Icon(Icons.location_on, size: 15),
            label: Text('Get Current Location', style: TextStyle(fontSize: 12)),
          );
        }),
        const SizedBox(height: 16),
        Row(
          spacing: 10.0,
          children: [
            Expanded(child: _buildCityField(ctrl, context)),
            Expanded(child: _buildStateField(ctrl, context)),
          ],
        ),
        const SizedBox(height: 16),
        _buildCountryField(ctrl, context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmergencyStep(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildSectionHeader('Emergency Contact'), const SizedBox(height: 20), _buildEmergencyNameField(ctrl, context), const SizedBox(height: 16), _buildEmergencyMobileField(ctrl, context)],
    );
  }

  Widget _buildMedicalStep(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Medical Information'),
        const SizedBox(height: 20),
        _buildBloodGroupField(ctrl, context),
        const SizedBox(height: 16),
        _buildAllergiesField(ctrl, context),
        const SizedBox(height: 24),
        _buildTermsAgreement(context),
      ],
    );
  }

  Widget _buildStepperControls(RegisterCtrl ctrl, BuildContext context) {
    return Row(
      children: [
        if (ctrl.currentStep.value > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: ctrl.previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: BorderSide(color: AppTheme.primaryTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Previous', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        if (ctrl.currentStep.value > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: ctrl.isLoading.value
                ? null
                : () {
                    if (ctrl.currentStep.value < 3) {
                      ctrl.nextStep();
                    } else {
                      ctrl.register();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: ctrl.isLoading.value ? 12 : 16),
            ),
            child: ctrl.isLoading.value
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8))))
                : Text(ctrl.currentStep.value == 3 ? 'Create Account' : 'Next', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
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
          'Full Name *',
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
          'Email Address *',
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

  Widget _buildMobileField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.mobileCtrl,
          keyboardType: TextInputType.numberWithOptions(signed: true),
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

  Widget _buildDateOfBirthField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.dateOfBirthCtrl,
          readOnly: true,
          onTap: () => ctrl.selectDateOfBirth(context),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Select your date of birth',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 22),
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

  Widget _buildGenderField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: ctrl.genderOptions.map((gender) {
              return Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    ctrl.setGender(gender);
                  },
                  style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(left: 10, right: 10))),
                  icon: Icon(ctrl.selectedGender.value == gender ? Icons.radio_button_on : Icons.radio_button_off, color: ctrl.selectedGender.value == gender ? null : Colors.grey),
                  label: Text(
                    gender[0].toUpperCase() + gender.substring(1),
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: ctrl.selectedGender.value == gender ? null : Colors.grey),
                  ),
                ),
              );
            }).toList(),
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
          'City *',
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
          'State *',
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

  Widget _buildCountryField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.countryCtrl,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your country',
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

  Widget _buildEmergencyNameField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contact Name *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.emergencyNameCtrl,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter emergency contact name',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.emergency_rounded, color: AppTheme.textSecondary, size: 22),
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

  Widget _buildEmergencyMobileField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contact Mobile *',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl.emergencyMobileCtrl,
          keyboardType: TextInputType.numberWithOptions(signed: true),
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

  Widget _buildBloodGroupField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: ctrl.selectedBloodGroup.value,
          onChanged: (value) => ctrl.setBloodGroup(value!),
          items: ctrl.bloodGroupOptions.map((bloodGroup) {
            return DropdownMenuItem(
              value: bloodGroup,
              child: Text(bloodGroup, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: 'Select blood group',
            hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.bloodtype_rounded, color: AppTheme.textSecondary, size: 22),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergiesField(RegisterCtrl ctrl, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allergies',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ctrl.commonAllergies.map((allergy) {
              final isSelected = ctrl.selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) => ctrl.toggleAllergy(allergy),
                selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryTeal,
                labelStyle: GoogleFonts.inter(color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary, fontWeight: FontWeight.w500),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => ctrl.selectedAllergies.isNotEmpty ? Text('Selected: ${ctrl.selectedAllergies.join(', ')}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)) : const SizedBox()),
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

  Widget _buildBackButton(RegisterCtrl ctrl) {
    return Container(
      height: 45,
      width: 45,
      margin: const EdgeInsets.all(20),
      child: IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        onPressed: () {
          if (ctrl.currentStep.value > 0) {
            ctrl.previousStep();
          } else {
            Get.close(1);
          }
        },
        icon: Icon(ctrl.currentStep.value > 0 ? Icons.arrow_back_ios_new : Icons.arrow_back_ios_new, size: 18),
        color: const Color(0xFF111827),
      ),
    );
  }
}
