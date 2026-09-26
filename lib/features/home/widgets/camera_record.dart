import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_text_style.dart';

enum CaptureMode { photo, video }

/// Callback receives the recorded File when capture completes.
typedef OnCaptureDone = void Function(File file);

class CameraRecorder extends StatefulWidget {
  final CaptureMode mode;
  final OnCaptureDone onDone;
  final int? maxSeconds; // null = unlimited

  const CameraRecorder({
    super.key,
    required this.mode,
    required this.onDone,
    this.maxSeconds,
  });

  @override
  State<CameraRecorder> createState() => _CameraRecorderState();
}

class _CameraRecorderState extends State<CameraRecorder> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  File? _captured;
  VideoPlayerController? _videoCtrl;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!cam.isGranted || !mic.isGranted) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final back = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      back,
      ResolutionPreset.medium,
      enableAudio: widget.mode == CaptureMode.video,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _controller!.takePicture();
    setState(() {
      _captured = File(file.path);
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds++);
      if (widget.maxSeconds != null && _seconds >= widget.maxSeconds!) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    if (_controller == null) return;
    final file = await _controller!.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _captured = File(file.path);
    });
    _videoCtrl = VideoPlayerController.file(_captured!)
      ..initialize().then((_) => setState(() {}));
  }

  void _confirm() {
    if (_captured != null) {
      widget.onDone(_captured!);
      Navigator.of(context).pop();
    }
  }

  void _retake() {
    _videoCtrl?.dispose();
    _videoCtrl = null;
    setState(() => _captured = null);
    _initCamera();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    // Preview mode (after capture)
    if (_captured != null) {
      return Column(
        children: [
          Expanded(
            child: widget.mode == CaptureMode.photo
                ? Image.file(_captured!, fit: BoxFit.cover)
                : (_videoCtrl != null && _videoCtrl!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoCtrl!.value.aspectRatio,
              child: VideoPlayer(_videoCtrl!),
            )
                : const Center(child: CircularProgressIndicator())),
          ),
          if (widget.mode == CaptureMode.video && _videoCtrl != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _videoCtrl!.value.isPlaying
                      ? _videoCtrl!.pause()
                      : _videoCtrl!.play();
                });
              },
              icon: Icon(
                _videoCtrl!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RoundButton(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'Retake',
                  onTap: _retake,
                ),
                _RoundButton(
                  icon: Icons.check,
                  color: Colors.green,
                  label: 'Use',
                  onTap: _confirm,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Live preview mode
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CameraPreview(_controller!),
              if (_isRecording)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'REC ${_seconds}s',
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.mode == CaptureMode.photo)
                _ShutterButton(onTap: _capturePhoto)
              else
                _ShutterButton(
                  recording: _isRecording,
                  onTap: _isRecording ? _stopRecording : _startRecording,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool recording;
  final VoidCallback onTap;
  const _ShutterButton({required this.onTap, this.recording = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: recording ? Colors.red : Colors.white,
              shape: recording ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: recording ? BorderRadius.circular(6.r) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTextStyles.medium.copyWith(
            fontSize: 11.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}