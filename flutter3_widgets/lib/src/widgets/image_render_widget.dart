part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 图片渲染小部件
class ImageRenderWidget extends SingleChildRenderObjectWidget {
  final ImageRenderController controller;

  const ImageRenderWidget(this.controller, {super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      ImageRenderObject(controller);

  @override
  void updateRenderObject(
      BuildContext context, ImageRenderObject renderObject) {
    renderObject
      ..controller = controller
      ..markNeedsPaint();
  }
}

/// 核心渲染对象
class ImageRenderObject extends RenderProxyBox {
  ImageRenderController controller;

  ImageRenderObject(this.controller);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
  }

  @override
  void detach() {
    super.detach();
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  /// 手势坐标点
  Offset? touchPointer;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    //l.d('${event.position} ${event.localPosition} ${event.delta}');
    if (event.isTouchEvent) {
      if (event.isPointerFinish) {
        if (touchPointer != null) {
          final imagePointer =
              controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
          if (controller._imageRect.contains(imagePointer)) {
            controller.onPointerUp?.call(imagePointer);
          }
        }
        touchPointer = null;
      } else {
        touchPointer = event.localPosition;
        final imagePointer =
            controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
        if (controller._imageRect.contains(imagePointer)) {
          controller.onPointerUpdate?.call(imagePointer);
        }
      }
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    controller._initIfNeed(this);

    final canvas = context.canvas;

    //bg
    final rect = offset & size;
    if (controller.renderBgColor != null) {
      canvas.drawRect(rect, Paint()..color = controller.renderBgColor!);
    }

    //child
    super.paint(context, offset);

    //image
    final image = controller.image;
    if (image != null) {
      /*assert(() {
        canvas.drawRect(
            controller._imageOperateRect, Paint()..color = Colors.black26);
        if (touchPointer != null) {
          canvas.drawCircle(touchPointer!, 10, Paint()..color = Colors.black26);
        }

        canvas.drawRect(controller._imageRect, Paint()..color = Colors.black26);
        if (touchPointer != null) {
          final rawPointer =
              controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
          canvas.drawCircle(rawPointer, 10, Paint()..color = Colors.black26);
        }
        return true;
      }());*/
      canvas.withMatrix(
        controller.operateMatrix,
        () {
          canvas.drawImage(image, offset, Paint());
        },
      );
    }
  }
}

/// 控制器
class ImageRenderController extends ChangeNotifier with NotifierMixin {
  /// 渲染的背景颜色
  Color? renderBgColor;

  /// 渲染的图片
  UiImage? image;

  /// 内边距
  EdgeInsets padding = const EdgeInsets.all(30);

  /// 在图片中手势移动的事件更新回调
  OffsetCallback? onPointerUpdate;

  /// 在图片中手势抬起的事件回调
  OffsetCallback? onPointerUp;

  ImageRenderController({
    this.image,
    this.renderBgColor,
  });

  //region --控制操作--

  /// 重置图片
  /// [resetMatrix] 是否重置矩阵
  void resetImage(UiImage? image, {bool resetMatrix = true}) {
    this.image = image;
    if (resetMatrix) {
      baseMatrix = null;
    }
  }

  //endregion --控制操作--

  //region --绘制操作--

  /// 图片矩形
  Rect get _imageRect => Rect.fromLTWH(0.0, 0.0, image?.width.toDouble() ?? 1.0,
      image?.height.toDouble() ?? 1.0);

  /// 图片操作之后的矩形
  Rect get _imageOperateRect => operateMatrix.mapRect(_imageRect);

  /// 用来刷新界面使用
  ImageRenderObject? _renderObject;

  @autoInjectMark
  @initialize
  void _initIfNeed(ImageRenderObject renderObject) {
    _renderObject = renderObject;
    if (baseMatrix == null) {
      final Size size = (renderObject.size -
          Offset(padding.horizontal, padding.vertical)) as Size;
      final rect = _imageRect;
      //默认居中显示图片
      final translate = Matrix4.identity();
      final scale = Matrix4.identity();
      final dst = applyAlignRect(size, rect.size,
          fit: BoxFit.contain, alignment: Alignment.center);
      translate.translate(dst.left + padding.left, dst.top + padding.top);
      scale.scale(dst.width / rect.size.width, dst.height / rect.size.height);
      baseMatrix = translate * scale;
    }
  }

  /// 基础矩阵
  Matrix4? baseMatrix;

  /// 操作后的矩阵, 包含了基础矩阵, 和操作属性的矩阵
  Matrix4 get operateMatrix => baseMatrix ?? Matrix4.identity();

//endregion --绘制操作--
}
