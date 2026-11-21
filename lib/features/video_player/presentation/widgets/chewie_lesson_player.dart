import 'package:chewie/chewie.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../providers/video_player_provider.dart';
import '../providers/video_player_state.dart';

class ChewieLessonPlayer extends ConsumerStatefulWidget {
  const ChewieLessonPlayer({
    super.key,
    required this.lessonId,
    required this.videoUrl,
    this.onVideoEnded,
  });

  final String lessonId;
  final String videoUrl;
  final VoidCallback? onVideoEnded;

  @override
  ConsumerState<ChewieLessonPlayer> createState() => _ChewieLessonPlayerState();
}

class _ChewieLessonPlayerState extends ConsumerState<ChewieLessonPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  VoidCallback? _videoListener;
  int _initToken = 0;
  bool _hasEndedTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(videoPlayerProvider.notifier)
          .loadLesson(lessonId: widget.lessonId, videoUrl: widget.videoUrl);
    });
  }

  @override
  void didUpdateWidget(covariant ChewieLessonPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.videoUrl != widget.videoUrl) {
      _initToken++;
      _disposeControllers(deferDispose: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(videoPlayerProvider.notifier)
            .loadLesson(lessonId: widget.lessonId, videoUrl: widget.videoUrl);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _pauseSafely();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _initToken++;
    _disposeControllers(deferDispose: false);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _pauseSafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          if (_videoPlayerController?.value.isInitialized == true &&
              _videoPlayerController?.value.isPlaying == true) {
            _videoPlayerController?.pause();
          }
        } catch (_) {}
      });
    } else {
      try {
        if (_videoPlayerController?.value.isInitialized == true &&
            _videoPlayerController?.value.isPlaying == true) {
          _videoPlayerController?.pause();
        }
      } catch (_) {}
    }
  }

  void _disposeControllers({bool deferDispose = false}) {
    final oldChewie = _chewieController;
    final oldVideo = _videoPlayerController;
    final oldListener = _videoListener;

    _chewieController = null;
    _videoPlayerController = null;
    _videoListener = null;

    if (oldListener != null) {
      try {
        oldVideo?.removeListener(oldListener);
      } catch (_) {}
    }

    void performDispose() {
      try {
        oldChewie?.dispose();
      } catch (_) {}

      try {
        oldVideo?.dispose();
      } catch (_) {}
    }

    if (deferDispose) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        performDispose();
      });
    } else {
      performDispose();
    }
  }

  void _onVideoPlayerChanged(int token, VideoPlayerController controller) {
    if (!mounted || token != _initToken) return;

    void safeDispatch(VoidCallback action) {
      final phase = SchedulerBinding.instance.schedulerPhase;
      if (phase == SchedulerPhase.persistentCallbacks ||
          phase == SchedulerPhase.midFrameMicrotasks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || token != _initToken) return;
          action();
        });
      } else {
        action();
      }
    }

    final value = controller.value;
    if (value.hasError) {
      debugPrint(
        'ChewieLessonPlayer playback error: ${value.errorDescription}',
      );
      safeDispatch(() {
        ref
            .read(videoPlayerProvider.notifier)
            .setError(
              'Video tidak dapat dimuat. Sumber video tidak tersedia atau koneksi terputus.',
            );
      });
      return;
    }

    if (value.isBuffering) {
      safeDispatch(() {
        ref
            .read(videoPlayerProvider.notifier)
            .updateStatus(LessonPlaybackStatus.buffering);
      });
      return;
    }

    if (value.isPlaying) {
      safeDispatch(() {
        ref
            .read(videoPlayerProvider.notifier)
            .updateStatus(LessonPlaybackStatus.playing);
      });
      return;
    }

    if (value.isInitialized) {
      final position = value.position;
      final duration = value.duration;
      if (duration > Duration.zero && position >= duration) {
        if (!_hasEndedTriggered) {
          _hasEndedTriggered = true;
          safeDispatch(() {
            ref
                .read(videoPlayerProvider.notifier)
                .updateStatus(LessonPlaybackStatus.ended);
            widget.onVideoEnded?.call();
          });
        }
      } else {
        safeDispatch(() {
          ref
              .read(videoPlayerProvider.notifier)
              .updateStatus(LessonPlaybackStatus.paused);
        });
      }
    }
  }

  Future<void> _initControllers(String url) async {
    final token = ++_initToken;
    _hasEndedTriggered = false;
    _disposeControllers(deferDispose: true);

    final uri = Uri.parse(url);
    final isHls = uri.path.toLowerCase().endsWith('.m3u8');
    final videoController = VideoPlayerController.networkUrl(
      uri,
      formatHint: isHls ? VideoFormat.hls : null,
    );

    _videoListener = () => _onVideoPlayerChanged(token, videoController);
    videoController.addListener(_videoListener!);

    void safeDispatch(VoidCallback action) {
      final phase = SchedulerBinding.instance.schedulerPhase;
      if (phase == SchedulerPhase.persistentCallbacks ||
          phase == SchedulerPhase.midFrameMicrotasks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || token != _initToken) return;
          action();
        });
      } else {
        action();
      }
    }

    try {
      await videoController.initialize();
      if (!mounted || token != _initToken) {
        await videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        aspectRatio: videoController.value.aspectRatio > 0
            ? videoController.value.aspectRatio
            : 16 / 9,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          debugPrint('ChewieController errorBuilder: $errorMessage');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Video tidak dapat dimuat. Sumber video tidak tersedia atau koneksi terputus.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          );
        },
      );

      if (!mounted || token != _initToken) {
        chewieController.dispose();
        await videoController.dispose();
        return;
      }

      _videoPlayerController = videoController;
      _chewieController = chewieController;

      safeDispatch(() {
        ref
            .read(videoPlayerProvider.notifier)
            .updateStatus(LessonPlaybackStatus.ready);
      });

      if (mounted) {
        final phase = SchedulerBinding.instance.schedulerPhase;
        if (phase == SchedulerPhase.persistentCallbacks ||
            phase == SchedulerPhase.midFrameMicrotasks) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && token == _initToken) {
              setState(() {});
            }
          });
        } else {
          setState(() {});
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ChewieLessonPlayer initialization error: $e\n$stackTrace');

      if (!mounted || token != _initToken) {
        await videoController.dispose();
        return;
      }

      final String userFriendlyMessage;
      if (e is PlatformException) {
        userFriendlyMessage = 'Video tidak dapat dimuat. Sumber video tidak tersedia atau koneksi terputus.';
      } else {
        userFriendlyMessage = 'Video tidak dapat dimuat. Sumber video tidak tersedia atau koneksi terputus.';
      }

      safeDispatch(() {
        ref.read(videoPlayerProvider.notifier).setError(userFriendlyMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VideoPlayerUiState>(videoPlayerProvider, (previous, next) {
      if (next.status == LessonPlaybackStatus.loading &&
          next.videoUrl != null) {
        final hasVideoChanged = previous?.videoUrl != next.videoUrl;
        final hasRetried = previous?.retryAttempt != next.retryAttempt;

        if (hasVideoChanged || hasRetried || _chewieController == null) {
          _initControllers(next.videoUrl!);
        }
      }
    });

    final state = ref.watch(videoPlayerProvider);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(color: Colors.black, child: _buildPlayerContent(state)),
    );
  }

  Widget _buildPlayerContent(VideoPlayerUiState state) {
    // 1. Error state (koneksi offline atau gagal playback)
    if (state.status == LessonPlaybackStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.isOfflineError
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ??
                    'Terjadi kesalahan saat memuat materi video.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(videoPlayerProvider.notifier)
                      .retry(
                        lessonId: widget.lessonId,
                        videoUrl: widget.videoUrl,
                      );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Loading state atau inisialisasi controller belum tuntas
    if (_chewieController == null ||
        _videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized ||
        state.status == LessonPlaybackStatus.initial ||
        state.status == LessonPlaybackStatus.checkingConnection ||
        state.status == LessonPlaybackStatus.loading) {
      final message = state.status == LessonPlaybackStatus.checkingConnection
          ? 'Memeriksa koneksi internet...'
          : 'Memuat video materi...';

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // 3. Controller siap dan aktif ditampilkan dengan key unik ChewieController
    return Chewie(
      key: ValueKey(_chewieController),
      controller: _chewieController!,
    );
  }
}
