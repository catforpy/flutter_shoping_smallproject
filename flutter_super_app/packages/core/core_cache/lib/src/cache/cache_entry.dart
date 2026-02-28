/// 缓存条目
///
/// 包装缓存数据，包含过期时间等信息
final class CacheEntry<T> {
  /// 缓存数据
  final T data;

  /// 过期时间（毫秒）
  final int? expireTimeMs;

  /// 创建时间
  final DateTime createdAt;

  CacheEntry({
    required this.data,
    this.expireTimeMs,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 是否已过期
  bool get isExpired {
    if (expireTimeMs == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expireTimeMs!;
  }

  /// 剩余有效时间（毫秒）
  int? get remainingTimeMs {
    if (expireTimeMs == null) return null;
    final remaining = expireTimeMs! - DateTime.now().millisecondsSinceEpoch;
    return remaining > 0 ? remaining : 0;
  }

  /// 剩余有效时间（秒）
  int? get remainingTimeSeconds {
    final ms = remainingTimeMs;
    return ms != null ? (ms / 1000).ceil() : null;
  }

  /// 创建副本
  CacheEntry<T> copyWith({
    T? data,
    int? expireTimeMs,
    DateTime? createdAt,
  }) {
    return CacheEntry<T>(
      data: data ?? this.data,
      expireTimeMs: expireTimeMs ?? this.expireTimeMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 创建带过期时间的缓存条目
  factory CacheEntry.withExpiry(
    T data, {
    required Duration expiry,
  }) {
    final expireTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
    return CacheEntry(
      data: data,
      expireTimeMs: expireTime,
    );
  }

  @override
  String toString() {
    return 'CacheEntry(data: $data, isExpired: $isExpired, remainingTime: ${remainingTimeSeconds}s)';
  }
}
