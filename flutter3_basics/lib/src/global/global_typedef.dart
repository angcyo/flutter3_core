part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///

//region Fn Callback

typedef Action = VoidCallback;
typedef VoidAction = Action;

/// [VoidAction]
typedef FutureVoidAction = FutureOr Function();

/// 只有返回值的回调
typedef ResultCallback<T> = T Function();

/// 返回值和一个参数的回调
typedef ResultValueCallback<R, T> = R Function(T value);

/// [Future] 返回值的回调
typedef FutureResultCallback<R, T> = Future<R> Function(T value);

/// 只有一个值回调
typedef ValueCallback<T> = dynamic Function([T value]);

/// [ValueCallback]
/// [FutureOr]
typedef FutureValueCallback<T> = FutureOr<T> Function([T value]);

/// 回调一个值和一个错误
typedef ValueErrorCallback = dynamic Function(dynamic value, dynamic error);

/// 进度回调
/// [count] 已发送的数据量
/// [total] 总数据量, 有可能为0
typedef ProgressAction = void Function(int count, int total);

/// 进度回调[0~1]
typedef ProgressRatioCallback = void Function(double progress);

/// 索引类型的回调
typedef IndexCallback = void Function(int index);

/// [num]数字类型的回调
typedef NumCallback = void Function(num number);

/// [bool]类型的回调
typedef BoolCallback = void Function(bool value);

/// 转变一个[widget]
typedef TransformWidgetBuilder = Widget Function(
    BuildContext context, Widget widget);

/// 转变一个[widget], 携带一个[data]参数
typedef TransformDataWidgetBuilder = Widget Function(
    BuildContext context, Widget widget, dynamic data);

//endregion Fn
