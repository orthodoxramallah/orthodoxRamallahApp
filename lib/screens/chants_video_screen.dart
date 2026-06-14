import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/media_service.dart';
import '../theme/app_colors.dart';

class ChantsVideoScreen extends StatefulWidget {
  const ChantsVideoScreen({super.key});

  @override
  State<ChantsVideoScreen> createState() => _ChantsVideoScreenState();
}

class _ChantsVideoScreenState extends State<ChantsVideoScreen> {
  VideoPlayerController? _controller;
  int? _currentlyPlayingIndex;
  late Future<List<MediaItem>> _videoItemsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _videoItemsFuture = MediaService.getVideoItems();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _playVideo(int index, MediaItem item) async {
    if (_currentlyPlayingIndex == index) {
      if (_controller?.value.isPlaying ?? false) {
        await _controller?.pause();
      } else {
        await _controller?.play();
      }
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    _controller?.dispose();

    try {
      if (MediaService.isNetworkPath(item.path)) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(item.path));
      } else {
        _controller = VideoPlayerController.asset(item.path);
      }

      await _controller?.initialize();
      _controller?.addListener(() => setState(() {}));
      await _controller?.play();
      setState(() {
        _currentlyPlayingIndex = index;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تشغيل الفيديو: $e')),
        );
      }
    }
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + offset;
    _controller!.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفيديوهات'),
          elevation: 0,
          centerTitle: true,
        ),
        body: FutureBuilder<List<MediaItem>>(
          future: _videoItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'فشل تحميل قائمة الفيديوهات. حاول مرة أخرى لاحقاً.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد فيديوهات متاحة حالياً.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isPlaying = _currentlyPlayingIndex == index;
                final isCurrentlyPlaying = isPlaying && (_controller?.value.isPlaying ?? false);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: isPlaying ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isPlaying
                        ? BorderSide(color: kDarkBlue, width: 2)
                        : BorderSide.none,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Video Player / Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isPlaying && _controller != null && _controller!.value.isInitialized)
                              AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            else
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      kDarkBlue.withValues(alpha: 0.7),
                                    kDarkBlue.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 72,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            if (_isLoading && _currentlyPlayingIndex == null)
                              Container(
                                height: 200,
                                color: Colors.black45,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Video Controls (when playing)
                      if (isPlaying && _controller != null && _controller!.value.isInitialized)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: kDarkBlue.withValues(alpha: 0.1),
                          ),
                          child: Column(
                            children: [
                              // Progress Slider
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: kDarkBlue,
                                  inactiveTrackColor: kDarkBlue.withValues(alpha: 0.3),
                                  thumbColor: kDarkBlue,
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _controller!.value.position.inMilliseconds.toDouble(),
                                  min: 0,
                                  max: _controller!.value.duration.inMilliseconds.toDouble(),
                                  onChanged: (value) {
                                    _controller!.seekTo(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                              // Time Display
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_controller!.value.position),
                                      style: TextStyle(color: kDarkBlue, fontSize: 12),
                                    ),
                                    Text(
                                      _formatDuration(_controller!.value.duration),
                                      style: TextStyle(color: kDarkBlue, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Control Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.replay_10),
                                    color: kDarkBlue,
                                    iconSize: 32,
                                    onPressed: () => _seekRelative(const Duration(seconds: -10)),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: kDarkBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                                      ),
                                      color: Colors.white,
                                      iconSize: 36,
                                      onPressed: () => _playVideo(index, item),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.forward_10),
                                    color: kDarkBlue,
                                    iconSize: 32,
                                    onPressed: () => _seekRelative(const Duration(seconds: 10)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Title and Description
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isPlaying)
                              Container(
                                decoration: BoxDecoration(
                                  color: kDarkBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  color: Colors.white,
                                  onPressed: () => _playVideo(index, item),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}