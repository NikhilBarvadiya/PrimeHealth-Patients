import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:prime_health_patients/models/appointment_model.dart';
import 'package:prime_health_patients/models/calling_model.dart';
import 'package:prime_health_patients/models/user_model.dart';
import 'package:prime_health_patients/service/agora_service.dart';
import 'package:prime_health_patients/service/calling_init_method.dart';
import 'package:prime_health_patients/service/calling_service.dart';

class CallingView extends StatefulWidget {
  final String channelName;
  final CallType callType;
  final AppointmentModel receiver;
  final UserModel sender;

  const CallingView({super.key, required this.channelName, required this.receiver, required this.sender, required this.callType});

  @override
  State<CallingView> createState() => _CallingViewState();
}

class _CallingViewState extends State<CallingView> with TickerProviderStateMixin {
  final AgoraService _callService = AgoraService();
  int? _remoteUid;
  bool _isLoading = true, _showControls = true;
  Timer? _hideControlsTimer;
  DateTime? _startTime;

  late AnimationController _controlsAnimationCtrl, _loadingAnimationCtrl, _pulseAnimationCtrl, _avatarPulseCtrl;
  late Animation<double> _controlsAnimation, _pulseAnimation, _avatarPulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controlsAnimationCtrl = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _loadingAnimationCtrl = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _pulseAnimationCtrl = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);
    _avatarPulseCtrl = AnimationController(duration: const Duration(milliseconds: 1800), vsync: this)..repeat(reverse: true);
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controlsAnimationCtrl, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseAnimationCtrl, curve: Curves.easeInOut));
    _avatarPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _avatarPulseCtrl, curve: Curves.easeInOut));
    _controlsAnimationCtrl.forward();
    _initializeCall();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
        _controlsAnimationCtrl.reverse();
      }
    });
  }

  void _showControlsTemporary() {
    if (!_showControls) {
      setState(() => _showControls = true);
      _controlsAnimationCtrl.forward();
    }
    _startHideTimer();
  }

  Future<void> _initializeCall() async {
    try {
      await _callService.initialize(isVoiceOnly: widget.callType == CallType.voice);
      _callService.onUserJoined = (uid) {
        setState(() {
          _remoteUid = uid;
          _isLoading = false;
        });
      };
      _callService.onUserOffline = (uid) {
        setState(() => _remoteUid = null);
        _endCall();
      };
      _callService.onJoinChannelSuccess = () => setState(() => _isLoading = false);
      await _callService.joinChannel(widget.channelName, isVoiceOnly: widget.callType == CallType.voice);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error initializing call: $e');
        Navigator.pop(context);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: CallingInitMethod().navigatorKey,
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _showControlsTemporary,
          child: Stack(
            children: [
              _renderRemoteVideo(),
              if (widget.callType == CallType.video) _renderLocalPreview(),
              _buildTopStatusBar(),
              if (_isLoading) _buildLoadingOverlay(),
              _buildAnimatedCallControls(),
              _buildConnectionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      if (widget.callType == CallType.voice) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [const Color(0xFF2a1810), const Color(0xFF1a1a2e), const Color(0xFF16213e), Colors.black]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade300.withOpacity(0.3), Colors.purple.shade300.withOpacity(0.3), Colors.pink.shade300.withOpacity(0.3)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 30, spreadRadius: 10),
                    BoxShadow(color: Colors.purple.withOpacity(0.15), blurRadius: 50, spreadRadius: 20),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _avatarPulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _avatarPulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade400, Colors.purple.shade400, Colors.pink.shade400]),
                        ),
                        child: Center(
                          child: Text(
                            widget.receiver.doctorName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26)],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Text(
                widget.receiver.doctorName,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Voice Call Connected',
                      style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
          child: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _callService.engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
        ),
      );
    } else {
      if (widget.callType == CallType.voice) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [const Color(0xFF2a1810), const Color(0xFF1a1a2e), const Color(0xFF16213e), Colors.black]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.orange.shade300.withOpacity(0.3), Colors.red.shade300.withOpacity(0.3), Colors.pink.shade300.withOpacity(0.3)],
                        ),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 40, spreadRadius: 15)],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.orange.shade400, Colors.red.shade400, Colors.pink.shade400]),
                        ),
                        child: Center(
                          child: Text(
                            widget.receiver.doctorName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                widget.receiver.doctorName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              Text(
                'Calling...',
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _loadingAnimationCtrl,
                    builder: (context, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3 + (0.7 * _loadingAnimationCtrl.value) * (index == (_loadingAnimationCtrl.value * 3).floor() % 3 ? 1 : 0.3)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF1a1a2e), const Color(0xFF16213e), Colors.black]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
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
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Waiting for participant',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Text(
                  widget.receiver.doctorName.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(widget.callType == CallType.video ? 'Incoming Video Call' : 'Incoming Voice Call', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _loadingAnimationCtrl,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3 + (0.7 * _loadingAnimationCtrl.value) * (index == (_loadingAnimationCtrl.value * 3).floor() % 3 ? 1 : 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    }
  }

  Widget _renderLocalPreview() {
    return Positioned(
      top: 60,
      right: 20,
      child: GestureDetector(
        onTap: _switchCamera,
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                AgoraVideoView(
                  controller: VideoViewController(rtcEngine: _callService.engine, canvas: const VideoCanvas(uid: 0)),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.cameraswitch, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _remoteUid != null ? 'Connected' : 'Connecting...',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: _remoteUid != null ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.receiver.doctorName, style: TextStyle(color: Colors.grey.shade300, fontSize: 12, letterSpacing: 0.2)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Initializing call...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCallControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 40 - (40 * (1 - _controlsAnimation.value)),
          left: 20,
          right: 20,
          child: Opacity(
            opacity: _controlsAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    icon: _callService.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    isActive: _callService.isMuted,
                    onPressed: _toggleMute,
                    activeColor: Colors.red,
                    tooltip: _callService.isMuted ? 'Unmute' : 'Mute',
                  ),
                  if (widget.callType == CallType.video)
                    _buildControlButton(
                      icon: _callService.isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      isActive: !_callService.isVideoEnabled,
                      onPressed: _toggleVideo,
                      activeColor: Colors.red,
                      tooltip: _callService.isVideoEnabled ? 'Turn off camera' : 'Turn on camera',
                    ),
                  if (widget.callType == CallType.voice)
                    _buildControlButton(
                      icon: _callService.isSpeakerphone ? Icons.volume_up : Icons.hearing,
                      isActive: _callService.isSpeakerphone,
                      onPressed: _toggleSpeakerphone,
                      activeColor: Colors.blue,
                      size: 60,
                      iconSize: 28,
                      tooltip: _callService.isSpeakerphone ? 'Switch to Earpiece' : 'Switch to Speaker',
                    ),
                  _buildControlButton(icon: Icons.call_end_rounded, isActive: true, onPressed: _endCall, activeColor: Colors.red, size: 60, iconSize: 28, tooltip: 'End call'),
                  if (widget.callType == CallType.video)
                    _buildControlButton(icon: Icons.cameraswitch_rounded, isActive: false, onPressed: _switchCamera, activeColor: Colors.blue, tooltip: 'Switch camera'),
                ],
              ),
            ),
          ),
        );
      },
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
        onTap: () {
          onPressed();
          _showControlsTemporary();
        },
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

  Widget _buildConnectionIndicator() {
    return Positioned(
      top: 120,
      left: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _remoteUid != null ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _remoteUid != null ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _remoteUid != null ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 6),
            Text(
              _remoteUid != null ? 'HD' : 'Connecting',
              style: TextStyle(color: _remoteUid != null ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMute() async {
    await _callService.toggleMute();
    setState(() {});
  }

  void _toggleVideo() async {
    await _callService.toggleVideo();
    setState(() {});
  }

  void _switchCamera() async {
    await _callService.switchCamera();
  }

  void _toggleSpeakerphone() async {
    await _callService.toggleSpeakerphone();
    setState(() {});
  }

  void _endCall() async {
    if (widget.receiver.fcmToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receiver FCM token is missing!')));
      return;
    }
    final endTime = DateTime.now();
    final duration = _startTime != null ? endTime.difference(_startTime!).inSeconds : 0;
    CallData callData = CallData(senderId: widget.sender.id, senderName: widget.sender.name, senderFCMToken: "", callType: widget.callType, status: CallStatus.ended, channelName: widget.channelName);
    await _callService.leaveChannel();
    CallingService().closeNotification(widget.receiver.id.hashCode);
    CallingService().makeCall(widget.receiver.fcmToken, callData);
    final callPayload = {
      "userIds": [widget.sender.id, widget.receiver.id],
      "videoCallData": {
        "callType": widget.callType == CallType.video ? "video" : "voice",
        "channelName": widget.channelName,
        "status": "ended",
        "startTime": _startTime?.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "duration": duration,
        "senderId": widget.sender.id,
        "senderName": widget.sender.name,
        "receiverId": widget.receiver.id,
        "receiverName": widget.receiver.doctorName,
      },
    };
    log("End Calling Req.---->$callPayload");
    // await ApiManager.request(endpoint: ApiConstant.storeVideoCall, data: callPayload);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _controlsAnimationCtrl.dispose();
    _loadingAnimationCtrl.dispose();
    _pulseAnimationCtrl.dispose();
    _avatarPulseCtrl.dispose();
    _hideControlsTimer?.cancel();
    _callService.dispose();
    super.dispose();
  }
}
