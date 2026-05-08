import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Minimal Backblaze B2 helper. Reads credentials from env:
/// - B2_KEY_ID
/// - B2_APP_KEY
///
/// Usage:
/// final svc = BackblazeService();
/// await svc.authorizeAccount();
/// await svc.uploadFile(File('path'), bucketId: '...'); // or pass bucketId env B2_BUCKET_ID
class BackblazeService {
  final String? keyId = '005a9a3e069ccb20000000001';
  final String? appKey = 'K0050OdCKvcmeVG+FOyJ0UEbfGt4RzI';
  final String? defaultBucketId = 'aptitude-files';

  BackblazeService();

  bool get _hasCredentials => keyId != null && appKey != null;

  Future<Map<String, dynamic>> authorizeAccount() async {
    if (!_hasCredentials) {
      throw StateError('Missing B2_KEY_ID or B2_APP_KEY in environment');
    }

    final basic = base64.encode(utf8.encode('$keyId:$appKey'));
    final resp = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
      headers: {'Authorization': 'Basic $basic'},
    );

    if (resp.statusCode != 200) {
      throw HttpException('Authorize failed: ${resp.statusCode} ${resp.body}');
    }

    return json.decode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUploadUrl({
    required String apiUrl,
    required String authToken,
    required String bucketId,
  }) async {
    final resp = await http.post(
      Uri.parse('$apiUrl/b2api/v2/b2_get_upload_url'),
      headers: {
        'Authorization': authToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({'bucketId': bucketId}),
    );

    if (resp.statusCode != 200) {
      throw HttpException('Get upload URL failed: ${resp.statusCode} ${resp.body}');
    }

    return json.decode(resp.body) as Map<String, dynamic>;
  }

  /// Uploads a file to B2. If [bucketId] is omitted, uses env B2_BUCKET_ID.
  /// Returns the parsed JSON response from B2 on success.
  Future<Map<String, dynamic>> uploadFile(
    File file, {
    String? bucketId,
    String? fileName,
  }) async {
    if (!await file.exists()) {
      throw ArgumentError('File does not exist: ${file.path}');
    }

    final bid = bucketId ?? defaultBucketId;
    if (bid == null) {
      throw StateError('Bucket id not provided and B2_BUCKET_ID not set in environment');
    }

    final auth = await authorizeAccount();
    final apiUrl = auth['apiUrl'] as String;
    final authToken = auth['authorizationToken'] as String;

    final uploadInfo = await getUploadUrl(apiUrl: apiUrl, authToken: authToken, bucketId: bid);
    final uploadUrl = uploadInfo['uploadUrl'] as String;
    final uploadAuthToken = uploadInfo['authorizationToken'] as String;

    final bytes = await file.readAsBytes();
    final sha1Digest = sha1.convert(bytes).toString();
    final name = fileName ?? Uri.encodeFull(file.uri.pathSegments.last);

    final resp = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': uploadAuthToken,
        'X-Bz-File-Name': name,
        'Content-Type': 'b2/x-auto',
        'Content-Length': bytes.length.toString(),
        'X-Bz-Content-Sha1': sha1Digest,
      },
      body: bytes,
    );

    if (resp.statusCode != 200) {
      throw HttpException('Upload failed: ${resp.statusCode} ${resp.body}');
    }

    return json.decode(resp.body) as Map<String, dynamic>;
  }
}