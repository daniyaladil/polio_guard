import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        showControls: true,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Video Proof'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null
            ? Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Failed to load video',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        )
            : AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}