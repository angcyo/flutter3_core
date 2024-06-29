part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
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
  if (data == null) {
    return null;
  }
  if (data is String) {
    return data;
  }
  if (data is ITextProvider) {
    return data.provideText;
  }
  if (data != null) {
    try {
      return data.text;
    } catch (e) {
      assert(() {
        l.w('当前类型[${data.runtimeType}],不支持[.text]/[ITextProvider]操作.');
        return true;
      }());
      return "$data";
    }
  }
  return null;
}

/// 在一个数据中, 提取Widget
/// [tryTextWidget] 是否尝试使用[Text]小部件
Widget? widgetOf(
  BuildContext context,
  dynamic data, {
  bool tryTextWidget = false,
  TextStyle? textStyle,
  TextAlign? textAlign,
}) {
  if (data == null) {
    return null;
  }
  if (data is Widget) {
    return data;
  }
  if (data is IWidgetProvider && data.provideWidget != null) {
    return data.provideWidget?.call(context);
  }
  if (tryTextWidget) {
    final text = textOf(data);
    if (text != null) {
      final globalTheme = GlobalTheme.of(context);
      return text.text(
        style: textStyle ?? globalTheme.textGeneralStyle,
        textAlign: textAlign,
      );
    }
  }
  assert(() {
    l.w('当前类型[${data.runtimeType}]不支持[IWidgetProvider]操作.');
    return true;
  }());
  return null;
}

//---
