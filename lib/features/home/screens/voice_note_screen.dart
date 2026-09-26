import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Track currently playing index
  int? _playingIndex;

  // Duration tracking
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<VoiceNote> _voiceNotes = [
    VoiceNote(
      title: 'English Awareness',
      subtitle: 'Polio vaccine importance',
      assetPath: 'audio/english.mp3',
      language: 'English',
      flagEmoji: '🇬🇧',
      color: const Color(0xFF1A73E8),
    ),
    VoiceNote(
      title: 'Urdu Awareness',
      subtitle: 'پولیو ویکسین کی اہمیت',
      assetPath: 'audio/urdu.mp3',
      language: 'Urdu',
      flagEmoji: '🇵🇰',
      color: const Color(0xFF34A853),
    ),
    VoiceNote(
      title: 'Punjabi Awareness',
      subtitle: 'پولیو ٹیکے دی اہمیت',
      assetPath: 'audio/english.mp3',
      language: 'Punjabi',
      flagEmoji: '🏴',
      color: const Color(0xFFEA4335),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    // Track duration
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    // Track position
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    // Track completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }
    });

    // Track state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped) {
        if (mounted) setState(() => _playingIndex = null);
      }
    });
  }

  Future<void> _playAudio(int index, String assetPath) async {
    try {
      if (_playingIndex == index) {
        // Toggle: pause if playing, resume if paused
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.pause();
          setState(() {}); // Rebuild to show play icon
        } else if (_audioPlayer.state == PlayerState.paused) {
          await _audioPlayer.resume();
          setState(() {});
        }
      } else {
        // Playing a different audio - stop current and play new
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(assetPath));
        setState(() {
          _playingIndex = index;
          _position = Duration.zero;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not play audio: $e',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingIndex = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.campaign, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Awareness Voice Notes',
              style: AppTextStyles.bold.copyWith(
                fontSize: 17.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F2FC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1A5276).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: const Color(0xFF1A5276), size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Play these awareness messages for parents who refuse vaccination. '
                          'Each message explains why polio drops are essential for their child.',
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 12.sp,
                        color: const Color(0xFF1A5276),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Select Language',
              style: AppTextStyles.bold.copyWith(
                fontSize: 15.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 12.h),

            // Voice note cards
            ...List.generate(_voiceNotes.length, (index) {
              final note = _voiceNotes[index];
              final isPlaying = _playingIndex == index;
              final isActuallyPlaying = isPlaying &&
                  _audioPlayer.state == PlayerState.playing;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _VoiceNoteCard(
                  note: note,
                  isPlaying: isActuallyPlaying,
                  isActive: isPlaying,
                  position: isPlaying ? _position : Duration.zero,
                  duration: isPlaying ? _duration : Duration.zero,
                  onPlayPause: () => _playAudio(index, note.assetPath),
                  onStop: _stopAudio,
                ),
              );
            }),

            SizedBox(height: 20.h),

            // Tips card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.orange.shade800, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Tips for Field Workers',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 13.sp,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildTip('Play in the parent\'s preferred language'),
                  _buildTip('Start with a calm, respectful tone'),
                  _buildTip('Play the message fully without interruption'),
                  _buildTip('Answer questions after the message ends'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.regular.copyWith(
                fontSize: 11.5.sp,
                color: Colors.orange.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// VOICE NOTE CARD
// ============================================
class _VoiceNoteCard extends StatelessWidget {
  final VoiceNote note;
  final bool isPlaying;
  final bool isActive;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;

  const _VoiceNoteCard({
    required this.note,
    required this.isPlaying,
    required this.isActive,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isActive ? note.color : Colors.transparent,
          width: isActive ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Language icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: note.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    note.flagEmoji,
                    style: TextStyle(fontSize: 22.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      note.subtitle,
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 11.5.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Play/Pause button
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: note.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: note.color.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),

          // Progress bar (only when active)
          if (isActive) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(note.color),
                      minHeight: 5.h,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.w),
                // Stop button
                GestureDetector(
                  onTap: onStop,
                  child: Icon(
                    Icons.stop_circle,
                    color: Colors.grey.shade500,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// ============================================
// VOICE NOTE MODEL
// ============================================
class VoiceNote {
  final String title;
  final String subtitle;
  final String assetPath;
  final String language;
  final String flagEmoji;
  final Color color;

  VoiceNote({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.language,
    required this.flagEmoji,
    required this.color,
  });
}