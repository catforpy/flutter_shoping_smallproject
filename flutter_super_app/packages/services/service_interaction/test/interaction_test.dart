import 'package:flutter_test/flutter_test.dart';
import 'package:service_interaction/service_interaction.dart';

void main() {
  group('TargetRef Tests', () {
    test('TargetRef.content should create correct ref', () {
      final ref = TargetRef.content('content123');
      expect(ref.type, TargetType.content);
      expect(ref.id, 'content123');
    });

    test('TargetRef.custom should store metadata', () {
      final ref = TargetRef.custom(
        id: 'custom123',
        metadata: {'domain': 'course', 'subType': 'lesson'},
      );
      expect(ref.type, TargetType.custom);
      expect(ref.metadata?['domain'], 'course');
    });

    test('TargetRef toJson/fromJson should work', () {
      final ref = TargetRef.topic('topic123');
      final json = ref.toJson();
      final restored = TargetRef.fromJson(json);
      expect(restored.type, TargetType.topic);
      expect(restored.id, 'topic123');
    });

    test('TargetRef equality should work', () {
      final ref1 = TargetRef.content('content123');
      final ref2 = TargetRef.content('content123');
      final ref3 = TargetRef.content('content456');
      expect(ref1, ref2);
      expect(ref1 == ref3, false);
    });
  });

  group('InteractionType Tests', () {
    test('InteractionType.fromString should parse correctly', () {
      expect(InteractionType.fromString('like'), InteractionType.like);
      expect(InteractionType.fromString('custom'), InteractionType.custom);
      expect(InteractionType.fromString('unknown'), InteractionType.custom);
    });
  });

  group('InteractionStats Tests', () {
    test('InteractionStats should initialize with defaults', () {
      final target = TargetRef.content('content123');
      final stats = InteractionStats(target: target);
      expect(stats.likeCount, 0);
      expect(stats.favoriteCount, 0);
      expect(stats.isLiked, false);
      expect(stats.isFavorited, false);
    });

    test('InteractionStats copyWith should work', () {
      final target = TargetRef.content('content123');
      final stats1 = InteractionStats(target: target, likeCount: 10);
      final stats2 = stats1.copyWith(likeCount: 20);
      expect(stats1.likeCount, 10);
      expect(stats2.likeCount, 20);
    });

    test('InteractionStats customStats should work', () {
      final target = TargetRef.content('content123');
      final stats = InteractionStats(
        target: target,
        customStats: {'reward_count': 150, 'view_count': 5000},
      );
      expect(stats.getCustomStat<int>('reward_count'), 150);
      expect(stats.getCustomStat<int>('view_count'), 5000);
    });
  });

  group('Interaction Tests', () {
    test('Interaction should create correctly', () {
      final interaction = Interaction(
        id: 'interaction123',
        userId: 'user123',
        target: TargetRef.content('content123'),
        type: InteractionType.like,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(interaction.id, 'interaction123');
      expect(interaction.type, InteractionType.like);
    });

    test('Interaction toJson/fromJson should work', () {
      final interaction = Interaction(
        id: 'interaction123',
        userId: 'user123',
        target: TargetRef.content('content123'),
        type: InteractionType.like,
        createdAt: DateTime(2026, 1, 1),
        metadata: {'channel': 'wechat'},
      );
      final json = interaction.toJson();
      final restored = Interaction.fromJson(json);
      expect(restored.id, interaction.id);
      expect(restored.metadata?['channel'], 'wechat');
    });
  });
}
