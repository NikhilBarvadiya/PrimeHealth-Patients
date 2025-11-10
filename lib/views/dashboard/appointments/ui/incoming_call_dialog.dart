import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/service/calling_service.dart';

class IncomingCallDialog extends StatefulWidget {
  final CallData callData;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallDialog({super.key, required this.callData, required this.onAccept, required this.onReject});

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> with TickerProviderStateMixin {
  late AnimationController _pulseController, _slideController, _loadingController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _slideController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _loadingController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _slideController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = widget.callData.callType == CallType.video;
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        height: screenHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Colors.black]),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildTopStatusBar(isVideo),
              const Spacer(flex: 1),
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildCallerInfo(),
              const SizedBox(height: 24),
              _buildLoadingDots(),
              const Spacer(flex: 2),
              _buildCallControls(isVideo),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusBar(bool isVideo) {
    return Container(
      height: 100 + MediaQuery.of(context).viewPadding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent]),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: isVideo ? Colors.blue : Colors.green, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Incoming ${isVideo ? 'Video' : 'Voice'} Call',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
            ),
            child: _buildInitialAvatar(),
          ),
        );
      },
    );
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        widget.callData.senderName.isNotEmpty ? widget.callData.senderName[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 1),
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        widget.callData.senderName.isNotEmpty ? widget.callData.senderName : 'Unknown Caller',
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 0.5),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _loadingController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3 + (0.7 * _loadingController.value) * (index == (_loadingController.value * 3).floor() % 3 ? 1 : 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCallControls(bool isVideo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.call_end_rounded,
            isActive: true,
            onPressed: () async {
              await CallingService().player.pause();
              HapticFeedback.heavyImpact();
              widget.onReject();
            },
            activeColor: Colors.red,
            size: 60,
            iconSize: 28,
            tooltip: 'Decline',
          ),
          _buildControlButton(
            icon: isVideo ? Icons.videocam_rounded : Icons.call_rounded,
            isActive: true,
            onPressed: () async {
              await CallingService().player.pause();
              HapticFeedback.heavyImpact();
              widget.onAccept();
            },
            activeColor: Colors.green,
            size: 60,
            iconSize: 28,
            tooltip: 'Accept',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required Color activeColor,
    double size = 50,
    double iconSize = 24,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: isActive ? LinearGradient(colors: [activeColor, activeColor.withOpacity(0.8)]) : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(color: isActive ? activeColor.withOpacity(0.3) : Colors.white.withOpacity(0.1), width: 1),
            boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
