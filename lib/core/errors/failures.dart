/// Base class untuk semua failure di aplikasi.
///
/// Menggunakan sealed class untuk memastikan exhaustive pattern matching
/// dan type-safe error handling.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Failure ketika terjadi masalah koneksi jaringan.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.',
  ]);
}

/// Failure ketika parsing data gagal atau format tidak sesuai.
final class DataParsingFailure extends AppFailure {
  const DataParsingFailure([
    super.message = 'Gagal memproses data. Format tidak valid.',
  ]);
}

/// Failure ketika resource yang diminta tidak ditemukan.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([
    super.message = 'Data tidak ditemukan.',
  ]);
}

/// Failure yang terjadi saat pemutaran video.
final class PlaybackFailure extends AppFailure {
  const PlaybackFailure([
    super.message = 'Gagal memutar video.',
    this.errorCode,
  ]);

  final int? errorCode;

  @override
  String toString() => errorCode != null
      ? '$message (Error code: $errorCode)'
      : message;
}

/// Failure untuk error yang tidak terkategori.
final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'Terjadi kesalahan yang tidak diketahui.',
  ]);
}
