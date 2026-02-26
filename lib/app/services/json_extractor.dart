import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/global_variables.dart';

class MessageExtractor {
  final Logger _logger = Logger();

  /// Extracts and stores all relevant API error messages
  void extractAndStoreMessage(String endPoint, String responseBody) {
    GlobalVariables.errorMessages
      .clear();
    try {
      _logger.i("💡 API EndPoint: $endPoint - Raw Response: $responseBody");

      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        GlobalVariables.errorMessages
            .add("Unexpected server response format. Please try again.");
        return;
      }

      final jsonMap = decoded;

      // ✅ Case 1: Laravel-style "errors" map
      if (jsonMap['errors'] is Map<String, dynamic>) {
        final errorsMap = jsonMap['errors'] as Map<String, dynamic>;
        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List) {
            for (final msg in value) {
              if (msg != null && msg.toString().trim().isNotEmpty) {
                GlobalVariables.errorMessages.add(msg.toString().trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(value.trim());
          }
        }
      }

      // ✅ Case 2: Simple list in "errors"
      else if (jsonMap['errors'] is List) {
        final errorsList = jsonMap['errors'] as List;
        for (final error in errorsList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      }

      // ✅ Case 3: Validation error list in "data"
      else if (jsonMap['data'] is List) {
        final dataList = jsonMap['data'] as List;
        for (final error in dataList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      }

      // ✅ Optional fallback to top-level message (if no detailed errors found)
      if (GlobalVariables.errorMessages.isEmpty &&
          jsonMap['message'] != null &&
          jsonMap['message'].toString().trim().isNotEmpty) {
        GlobalVariables.errorMessages.add(jsonMap['message'].toString().trim());
      }

      // ✅ Final fallback if still empty
      if (GlobalVariables.errorMessages.isEmpty) {
        GlobalVariables.errorMessages
            .add("Something went wrong. Please try again later.");
      }
    } catch (e, st) {
      _logger.e("❌ Error extracting message: $e", error: e, stackTrace: st);
      GlobalVariables.errorMessages
          .add("Connection issue. Please check your network and retry.");
    }

    _logger.i("✅ Extracted Errors: ${GlobalVariables.errorMessages}");
  }
}
