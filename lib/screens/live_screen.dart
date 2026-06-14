import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class LivePlayerPage extends StatefulWidget {
  const LivePlayerPage({super.key});

  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  static const String _liveStreamUrl =
      'https://htvint.mada.ps/orthodoxramallah/index.m3u8';

  late final Player _player;
  late final VideoController _controller;

  Timer? _retryTimer;
  Timer? _loadingTimer;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = Player();

    // Force software rendering to fix black screen on Android
    _controller = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );

    _player.stream.error.listen(_onError);
    _player.stream.playing.listen(_onPlaying);

    _loadLiveSource();
  }

  void _onError(String error) {
    if (!mounted) return;
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
    _scheduleRetry();
  }

  void _onPlaying(bool playing) {
    if (!mounted) return;
    if (playing) {
      _loadingTimer?.cancel();
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    }
  }

  Future<void> _loadLiveSource() async {
    _retryTimer?.cancel();
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _player.open(
        Media(_liveStreamUrl),
        play: true,
      );

      // Fallback: hide loading after 5 seconds if playing event is delayed
      _loadingTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _isLoading && !_hasError) {
          setState(() => _isLoading = false);
        }
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), _loadLiveSource);
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _loadLiveSource();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _loadingTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildPlayerArea() {
      if (_hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'لا يوجد بث مباشر الآن',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'البث غير متاح حاليًا. جاري إعادة المحاولة تلقائيًا للتحقق من حالة البث.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video always rendered underneath
                  Video(
                    controller: _controller,
                    controls: NoVideoControls,
                  ),
                  // Loading overlay on top until stream starts
                  if (_isLoading)
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [buildPlayerArea(), const SizedBox(height: 24)],
      ),
    );
  }
}
