import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/dashboard/profile/profile_ctrl.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileCtrl>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppTheme.primaryLight,
            leading: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryLight, size: 20),
              onPressed: () => Get.close(1),
            ),
            title: Text(
              'Edit Profile',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(ctrl),
                  const SizedBox(height: 20),
                  _buildLocationSection(ctrl),
                  const SizedBox(height: 20),
                  _buildHealthInfoSection(ctrl),
                  const SizedBox(height: 20),
                  _buildEmergencyContactSection(ctrl),
                  const SizedBox(height: 20),
                  _buildAllergiesSection(ctrl),
                  const SizedBox(height: 30),
                  _buildSaveButton(ctrl),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.person_outline_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Basic Information',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(controller: ctrl.nameController, label: 'Full Name', icon: Icons.person_rounded, hint: 'Enter your full name'),
                const SizedBox(height: 16),
                _buildTextField(controller: ctrl.emailController, label: 'Email Address', icon: Icons.email_rounded, hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildDatePickerField(
                  controller: TextEditingController(text: DateFormat('MMM dd, yyyy').format(DateTime.parse(ctrl.dateOfBirthController.text))),
                  label: 'Date of Birth',
                  icon: Icons.cake_rounded,
                  hint: 'Select your date of birth',
                  onTap: () => _selectDate(ctrl),
                ),
                const SizedBox(height: 16),
                _buildGenderSelector(ctrl),
                const SizedBox(height: 16),
                _buildTextField(controller: ctrl.bloodGroupController, label: 'Blood Group', icon: Icons.bloodtype_rounded, hint: 'e.g., A+, B-, O+'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.location_on_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Details',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(controller: ctrl.cityController, label: 'City', icon: Icons.location_city_rounded, hint: 'Enter your city'),
                const SizedBox(height: 16),
                _buildTextField(controller: ctrl.stateController, label: 'State', icon: Icons.map_rounded, hint: 'Enter your state'),
                const SizedBox(height: 16),
                _buildTextField(controller: ctrl.countryController, label: 'Country', icon: Icons.public_rounded, hint: 'Enter your country'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.favorite_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Health Information',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Add any important medical information here', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.phone_in_talk_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(controller: ctrl.emergencyNameController, label: 'Contact Name', icon: Icons.person_rounded, hint: 'Enter emergency contact name'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: ctrl.emergencyMobileController,
                  label: 'Contact Number',
                  icon: Icons.phone_rounded,
                  hint: 'Enter emergency contact number',
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.warning_amber_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Allergies',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddAllergyDialog(ctrl),
                  icon: Icon(Icons.add_rounded, size: 18),
                  label: Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primaryTeal),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            final allergies = ctrl.user.value.allergies ?? [];
            if (allergies.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 20, color: AppTheme.primaryTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('No allergies added yet', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allergies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final allergy = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, size: 16, color: AppTheme.primaryTeal),
                        const SizedBox(width: 6),
                        Text(
                          allergy.toString(),
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryTeal),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeAllergy(ctrl, index),
                          child: Icon(Icons.close_rounded, size: 16, color: AppTheme.primaryTeal),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            prefixIcon: Icon(icon, color: AppTheme.primaryTeal, size: 20),
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({required TextEditingController controller, required String label, required IconData icon, required String hint, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            prefixIcon: Icon(icon, color: AppTheme.primaryTeal, size: 20),
            suffixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ProfileCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  label: 'Male',
                  icon: Icons.male_rounded,
                  isSelected: ctrl.user.value.gender == 'male',
                  onTap: () {
                    ctrl.user.value.gender = 'male';
                    ctrl.update();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  label: 'Female',
                  icon: Icons.female_rounded,
                  isSelected: ctrl.user.value.gender == 'female',
                  onTap: () {
                    ctrl.user.value.gender = 'female';
                    ctrl.update();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  label: 'Other',
                  icon: Icons.transgender_rounded,
                  isSelected: ctrl.user.value.gender == 'other',
                  onTap: () {
                    ctrl.user.value.gender = 'other';
                    ctrl.update();
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildGenderOption({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ProfileCtrl ctrl) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => ctrl.saveProfile(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'Save Changes',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _selectDate(ProfileCtrl ctrl) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryTeal, onPrimary: Colors.white, surface: Colors.white, onSurface: AppTheme.textPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ctrl.dateOfBirthController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ctrl.update();
    }
  }

  void _showAddAllergyDialog(ProfileCtrl ctrl) {
    final TextEditingController allergyController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.warning_amber_rounded, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Allergy',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: allergyController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter allergy name',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.close(1),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (allergyController.text.trim().isNotEmpty) {
                          final allergies = ctrl.user.value.allergies ?? [];
                          allergies.add(allergyController.text.trim());
                          ctrl.user.value.allergies = allergies;
                          ctrl.update();
                          Get.close(1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAllergy(ProfileCtrl ctrl, int index) {
    final allergies = ctrl.user.value.allergies ?? [];
    allergies.removeAt(index);
    ctrl.user.value.allergies = allergies;
    ctrl.update();
  }
}
