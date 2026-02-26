import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/app_urls.dart';
import 'logger_service.dart';
import 'shared_preferences_service.dart';

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

/// Simple cancellation token for requests.
class CancelToken {
  bool _canceled = false;
  String? reason;
  final Completer<void> _notifier = Completer<void>();

  bool get isCanceled => _canceled;

  Future<void> get whenCanceled => _notifier.future;

  void cancel([String? reason]) {
    if (_canceled) return;
    _canceled = true;
    this.reason = reason;
    if (!_notifier.isCompleted) {
      _notifier.complete();
    }
  }
}

class HttpsCalls {
  late final IOClient _pooledClient = () {
    final h = HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..connectionTimeout = const Duration(seconds: 15)
      ..maxConnectionsPerHost = 8
      ..autoUncompress = true;
    return IOClient(h);
  }();

  void dispose() {
    try {
      _pooledClient.close();
    } catch (_) {}
  }

  final int _maxConcurrency = 8;
  int _active = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<void> _acquireSlot() async {
    if (_active < _maxConcurrency) {
      _active++;
      return;
    }
    final c = Completer<void>();
    _waiters.addLast(c);
    await c.future;
  }

  void _releaseSlot() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      if (_active > 0) _active--;
    }
  }

  final _ongoingRequests = <String, Future<http.Response>>{};

  final Duration _timeoutDuration = const Duration(seconds: 20);
  final int _maxRetries = 2;

  final _random = Random();

  final Set<CancelToken> _attachedTokens = <CancelToken>{};

  void cancelAll([String reason = 'Global cancelAll']) {
    for (final t in _attachedTokens.toList()) {
      t.cancel(reason);
    }
    _attachedTokens.clear();
  }

  bool _isIdempotent(HttpMethod m) {
    switch (m) {
      case HttpMethod.GET:
      case HttpMethod.PUT:
      case HttpMethod.DELETE:
        return true;
      case HttpMethod.POST:
      case HttpMethod.PATCH:
        return false;
    }
  }

  String _buildKey(HttpMethod method, String endpoint, {List<int>? body}) {
    final methodStr = method.toString().split('.').last;
    final bodyHash = (body == null || body.isEmpty)
        ? ''
        : base64Url.encode(body.take(32).toList());
    return '$methodStr $endpoint $bodyHash';
  }

  Future<http.Response> _performRequest(
    HttpMethod method,
    String endpoint,
    Future<http.Response> Function(http.Client client) request, {
    List<int>? body,
    CancelToken? cancelToken,
    bool retryablePost = false,
  }) async {
    final key = _buildKey(method, endpoint, body: body);

    // Join in-flight requests (dedupe)
    if (_ongoingRequests.containsKey(key)) {
      LoggerService.i('🔁 Joining in-flight request for $key');
      return _ongoingRequests[key]!;
    }

    await _acquireSlot();

    final token = cancelToken;
    if (token != null) _attachedTokens.add(token);

    IOClient? perRequestClient;
    http.Client? client;

    try {
      // Choose client
      if (token != null) {
        final h = HttpClient()
          ..idleTimeout = const Duration(seconds: 30)
          ..connectionTimeout = const Duration(seconds: 30)
          ..maxConnectionsPerHost = 8
          ..autoUncompress = true;
        perRequestClient = IOClient(h);
        client = perRequestClient;
      } else {
        client = _pooledClient;
      }

      final canRetry =
          _isIdempotent(method) || (method == HttpMethod.POST && retryablePost);
      final maxAttempts = canRetry ? (_maxRetries + 1) : 1;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        if (token?.isCanceled == true) {
          _ongoingRequests.remove(key);
          throw Exception('Request cancelled: ${token?.reason ?? ""}');
        }

        Future<http.Response> inflight = request(
          client,
        ).timeout(_timeoutDuration);

        // If token exists, race with cancel
        if (token != null) {
          inflight = Future.any<http.Response>([
            inflight,
            token.whenCanceled.then((_) {
              throw Exception('Request cancelled: ${token.reason ?? ""}');
            }),
          ]);
        }

        // ✅ Publish per-attempt so joiners always get the current attempt
        _ongoingRequests[key] = inflight;

        try {
          final res = await inflight;
          LoggerService.i('✅ $method $endpoint → ${res.statusCode}');
          return res;
        } on TimeoutException catch (e) {
          LoggerService.w(
            '⏰ Timeout attempt ${attempt + 1}/$maxAttempts for $key: $e',
          );
          if (attempt == maxAttempts - 1) {
            throw Exception('Timeout after $maxAttempts attempts');
          }
          await _retryDelay(attempt);
        } on http.ClientException catch (e, st) {
          LoggerService.w(
            '🌐 ClientException attempt ${attempt + 1}/$maxAttempts for $key: $e',
          );

          if (token?.isCanceled == true ||
              e.toString().contains('Request cancelled'))
            rethrow;

          if (attempt == maxAttempts - 1) {
            LoggerService.e(
              '💥 $method $endpoint failed after $maxAttempts attempts: $e',
              error: e,
              stackTrace: st,
            );
            throw Exception('Failed after $maxAttempts attempts: $e');
          }

          await _retryDelay(attempt);
        } on SocketException catch (e, st) {
          LoggerService.w(
            '🔌 SocketException attempt ${attempt + 1}/$maxAttempts for $key: $e',
          );

          if (attempt == maxAttempts - 1) {
            LoggerService.e(
              '💥 $method $endpoint failed after $maxAttempts attempts: $e',
              error: e,
              stackTrace: st,
            );
            throw Exception('Failed after $maxAttempts attempts: $e');
          }

          await _retryDelay(attempt);
        } catch (e, st) {
          if (token?.isCanceled == true ||
              e.toString().contains('Request cancelled'))
            rethrow;

          if (attempt == maxAttempts - 1) {
            LoggerService.e(
              '💥 $method $endpoint failed after $maxAttempts attempts: $e',
              error: e,
              stackTrace: st,
            );
            throw Exception('Failed after $maxAttempts attempts: $e');
          }

          LoggerService.w(
            '🔁 Retry attempt ${attempt + 1}/$maxAttempts for $key due to error: $e',
          );
          await _retryDelay(attempt);
        } finally {
          // ✅ Always remove so it never poisons joiners
          _ongoingRequests.remove(key);
        }
      }

      throw Exception('Unexpected error in _performRequest');
    } finally {
      if (token != null) _attachedTokens.remove(token);

      // ✅ Only close per-request client (never close pooled)
      perRequestClient?.close();

      _releaseSlot();
    }
  }

  Future<void> _retryDelay(int attempt) async {
    final base = pow(2, attempt).toInt();
    final jitter = _random.nextInt(300);
    await Future.delayed(Duration(milliseconds: base * 400 + jitter));
  }

  Future<Map<String, String>> _getDefaultHeaders() async {
    // final token = await SharedPreferencesService().readToken();
    final token = '';

    debugPrint('======>>> Token: $token');
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Future<http.Response> _sendRequest(
    http.Client client,
    HttpMethod method,
    String endpoint, {
    List<int>? body,
  }) async {
    final headers = await _getDefaultHeaders();
    final url = Uri.parse('${AppUrls.baseAPIURL}$endpoint');

    LoggerService.d('🌀 Sending $method → $url');

    switch (method) {
      case HttpMethod.GET:
        return client.get(url, headers: headers);
      case HttpMethod.POST:
        return client.post(url, headers: headers, body: body);
      case HttpMethod.PUT:
        return client.put(url, headers: headers, body: body);
      case HttpMethod.PATCH:
        return client.patch(url, headers: headers, body: body);
      case HttpMethod.DELETE:
        return client.delete(url, headers: headers, body: body);
    }
  }

  Future<http.Response> getApiHits(
    String endpoint, {
    CancelToken? cancelToken,
  }) {
    return _performRequest(
      HttpMethod.GET,
      endpoint,
      (client) => _sendRequest(client, HttpMethod.GET, endpoint),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> postApiHits(
    String endpoint,
    List<int>? utfContent, {
    CancelToken? cancelToken,
    bool retryablePost = true,
  }) {
    return _performRequest(
      HttpMethod.POST,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.POST, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
      retryablePost: retryablePost,
    );
  }

  Future<http.Response> putApiHits(
    String endpoint,
    List<int> utfContent, {
    CancelToken? cancelToken,
  }) {
    return _performRequest(
      HttpMethod.PUT,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.PUT, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> patchApiHits(
    String endpoint,
    List<int> utfContent, {
    CancelToken? cancelToken,
  }) {
    return _performRequest(
      HttpMethod.PATCH,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.PATCH, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> deleteApiHits(
    String endpoint, {
    List<int>? utfContent,
    CancelToken? cancelToken,
  }) {
    return _performRequest(
      HttpMethod.DELETE,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.DELETE, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  // ===================== MULTIPART (SIGNUP / UPDATE PROFILE) =====================

  Future<http.Response> _genericMultipartRequest(
    http.Client client,
    String endpoint,
    dynamic model, {
    Map<String, dynamic Function()>? fileExtractors,
    String method = 'POST',
  }) async {
    final token = '';

    // final token = await SharedPreferencesService().readToken();
    final url = Uri.parse(AppUrls.baseAPIURL + endpoint);
    final request = http.MultipartRequest(method, url);

    request.headers.addAll({
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    });

    final json = model.toJson();
    json.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          request.fields['$key[$i]'] = value[i].toString();
        }
      } else if (value is String || value is num || value is bool) {
        request.fields[key] = value.toString();
      }
    });

    if (fileExtractors != null) {
      for (var entry in fileExtractors.entries) {
        final fKey = entry.key;
        final v = entry.value();
        if (v is File) {
          request.files.add(await http.MultipartFile.fromPath(fKey, v.path));
        } else if (v is List<File>) {
          for (final f in v) {
            request.files.add(await http.MultipartFile.fromPath(fKey, f.path));
          }
        }
      }
    }

    LoggerService.d('📤 Sending multipart → $endpoint ($method)');
    final streamedResponse = await client.send(request);
    return http.Response.fromStream(streamedResponse);
  }
}
