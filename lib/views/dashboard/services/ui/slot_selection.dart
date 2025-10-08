import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/service_model.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SlotSelection extends StatefulWidget {
  final ServiceModel service;

  const SlotSelection({super.key, required this.service});

  @override
  State<SlotSelection> createState() => _SlotSelectionState();
}

class _SlotSelectionState extends State<SlotSelection> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final _razorpay = Razorpay();
  String _selectedPaymentMethod = 'online';
  bool _isProcessing = false;
  String? _selectedDate, _selectedTime;

  final List<String> _timeSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM'];

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    _confirmBooking(_selectedDate!, _selectedTime!, response.paymentId ?? 'N/A', 'completed');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    Get.snackbar('Payment Failed', 'Please try again or choose another payment method', backgroundColor: AppTheme.emergencyRed, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('Payment Failed', 'External Wallet: ${response.walletName}', backgroundColor: AppTheme.emergencyRed, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _initiateRazorpayPayment() async {
    final options = {
      'key': 'rzp_test_RHRLTvT4Rm3WOP',
      'amount': (widget.service.rate * 100).toInt(),
      'name': 'Prime Health',
      'description': widget.service.name,
      'prefill': {'contact': '9876543210', 'email': 'patient@example.com'},
      'theme': {'color': AppTheme.primaryTeal.value},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Payment Error', 'Failed to initiate payment', backgroundColor: AppTheme.emergencyRed, colorText: Colors.white);
    }
  }

  void _processBooking() {
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar('Incomplete Details', 'Please select both date and time', backgroundColor: AppTheme.warningAmber, colorText: Colors.white);
      return;
    }

    if (_selectedPaymentMethod == 'online') {
      setState(() => _isProcessing = true);
      _initiateRazorpayPayment();
    } else {
      _confirmBooking(_selectedDate!, _selectedTime!, 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}', 'pending');
    }
  }

  void _confirmBooking(String date, String time, String transactionId, String status) {
    Get.back();
    Get.snackbar(
      'Booking Confirmed! 🎉',
      '${widget.service.name} booked for $date at $time\nPayment: ${status == 'completed' ? 'Confirmed' : 'Pending Verification'}',
      backgroundColor: AppTheme.successGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Book Appointment',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isProcessing
          ? _buildLoadingState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildServiceInfo(),
                  const SizedBox(height: 24),
                  _buildDateSelection(),
                  const SizedBox(height: 24),
                  _buildTimeSelection(),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal)),
          const SizedBox(height: 20),
          Text(
            'Processing Payment...',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text('Please wait while we process your payment', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.service.icon, color: AppTheme.primaryTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(widget.service.category, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Date',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dateController,
            decoration: InputDecoration(
              labelText: 'Appointment Date',
              hintText: 'Choose a date',
              prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryTeal, width: 2),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now,
                lastDate: DateTime(now.year + 1, now.month, now.day),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: AppTheme.primaryTeal,
                      colorScheme: ColorScheme.light(primary: AppTheme.primaryTeal),
                      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
                dateController.text = formattedDate;
                _selectedDate = formattedDate;
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Time Slot',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Available time slots', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((slot) {
              final isSelected = _selectedTime == slot;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = slot;
                    timeController.text = slot;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryTeal : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor, width: 1.5),
                  ),
                  child: Text(
                    slot,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppTheme.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Method',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            title: 'Online Payment',
            subtitle: 'Pay securely with Razorpay',
            icon: Icons.credit_card_rounded,
            isSelected: _selectedPaymentMethod == 'online',
            onTap: () => setState(() => _selectedPaymentMethod = 'online'),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            title: 'Pay at Clinic',
            subtitle: 'Pay when you visit the clinic',
            icon: Icons.payments_outlined,
            isSelected: _selectedPaymentMethod == 'offline',
            onTap: () => setState(() => _selectedPaymentMethod = 'offline'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: AppTheme.successGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Your payment is secure and encrypted', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String title, required String subtitle, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isSelected ? AppTheme.primaryTeal : AppTheme.backgroundLight, shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? Colors.white : AppTheme.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isSelected ? AppTheme.primaryTeal.withOpacity(0.8) : AppTheme.textSecondary)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final isFormValid = _selectedDate != null && _selectedTime != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(
                    '₹${widget.service.rate.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isFormValid ? _processBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.textLight.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_selectedPaymentMethod == 'online' ? Icons.lock_rounded : Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(_selectedPaymentMethod == 'online' ? 'Pay & Book' : 'Confirm Booking', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
