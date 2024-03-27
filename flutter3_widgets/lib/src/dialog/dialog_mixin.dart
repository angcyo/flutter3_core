part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///

const String kDialogCancel = '取消';
const String kDialogConfirm = '确定';
const String kDialogSave = '保存';

/// 对话框的一下基础约束
mixin DialogConstraintMixin {
  /// 对话框外边距
  EdgeInsets get dialogMargin =>
      const EdgeInsets.symmetric(horizontal: 60, vertical: kToolbarHeight);

  /// 对话框的最大宽度/高度限制
  BoxConstraints get dialogConstraints => BoxConstraints(
      minWidth: 0,
      maxWidth: min(screenWidth, screenHeight),
      minHeight: 0,
      maxHeight: max(screenWidth, screenHeight));

  /// 对话框的容器, 带圆角, 带margin
  /// [color] 背景颜色
  /// [fillDecoration]
  /// [strokeDecoration]
  Widget dialogContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? margin,
    Color? color,
    Decoration? decoration,
    BoxConstraints? constraints,
    BorderRadiusGeometry? borderRadius,
    double radius = kDefaultBorderRadiusXX,
  }) {
    var globalTheme = GlobalTheme.of(context);
    borderRadius ??= BorderRadius.circular(radius);
    return Padding(
      padding: margin ?? dialogMargin,
      child: ConstrainedBox(
        constraints: constraints ?? dialogConstraints,
        child: DecoratedBox(
          decoration: decoration ??
              BoxDecoration(
                color: color ?? globalTheme.themeWhiteColor,
                borderRadius: borderRadius,
              ),
          child: child,
        ),
      ).clip(borderRadius: borderRadius),
    );
  }

  /// 居中显示的对话框样式
  @api
  Widget dialogCenterContainer({
    required BuildContext context,
    required Widget child,
    double radius = kDefaultBorderRadiusXX,
  }) {
    return Center(
      child: dialogContainer(
        context: context,
        radius: radius,
        child: child.matchParent(matchHeight: false),
      ).material(),
    );
  }

  /// 底部全屏显示的对话框样式
  @api
  Widget dialogBottomContainer({
    required BuildContext context,
    required Widget child,
    double radius = kDefaultBorderRadiusXX,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: dialogContainer(
        context: context,
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        child: child.matchParent(matchHeight: false),
      ) /*.material()*/,
    );
  }

//region 辅助方法

//endregion 辅助方法
}

extension DialogExtension on BuildContext {
  /// 显示对话框
  Future<T?> showDialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Offset? anchorPoint,
    TranslationType? type,
  }) {
    return showDialogWidget<T>(
      context: this,
      widget: widget,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      traversalEdgeBehavior: traversalEdgeBehavior,
      anchorPoint: anchorPoint,
      type: type,
    );
  }
}

/// 对话框的一些基础方法
/// [barrierDismissible] 窗口外是否可以销毁对话框
/// [barrierColor] 障碍的颜色, 默认是[Colors.black54]
///
/// [useSafeArea] 是否使用安全区域
///
/// [DialogRoute]
/// [DialogPageRoute]
/// [showDialog]
/// [DialogExtension.showDialog]
Future<T?> showDialogWidget<T>({
  required BuildContext context,
  required Widget widget,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  Offset? anchorPoint,
  TranslationType? type,
}) {
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  if (type == null) {
    if (widget is TranslationTypeImpl) {
      type = (widget as TranslationTypeImpl).translationType;
    }
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(DialogPageRoute<T>(
    context: context,
    builder: (context) {
      return widget;
    },
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    themes: themes,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior:
        traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
    type: type,
  ));

  /*return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    builder: (context) {
      return widget;
    },
  );*/
}

/// 对话框的一些基础方法
mixin DialogMixin implements TranslationTypeImpl {
  @override
  TranslationType get translationType => TranslationType.translationFade;

  /// 关闭一个对话框, 如果[close]为true
  @callPoint
  void closeDialogIf(BuildContext context, bool close) {
    if (close) {
      Navigator.of(context).pop();
    }
  }

  /// 构建一个底部弹出的对话框
  @entryPoint
  Widget buildBottomDialog(BuildContext context, WidgetList children) {
    return children
        .column()!
        .container(color: Colors.white)
        .matchParent(matchHeight: false)
        .align(Alignment.bottomCenter);
  }
}
