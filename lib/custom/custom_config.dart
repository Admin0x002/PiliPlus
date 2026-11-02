/// 本地二次定制总开关。
///
/// 约定：定制代码全部放在 `lib/custom/` 下，上游文件只在挂载点做最小改动，
/// 这样 `git merge upstream/main` 时冲突面只有几行，便于长期跟进上游。
///
/// 默认全部开启；需要临时关掉某一项时不用改代码，构建时用 dart-define 覆盖：
/// `flutter build windows --dart-define=CUSTOM_HIDE_COMMENT_TAB=false`
abstract final class CustomConfig {
  /// 视频播放页：隐藏「评论」Tab（同时不再发起评论数据请求）
  static const bool hideCommentTab = bool.fromEnvironment(
    'CUSTOM_HIDE_COMMENT_TAB',
    defaultValue: true,
  );

  /// 视频播放页：移除播放器下方的 UP 主 / 标题 / 数据 / 简介区域
  static const bool hideVideoIntro = bool.fromEnvironment(
    'CUSTOM_HIDE_VIDEO_INTRO',
    defaultValue: true,
  );

  /// 视频播放页：横屏分栏时，右侧相关视频只展示封面（单列）
  static const bool relatedCoverOnly = bool.fromEnvironment(
    'CUSTOM_RELATED_COVER_ONLY',
    defaultValue: true,
  );

  /// 右侧推荐栏宽度（逻辑像素）
  static const int splitRightExtent = int.fromEnvironment(
    'CUSTOM_SPLIT_RIGHT_EXTENT',
    defaultValue: 320,
  );

  /// 相关视频中过滤掉充电专属 / 大会员 / 付费课程等收费内容
  static const bool hidePaidRelated = bool.fromEnvironment(
    'CUSTOM_HIDE_PAID_RELATED',
    defaultValue: true,
  );
}
