import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../errors/failures.dart';

/// Service untuk membaca dan mem-parsing file JSON dari asset lokal.
final class LocalJsonService {
  LocalJsonService({
    AssetBundle? bundle,
    this.simulatedDelay = const Duration(milliseconds: 400),
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Duration simulatedDelay;

  /// Membaca file JSON dari asset dan mengembalikan `Map<String, dynamic>`.
  ///
  /// Mensimulasikan delay untuk memverifikasi loading state.
  /// Melempar [DataParsingFailure] jika:
  /// - Format JSON tidak valid
  /// - Gagal membaca file asset
  /// - Root JSON bukan Map/Object
  Future<Map<String, dynamic>> loadJsonObject(String assetPath) async {
    try {
      await Future.delayed(simulatedDelay);

      final jsonString = await _bundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        throw const DataParsingFailure(
          'Root JSON harus berupa objek, bukan array atau tipe lain.',
        );
      }

      return decoded;
    } on DataParsingFailure {
      rethrow;
    } on FormatException {
      throw const DataParsingFailure('Format JSON tidak valid.');
    } on FlutterError {
      throw const DataParsingFailure('Gagal membaca file asset.');
    } catch (e) {
      throw DataParsingFailure('Error parsing JSON: $e');
    }
  }
}
