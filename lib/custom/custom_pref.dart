import 'package:PiliPlus/utils/storage.dart';

/// 运行时可在设置页修改的定制项。
///
/// 与 [CustomConfig] 的编译期开关区分：这里直接存在 `GStorage.setting` 里，
/// key 使用自定义字符串而不占用上游的 `SettingBoxKey`，
/// 因此新增设置项只需要在设置列表里加一条，不必改上游的 storage_key/storage_pref。
abstract final class CustomPref {
  /// 单击暂停/播放，双击呼出底部控制条，顶部控制条常驻
  static const String tapToPauseKey = 'customTapToPause';

  static bool get tapToPause =>
      GStorage.setting.get(tapToPauseKey, defaultValue: true);
}
