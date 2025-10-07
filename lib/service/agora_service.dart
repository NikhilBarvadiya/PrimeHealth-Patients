import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_generator/agora_token_generator.dart';

class AgoraService {
  static const String appId = '20bf50237d6643d2a223489956af685a';
  static const String appCertificate = '0bb79a33248d4ce192aa4519c0b9d761';
  late RtcEngine _engine;
  bool _isJoined = false, _isMuted = false, _isVideoEnabled = true, _isSpeakerphone = true;
  Function(int uid)? onUserJoined, onUserOffline;
  Function()? onJoinChannelSuccess;
  Function(RtcStats stats)? onRtcStats;

  Future<void> initialize({bool isVoiceOnly = false}) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          onJoinChannelSuccess?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          onUserOffline?.call(remoteUid);
        },
        onRtcStats: (RtcConnection connection, RtcStats stats) {
          onRtcStats?.call(stats);
        },
      ),
    );
    if (isVoiceOnly) {
      await _engine.setAudioProfile(profile: AudioProfileType.audioProfileSpeechStandard, scenario: AudioScenarioType.audioScenarioChatroom);
      await _engine.disableVideo();
      await _engine.muteLocalVideoStream(true);
      await _engine.setDefaultAudioRouteToSpeakerphone(true);
    } else {
      await _engine.enableVideo();
      await _engine.setVideoEncoderConfiguration(
        VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: FrameRate.frameRateFps15.index,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );
      await _engine.startPreview();
    }
  }

  Future<void> joinChannel(String channelName, {bool isVoiceOnly = false}) async {
    if (!_isJoined) {
      String rtcToken = RtcTokenBuilder.buildTokenWithUid(appId: appId, appCertificate: appCertificate, channelName: channelName, uid: 0, tokenExpireSeconds: 3600);
      await _engine.joinChannel(
        token: rtcToken,
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: isVoiceOnly ? false : true,
        ),
      );
    }
  }

  Future<void> toggleSpeakerphone() async {
    _isSpeakerphone = !_isSpeakerphone;
    await _engine.setEnableSpeakerphone(_isSpeakerphone);
  }

  Future<void> leaveChannel() async {
    if (_isJoined) {
      await _engine.leaveChannel();
      _isJoined = false;
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> toggleVideo() async {
    _isVideoEnabled = !_isVideoEnabled;
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> dispose() async {
    await leaveChannel();
    await _engine.release();
  }

  bool get isMuted => _isMuted;

  bool get isVideoEnabled => _isVideoEnabled;

  bool get isSpeakerphone => _isSpeakerphone;

  RtcEngine get engine => _engine;
}
