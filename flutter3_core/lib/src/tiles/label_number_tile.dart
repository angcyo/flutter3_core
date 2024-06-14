part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/10
///
/// 数字输入tile
/// 上label     右number(支持键盘输入)
/// 下des
/// [LabelNumberSliderTile]
class LabelNumberTile extends StatefulWidget {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  /// 描述
  final String? des;
  final EdgeInsets? desPadding;
  final Widget? desWidget;

  //--

  /// 数值
  /// value
  final num value;
  final num? minValue;
  final num? maxValue;
  final int maxDigits;
  final NumType? _numType;

  /// 并不需要在此方法中更新界面
  final ValueChanged<num>? onChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<num>? onConfirmChange;

  /// tile的填充
  final EdgeInsets? tilePadding;

  const LabelNumberTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.labelActions,
    this.des,
    this.desWidget,
    this.desPadding = kDesPadding,
    this.value = 0,
    this.minValue,
    this.maxValue,
    this.maxDigits = 2,
    this.onChanged,
    this.onConfirmChange,
    this.tilePadding = kTilePadding,
    NumType? numType,
  }) : _numType = numType ?? (value is int ? NumType.i : NumType.d);

  @override
  State<LabelNumberTile> createState() => _LabelNumberTileState();
}

class _LabelNumberTileState extends State<LabelNumberTile> with TileMixin {
  num _initialValue = 0;
  num _currentValue = 0;

  @override
  void initState() {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberTile oldWidget) {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // build label
    Widget? label = buildLabelWidget(
      context,
      labelWidget: widget.labelWidget,
      label: widget.label,
      labelPadding: widget.labelPadding,
      constraints: null,
    );
    if (label != null && !isNil(widget.labelActions)) {
      label = [
        label,
        ...?widget.labelActions,
      ].row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center);
    }

    final numberStr = formatNumber(_currentValue, numType: widget._numType);
    final number = buildNumberWidget(context, numberStr, onTap: () async {
      final value = await context.showWidgetDialog(NumberKeyboardDialog(
        number: _currentValue,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        maxDigits: widget.maxDigits,
        numType: widget._numType,
      ));
      if (value != null) {
        _changeValue(value);
      }
    });

    return [
      [
        label,
        buildDesWidget(
          context,
          desWidget: widget.desWidget,
          des: widget.des,
          desPadding: widget.desPadding,
        )
      ].column(crossAxisAlignment: CrossAxisAlignment.start)?.expanded(),
      number,
    ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding)
        .material();
  }

  void _changeValue(num toValue) async {
    if (widget.onConfirmChange != null) {
      final result = await widget.onConfirmChange!(toValue);
      if (result is bool && result != true) {
        return;
      }
    }
    _currentValue = toValue;
    widget.onChanged?.call(toValue);
    updateState();
  }
}
