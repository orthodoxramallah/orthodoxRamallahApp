import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/media_service.dart';
import '../theme/app_colors.dart';

class ChantsAudioScreen extends StatefulWidget {
  const ChantsAudioScreen({super.key});

  @override
  State<ChantsAudioScreen> createState() => _ChantsAudioScreenState();
}

class _ChantsAudioScreenState extends State<ChantsAudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  late Future<List<MediaItem>> _audioItemsFuture;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioItemsFuture = MediaService.getAudioItems();

    _audioPlayer.positionStream.listen((position) {
      setState(() => _currentPosition = position);
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() => _totalDuration = duration ?? Duration.zero);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _currentlyPlayingIndex = null;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int index, MediaItem item) async {
    if (_currentlyPlayingIndex == index) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (MediaService.isNetworkPath(item.path)) {
        await _audioPlayer.setUrl(item.path);
      } else {
        await _audioPlayer.setAsset(item.path);
      }
      await _audioPlayer.play();
      setState(() {
        _currentlyPlayingIndex = index;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  void _seekRelative(Duration offset) {
    final newPosition = _currentPosition + offset;
    _audioPlayer.seek(newPosition);
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
          title: const Text('التراتيل الصوتية'),
          elevation: 0,
          centerTitle: true,
        ),
        body: FutureBuilder<List<MediaItem>>(
          future: _audioItemsFuture,
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
                        'فشل تحميل قائمة الصوتيات. حاول مرة أخرى لاحقاً.',
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
                    Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد صوتيات متاحة حالياً.',
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
                final isCurrentlyPlaying = isPlaying && _audioPlayer.playing;

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
                    children: [
                      // Main Content Row
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Album Art / Icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kDarkBlue,
                                    kDarkBlue.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: kDarkBlue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isCurrentlyPlaying
                                    ? Icons.music_note
                                    : Icons.audiotrack,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title and Description
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Play Button
                            if (!isPlaying)
                              Container(
                                decoration: BoxDecoration(
                                  color: kDarkBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kDarkBlue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.play_arrow),
                                  color: Colors.white,
                                  onPressed: () => _playAudio(index, item),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Audio Controls (when playing)
                      if (isPlaying)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              // Progress Slider
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: kDarkBlue,
                                  inactiveTrackColor: kDarkBlue.withValues(alpha: 0.3),
                                  thumbColor: kDarkBlue,
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                ),
                                child: Slider(
                                  value: _currentPosition.inMilliseconds
                                      .toDouble()
                                      .clamp(0, _totalDuration.inMilliseconds.toDouble()),
                                  min: 0,
                                  max: _totalDuration.inMilliseconds.toDouble() > 0
                                      ? _totalDuration.inMilliseconds.toDouble()
                                      : 1,
                                  onChanged: (value) {
                                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                              // Time Display
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: TextStyle(
                                        color: kDarkBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_totalDuration),
                                      style: TextStyle(
                                        color: kDarkBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Control Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.replay_10),
                                    color: kDarkBlue,
                                    iconSize: 28,
                                    onPressed: () => _seekRelative(const Duration(seconds: -10)),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: kDarkBlue,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                        color: kDarkBlue.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                                      ),
                                      color: Colors.white,
                                      iconSize: 32,
                                      onPressed: () => _playAudio(index, item),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.forward_10),
                                    color: kDarkBlue,
                                    iconSize: 28,
                                    onPressed: () => _seekRelative(const Duration(seconds: 10)),
                                  ),
                                ],
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