import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/errors/failures.dart';
import 'video_player_state.dart';

/// Provider pengelola state pemutar video dengan autoDispose untuk mencegah memory leak.
final videoPlayerProvider =
    NotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerUiState>(
  VideoPlayerNotifier.new,
);

/// Notifier untuk mengendalikan alur state, validasi koneksi, dan lifecycle pemutar video.
class VideoPlayerNotifier extends Notifier<VideoPlayerUiState> {
  @override
  VideoPlayerUiState build() {
    return const VideoPlayerUiState();
  }

  /// Memuat materi pembelajaran ke dalam pemutar video dengan validasi URI, koneksi, dan anti-race condition.
  Future<void> loadLesson({
    required String lessonId,
    required String videoUrl,
  }) async {
    // 1. Validasi format URL video
    final uri = Uri.tryParse(videoUrl);
    final isValid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (!isValid) {
      state = state.copyWith(
        activeLessonId: lessonId,
        videoUrl: null,
        status: LessonPlaybackStatus.error,
        errorMessage: 'Format tautan video tidak valid.',
        isOfflineError: false,
      );
      return;
    }

    // 2. Set status checkingConnection
    state = state.copyWith(
      activeLessonId: lessonId,
      status: LessonPlaybackStatus.checkingConnection,
      clearError: true,
    );

    // 3. Periksa status konektivitas internet secara aktif
    final isConnected = await ref.read(networkCheckerProvider).isConnected;

    // 4. Validasi anti-race condition: abaikan hasil jika pengguna sudah berpindah materi
    if (state.activeLessonId != lessonId) {
      return;
    }

    // 5. Tangani kondisi offline
    if (!isConnected) {
      state = state.copyWith(
        status: LessonPlaybackStatus.error,
        errorMessage: const NetworkFailure().message,
        isOfflineError: true,
      );
      return;
    }

    // 6. Set status loading dengan URL video terverifikasi
    state = state.copyWith(
      status: LessonPlaybackStatus.loading,
      videoUrl: videoUrl,
      isOfflineError: false,
      clearError: true,
    );
  }

  /// Mencoba memuat ulang video dengan menaikkan penanda `retryAttempt`.
  Future<void> retry({
    required String lessonId,
    required String videoUrl,
  }) async {
    state = state.copyWith(
      retryAttempt: state.retryAttempt + 1,
    );
    await loadLesson(lessonId: lessonId, videoUrl: videoUrl);
  }

  /// Memperbarui status playback jika berbeda dengan status saat ini.
  void updateStatus(LessonPlaybackStatus status) {
    if (state.status != status) {
      state = state.copyWith(status: status);
    }
  }

  /// Menetapkan pesan error kustom untuk pemutar video.
  void setError(String message, {bool isOffline = false}) {
    state = state.copyWith(
      status: LessonPlaybackStatus.error,
      errorMessage: message,
      isOfflineError: isOffline,
    );
  }

  /// Mengembalikan state pemutar video ke kondisi awal.
  void reset() {
    state = const VideoPlayerUiState();
  }
}
