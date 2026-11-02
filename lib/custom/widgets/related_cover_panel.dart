import 'package:PiliPlus/common/skeleton/skeleton.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/custom/custom_config.dart';
import 'package:PiliPlus/custom/widgets/video_cover_card.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/pages/video/related/controller.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 仅封面的相关视频面板。
///
/// 与 `RelatedVideoPanel` 的差别只有两点：复用同一份 [RelatedController] 数据源，
/// 以及用 [VideoCoverCard] 替换带标题/UP 主/播放量的横向卡片。
class RelatedCoverPanel extends StatefulWidget {
  const RelatedCoverPanel({super.key, required this.heroTag});
  final String heroTag;
  @override
  State<RelatedCoverPanel> createState() => _RelatedCoverPanelState();
}

class _RelatedCoverPanelState extends State<RelatedCoverPanel> {
  late final RelatedController _relatedController = Get.putOrFind(
    RelatedController.new,
    tag: widget.heroTag,
  );

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: CustomConfig.relatedCoverExtent,
    childAspectRatio: Style.aspectRatio,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  );

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        Style.safeSpace,
        Style.safeSpace,
        Style.safeSpace,
        100,
      ),
      sliver: Obx(() => _buildBody(_relatedController.loadingState.value)),
    );
  }

  Widget get _skeleton => SliverGrid(
    gridDelegate: _gridDelegate,
    delegate: SliverChildBuilderDelegate(
      (context, index) => Skeleton(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).onInverseSurface,
            borderRadius: Style.mdRadius,
          ),
        ),
      ),
      childCount: 8,
    ),
  );

  Widget _buildBody(LoadingState<List<HotVideoItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => _skeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: _gridDelegate,
                itemBuilder: (context, index) {
                  return VideoCoverCard(
                    videoItem: response[index],
                    onRemove: () => _relatedController.loadingState
                      ..value.data!.removeAt(index)
                      ..refresh(),
                  );
                },
                itemCount: response.length,
              )
            : const SliverToBoxAdapter(),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _relatedController.onReload,
      ),
    };
  }
}
