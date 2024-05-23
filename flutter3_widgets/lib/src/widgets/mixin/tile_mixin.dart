part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/21
///

/// 提供一个文本字符串
mixin ITextProvider {
  String? get provideText;
}

/// 提供一个Widget
mixin IWidgetProvider {
  WidgetBuilder? get provideWidget;
}

/// 在一个数据中, 提取文本
String? textOf(dynamic data) {
  if (data is String) {
    return data;
  } else if (data is ITextProvider) {
    return data.provideText;
  } else if (data != null) {
    try {
      return data.text;
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
      return "$data";
    }
  }
  return null;
}

/// 在一个数据中, 提取Widget
Widget? widgetOf(BuildContext context, dynamic data) {
  if (data is Widget) {
    return data;
  } else if (data is IWidgetProvider) {
    return data.provideWidget?.call(context);
  }
  return null;
}

//---

/// label默认的填充
const kLabelPadding = EdgeInsets.only(
  left: kX,
  right: kX,
  top: kH,
  bottom: kH,
);

const kLabelMinWidth = 80.0;

/// label默认的约束
const kLabelConstraints = BoxConstraints(
  minWidth: kLabelMinWidth,
  maxWidth: kLabelMinWidth,
);

//---

mixin TileMixin {
  /// 构建图标小部件
  Widget? buildIconWidget(
    BuildContext context, {
    Widget? iconWidget,
    IconData? icon,
    double? iconSize,
    Color? iconColor,
    bool themeStyle = true,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = iconWidget ??
        (icon == null
            ? null
            : Icon(
                icon,
                size: iconSize,
                color:
                    iconColor ?? (themeStyle ? globalTheme.accentColor : null),
              ));
    return widget?.paddingInsets(padding);
  }

  /// 构建文本小部件
  /// [GlobalTheme.textDesStyle]
  /// [GlobalTheme.textBodyStyle]
  /// [GlobalTheme.textLabelStyle]
  Widget? buildTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    TextStyle? textStyle,
    bool themeStyle = true,
    EdgeInsets? textPadding,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = textWidget ??
        (text
            ?.text(
              style:
                  textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null),
            )
            .paddingInsets(textPadding));
    return widget?.paddingInsets(padding);
  }

  /// [buildTextWidget]
  Widget? buildLabelWidget(
    BuildContext context, {
    Widget? labelWidget,
    String? label,
    TextStyle? labelStyle,
    bool themeStyle = true,
    EdgeInsets? labelPadding = kLabelPadding,
    EdgeInsets? padding,
    BoxConstraints? constraints = kLabelConstraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = labelWidget ??
        (label
            ?.text(
              style: labelStyle ??
                  (themeStyle ? globalTheme.textLabelStyle : null),
            )
            .constrainedBox(constraints)
            .paddingInsets(labelPadding));
    return widget?.paddingInsets(padding);
  }

  /// 构建判断文本小部件, 支持选中状态提示
  /// [enable] 是否启用
  /// [isSelected] 是否选中
  Widget? buildSegmentTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    bool enable = true,
    bool isSelected = false,
    bool themeStyle = true,
    EdgeInsets? padding = const EdgeInsets.all(kL),
  }) {
    final globalTheme = GlobalTheme.of(context);
    final normalTextStyle =
        textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null);
    final selectTextStyle = selectedTextStyle ??
        textStyle?.copyWith(fontWeight: ui.FontWeight.bold) ??
        (themeStyle
            ? globalTheme.textBodyStyle.copyWith(fontWeight: ui.FontWeight.bold)
            : null);

    final widget = textWidget ??
        (text?.text(
          textAlign: ui.TextAlign.center,
          style: isSelected ? selectTextStyle : normalTextStyle,
        ));
    return widget?.paddingInsets(padding).backgroundDecoration(!enable
        ? fillDecoration(
            color: globalTheme.disableColor,
            borderRadius: kDefaultBorderRadiusX,
          )
        : isSelected
            ? fillDecoration(
                color: globalTheme.accentColor,
                borderRadius: kDefaultBorderRadiusX,
              )
            : null);
  }

  /// 构建一个[Switch]开关小部件
  /// [activeColor] 激活时圈圈的颜色
  /// [activeTrackColor] 激活时轨道的颜色
  /// [Switch]小部件需要[Material]支持.
  Widget buildSwitchWidget(
    BuildContext context,
    bool value, {
    ValueChanged<bool>? onChanged,
    double? height = 30.0,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    Color? focusColor,
    Color? hoverColor,
    Color? splashColor,
    Color? disabledColor,
    MouseCursor? mouseCursor,
    MaterialTapTargetSize? materialTapTargetSize =
        MaterialTapTargetSize.shrinkWrap,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? iconSize,
    Widget? icon,
    Widget? activeIcon,
    Color? tintColor,
    Color? disableTintColor,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    Widget widget = Switch(
      value: value,
      onChanged: onChanged ??
          (value) {
            assert(() {
              l.d('开关切换->$value');
              return true;
            }());
          },
      activeColor: activeColor,
      activeTrackColor: activeTrackColor ?? globalTheme.accentColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      mouseCursor: mouseCursor,
      materialTapTargetSize: materialTapTargetSize,
      dragStartBehavior: dragStartBehavior,
    );

    //使用[FittedBox]控制大小
    if (height != null) {
      widget = widget.fittedBox().wh(60 / 40 * height, height);
    }

    return widget.paddingInsets(padding);
  }
}
