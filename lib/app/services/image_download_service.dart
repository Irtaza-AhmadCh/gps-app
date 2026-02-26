// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'logger_service.dart';
//
// class ImageDownloadService {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 30),
//       sendTimeout: const Duration(seconds: 10),
//       responseType: ResponseType.bytes,
//     ),
//   )..interceptors.add(LogInterceptor(responseBody: false));
//
//   static const int _maxConcurrentDownloads = 3;
//   static final _semaphore = _Semaphore(_maxConcurrentDownloads);
//
//   /// Downloads a single file with retry logic and timeout
//   static Future<File?> _downloadWithRetry(String url, String filePath, {int retries = 3}) async {
//     for (int attempt = 1; attempt <= retries; attempt++) {
//       try {
//         final response = await _dio.download(url, filePath, options: Options(responseType: ResponseType.bytes));
//
//         if (response.statusCode == 200) {
//           return File(filePath);
//         }
//       } catch (e) {
//         if (attempt == retries) {
//           LoggerService.e('Download failed for $url after $retries attempts.', error: e);
//         } else {
//           await Future.delayed(const Duration(seconds: 2));
//         }
//       }
//     }
//     return null;
//   }
//
//   /// Downloads multiple files with concurrency limit
//   static Future<List<File>> downloadFilesFromUrls(List<String>? urls, String filePrefix) async {
//     if (urls == null || urls.isEmpty) return [];
//
//     final tempDir = await getTemporaryDirectory();
//     final List<File> downloadedFiles = [];
//
//     final List<Future<void>> tasks = [];
//
//     for (int index = 0; index < urls.length; index++) {
//       LoggerService.i("Url of PDF: ${urls[index]}");
//
//       final url = urls[index];
//       final filePath = '${tempDir.path}/${filePrefix + index.toString()}_${getNormalizedFileExtension(url)}';
//
//       tasks.add(
//         _semaphore.withPermit(() async {
//           try {
//             final file = await _downloadWithRetry(url, filePath);
//             if (file != null) {
//               downloadedFiles.add(file);
//             }
//           } catch (e, s) {
//             LoggerService.e("Failed to download file from $url $e $s");
//           }
//         }),
//       );
//     }
//
//     await Future.wait(tasks);
//     return downloadedFiles;
//   }
// }
// // function to check the files extentions
//
// String getNormalizedFileExtension(String url) {
//   final uri = Uri.parse(url);
//   final extension = uri.path.split('.').last.toLowerCase();
//
//   // Normalize image types to '.jpg'
//   const imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'bmp'];
//
//   if (imageExtensions.contains(extension)) {
//     return '.jpg'; // Normalize all image types to .jpg
//   } else if (extension == 'pdf') {
//     return '.pdf';
//   }
//
//   return 'unknown'; // fallback for unsupported types
// }
//
// /// Simple semaphore to control concurrency
// class _Semaphore {
//   final int _maxConcurrent;
//   int _current = 0;
//   final _waitQueue = <Completer<void>>[];
//
//   _Semaphore(this._maxConcurrent);
//
//   Future<void> _acquire() {
//     if (_current < _maxConcurrent) {
//       _current++;
//       return Future.value();
//     }
//
//     final completer = Completer<void>();
//     _waitQueue.add(completer);
//     return completer.future;
//   }
//
//   void _release() {
//     if (_waitQueue.isNotEmpty) {
//       _waitQueue.removeAt(0).complete();
//     } else {
//       _current--;
//     }
//   }
//
//   Future<T> withPermit<T>(Future<T> Function() action) async {
//     await _acquire();
//     try {
//       return await action();
//     } finally {
//       _release();
//     }
//   }
// }
