import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';



/// Generic file storage contract used across the app.
abstract class FileStorageService {
  /// Upload [file] to storage. Returns parsed response from provider.
  Future<Map<String, dynamic>> uploadFile(File file, {String? bucketId, String? fileName});

  /// Optional: get a download URL or file info.
  Future<String?> getFileDownloadUrl(String fileName, {String? bucketId});
}


/// Minimal Backblaze B2 helper. Reads credentials from env:
/// - B2_KEY_ID
/// - B2_APP_KEY
///
/// Usage:
/// final svc = BackblazeService();
/// await svc.authorizeAccount();
/// await svc.uploadFile(File('path'), bucketId: '...'); // or pass bucketId env B2_BUCKET_ID
class BackblazeB2Service implements FileStorageService {
  final String? keyId = '005a9a3e069ccb20000000001';
  final String? appKey = 'K0050OdCKvcmeVG+FOyJ0UEbfGt4RzI';
  final String? defaultBucketId = 'aptitude-files';

  BackblazeB2Service();

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


/// Uploads a file to B2. If [bucketId] is omitted, uses defaultBucketId.
  /// Returns parsed JSON response and an added `fileUrl` entry when possible.
  @override
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
    final downloadUrl = auth['downloadUrl'] as String?;
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

    final parsed = json.decode(resp.body) as Map<String, dynamic>;

    // If the account provided a downloadUrl and the bucket is public, construct a public URL.
    if (downloadUrl != null) {
      // downloadUrl usually looks like https://f001.backblazeb2.com
      parsed['fileUrl'] = '$downloadUrl/$bid/$name';
    }

    return parsed;
  }

    /// Simple helper: build a download URL for a publicly accessible file name
  /// (requires bucket configured for public access / or use b2_get_download_authorization
  /// for private buckets).
  @override
  Future<String?> getFileDownloadUrl(String fileName, {String? bucketId}) async {
    final auth = await authorizeAccount();
    final apiUrl = auth['apiUrl'] as String;
    // If bucket is public, you can construct URL directly:
    // https://f002.backblazeb2.com/file/<bucketName>/<fileName>
    // But here we return null by default — implement based on your bucket policy.
    return null;
  }

    /// Convenience: upload bytes by creating a temp file and calling uploadFile.
  Future<Map<String, dynamic>> uploadBytes(Uint8List bytes, {required String fileName, String? bucketId}) async {
    final tmp = File('${Directory.systemTemp.path}/${Uuid().v4()}_$fileName');
    await tmp.writeAsBytes(bytes);
    try {
      return await uploadFile(tmp, bucketId: bucketId, fileName: fileName);
    } finally {
      try { await tmp.delete(); } catch (_) {}
    }
  }
}