import 'package:flutter_test/flutter_test.dart';
import 'package:service_user/service_user.dart';

void main() {
  group('User', () {
    test('should create user with required fields', () {
      final user = const User(
        id: '123',
        username: 'testuser',
      );
      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.nickname, null);
    });

    test('should create user with all fields', () {
      final now = DateTime.now();
      final user = User(
        id: '123',
        username: 'testuser',
        nickname: 'Test User',
        avatar: 'https://example.com/avatar.jpg',
        phone: '13800138000',
        email: 'test@example.com',
        gender: 'male',
        birthday: now,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      expect(user.displayName, 'Test User');
      expect(user.isActive, true);
    });

    test('should create user from json', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'nickname': 'Test',
        'avatar': 'avatar.jpg',
        'status': 'active',
      };
      final user = User.fromJson(json);
      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.nickname, 'Test');
      expect(user.status, UserStatus.active);
    });

    test('should convert user to json', () {
      final user = const User(
        id: '123',
        username: 'testuser',
      );
      final json = user.toJson();
      expect(json['id'], '123');
      expect(json['username'], 'testuser');
    });

    test('should copy user with new values', () {
      final user = const User(
        id: '123',
        username: 'testuser',
      );
      final copied = user.copyWith(nickname: 'New Nickname');
      expect(copied.nickname, 'New Nickname');
      expect(copied.username, 'testuser'); // Original unchanged
    });

    test('should compare users by id', () {
      const user1 = User(id: '123', username: 'user1');
      const user2 = User(id: '123', username: 'user2');
      expect(user1, user2);
    });
  });

  group('UserStatus', () {
    test('should have correct values', () {
      expect(UserStatus.active.value, 'active');
      expect(UserStatus.disabled.value, 'disabled');
      expect(UserStatus.deleted.value, 'deleted');
      expect(UserStatus.inactive.value, 'inactive');
    });
  });

  group('UserProfile', () {
    test('should create profile with userId', () {
      final profile = const UserProfile(
        userId: '123',
        realName: 'John Doe',
      );
      expect(profile.userId, '123');
      expect(profile.realName, 'John Doe');
    });

    test('should create profile from json', () {
      final json = {
        'userId': '123',
        'realName': 'John Doe',
        'wechat': 'johndoe',
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.userId, '123');
      expect(profile.wechat, 'johndoe');
    });

    test('should copy profile with new values', () {
      final profile = const UserProfile(userId: '123');
      final copied = profile.copyWith(realName: 'Jane Doe');
      expect(copied.realName, 'Jane Doe');
    });
  });
}
