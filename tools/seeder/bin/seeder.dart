import 'dart:io';

import '../lib/firebase_client.dart';
import '../lib/seeder.dart';

void main(List<String> args) async {
  // Parse command-line args
  String? apiKey;
  String? databaseUrl;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--api-key' && i + 1 < args.length) {
      apiKey = args[i + 1];
      i++;
    } else if (args[i] == '--database-url' && i + 1 < args.length) {
      databaseUrl = args[i + 1];
      i++;
    } else if (args[i] == '--help' || args[i] == '-h') {
      printUsage();
      return;
    }
  }

  apiKey ??= Platform.environment['FIREBASE_API_KEY'];
  databaseUrl ??= Platform.environment['FIREBASE_DATABASE_URL'];

  if (apiKey == null || databaseUrl == null) {
    stderr.writeln('Missing Firebase configuration.');
    stderr.writeln();
    printUsage();
    exitCode = 1;
    return;
  }

  final client = FirebaseClient(apiKey: apiKey, databaseUrl: databaseUrl);
  final seeder = Seeder(client: client);

  print('');
  print('  🌱  Aptitude Database Seeder');
  print('  ─────────────────────────────────────────────');
  print('');

  await seeder.run(onLog: (line) => print(line));

  print('');
}

void printUsage() {
  print('Usage: dart run tools/seeder/bin/seeder.dart [options]');
  print('');
  print('Options:');
  print('  --api-key KEY        Firebase Web API key');
  print('  --database-url URL   Firebase Realtime Database URL');
  print('  --help, -h           Show this help');
  print('');
  print('Alternatively, set FIREBASE_API_KEY and FIREBASE_DATABASE_URL');
  print('environment variables.');
  print('');
  print('Example:');
  print(r'  $env:FIREBASE_API_KEY = "AIzaSy..."');
  print(r'  $env:FIREBASE_DATABASE_URL = "https://....firebaseio.com"');
  print('  dart run tools/seeder/bin/seeder.dart');
}
