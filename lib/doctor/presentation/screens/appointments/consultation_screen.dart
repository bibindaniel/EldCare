import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'package:intl/intl.dart';

class ConsultationScreen extends StatefulWidget {
  final Appointment appointment;

  const ConsultationScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  // Your Agora App ID (get from Agora Console)
  final String appId = "7d8bb0fb3b0b492b9de0487ba6e475e4";

  // Video call variables
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _muted = false;
  bool _videoDisabled = false;

  // Controllers for notes and prescription
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize the video call
    _initializeAgora();
  }

  @override
  void dispose() {
    // Clean up controllers
    _notesController.dispose();
    _prescriptionController.dispose();
    _tabController.dispose();

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

    // Use appointment ID as channel name for uniqueness
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
                title: const Text('End Consultation?'),
                content: const Text(
                    'Are you sure you want to end this consultation? You can save your notes and prescription before leaving.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      _completeConsultation();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor),
                    child: const Text('Save & End'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Consultation with ${widget.appointment.userName}',
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Notes'),
              Tab(text: 'Prescription'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Video call area
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    // Remote video
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
                              'Waiting for patient to join...',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    // Local video (picture-in-picture)
                    Positioned(
                      right: 10,
                      top: 10,
                      width: 120,
                      height: 160,
                      child: _localUserJoined
                          ? Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
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
            ),

            // Notes and Prescription tabs
            Expanded(
              flex: 3,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotesTab(),
                  _buildPrescriptionTab(),
                ],
              ),
            ),
          ],
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
                    // End call and complete consultation
                    _completeConsultation();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save & End Consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
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

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.appointment.userPhotoUrl != null
                      ? NetworkImage(widget.appointment.userPhotoUrl!)
                      : null,
                  child: widget.appointment.userPhotoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.userName,
                      style: AppFonts.headline4,
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy • h:mm a')
                          .format(widget.appointment.appointmentTime),
                      style: AppFonts.bodyText2,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Reason for Visit:',
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.appointment.reason,
              style: AppFonts.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Prescription'),
                Tab(text: 'Notes'),
              ],
              labelColor: kPrimaryColor,
              indicatorColor: kPrimaryColor,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrescriptionTab(),
                  _buildNotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prescription',
            style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _prescriptionController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText:
                    'Enter medication details...\n\nExample format:\n1. Medication Name - Dosage - Duration\n2. Medication Name - Dosage - Duration',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Notes',
            style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Add notes about this consultation...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeConsultation() async {
    try {
      // Create consultation details
      final consultationDetails = {
        'notes': _notesController.text.trim(),
        'prescription': _prescriptionController.text.trim(),
        'consultationDate': DateTime.now().toIso8601String(),
      };

      // Update the appointment with consultation details and mark as completed
      await AppointmentRepository().updateAppointmentWithConsultation(
        widget.appointment.id,
        consultationDetails,
        AppointmentStatus.completed,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
