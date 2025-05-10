import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:najih_education_app/constants/api_config.dart';

class FileUploadService {
  final Dio _dio;

  FileUploadService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Content-Type': 'multipart/form-data'},
        ));

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

    try {
      final res = await _dio.post(
        '$route/upload/$filter',
        data: formData,
        onSendProgress: onProgress,
      );

      final data = res.data is String ? jsonDecode(res.data) : res.data;
      print('Upload response: $data');

      if (data is Map<String, dynamic> &&
          data.containsKey('url') &&
          data['url'] != null &&
          data['url'].toString().isNotEmpty) {
        return data;
      }

      throw Exception('Missing or empty "url" field in response');
    } catch (e) {
      print('Upload error: $e');
      throw DioException(
        requestOptions: RequestOptions(path: '$route/upload/$filter'),
        message: 'Upload failed: $e',
      );
    }
  }

  Future<void> deleteFile({
    required String route,
    required String filename,
  }) async {
    await _dio.delete('$route/delete/$filename');
  }
}
