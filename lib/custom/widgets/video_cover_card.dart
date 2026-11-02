import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:PiliPlus/common/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/common/widgets/video_popup_menu.dart';
import 'package:PiliPlus/models/horizontal_video_model.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:material_ui/material_ui.dart';

/// 只展示封面的视频卡片。
///
/// 用于横屏分栏后的右侧窄栏：标题、UP 主、播放量等文本全部去掉，
/// 让封面独占整个网格单元，点击/长按行为与 [VideoCardH] 保持一致。
class VideoCoverCard extends StatelessWidget {
  const VideoCoverCard({
    super.key,
    required this.videoItem,
    this.onRemove,
  });

  final HorizontalVideoModel videoItem;
  final VoidCallback? onRemove;

  void _onLongPress() => imageSaveDialog(
    bvid: videoItem.bvid,
    title: videoItem.title,
    cover: videoItem.cover,
  );

  @override
  Widget build(BuildContext context) {
    final progress = videoItem.progress;
    return Material(
      type: .transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              borderRadius: Style.mdRadius,
              onTap: () => pushVideoH(videoItem),
              onLongPress: _onLongPress,
              onSecondaryTap: PlatformUtils.isMobile ? null : _onLongPress,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  return Stack(
                    children: [
                      NetworkImgLayer(
                        src: videoItem.cover,
                        width: width,
                        height: height,
                      ),
                      if (videoItem.badge case final badge?)
                        PBadge(
                          text: badge,
                          top: 6,
                          left: 6,
                          type: switch (badge) {
                            '充电专属' => .error,
                            _ => .primary,
                          },
                        ),
                      if (progress != null && progress != 0) ...[
                        PBadge(
                          text: progress == -1
                              ? '已看完'
                              : '${DurationUtils.formatDuration(progress)}/${DurationUtils.formatDuration(videoItem.duration)}',
                          left: 6,
                          bottom: 8,
                          type: .gray,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: VideoProgressIndicator(
                            color: ColorScheme.of(context).primary,
                            backgroundColor: ColorScheme.of(
                              context,
                            ).secondaryContainer,
                            progress: progress == -1
                                ? 1
                                : progress / videoItem.duration,
                          ),
                        ),
                      ] else if (videoItem.duration > 0)
                        PBadge(
                          text: DurationUtils.formatDuration(
                            videoItem.duration,
                          ),
                          left: 6,
                          bottom: 6,
                          type: .gray,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: .circle,
              ),
              child: VideoPopupMenu(
                iconSize: 16,
                videoItem: videoItem,
                onRemove: onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
