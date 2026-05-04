import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';

void main() {
  group('SkillModel', () {
    final tJson = {
      'title': 'Flutter Development',
      'description': 'Teaches Flutter from basics',
      'category': 'Technology',
      'type': 'offer',
      'level': 'intermediate',
      'format': 'online',
      'userId': 'user123',
      'tags': ['mobile', 'dart'],
      'createdAt': '2024-01-15T10:00:00.000',
    };

    test('fromJson should return a valid model', () {
      final model = SkillModel.fromJson('skill1', tJson);

      expect(model.id, 'skill1');
      expect(model.title, 'Flutter Development');
      expect(model.description, 'Teaches Flutter from basics');
      expect(model.category, 'Technology');
      expect(model.level, SkillLevel.intermediate);
      expect(model.format, SkillFormat.online);
      expect(model.userId, 'user123');
      expect(model.tags, ['mobile', 'dart']);
    });

    test('toJson should return a valid JSON map', () {
      final model = SkillModel(
        id: 'skill1',
        title: 'Flutter Development',
        description: 'Teaches Flutter from basics',
        category: 'Technology',
        level: SkillLevel.intermediate,
        format: SkillFormat.online,
        userId: 'user123',
        tags: ['mobile', 'dart'],
        createdAt: DateTime(2024, 1, 15),
      );

      final json = model.toJson();

      expect(json['title'], 'Flutter Development');
      expect(json['category'], 'Technology');
      expect(json['type'], 'offer');
      expect(json['level'], 'intermediate');
      expect(json['format'], 'online');
      expect(json['userId'], 'user123');
      expect(json['tags'], ['mobile', 'dart']);
    });

    test('parseLevel should return correct enum values', () {
      expect(SkillModel.parseLevel('beginner'), SkillLevel.beginner);
      expect(SkillModel.parseLevel('intermediate'), SkillLevel.intermediate);
      expect(SkillModel.parseLevel('advanced'), SkillLevel.advanced);
      expect(SkillModel.parseLevel(null), SkillLevel.beginner);
      expect(SkillModel.parseLevel('unknown'), SkillLevel.beginner);
    });

    test('parseType should return correct enum values', () {
      expect(SkillModel.parseType('offer'), SkillType.offer);
      expect(SkillModel.parseType('request'), SkillType.request);
      expect(SkillModel.parseType(null), SkillType.offer);
      expect(SkillModel.parseType('unknown'), SkillType.offer);
    });

    test('fromJson should parse type field correctly', () {
      final requestJson = {...tJson, 'type': 'request'};
      final model = SkillModel.fromJson('skill1', requestJson);

      expect(model.type, SkillType.request);
    });

    test('toJson should include type field', () {
      final model = SkillModel(
        id: 'skill1',
        title: 'Flutter Development',
        description: 'Teaches Flutter from basics',
        category: 'Technology',
        type: SkillType.request,
        level: SkillLevel.intermediate,
        format: SkillFormat.online,
        userId: 'user123',
        tags: ['mobile', 'dart'],
        createdAt: DateTime(2024, 1, 15),
      );

      final json = model.toJson();

      expect(json['type'], 'request');
    });

    test('parseFormat should return correct enum values', () {
      expect(SkillModel.parseFormat('online'), SkillFormat.online);
      expect(SkillModel.parseFormat('inPerson'), SkillFormat.inPerson);
      expect(SkillModel.parseFormat('both'), SkillFormat.both);
      expect(SkillModel.parseFormat(null), SkillFormat.online);
      expect(SkillModel.parseFormat('unknown'), SkillFormat.online);
    });
  });
}
