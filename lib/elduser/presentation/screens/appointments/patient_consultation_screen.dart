import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';

class PatientConsultationScreen extends StatefulWidget {
  final Appointment appointment;

  const PatientConsultationScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _PatientConsultationScreenState createState() =>
      _PatientConsultationScreenState();
}

class _PatientConsultationScreenState extends State<PatientConsultationScreen> {
  // Your Agora App ID (should match the doctor's app ID)
  final String appId = "7d8bb0fb3b0b492b9de0487ba6e475e4";

  // Video call variables
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _muted = false;
  bool _videoDisabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video call
    _initializeAgora();
  }

  @override
  void dispose() {
    // Destroy Agora engine
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _initializeAgora() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Create RTC engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Setup event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (connection, uid, elapsed) {
          setState(() {
            _remoteUid = uid;
          });
        },
        onUserOffline: (connection, uid, reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Set client role and join channel
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    // Use appointment ID as channel name for uniqueness - must match doctor's
    await _engine.joinChannel(
      token: '', // Use empty string for development, real token for production
      channelId: 'consultation_${widget.appointment.id}',
      uid: 0, // 0 means auto-assign
      options: const ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Leave Consultation?'),
                content: const Text(
                    'Are you sure you want to leave this consultation?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Leave'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Consultation with Dr. ${widget.appointment.doctorName}',
              style: AppFonts.headline3),
          backgroundColor: kPrimaryColor,
          actions: [
            IconButton(
              icon: Icon(_muted ? Icons.mic_off : Icons.mic),
              onPressed: () {
                setState(() {
                  _muted = !_muted;
                  _engine.muteLocalAudioStream(_muted);
                });
              },
            ),
            IconButton(
              icon: Icon(_videoDisabled ? Icons.videocam_off : Icons.videocam),
              onPressed: () {
                setState(() {
                  _videoDisabled = !_videoDisabled;
                  _engine.muteLocalVideoStream(_videoDisabled);
                });
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Remote video (doctor)
              Center(
                child: _remoteUid != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: _engine,
                          canvas: VideoCanvas(uid: _remoteUid),
                          connection: RtcConnection(
                              channelId:
                                  'consultation_${widget.appointment.id}'),
                        ),
                      )
                    : const Text(
                        'Waiting for doctor to join...',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              // Local video (patient - picture-in-picture)
              Positioned(
                right: 10,
                top: 10,
                width: 120,
                height: 160,
                child: _localUserJoined
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.call_end),
                  label: const Text('End Consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
