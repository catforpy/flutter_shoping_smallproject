library;

import 'package:core_base/core_base.dart';
import '../models/content.dart';

/// 内容仓库接口
abstract class ContentRepository {
  /// 创建内容
  Future<Result<Content>> createContent(Content content);

  /// 更新内容
  Future<Result<Content>> updateContent(Content content);

  /// 删除内容
  Future<Result<void>> deleteContent(String contentId);

  /// 获取内容详情
  Future<Result<Content>> getContent(String contentId);

  /// 获取内容列表
  Future<Result<PagedResult<Content>>> getContents(ContentQuery query);

  /// 发布内容（草稿->已发布）
  Future<Result<Content>> publishContent(String contentId);

  /// 增加浏览量
  Future<Result<void>> incrementViewCount(String contentId);

  /// 清除缓存
  Future<void> clearCache();
}
