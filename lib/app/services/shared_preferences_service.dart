// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:social_media_app_flutter/app/mvvm/model/api_reponse/signup_login_resp_model.dart';
// import '../mvvm/model/api_reponse/login_resp_model.dart';
// import '../mvvm/model/app_user_model.dart';
// import '../mvvm/model/response_model/user_feeds_respmodel.dart';
// import 'logger_service.dart';

// /// Service for managing local storage using SharedPreferences.
// class SharedPreferencesService {
//   static const String _keyDataModel = 'data_model';
//   static const String _keyUserData = 'user_data';
//   static const String _deviceToken = 'deviceToken';
//   static const String _apiToken = 'apiToken';
//   static const String _languageLocale = 'languageLocale';
//   static const String _cachedFeedData = 'cached_feed_data';
//   static const String _keyThemeMode = 'theme_mode';

//   Future<void> saveDeviceToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_deviceToken, token);
//     LoggerService.i('Saved device token');
//   }

//   Future<String?> readDeviceToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(_deviceToken);
//     LoggerService.d('Read device token: $token');
//     return token;
//   }

//   Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_apiToken, token);
//     LoggerService.i('Saved API token');
//   }

//   Future<String?> readToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(_apiToken);
//     LoggerService.d('Read API token: $token');
//     return token;
//   }

//   Future<void> saveUserData(AppUser userData) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String data = json.encode(userData.toJson());
//     await prefs.setString(_keyUserData, data);
//   }

//   Future<AppUser?> readUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? data = prefs.getString(_keyUserData);
//     if (data != null) {
//       Map<String, dynamic> jsonData = json.decode(data);
//       return AppUser.fromJson(jsonData);
//     }
//     return null;
//   }

//   // static Future<void> saveLocaleLanguage(NinjaLangModel locale) async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   final data = json.encode(locale.toJson());
//   //   await prefs.setString(_languageLocale, data);
//   // }
//   //
//   // static Future<NinjaLangModel?> readLanguageLocale() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? data = prefs.getString(_languageLocale);
//   //   if (data != null) {
//   //     final jsonData = json.decode(data);
//   //     return NinjaLangModel.fromJson(jsonData);
//   //   }
//   //   return null;
//   // }

//   Future<void> clearAllPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final result = await prefs.clear();
//     if (result) {
//       LoggerService.i('All SharedPreferences data cleared successfully');
//     } else {
//       LoggerService.e('Failed to clear SharedPreferences data');
//     }
//   }

//   // =========================================================
//   // 🎯 FEED DATA PERSISTENCE
//   // =========================================================

//   Future<void> saveFeedData(List<VideoPostModel> posts) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (posts.isEmpty) {
//         await prefs.remove(_cachedFeedData);
//         return;
//       }

//       // Limit to 50 items to avoid storage issues
//       final List<VideoPostModel> toSave = posts.take(50).toList();
//       final List<Map<String, dynamic>> jsonList =
//           toSave.map((p) => p.toJson()).toList();
//       final String jsonString = json.encode(jsonList);

//       await prefs.setString(_cachedFeedData, jsonString);
//       LoggerService.i('💾 Saved ${toSave.length} videos to SharedPreferences');
//     } catch (e) {
//       LoggerService.e('Failed to save feed data: $e');
//     }
//   }

//   Future<List<VideoPostModel>> readFeedData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? jsonString = prefs.getString(_cachedFeedData);

//       if (jsonString == null || jsonString.isEmpty) {
//         return <VideoPostModel>[];
//       }

//       final List<dynamic> jsonList = json.decode(jsonString);
//       final List<VideoPostModel> posts = jsonList
//           .map((e) => VideoPostModel.fromJson(e as Map<String, dynamic>))
//           .toList();

//       LoggerService.i('💾 Loaded ${posts.length} videos from SharedPreferences');
//       return posts;
//     } catch (e) {
//       LoggerService.e('Failed to read feed data: $e');
//       return <VideoPostModel>[];
//     }
//   }

//   Future<void> saveThemeMode(bool isDark) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyThemeMode, isDark);
//   }

//   Future<bool?> readThemeMode() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyThemeMode);
//   }
// }
