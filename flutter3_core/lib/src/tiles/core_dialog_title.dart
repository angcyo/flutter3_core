part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 对话框标题
class CoreDialogTitle extends StatelessWidget {
  ///
  final Widget? leading;
  final bool enableLeading;
  final bool showLeading;
  final bool invisibleLeading;

  ///
  final Widget? trailing;
  final bool enableTrailing;
  final bool showTrailing;
  final bool invisibleTrailing;

  ///
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleTextStyle;

  final String? subTitle;
  final Widget? subTitleWidget;
  final TextStyle? subTitleTextStyle;

  /// 点击确认后的返回值
  final ResultCallback? onPop;

  const CoreDialogTitle({
    super.key,
    this.title,
    this.titleWidget,
    this.subTitle,
    this.subTitleWidget,
    this.leading,
    this.trailing,
    this.enableLeading = true,
    this.showLeading = true,
    this.invisibleLeading = false,
    this.enableTrailing = true,
    this.showTrailing = true,
    this.invisibleTrailing = false,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final leading = !showLeading
        ? null
        : this.leading ??
            InkButton(
              loadCoreAssetSvgPicture(
                Assets.svg.coreBack,
                tintColor: context.isThemeDark
                    ? globalTheme.textTitleStyle.color
                    : null,
              ),
              enable: enableLeading,
              onTap: () {
                context.pop();
              },
            );

    final trailing = !showTrailing
        ? null
        : this.trailing ??
            InkButton(
              loadCoreAssetSvgPicture(
                Assets.svg.coreConfirm,
                tintColor: context.isThemeDark
                    ? globalTheme.textTitleStyle.color
                    : null,
              ),
              enable: enableTrailing,
              onTap: () {
                context.pop(onPop == null ? true : onPop?.call());
              },
            );

    return DialogTitleTile(
      leading: leading?.invisible(invisible: invisibleLeading),
      trailing: trailing?.invisible(invisible: invisibleTrailing),
      title: title,
      titleWidget: titleWidget,
      titleTextStyle: titleTextStyle,
      subTitle: subTitle,
      subTitleWidget: subTitleWidget,
      subTitleTextStyle: subTitleTextStyle,
    );
  }
}
