/// Formatter untuk mengonversi durasi dalam detik ke representasi string.
final class DurationFormatter {
  const DurationFormatter._();

  
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
