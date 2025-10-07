import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_health_patients/models/service_model.dart';
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
    _confirmBooking(dateController.text, timeController.text, response.paymentId ?? 'N/A', 'completed');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    Get.snackbar('Payment Failed', 'Please try again or choose another payment method', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('Payment Failed', 'External Wallet: ${response.walletName}', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _initiateRazorpayPayment() async {
    final options = {
      'key': 'rzp_test_RHRLTvT4Rm3WOP',
      'amount': (widget.service.rate * 100).toInt(),
      'name': 'PhysioCare Clinic',
      'description': widget.service.name,
      'prefill': {'contact': '9876543210', 'email': 'patient@example.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Payment Error', 'Failed to initiate payment: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _processBooking() {
    if (dateController.text.isEmpty || timeController.text.isEmpty) {
      Get.snackbar('Incomplete Details', 'Please select both date and time', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (_selectedPaymentMethod == 'online') {
      setState(() => _isProcessing = true);
      _initiateRazorpayPayment();
    } else {
      _confirmBooking(dateController.text, timeController.text, 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}', 'pending');
    }
  }

  void _confirmBooking(String date, String time, String transactionId, String status) {
    // final bookingData = {
    //   'service': widget.service.name,
    //   'date': date,
    //   'time': time,
    //   'amount': widget.service.price,
    //   'paymentMethod': _selectedPaymentMethod,
    //   'transactionId': transactionId,
    //   'status': status,
    //   'screenshot': _paymentScreenshot != null,
    // };
    Get.back();
    Get.snackbar(
      'Booking Confirmed! 🎉',
      '${widget.service.name} booked for $date at $time\nPayment: ${status == 'completed' ? 'Confirmed' : 'Pending Verification'}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Book Appointment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(children: [_buildServiceInfo(), const SizedBox(height: 24), _buildSlotSelection(), const SizedBox(height: 24), _buildPaymentSection()]),
            ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB))),
          const SizedBox(height: 20),
          Text(
            'Processing Payment...',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text('Please wait while we process your payment', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(widget.service.icon, color: const Color(0xFF2563EB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.service.rate.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date & Time',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text('Choose your preferred appointment slot', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 20),
          TextField(
            controller: dateController,
            decoration: InputDecoration(
              labelText: 'Appointment Date',
              hintText: 'Select date',
              prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF2563EB)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2563EB)),
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
                      primaryColor: Color(0xFF2563EB),
                      colorScheme: ColorScheme.light(primary: Color(0xFF2563EB)),
                      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: timeController,
            decoration: InputDecoration(
              labelText: 'Appointment Time',
              hintText: 'Select time',
              prefixIcon: Icon(Icons.access_time_outlined, color: Color(0xFF2563EB)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: Color(0xFF2563EB),
                      colorScheme: ColorScheme.light(primary: Color(0xFF2563EB)),
                      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                timeController.text = "${picked.hourOfPeriod}:${picked.minute.toString().padLeft(2, '0')} ${picked.period == DayPeriod.am ? 'AM' : 'PM'}";
                setState(() {});
              }
            },
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text('Choose how you want to pay', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  title: 'Online',
                  subtitle: 'Pay with Razorpay',
                  icon: Icons.credit_card,
                  isSelected: _selectedPaymentMethod == 'online',
                  onTap: () => setState(() => _selectedPaymentMethod = 'online'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  title: 'COD',
                  subtitle: 'Pay at clinic',
                  icon: Icons.payments_outlined,
                  isSelected: _selectedPaymentMethod == 'offline',
                  onTap: () => setState(() => _selectedPaymentMethod = 'offline'),
                ),
              ),
            ],
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
          color: isSelected ? Color(0xFF2563EB).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Color(0xFF2563EB) : Colors.grey[300]!, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Color(0xFF2563EB) : Colors.grey[600], size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Color(0xFF2563EB) : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 10, color: isSelected ? Color(0xFF2563EB).withOpacity(0.8) : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final isFormValid = dateController.text.isNotEmpty && timeController.text.isNotEmpty && (_selectedPaymentMethod == 'online' || (_selectedPaymentMethod == 'offline'));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          spacing: 20.0,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                Text(
                  '₹${widget.service.rate.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isFormValid ? _processBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedPaymentMethod == 'online' ? 'Pay Now' : 'Confirm Booking',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
