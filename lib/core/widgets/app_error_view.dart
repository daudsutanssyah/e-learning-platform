import 'package:material_ui/material_ui.dart';

import '../errors/failures.dart';
import '../theme/app_colors.dart';

/// Komponen terpusat untuk menampilkan state error atau kegagalan koneksi.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
  });

  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    // Pattern matching Dart 3 untuk membedakan tipe kegagalan
    final (IconData icon, String title, String message, Color iconColor) =
        switch (error) {
      NetworkFailure failure => (
          Icons.wifi_off_rounded,
          'Koneksi Internet Terputus',
          customMessage ?? failure.message,
          AppColors.warning,
        ),
      DataParsingFailure failure => (
          Icons.data_object_rounded,
          'Gagal Memproses Data',
          customMessage ?? failure.message,
          AppColors.error,
        ),
      NotFoundFailure failure => (
          Icons.search_off_rounded,
          'Data Tidak Ditemukan',
          customMessage ?? failure.message,
          AppColors.textMuted,
        ),
      PlaybackFailure failure => (
          Icons.play_disabled_rounded,
          'Gagal Memutar Video',
          customMessage ?? failure.toString(),
          AppColors.error,
        ),
      UnknownFailure failure => (
          Icons.error_outline_rounded,
          'Terjadi Kesalahan',
          customMessage ?? failure.message,
          AppColors.error,
        ),
      _ => (
          Icons.error_outline_rounded,
          'Terjadi Kesalahan',
          customMessage ?? error.toString(),
          AppColors.error,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
