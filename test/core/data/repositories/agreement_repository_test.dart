import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class ManualAgreementDb implements DatabaseService<DataSnapshot> {
  final Map<String, Map<String, dynamic>> data = {};
  final List<String> createdLocations = [];
  final List<String> updatedLocations = [];

  @override
  Future<void> create({
    required String location,
    required Map<String, dynamic> data,
  }) async {
    this.data[location] = Map<String, dynamic>.from(data);
    createdLocations.add(location);
  }

  @override
  Future<DataSnapshot?> read({required String location}) async {
    return ManualSnapshot(data[location]);
  }

  @override
  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  }) async {
    this.data[location] = {...?this.data[location], ...data};
    updatedLocations.add(location);
  }

  @override
  Future<void> delete({required String location}) async {
    data.remove(location);
  }

  @override
  Future<DataSnapshot?> list({required String location}) async {
    final prefix = '$location/';
    final values = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.key.startsWith(prefix)) {
        values[entry.key.substring(prefix.length)] = entry.value;
      }
    }

    return ManualSnapshot(values.isEmpty ? null : values);
  }
}

class ManualSnapshot implements DataSnapshot {
  @override
  final dynamic value;

  ManualSnapshot(this.value);

  @override
  bool get exists => value != null;

  @override
  String? get key => 'key';

  int get childrenCount => 0;

  @override
  bool hasChild(String path) => false;

  @override
  DataSnapshot child(String path) => ManualSnapshot(null);

  @override
  Iterable<DataSnapshot> get children => [];

  @override
  DatabaseReference get ref => throw UnimplementedError();

  @override
  Object? get priority => null;
}

void main() {
  late AgreementRepository repository;
  late ManualAgreementDb db;

  final agreement = Agreement(
    id: 'agreement_1',
    channelId: 'channel_1',
    proposerId: 'user_1',
    receiverId: 'user_2',
    offerSkillId: 'flutter',
    requestSkillId: 'spanish',
    sessionsCount: 4,
    minutesPerSession: 60,
    frequency: 'Weekly',
    createdAt: 1000,
  );

  setUp(() {
    db = ManualAgreementDb();
    repository = AgreementRepository(databaseService: db);
  });

  group('AgreementRepository C09-C13', () {
    test('C09 createAgreement stores proposed terms', () async {
      await repository.createAgreement(agreement);

      expect(db.createdLocations, ['agreements/agreement_1']);
      expect(db.data['agreements/agreement_1'], agreement.toJson());
    });

    test('C10 updateStatus accepts an agreement', () async {
      await repository.createAgreement(agreement);
      await repository.updateStatus('agreement_1', AgreementStatus.accepted);

      final stored = db.data['agreements/agreement_1']!;
      expect(stored['status'], AgreementStatus.accepted.index);
      expect(stored['updatedAt'], isA<int>());
    });

    test(
      'C11 modifyAgreementTerms updates terms and resets to pending',
      () async {
        await repository.createAgreement(
          agreement.copyWith(status: AgreementStatus.accepted),
        );

        await repository.modifyAgreementTerms(
          id: 'agreement_1',
          sessionsCount: 6,
          minutesPerSession: 45,
          frequency: 'Biweekly',
        );

        final stored = db.data['agreements/agreement_1']!;
        expect(stored['sessionsCount'], 6);
        expect(stored['minutesPerSession'], 45);
        expect(stored['frequency'], 'Biweekly');
        expect(stored['status'], AgreementStatus.pending.index);
        expect(stored['updatedAt'], isA<int>());
      },
    );

    test('C12 updateStatus cancels an agreement', () async {
      await repository.createAgreement(agreement);
      await repository.updateStatus('agreement_1', AgreementStatus.cancelled);

      expect(
        db.data['agreements/agreement_1']!['status'],
        AgreementStatus.cancelled.index,
      );
    });

    test('C13 getAgreement and listByChannel return agreement views', () async {
      await repository.createAgreement(agreement);
      await repository.createAgreement(
        Agreement(
          id: 'agreement_2',
          channelId: 'other_channel',
          proposerId: 'user_1',
          receiverId: 'user_3',
          offerSkillId: 'piano',
          requestSkillId: 'math',
          sessionsCount: 2,
          minutesPerSession: 30,
          frequency: 'Monthly',
          createdAt: 2000,
        ),
      );

      final loaded = await repository.getAgreement('agreement_1');
      final channelAgreements = await repository.listByChannel('channel_1');

      expect(loaded?.id, 'agreement_1');
      expect(channelAgreements, hasLength(1));
      expect(channelAgreements.single.channelId, 'channel_1');
    });
  });
}
