import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Kontrak untuk memeriksa koneksi jaringan.
abstract interface class NetworkChecker {
  /// Memeriksa apakah perangkat terhubung ke internet.
  Future<bool> get isConnected;
}

/// Implementasi [NetworkChecker] menggunakan dart:io untuk mobile/desktop
/// dan fallback ramah web untuk browser.
///
/// Pada platform Web, perutean socket raw/DNS tidak didukung oleh browser,
/// sehingga langsung mengembalikan status aktif secara aman tanpa memicu UnsupportedError.
final class DartIoNetworkChecker implements NetworkChecker {
  const DartIoNetworkChecker();

  @override
  Future<bool> get isConnected async {
    // Platform web tidak mendukung lookup socket raw dart:io (akan melempar UnsupportedError)
    if (kIsWeb) {
      return true;
    }

    try {
      final result = await InternetAddress.lookup(
        'one.one.one.one',
        type: InternetAddressType.IPv4,
      ).timeout(const Duration(milliseconds: 1500));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
