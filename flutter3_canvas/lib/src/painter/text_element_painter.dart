part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
/// 文本绘制元素对象
class TextElementPainter extends ElementPainter {
  /// 当前绘制文本的对象
  BaseTextPainter? textPainter;

  TextElementPainter() {
    debug = false;
  }

  /// 使用一个文本初始化[textPainter]对象,
  /// 并确认[TextElementPainter]元素的大小, 位置默认是0,0
  /// [onInitTextPainter] 回调给外部设置属性
  @initialize
  void initElementFromText(
    String? text, {
    void Function(BaseTextPainter textPainter)? onInitTextPainter,
  }) {
    final textPainter = NormalTextPainter()
      ..debugPaintBounds = debug
      ..text = text;
    onInitTextPainter?.call(textPainter);
    textPainter.initPainter();
    this.textPainter = textPainter;
    final size = textPainter.painterBounds;
    paintProperty = PaintProperty()
      ..width = size.width
      ..height = size.height;
    //paintTextPainter = textPainter;
  }

  /// 绘制前, 更新文本颜色
  @override
  void onPaintingSelfBefore(Canvas canvas, PaintMeta paintMeta) {
    super.onPaintingSelfBefore(canvas, paintMeta);
    onSelfUpdateTextPainter();
  }

  /// 绘制前, 更新文本颜色
  /// [onPaintingSelfBefore]
  @overridePoint
  void onSelfUpdateTextPainter() {
    textPainter?.updateTextProperty(textColor: paint.color);
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    paintItTextPainter(canvas, paintMeta, textPainter);
    super.onPaintingSelf(canvas, paintMeta);
  }
}
