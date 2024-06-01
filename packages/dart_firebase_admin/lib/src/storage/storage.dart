import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:firebaseapis/storage/v1.dart' as storage1;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../object_utils.dart';

part 'storage_exception.dart';

class Storage {
  Storage(this.app);

  final FirebaseAdminApp app;

  late final _client = _StorageHttpClient(app);

  Future<void> upload(storage1.Object object, String bucket) async {
    await _client.v1((client) async {
      await client.objects.insert(object, bucket);
    });
  }
}

class SettingsCredentials {
  SettingsCredentials({this.clientEmail, this.privateKey});

  final String? clientEmail;
  final String? privateKey;
}

class _StorageHttpClient {
  _StorageHttpClient(this.app);

  @internal
  Uri storageApiHost = Uri.https('storage.googleapis.com', '/');

  final FirebaseAdminApp app;

  Future<R> _run<R>(
    Future<R> Function(AutoRefreshingAuthClient client) fn,
  ) {
    return _storageGuard(() => app.credential.client.then(fn));
  }

  Future<R> v1<R>(
    Future<R> Function(storage1.StorageApi client) fn,
  ) {
    return _run(
      (client) => fn(
        storage1.StorageApi(
          client,
          rootUrl: storageApiHost.toString(),
        ),
      ),
    );
  }
}
