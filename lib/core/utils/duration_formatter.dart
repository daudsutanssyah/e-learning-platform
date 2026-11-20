/// Formatter untuk mengonversi durasi dalam detik ke representasi string.
final class DurationFormatter {
  const DurationFormatter._();

  /// Mengonversi total detik ke format clock `mm:ss` atau `h:mm:ss`.
  ///
  /// Contoh:
  /// - `65` -> `"1:05"`
  /// - `3661` -> `"1:01:01"`
  /// - `0` -> `"0:00"`
  static String toClockFormat(int totalSeconds) {
    if (totalSeconds <= 0) return '0:00';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Mengonversi total detik ke format ringkas berbahasa Indonesia.
  ///
  /// Contoh:
  /// - `1860` -> `"31 mnt"`
  /// - `3600` -> `"1 j"`
  /// - `4500` -> `"1 j 15 mnt"`
  /// - `0` -> `"0 mnt"`
  static String toReadableTotal(int totalSeconds) {
    if (totalSeconds <= 0) return '0 mnt';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return '$hours j $minutes mnt';
    } else if (hours > 0) {
      return '$hours j';
    } else {
      return '$minutes mnt';
    }
  }
}
