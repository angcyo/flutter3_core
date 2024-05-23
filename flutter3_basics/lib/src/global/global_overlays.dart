part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/10
///

/// The length of time the notification is fully displayed.
const Duration kNotificationDuration = Duration(milliseconds: 2000);

/// Notification display or hidden animation duration.
const Duration kNotificationSlideDuration = Duration(milliseconds: 300);

/// To build a widget with animated value.
/// [progress] : the progress of overlay animation from 0 - 1
///
typedef OverlayAnimatedWidgetBuilder = Widget Function(
  BuildContext context,
  double progress,
);

/// [OverlayAnimatedWidgetBuilder]
typedef OverlayEntryAnimatedWidgetBuilder = Widget Function(
  OverlayEntry entry,
  OverlayAnimatedState state,
  BuildContext context,
  double progress,
);

/// 动画类型
enum OverlayAnimate {
  /// 顶部滑入动画
  topSlide,

  /// 透明动画
  opacity,

  /// 底部滑入动画
  bottomSlide,

  /// 缩放动画
  scale,

  /// 无动画
  none,
}

/// 显示的位置
enum OverlayPosition {
  top,
  center,
  bottom,
}

/// toast通知
toast(
  Widget msg, {
  /// 背景颜色
  Color? background,

  /// 背景模糊的伽马值
  double? bgBlurSigma,

  /// 显示的位置
  OverlayPosition position = OverlayPosition.bottom,

  /// 显示的动画
  OverlayAnimate? animate,
}) {
  showNotification((context) {
    return ToastWidget(
      background: background,
      bgBlurSigma: bgBlurSigma,
      child: msg,
    );
  }, position: position, animate: animate ?? OverlayAnimate.opacity);
}

/// [msg] 显示小部件
/// [text] 显示文本
/// [toast]
toastBlur({
  Widget? msg,
  dynamic text,
  double? bgBlurSigma = kM,
  OverlayPosition position = OverlayPosition.center,
}) =>
    toast(
      msg ?? "$text".text(),
      bgBlurSigma: bgBlurSigma,
      position: position,
    );

/// 顶部全屏toast
toastMessage(
  Widget msg, {
  Color? background = Colors.white,
  OverlayPosition position = OverlayPosition.top,
  OverlayAnimate? animate = OverlayAnimate.scale,
}) {
  showNotification((context) {
    Widget child = ToastWidget(
      background: background,
      elevation: 10,
      child: msg,
    );
    return child;
  }, position: position, animate: animate ?? OverlayAnimate.opacity);
}

/// [toastMessage]
toastInfo(
  String? msg, {
  /// 图标
  IconData? icon,
  OverlayPosition position = OverlayPosition.top,
  OverlayAnimate? animate = OverlayAnimate.scale,
}) {
  if (msg == null) return;

  toastMessage(
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.info_outline,
          /*color: GlobalConfig.def.themeData.primaryColor,*/
        ),
        //间隙
        Empty.width(8),
        Text(msg).expanded(),
      ],
    ),
    position: position,
    animate: animate,
  );
}

//---

/// 显示一个简单的通知
/// [showNotification]的简单封装
OverlayEntry? showSimpleNotification(
  Widget content, {
  /// 通知的背景颜色
  Color? background,

  /// 高度,决定阴影
  double elevation = 16,

  /// 显示的位置
  OverlayPosition position = OverlayPosition.top,

  /// 显示的动画
  OverlayAnimate? animate,

  /// 滑动删除的方向
  DismissDirection? slideDismissDirection = DismissDirection.horizontal,

  //---ListTile---

  /// See more [ListTile.leading].
  Widget? leading,

  /// See more [ListTile.subtitle].
  Widget? subtitle,

  /// See more [ListTile.trailing].
  Widget? trailing,

  /// See more [ListTile.contentPadding].
  EdgeInsetsGeometry? contentPadding,
}) {
  final stateKey = GlobalKey<OverlayAnimatedState>();
  final dismissDirection = slideDismissDirection ?? DismissDirection.none;

  //判断背景颜色是否是亮色, 亮色用默认的文本图标颜色
  final isLight = background?.isLight ?? false;
  final textColor = isLight ? null : Colors.white;
  final iconColor = isLight ? null : Colors.white;

  Widget child = SafeArea(
    top: true,
    child: ListTile(
      iconColor: iconColor,
      textColor: textColor,
      title: content,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing,
      contentPadding: contentPadding,
    ),
  );
  child = Material(
    color: background ?? GlobalConfig.def.themeData.colorScheme.secondary,
    elevation: elevation,
    child: child,
  );
  if (dismissDirection != DismissDirection.none) {
    child = _SlideDismissible(
      direction: dismissDirection,
      key: ValueKey(stateKey),
      overlayAnimatedStateKey: stateKey,
      child: child,
    );
  }
  return showNotification((context) {
    return child;
  }, position: position, animate: animate);
}

