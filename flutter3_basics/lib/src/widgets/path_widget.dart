part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/08
///
/// [Path]路径绘制小部件
class PathWidget extends LeafRenderObjectWidget {
  /// The path to render.
  final Path? path;

  final ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  final Color color;

  final BoxFit fit;

  final Alignment alignment;

  const PathWidget({
    super.key,
    this.path,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => PathRenderBox(
        path: path,
        style: style,
        color: color,
        fit: fit,
        alignment: alignment,
      );

  @override
  void updateRenderObject(BuildContext context, PathRenderBox renderObject) {
    renderObject
      ..updatePath(path)
      ..style = style
      ..color = color
      ..fit = fit
      ..alignment = alignment
      ..markNeedsPaint();
  }
}

class PathRenderBox extends RenderBox {
  /// The path to render.
  Path? path;

  ui.PaintingStyle style;

  /// The fill color to use when rendering the path.
  Color color;

  BoxFit fit;

  Alignment alignment;

  Rect? _pathBounds;

  PathRenderBox({
    this.path,
    this.style = ui.PaintingStyle.stroke,
    this.color = Colors.black,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  void updatePath(Path? newPath) {
    if (path != newPath) {
      _pathBounds = null;
    }
    path = newPath;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (path != null) {
      _pathBounds ??= path!.getExactBounds();
      final pathSize = _pathBounds!.size;
      if (constraints.isTight) {
        //有一种满意的约束尺寸
        size = constraints.smallest;
      } else {
        size = constraints.constrain(pathSize);
      }
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    if (path != null) {
      final canvas = context.canvas;
      canvas.drawPathIn(path, _pathBounds, offset & size,
          fit: fit,
          alignment: alignment,
          paint: Paint()
            ..color = color
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = style);
    }
  }
}

//--

class PathRegionInfo {
  /// 需要绘制的路径
  final Path? path;

  /// 填充绘制的颜色, 有值就绘制
  final Color? fillColor;

  /// 按下时的填充颜色
  @defInjectMark
  final Color? downFillColor;

  /// 描边绘制的颜色, 有值就绘制
  final Color? strokeColor;

  /// 按下时的描边颜色
  @defInjectMark
  final Color? downStrokeColor;

  /// 描边的宽度
  final double strokeWidth;

  /// 点击事件
  final VoidCallback? onTap;

  // --
  Rect? boundsCache;
  bool isPointerDown;

  PathRegionInfo({
    this.path,
    this.fillColor,
    this.downFillColor,
    this.strokeColor = Colors.black,
    this.downStrokeColor,
    this.strokeWidth = 1.0,
    this.onTap,
    //--
    this.boundsCache,
    this.isPointerDown = false,
  });
}

/// [Path]路径区域绘制小部件
/// 支持绘制n个[Path]并且支持事件响应
class PathRegionWidget extends LeafRenderObjectWidget {
  /// 检查命中元素时, 是否倒序
  final bool reverseHitTest;

  final List<PathRegionInfo>? regionInfoList;

  const PathRegionWidget({
    super.key,
    this.reverseHitTest = false,
    this.regionInfoList,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      PathRegionRenderBox(this);

  @override
  void updateRenderObject(
      BuildContext context, PathRegionRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..config = this
      ..markNeedsLayout();
  }
}

class PathRegionRenderBox extends RenderBox {
  PathRegionWidget config;

  PathRegionRenderBox(
    this.config,
  );

  @override
  void performLayout() {
    final constraints = this.constraints;
    size = constraints.biggest;
  }

  /// 命中时, 颜色亮度
  final double _hitBrightness = 60.0;

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    final canvas = context.canvas;
    canvas.withTranslate(offset.dx, offset.dy, () {
      for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
        if (item.path != null) {
          if (item.fillColor != null) {
            canvas.drawPath(
                item.path!,
                Paint()
                  ..color = item.isPointerDown
                      ? item.downFillColor ??
                          item.fillColor!.withBrightness(_hitBrightness)
                      : item.fillColor!
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round
                  ..style = PaintingStyle.fill);
          }
          if (item.strokeColor != null) {
            canvas.drawPath(
                item.path!,
                Paint()
                  ..color = item.isPointerDown
                      ? item.downStrokeColor ??
                          item.strokeColor!.withBrightness(_hitBrightness)
                      : item.strokeColor!
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round
                  ..strokeWidth = item.strokeWidth
                  ..style = PaintingStyle.stroke);
          }
        }
      }
    });
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  Iterable<PathRegionInfo> get _hitTestList =>
      (config.reverseHitTest
          ? config.regionInfoList?.reversed
          : config.regionInfoList) ??
      <PathRegionInfo>[];

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerDownEvent) {
      cancelPointerDown();
    }
    for (final item in _hitTestList) {
      if (event is PointerDownEvent) {
        item.isPointerDown = item.path?.contains(event.localPosition) == true;
        if (item.isPointerDown) {
          markNeedsPaint();
          break;
        }
      } else if (event is PointerUpEvent) {
        if (item.isPointerDown == true) {
          item.onTap?.call();
          markNeedsPaint();
          break;
        }
      } else if (event.isPointerFinish) {
        item.isPointerDown = false;
        markNeedsPaint();
      }
    }
    if (event.isPointerFinish) {
      cancelPointerDown();
    }
  }

  /// 取消所有手势按下状态
  void cancelPointerDown() {
    for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
      item.isPointerDown = false;
    }
  }

  /// 查找手势按下时在的[PathRegionInfo]区域
  PathRegionInfo? findPathRegionInfo(Offset localPosition) {
    for (final item in config.regionInfoList ?? <PathRegionInfo>[]) {
      if (item.path != null) {
        if (item.path!.contains(localPosition)) {
          return item;
        }
      }
    }
    return null;
  }
}
