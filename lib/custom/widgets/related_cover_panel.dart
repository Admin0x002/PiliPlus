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

  /// 单列封面：宽度占满右侧栏，高度按封面比例推算
  Widget _item(Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AspectRatio(
      aspectRatio: Style.aspectRatio,
      child: child,
    ),
  );

  Widget get _skeleton => SliverList.builder(
    itemCount: 6,
    itemBuilder: (context, index) => _item(
      Skeleton(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorScheme.of(context).onInverseSurface,
            borderRadius: Style.mdRadius,
          ),
        ),
      ),
    ),
  );

  Widget _buildBody(LoadingState<List<HotVideoItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => _skeleton,
      Success(:final response) => _buildList(response),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _relatedController.onReload,
      ),
    };
  }

  /// PGC 跳转（番剧/课程）基本都是会员或付费内容
  static final _pgcUriRegex = RegExp(r'(bangumi|cheese)/');

  static bool _isPaid(HotVideoItemModel item) {
    final badge = item.badge;
    if (badge != null &&
        (badge == '充电专属' ||
            badge.contains('会员') ||
            badge.contains('付费') ||
            badge.contains('课堂'))) {
      return true;
    }
    final uri = item.redirectUrl;
    return uri != null && _pgcUriRegex.hasMatch(uri);
  }

  Widget _buildList(List<HotVideoItemModel>? response) {
    if (response == null || response.isEmpty) {
      return const SliverToBoxAdapter();
    }
    final items = CustomConfig.hidePaidRelated
        ? response.where((e) => !_isPaid(e)).toList(growable: false)
        : response;
    if (items.isEmpty) {
      return const SliverToBoxAdapter();
    }
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _item(
          VideoCoverCard(
            videoItem: item,
            onRemove: () => _relatedController.loadingState
              ..value.data!.remove(item)
              ..refresh(),
          ),
        );
      },
    );
  }
}
