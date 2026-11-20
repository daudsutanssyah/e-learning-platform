import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../models/lesson_model.dart';
import 'lesson_data_source.dart';

/// Implementasi [LessonDataSource] yang mengambil data dari Supabase PostgreSQL API.
final class SupabaseLessonDataSource implements LessonDataSource {
  const SupabaseLessonDataSource({
    required this.client,
    required this.networkChecker,
  });

  final SupabaseClient client;
  final NetworkChecker networkChecker;

  @override
  Future<List<LessonModel>> fetchLessonsByCourseId(String courseId) async {
    final isConnected = await networkChecker.isConnected;
    if (!isConnected) {
      throw const NetworkFailure();
    }

    try {
      final response = await client
          .from('lessons')
          .select()
          .eq('course_id', courseId)
          .order('order', ascending: true);

      final dataList = response as List<dynamic>;
      if (dataList.isEmpty) {
        return const [];
      }

      return dataList
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppFailure {
      rethrow;
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on PostgrestException catch (e) {
      throw UnknownFailure('Kesalahan basis data: ${e.message}');
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw UnknownFailure('Gagal memuat materi kursus: $e');
    }
  }

  @override
  Future<LessonModel> fetchLessonById(String lessonId) async {
    final isConnected = await networkChecker.isConnected;
    if (!isConnected) {
      throw const NetworkFailure();
    }

    try {
      final response = await client
          .from('lessons')
          .select()
          .eq('id', lessonId)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundFailure('Materi tidak ditemukan.');
      }

      return LessonModel.fromJson(response);
    } on AppFailure {
      rethrow;
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on PostgrestException catch (e) {
      throw UnknownFailure('Kesalahan basis data: ${e.message}');
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw UnknownFailure('Gagal memuat materi: $e');
    }
  }
}
