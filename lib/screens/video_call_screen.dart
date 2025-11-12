import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../config/agora_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String doctorName;
  final bool isVideoCall;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.doctorName,
    this.isVideoCall = true,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  int? _remoteUid;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _initializeAgora() async {
    // Check if Agora credentials are configured
    if (AgoraConfig.appId == 'YOUR_AGORA_APP_ID' ||
        AgoraConfig.token == 'YOUR_AGORA_TOKEN') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خدمة المكالمات غير مكونة. يرجى إعداد بيانات Agora'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
            _callStartTime = DateTime.now();
          });
          _startCallTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              setState(() {
                _remoteUid = null;
              });
            },
      ),
    );

    if (widget.isVideoCall) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    await _engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Remote video/audio (full screen)
            _remoteUid != null
                ? (widget.isVideoCall
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine,
                            canvas: VideoCanvas(uid: _remoteUid),
                            connection: const RtcConnection(channelId: ''),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF00BFFF),
                          child: const Center(
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                        ))
                : Container(
                    color: widget.isVideoCall
                        ? Colors.black
                        : const Color(0xFF00BFFF),
                    child: Center(
                      child: Text(
                        widget.isVideoCall
                            ? 'في انتظار الطبيب...'
                            : 'في انتظار الطبيب للمكالمة الصوتية...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

            // Local video (small overlay) - only for video calls
            if (widget.isVideoCall)
              Positioned(
                top: 40,
                right: 20,
                width: 120,
                height: 160,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isVideoEnabled
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.videocam_off,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),

            // Doctor name and call duration
            Positioned(
              top: 60,
              left: 20,
              right: 160,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isJoined)
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isVideoCall)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildControlButton(
                        icon: Icons.screen_share,
                        onPressed: _toggleScreenShare,
                        color: Colors.white,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        onPressed: _toggleMute,
                        color: _isMuted ? Colors.red : Colors.white,
                      ),
                      if (widget.isVideoCall) ...[
                        const SizedBox(width: 20),
                        _buildControlButton(
                          icon: _isVideoEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          onPressed: _toggleVideo,
                          color: _isVideoEnabled ? Colors.white : Colors.red,
                        ),
                      ],
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.call_end,
                        onPressed: _endCall,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color == Colors.white ? Colors.white.withOpacity(0.2) : color,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }

  void _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine.muteLocalAudioStream(_isMuted);
  }

  void _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  void _endCall() {
    Navigator.of(context).pop();
  }

  void _toggleScreenShare() {
    // Screen sharing implementation would require additional Agora setup
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة مشاركة الشاشة قيد التطوير')),
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime!);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
