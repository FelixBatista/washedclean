import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final cloudflareApiServiceProvider = Provider<CloudflareApiService>((ref) {
  return CloudflareApiService();
});

class CloudflareApiService {
  CloudflareApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _mobileApiBaseUrl = String.fromEnvironment(
    'CLOUDFLARE_API_BASE_URL',
  );

  final http.Client _client;

  Future<List<Map<String, dynamic>>> getContent() async {
    final response = await _client
        .get(_contentUri(), headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw CloudflareApiException(
        'Content request failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>();
  }

  Uri _contentUri() {
    if (kIsWeb) {
      return Uri.base.resolve('/api/content');
    }

    if (_mobileApiBaseUrl.isEmpty) {
      throw const CloudflareApiException(
        'Set CLOUDFLARE_API_BASE_URL when building the mobile app.',
      );
    }

    return Uri.parse(_mobileApiBaseUrl).resolve('/api/content');
  }
}

class CloudflareApiException implements Exception {
  const CloudflareApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
