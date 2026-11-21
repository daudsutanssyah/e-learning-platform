import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

abstract interface class NetworkChecker {
  Future<bool> get isConnected;
}

/// Implementasi [NetworkChecker] menggunakan dart:io untuk mobile/desktop
final class DartIoNetworkChecker implements NetworkChecker {
  const DartIoNetworkChecker();

  @override
  Future<bool> get isConnected async {
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
