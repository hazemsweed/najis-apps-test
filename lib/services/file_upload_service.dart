import 'dart:io';
import 'package:dio/dio.dart';

/// Central file-upload helper based on Dio.
/// It POSTs to  {baseUrl}{route}/upload/{filter}
///   • returns decoded JSON from the server
///   • reports progress via [onProgress]
///   • lets you delete a file later
class FileUploadService {
  /// Default base URL (change to your real host)
  static const String _defaultBase =
      'http://localhost:1022/'; // ← update if needed

  final Dio _dio;

  FileUploadService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultBase,
          headers: {'Content-Type': 'multipart/form-data'},
        ));

  /// Upload a single [file] to  {baseUrl}{route}/upload/{filter}
  ///
  /// • [route]  e.g.  'studentsLessons'
  /// • [filter] e.g.  'only-images'  or  'all-files'  (matches your backend)
  ///
  /// Returns the server’s JSON `{ url, filename, ... }`
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String route,
    required String filter,
    void Function(int sent, int total)? onProgress,
  }) async {
    final name = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: name,
      ),
    });

    final res = await _dio.post<Map<String, dynamic>>(
      '$route/upload/$filter',
      data: formData,
      onSendProgress: onProgress,
    );

    if (res.statusCode == 200 && res.data != null) {
      return res.data!;
    }
    throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Upload failed');
  }

  /// Deletes a file you previously uploaded
  Future<void> deleteFile({
    required String route,
    required String filename,
  }) async {
    await _dio.delete('$route/delete/$filename');
  }
}
