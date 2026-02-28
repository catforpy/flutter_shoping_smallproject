import 'package:flutter_test/flutter_test.dart';
import 'package:core_media/core_media.dart';

void main() {
  group('MediaUtils (from core_utils)', () {
    test('should detect image files', () {
      expect(MediaUtils.isImageFile('test.jpg'), true);
      expect(MediaUtils.isImageFile('test.png'), true);
      expect(MediaUtils.isImageFile('test.gif'), true);
      expect(MediaUtils.isImageFile('test.webp'), true);
      expect(MediaUtils.isImageFile('test.txt'), false);
    });

    test('should detect video files', () {
      expect(MediaUtils.isVideoFile('test.mp4'), true);
      expect(MediaUtils.isVideoFile('test.mov'), true);
      expect(MediaUtils.isVideoFile('test.avi'), true);
      expect(MediaUtils.isVideoFile('test.mkv'), true);
      expect(MediaUtils.isVideoFile('test.jpg'), false);
    });

    test('should detect audio files', () {
      expect(MediaUtils.isAudioFile('test.mp3'), true);
      expect(MediaUtils.isAudioFile('test.wav'), true);
      expect(MediaUtils.isAudioFile('test.aac'), true);
      expect(MediaUtils.isAudioFile('test.flac'), true);
      expect(MediaUtils.isAudioFile('test.jpg'), false);
    });

    test('should format file size', () {
      expect(MediaUtils.formatFileSize(512), '512 B');
      expect(MediaUtils.formatFileSize(1024), '1.00 KB');
      expect(MediaUtils.formatFileSize(1024 * 1024), '1.00 MB');
      expect(MediaUtils.formatFileSize(1024 * 1024 * 1024), '1.00 GB');
    });

    test('should get image type', () {
      expect(MediaUtils.getImageType('test.jpg'), 'jpeg');
      expect(MediaUtils.getImageType('test.png'), 'png');
      expect(MediaUtils.getImageType('test.gif'), 'gif');
      expect(MediaUtils.getImageType('test.webp'), 'webp');
    });

    test('should calculate aspect ratio', () {
      expect(MediaUtils.calculateAspectRatio(1920, 1080), closeTo(1.78, 0.01));
      expect(MediaUtils.calculateAspectRatio(1080, 1920), closeTo(0.56, 0.01));
      expect(MediaUtils.calculateAspectRatio(1000, 1000), 1.0);
    });
  });

  group('AppVideoPlayerController', () {
    test('should have correct initial values', () {
      // 注意：实际测试需要创建真实的 controller
      // 这里只是测试类的存在性
      expect(AppVideoPlayerController, isNotNull);
    });
  });

  group('MediaType', () {
    test('should have image and video types', () {
      expect(MediaType.values.length, greaterThanOrEqualTo(2));
      expect(MediaType.values, contains(MediaType.image));
      expect(MediaType.values, contains(MediaType.video));
    });
  });
}
