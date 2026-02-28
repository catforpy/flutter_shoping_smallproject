import 'package:flutter_test/flutter_test.dart';
import 'package:service_comment/service_comment.dart';
import 'package:service_interaction/service_interaction.dart';

void main() {
  group('Comment Tests', () {
    test('Comment should create correctly', () {
      final comment = Comment(
        id: 'comment123',
        target: TargetRef.content('content123'),
        userId: 'user123',
        content: '这是评论内容',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(comment.id, 'comment123');
      expect(comment.content, '这是评论内容');
      expect(comment.isRoot, true);
    });

    test('Comment with reply should work', () {
      final comment = Comment(
        id: 'comment123',
        target: TargetRef.content('content123'),
        userId: 'user123',
        content: '这是回复',
        parentId: 'parent123',
        replyToUserId: 'author123',
        depth: 1,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(comment.isReply, true);
      expect(comment.depth, 1);
    });
  });

  group('CommentStatus Tests', () {
    test('CommentStatus should have correct values', () {
      expect(CommentStatus.normal.value, 'normal');
      expect(CommentStatus.pending.value, 'pending');
      expect(CommentStatus.deleted.value, 'deleted');
    });
  });
}
