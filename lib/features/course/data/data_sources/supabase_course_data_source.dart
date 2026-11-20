import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../models/course_model.dart';
import 'course_data_source.dart';

/// Implementasi [CourseDataSource] yang mengambil data dari Supabase PostgreSQL API.
final class SupabaseCourseDataSource implements CourseDataSource {
  const SupabaseCourseDataSource({
    required this.client,
    required this.networkChecker,
  });

  final SupabaseClient client;
  final NetworkChecker networkChecker;

  @override
  Future<List<CourseModel>> fetchCourses() async {
    final isConnected = await networkChecker.isConnected;
    if (!isConnected) {
      throw const NetworkFailure();
    }

    try {
      final response = await client
          .from('courses')
          .select('*, lessons(*)')
          .order('id', ascending: true);

      final dataList = response as List<dynamic>;
      if (dataList.isEmpty) {
        return const [];
      }

      return dataList
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
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
      throw UnknownFailure('Gagal memuat data kursus: $e');
    }
  }

  @override
  Future<CourseModel> fetchCourseById(String courseId) async {
    final isConnected = await networkChecker.isConnected;
    if (!isConnected) {
      throw const NetworkFailure();
    }

    try {
      final response = await client
          .from('courses')
          .select('*, lessons(*)')
          .eq('id', courseId)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundFailure('Kursus tidak ditemukan.');
      }

      return CourseModel.fromJson(response);
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
      throw UnknownFailure('Gagal memuat data kursus: $e');
    }
  }
}
