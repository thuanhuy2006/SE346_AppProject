import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String url;
  final VoidCallback onVideoFinished;

  const SimpleVideoPlayer({super.key, required this.url, required this.onVideoFinished});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load video từ mạng (Nếu dùng file máy thì đổi thành .asset)
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play(); // Tự động phát
        });
      });

    // Lắng nghe khi video kết thúc
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        widget.onVideoFinished(); // Báo cho màn hình cha biết
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
          // Nút Play/Pause ở giữa
          Center(
            child: IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white.withOpacity(0.5),
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
          )
        ],
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }
}