/// 显示一个通知
/// [showOverlay]的简单封装
OverlayEntry? showNotification(
  WidgetBuilder builder, {
  Duration? duration = kNotificationDuration,
  Duration? animationDuration,
  Duration? reverseAnimationDuration,
  Key? key,
  GlobalKey<OverlayAnimatedState>? overlayStateKey,
  OverlayPosition position = OverlayPosition.center,
  OverlayAnimate? animate,
  BuildContext? context,
}) {
  return showOverlay(
    (entry, state, context, progress) {
      Widget content;
      OverlayAnimate anim;
      if (animate == null) {
        switch (position) {
          case OverlayPosition.top:
            anim = OverlayAnimate.topSlide;
            break;
          case OverlayPosition.center:
            anim = OverlayAnimate.opacity;
            break;
          case OverlayPosition.bottom:
            anim = OverlayAnimate.bottomSlide;
            break;
        }
      } else {
        anim = animate;
      }

      if (anim == OverlayAnimate.topSlide) {
        content = TopSlideNotification(builder: builder, progress: progress);
      } else if (anim == OverlayAnimate.opacity) {
        content = OpacityNotification(
          builder: builder,
          progress: progress,
        );
      } else if (anim == OverlayAnimate.bottomSlide) {
        content = BottomSlideNotification(builder: builder, progress: progress);
      } else if (anim == OverlayAnimate.scale) {
        content = ScaleNotification(builder: builder, progress: progress);
      } else {
        content = builder(context);
      }

      Alignment alignment;
      if (position == OverlayPosition.center) {
        alignment = Alignment.center;
      } else if (position == OverlayPosition.top) {
        alignment = Alignment.topCenter;
      } else if (position == OverlayPosition.bottom) {
        alignment = Alignment.bottomCenter;
      } else {
        alignment = Alignment.center;
      }
      return Align(
        alignment: alignment,
        child: content,
      );
    },
    duration: duration,
    animationDuration: animationDuration,
    reverseAnimationDuration: reverseAnimationDuration,
    key: key,
    overlayStateKey: overlayStateKey,
    context: context,
    curve: animate == OverlayAnimate.scale ? Curves.easeOutBack : null,
  );
}

/// 全局显示一个[OverlayEntry]
/// [curve] 动画曲线/差值器
///
/// [OverlayState]
/// [Overlay.of]
///
/// [Navigator.of]
/// [NavigatorState.overlay]
OverlayEntry? showOverlay(
  OverlayEntryAnimatedWidgetBuilder builder, {
  BuildContext? context,
  Curve? curve,
  Duration? duration,
  Key? key,
  GlobalKey<OverlayAnimatedState>? overlayStateKey,
  Duration? animationDuration,
  Duration? reverseAnimationDuration,
}) {
  OverlayState? overlayState;
  if (context == null) {
    GlobalConfig.def.globalTopContext
        ?.eachVisitChildElements((element, depth, childIndex) {
      if (element.widget is Overlay) {
        overlayState = (element as StatefulElement?)?.state as OverlayState?;
        return false;
      }
      return true;
    });
    //Overlay
  } else {
    overlayState = Overlay.of(context);
  }
  if (overlayState == null) {
    assert(() {
      debugPrint('overlayState is null, dispose this call');
      return true;
    }());
    return null;
  }
  context ??= GlobalConfig.def.globalTopContext;
  if (context == null) {
    assert(() {
      debugPrint('context is null, dispose this call');
      return true;
    }());
    return null;
  }
  final overlayKey = key ?? UniqueKey();
  final stateKey = overlayStateKey ?? GlobalKey<OverlayAnimatedState>();

  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (context) {
      return KeyedSubtree(
        key: key,
        child: OverlayAnimated(
          key: stateKey,
          builder: (context, progress) => builder(entry!,
              stateKey.currentState as OverlayAnimatedState, context, progress),
          curve: curve,
          animationDuration: animationDuration ?? kNotificationSlideDuration,
          reverseAnimationDuration:
              reverseAnimationDuration ?? kNotificationSlideDuration,
          duration: duration ?? Duration.zero,
          overlayKey: overlayKey,
        ),
      );
    },
  );

  GlobalConfig.of(context).addOverlayEntry(entry, key: overlayKey);
  overlayState?.insert(entry);
  return entry;
}
