/// Status siklus pemutaran video materi pembelajaran.
enum LessonPlaybackStatus {
  initial,
  checkingConnection,
  loading,
  ready,
  playing,
  paused,
  buffering,
  ended,
  error,
}

/// State immutable representasi UI pemutar video materi pembelajaran.
final class VideoPlayerUiState {
  const VideoPlayerUiState({
    this.activeLessonId,
    this.videoUrl,
    this.status = LessonPlaybackStatus.initial,
    this.errorMessage,
    this.isOfflineError = false,
    this.retryAttempt = 0,
  });

  final String? activeLessonId;
  final String? videoUrl;
  final LessonPlaybackStatus status;
  final String? errorMessage;
  final bool isOfflineError;
  final int retryAttempt;

  /// Membuat salinan state dengan opsi pembaruan field dan pembersihan error eksplisit.
  VideoPlayerUiState copyWith({
    String? activeLessonId,
    String? videoUrl,
    LessonPlaybackStatus? status,
    String? errorMessage,
    bool? isOfflineError,
    int? retryAttempt,
    bool clearError = false,
  }) {
    return VideoPlayerUiState(
      activeLessonId: activeLessonId ?? this.activeLessonId,
      videoUrl: videoUrl ?? this.videoUrl,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOfflineError:
          clearError ? false : (isOfflineError ?? this.isOfflineError),
      retryAttempt: retryAttempt ?? this.retryAttempt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlayerUiState &&
          runtimeType == other.runtimeType &&
          activeLessonId == other.activeLessonId &&
          videoUrl == other.videoUrl &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          isOfflineError == other.isOfflineError &&
          retryAttempt == other.retryAttempt;

  @override
  int get hashCode => Object.hash(
        activeLessonId,
        videoUrl,
        status,
        errorMessage,
        isOfflineError,
        retryAttempt,
      );

  @override
  String toString() =>
      'VideoPlayerUiState(activeLessonId: $activeLessonId, videoUrl: $videoUrl, '
      'status: $status, errorMessage: $errorMessage, isOfflineError: $isOfflineError, '
      'retryAttempt: $retryAttempt)';
}
