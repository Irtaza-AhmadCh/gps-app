// import 'dart:async';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// import 'logger_service.dart';

// class InternetService {
//   static final Connectivity _connectivity = Connectivity();

//   static const Duration _timeout = Duration(seconds: 3);
//   static const Duration _overallTimeout = Duration(seconds: 6);
//   static DateTime? _lastCheckTime;
//   static bool? _lastCheckResult;

//   static Future<bool> hasWorkingInternet({
//     int retries = 2,
//     Duration cacheDuration = const Duration(seconds: 2),
//     bool useCache = true,
//   }) async {
//     // Return cached result if valid
//     if (useCache &&
//         _lastCheckTime != null &&
//         DateTime.now().difference(_lastCheckTime!) < cacheDuration &&
//         _lastCheckResult != null) {
//       LoggerService.i('💾 Using cached internet result: $_lastCheckResult');
//       return _lastCheckResult!;
//     }

//     try {
//       final result = await _checkWithRetries(retries).timeout(
//         _overallTimeout,
//         onTimeout: () {
//           LoggerService.w('⏱️ Internet check timed out');
//           return false;
//         },
//       );

//       _lastCheckTime = DateTime.now();
//       _lastCheckResult = result;
//       return result;
//     } catch (e, stack) {
//       LoggerService.e(
//         '❌ Unhandled error during internet check',
//         error: e,
//         stackTrace: stack,
//       );
//       return false;
//     }
//   }

//   static Future<bool> _checkWithRetries(int retries) async {
//     for (int attempt = 0; attempt <= retries; attempt++) {
//       final result = await _checkOnce();
//       if (result) return true;

//       if (attempt < retries) {
//         final wait = Duration(milliseconds: 500 * (attempt + 1));
//         LoggerService.i(
//             '🔁 Retry $attempt failed. Waiting ${wait.inMilliseconds}ms before retry...');
//         await Future.delayed(wait);
//       }
//     }
//     return false;
//   }

//   static Future<bool> _checkOnce() async {
//     try {
//       // 1. Check network interface
//       final connectivityResult = await _connectivity.checkConnectivity();
//       if (connectivityResult == ConnectivityResult.none) {
//         LoggerService.w('🚫 No WiFi or Mobile Data');
//         return false;
//       }
//       LoggerService.i('📶 Connected via: $connectivityResult');

//       // 2. Do actual HTTP request to Google
//       final response = await http
//           .get(Uri.parse('https://www.google.com'))
//           .timeout(_timeout);

//       final success = response.statusCode == 200;
//       LoggerService.i(
//         success
//             ? '✅ Internet access confirmed (Google responded)'
//             : '❌ Google responded with status: ${response.statusCode}',
//       );
//       return success;
//     } on TimeoutException {
//       LoggerService.w('⏱️ Timeout while checking internet (Google)');
//       return false;
//     } on SocketException catch (e) {
//       LoggerService.w('❌ SocketException: $e');
//       return false;
//     } catch (e) {
//       LoggerService.w('⚠️ Unexpected error: $e');
//       return false;
//     }
//   }
// }
