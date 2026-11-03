# PiliPlus 本地定制说明

本仓库 fork 自 [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)，面向 **Windows 11 平板横屏** 使用做了二次定制。
本文档记录：定制了什么、代码放在哪、如何跟进上游、如何编译出新安装包。

---

## 1. 分支与远程约定

| 名称 | 作用 |
| --- | --- |
| `origin` | 自己的 fork：`git@github.com:Admin0x002/PiliPlus.git` |
| `upstream` | 上游：`git@github.com:bggRGjQaUbCoE/PiliPlus.git` |
| `main` | **上游镜像**，只做 `--ff-only` 快进，不提交任何自己的改动 |
| `custom` | **定制分支**，所有定制提交都在这里 |

原则：`main` 永远等于 `upstream/main`，自己的改动全部在 `custom`，这样 `git diff upstream/main..custom` 就是"我改了什么"的完整清单。

一次性配置（让重复冲突自动复用解法）：

```bash
cd /path/to/PiliPlus
git config rerere.enabled true
git config rerere.autoupdate true
```

---

## 2. 定制内容与代码位置

所有定制代码集中在 `lib/custom/`，上游文件只在"挂载点"做最小改动，并带 `// [custom]` 注释。

| 定制 | 运行/编译开关 | 主要文件 |
| --- | --- | --- |
| 隐藏播放页「评论」Tab（并停止请求评论数据） | `CustomConfig.hideCommentTab` | `lib/pages/video/controller.dart`（`showReply` getter） |
| 横屏分栏：移除播放器下方的 UP 主/标题/数据/简介 | `CustomConfig.hideVideoIntro` | `lib/pages/video/view.dart`（`_childWhenDisabledLandscapeInner`） |
| 横屏分栏：左侧视频撑满整列（黑边居中） | 同上 | `lib/pages/video/view.dart` |
| 横屏分栏：右侧推荐栏宽度 320 | `CustomConfig.splitRightExtent` | `lib/pages/video/view.dart` |
| 相关视频只显示封面、单列 | `CustomConfig.relatedCoverOnly` | `lib/custom/widgets/related_cover_panel.dart`、`video_cover_card.dart` |
| 过滤充电专属 / 大会员 / 付费课程 | `CustomConfig.hidePaidRelated` | `lib/custom/widgets/related_cover_panel.dart`（`_isPaid`） |
| 单击暂停/播放、双击呼出底部控制条、顶部控制条常驻 | 设置项「单击暂停/播放」 | `lib/custom/custom_pref.dart`、`lib/plugin/pl_player/view/view.dart`、`lib/plugin/pl_player/widgets/app_bar_ani.dart`、`lib/pages/setting/models/play_settings.dart` |

两类开关的区别：

- **编译期开关** `lib/custom/custom_config.dart`：`bool.fromEnvironment`，默认全开，可在构建时覆盖：
  ```bash
  flutter build windows --dart-define=CUSTOM_HIDE_COMMENT_TAB=false
  ```
- **运行时开关** `lib/custom/custom_pref.dart`：存在 `GStorage.setting` 里，key 为自定义字符串（`customTapToPause`），在「设置 > 播放设置」里切换，立即生效（顶部控制条常驻在重新进入播放页后生效）。

查询所有侵入上游的位置：

```bash
grep -rn "\[custom\]" lib
```

### 新增定制的约定

1. 新组件/工具类放进 `lib/custom/`，命名加 `Custom` 前缀，避免和上游重名；
2. 需要挂到上游页面时，只加 1~3 行挂载点代码，并在上方写 `// [custom] ...`；
3. 能做成开关就做成开关，方便上游代码大改时先关掉、后适配；
4. 每个定制单独一个提交，提交信息以 `custom:` 开头，便于 `git rebase -i` 单独丢弃/重做。

---

## 3. 同步上游

```bash
# 1) 拉取上游（连 tag）
git fetch upstream --tags

# 2) main 保持为上游镜像
git switch main
git merge --ff-only upstream/main
git push origin main

# 3) 把定制提交搬到新上游之上
git switch custom
git rebase upstream/main
#   冲突：改完文件 → git add <文件> → git rebase --continue
#   放弃：git rebase --abort

# 4) 推回 fork（rebase 重写了历史，必须 --force-with-lease）
git push --force-with-lease origin custom
```

同步后自检：

```bash
git log --oneline upstream/main..custom   # 只应看到 custom: / fix(custom): 提交
git diff --stat upstream/main..custom     # 只应命中 lib/custom/** 和几个挂载点
```

如果 `git diff --stat` 里出现大量上游文件，说明定制代码泄漏到了不该改的地方，需要收敛。

关于 `--force-with-lease`：只影响自己的 `custom` 分支，比 `--force` 安全（远端被他人更新时会拒绝）。
如果不想改写历史，可以用 `git merge upstream/main` 代替 rebase，但会多出合并提交。

---

## 4. 编译 Windows 安装包（GitHub Actions）

仓库自带 `.github/workflows/win_x64.yml`，支持手动触发，无需任何 secret。

网页操作：

> Actions → **Build for Windows x64** → **Run workflow** → 分支选 `custom` → **Run** → 等待约 12 分钟 → 在该 run 页面底部 **Artifacts** 下载。

命令行：

```bash
# 必须带 --repo，否则 gh 会解析到 upstream（上游仓库没有权限，会 403）
gh workflow run win_x64.yml --ref custom --repo Admin0x002/PiliPlus

# 查看运行状态
gh run list --repo Admin0x002/PiliPlus --workflow=win_x64.yml --limit 3
gh run watch <run-id> --repo Admin0x002/PiliPlus

# 下载产物
gh run download <run-id> --repo Admin0x002/PiliPlus --dir out
```

产物：

- `PiliPlus_windows_<版本>+<提交数>_x64_setup.exe`：安装版
- `PiliPlus_windows_<版本>+<提交数>_x64_portable.zip`：免安装版

版本号由 `pubspec.yaml` 的 `version` + `git rev-list --count HEAD` 生成（见 `lib/scripts/build.ps1`），所以每次提交/同步后数字都会变，属正常现象。
`Release` 步骤只有在传入 tag 时才会执行，日常下载 artifact 即可。

> 首次在 fork 上使用 Actions 时，若 Actions 页提示需要启用，点一次 "I understand my workflows, go ahead and enable them"，或调用
> `gh api -X PUT repos/<owner>/<repo>/actions/permissions -F enabled=true`。

---

## 5. 本地编译（可选）

需要 Flutter 版本对齐 `.fvmrc`（当前 3.47.9）+ Windows 工具链，并且要先应用框架补丁：

```powershell
flutter pub get
lib/scripts/patch.ps1 windows
flutter build windows --release
```

Linux/macOS 无法构建 Windows 桌面版，直接用上面的 GitHub Actions。

---

## 6. 常见问题

| 现象 | 处理 |
| --- | --- |
| `gh` 报 403 / 404 | 命令漏了 `--repo Admin0x002/PiliPlus`，`gh` 默认解析到了 upstream |
| `git push` 被拒绝（non-fast-forward） | rebase 后历史被重写，用 `git push --force-with-lease origin custom` |
| Windows 构建里 `Member not found` / 类型错误 | 本地没有 Dart 分析环境，只能靠 CI 编译发现；改完直接重跑 workflow |
| 修改没生效 | 运行时开关（设置页）立即生效；编译期开关（`CustomConfig`）需要重新构建 |
| 想临时回到原版行为 | 关掉对应开关；或 `git revert <custom 提交>` |
