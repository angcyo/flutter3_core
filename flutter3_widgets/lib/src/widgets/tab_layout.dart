part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/11
///
/// [TabLayout]的指示器控制器
class TabLayoutController extends TabController {
  final ScrollContainerController? scrollController;

  TabLayoutController({
    required super.vsync,

    /// 初始位置
    super.initialIndex = 0,

    ///[kTabScrollDuration]
    super.animationDuration,

    /// 没啥用
    /// 如果在[TabBarView]中使用, 就需要指定此值
    /// 如果在[TabLayoutPageViewWrap]中使用, 则不需要
    super.length = intMax32Value,

    /// 用来实现滚动居中
    this.scrollController,
  });

  /// 选择tab的位置
  @api
  void selectedItem(
    int index, {
    bool animate = true,
    Duration? duration,
    Curve curve = Curves.ease,
  }) {
    scrollController?.scrollToIndex(
      index,
      animate: animate,
      duration: duration,
      curve: curve,
    );
    animateTo(
      index,
      duration: animate ? duration : Duration.zero,
      curve: curve,
    );
  }
}

/// [SingleChildScrollView]
class TabLayout extends ScrollContainerWidget {
  /// [TabLayoutController]
  final TabLayoutController? tabLayoutController;

  /// 子节点之间的间隙
  final double gap;

  /// 当子元素的数量在这个范围时, 开启等宽
  /// [min~max]
  final String? autoEqualWidthRange;

  /// 自动等宽, 当所有子节点的大小没有超过父节点时, 开启等宽
  final bool autoEqualWidth;

  TabLayout({
    super.key,
    required super.children,
    ScrollController? scrollController,
    this.tabLayoutController,
    this.gap = 0,
    this.autoEqualWidthRange,
    this.autoEqualWidth = false,
    super.scrollDirection = Axis.horizontal,
    super.reverse = false,
    super.padding,
    super.primary,
    super.physics,
    super.dragStartBehavior = DragStartBehavior.start,
    super.clipBehavior = Clip.hardEdge,
    super.restorationId,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(
            scrollController:
                scrollController ?? tabLayoutController?.scrollController);

  @override
  State<TabLayout> createState() => _TabLayoutState();
}

class _TabLayoutState extends ScrollContainerState<TabLayout> {
  @override
  Widget build(BuildContext context) {
    return buildScrollContainer(
        context,
        (context, position) => TabLayoutViewport(
              offset: position,
              axisDirection: _getDirection(context),
              padding: widget.padding,
              clipBehavior: widget.clipBehavior,
              scrollController: widget.scrollController,
              crossAxisAlignment: widget.crossAxisAlignment,
              tabController: widget.tabLayoutController,
              gap: widget.gap,
              autoEqualWidth: widget.autoEqualWidth,
              autoEqualWidthRange: widget.autoEqualWidthRange,
              children: widget.children,
            ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TabLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// [TabLayout] 的子布局
class TabLayoutViewport extends MultiChildRenderObjectWidget {
  const TabLayoutViewport({
    super.key,
    super.children,
    required this.offset,
    this.axisDirection = AxisDirection.left,
    this.crossAxisDirection,
    this.padding,
    this.scrollController,
    this.tabController,
    this.gap = 0,
    this.clipBehavior = Clip.hardEdge,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.autoEqualWidthRange,
    this.autoEqualWidth = false,
  });

  /// 确定原点位置
  final AxisDirection axisDirection;

  final AxisDirection? crossAxisDirection;

  /// 滚动偏移
  final ViewportOffset offset;

  /// The amount of space by which to inset the child.
  final EdgeInsets? padding;
  final Clip clipBehavior;
  final ScrollController? scrollController;
  final CrossAxisAlignment? crossAxisAlignment;
  final TabLayoutController? tabController;
  final double gap;

  /// 当子元素的数量在这个范围时, 开启等宽
  /// [min~max]
  final String? autoEqualWidthRange;

  /// 自动等宽, 当所有子节点的大小没有超过父节点时, 开启等宽
  final bool autoEqualWidth;

  @override
  TabLayoutRender createRenderObject(BuildContext context) {
    return TabLayoutRender(
      axisDirection: axisDirection,
      clipBehavior: clipBehavior,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      offset: offset,
      scrollController: scrollController ?? tabController?.scrollController,
      crossAxisAlignment: crossAxisAlignment,
      tabController: tabController,
      padding: padding,
      gap: gap,
      autoEqualWidth: autoEqualWidth,
      autoEqualWidthRange: autoEqualWidthRange,
    );
  }

  @override
  void updateRenderObject(BuildContext context, TabLayoutRender renderObject) {
    renderObject
      ..axisDirection = axisDirection
      ..clipBehavior = clipBehavior
      ..crossAxisDirection = crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection)
      ..offset = offset
      ..scrollController = scrollController ?? tabController?.scrollController
      ..tabController = tabController
      ..padding = padding
      ..gap = gap
      ..autoEqualWidth = autoEqualWidth
      ..autoEqualWidthRange = autoEqualWidthRange
      ..crossAxisAlignment = crossAxisAlignment;
  }

  @override
  TabLayoutElement createElement() {
    return TabLayoutElement(this);
  }
}

/// [_SingleChildViewportElement]
/// [_ViewportElement]
class TabLayoutElement extends MultiChildRenderObjectElement
    with NotifiableElementMixin, ViewportElementMixin {
  TabLayoutElement(TabLayoutViewport super.widget);
}

/// [SingleChildScrollView]
/// [_RenderSingleChildViewport]
class TabLayoutRender extends ScrollContainerRenderBox {
  /// [TabLayoutController]
  /// 指示器控制
  TabLayoutController? tabController;

  /// 当子元素的数量在这个范围时, 开启等宽
  /// [min~max]
  String? autoEqualWidthRange;

  /// 自动等宽, 当所有子节点的大小没有超过父节点时, 开启等宽
  bool autoEqualWidth;

  TabLayoutRender({
    super.axisDirection = AxisDirection.right,
    required super.crossAxisDirection,
    required super.offset,
    super.clipBehavior = Clip.hardEdge,
    super.scrollController,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.padding,
    super.gap = 0,
    this.tabController,
    this.autoEqualWidthRange,
    this.autoEqualWidth = false,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TabLayoutParentData) {
      child.parentData = TabLayoutParentData();
    }
  }

  /// 指示器需要绘制改变
  void _tabChanged() {
    //debugger();
    assert(() {
      //offset + index =  _animationController!.value;
      //l.d('index:${tabController?.index} offset:${tabController?.offset} animateValue:${tabController?.animation?.value}');
      return true;
    }());
    markNeedsLayout();
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    tabController?.addListener(_tabChanged);
    tabController?.animation?.addListener(_tabChanged);
  }

  @override
  void detach() {
    tabController?.removeListener(_tabChanged);
    tabController?.animation?.removeListener(_tabChanged);
    super.detach();
  }

  /// 获取滚动的子节点
  @override
  List<RenderBox> getScrollChildren() => getIndicatorChildren(null);

  /// 获取指定类型的子节点
  List<RenderBox> getIndicatorChildren(TabItemType? itemType) {
    return tabController == null
        ? []
        : getChildren().where((element) {
            final parentData = element.parentData;
            return parentData is TabLayoutParentData &&
                parentData.itemType == itemType;
          }).toList();
  }

  @override
  void performLayout() {
    //debugger();
    super.performLayout();
    _relayoutDecoration();
    _relayoutIndicator();
    _relayoutStack();
  }

  @override
  (double, double) measureChildren(List<RenderBox> children) {
    final BoxConstraints constraints = this.constraints;
    final (childMaxWidth, childMaxHeight) = super.measureChildren(children);

    bool equalWidthOrHeight = false;
    final parentWidth =
        (constraints.maxWidth - paddingHorizontal).ensureValid(childMaxWidth);
    final parentHeight =
        (constraints.maxHeight - paddingVertical).ensureValid(childMaxHeight);

    if (autoEqualWidthRange?.matchVersion(children.length) == true) {
      equalWidthOrHeight = true;
    } else if (autoEqualWidth) {
      //所有的子节点, 都没有超过父节点的大小
      if (axis == Axis.horizontal) {
        final childWidth =
            children.fold(0.0, (value, element) => value + element.size.width);
        if (childWidth < parentWidth) {
          equalWidthOrHeight = true;
        }
      } else {
        final childHeight =
            children.fold(0.0, (value, element) => value + element.size.height);
        if (childHeight < parentHeight) {
          equalWidthOrHeight = true;
        }
      }
    }
    //--
    if (equalWidthOrHeight) {
      //等宽or等高
      final childCount = children.length;
      if (childCount > 0) {
        double? childWidth;
        double? childHeight;
        //debugger();

        if (axis == Axis.horizontal) {
          childWidth = (parentWidth - gap * (childCount - 1)) / childCount;
          if (isChildMatchParent) {
            childHeight = constraints.maxHeight.ensureValid(parentHeight);
          }
        } else {
          childHeight = (parentHeight - gap * (childCount - 1)) / childCount;
          if (isChildMatchParent) {
            childWidth = constraints.maxWidth.ensureValid(parentWidth);
          }
        }
        return measureWrapChildren(
          children,
          childWidth: childWidth,
          childHeight: childHeight,
        );
      }
    }
    return (childMaxWidth, childMaxHeight);
  }

  /// 重新布局指示器
  void _relayoutIndicator() {
    final children = getIndicatorChildren(TabItemType.indicator);
    final controller = tabController;
    if (controller != null) {
      int startIndex = controller.index;
      int endIndex = startIndex;

      //动画进度 [-1~1]
      double progress = controller.offset;

      if (controller.indexIsChanging) {
        //这种情况可能是, 直接滚动到指定位置
        startIndex = controller.previousIndex;
        endIndex = controller.index;
        final animateProgress =
            (controller.offset / (endIndex - startIndex)).ensureValid(0);
        progress = 1 - animateProgress.abs();
      } else {
        //这种情况可能是, 在pageView中手势滚动
        if (controller.offset >= 0) {
          //向右滚动
          endIndex = startIndex + controller.offset.ceil();
        } else {
          //向左滚动
          endIndex = startIndex + controller.offset.floor();
          progress = progress.abs();
        }
      }

      //目标位置
      final startChild = getScrollChildAt(startIndex);
      final endChild = getScrollChildAt(endIndex);
      assert(() {
        //l.d('from:$startIndex to:$endIndex animateProgress:$progress');
        return true;
      }());

      final startRect = startChild?.getBoundsInParentOrNull() ?? Rect.zero;
      final endRect = endChild?.getBoundsInParentOrNull() ?? Rect.zero;
      assert(() {
        //l.i('startRect:$startRect endRect:$endRect :$progress');
        return true;
      }());

      //debugger();

      //开始测量/布局
      for (final child in children) {
        final parentData = child.parentData as TabLayoutParentData;
        //measure, 计算指示器的宽高
        double startWidth = startRect.width;
        double startHeight = startRect.height;
        double endWidth = endRect.width;
        double endHeight = endRect.height;

        startWidth += parentData.paddingHorizontal;
        startHeight += parentData.paddingVertical;
        endWidth += parentData.paddingHorizontal;
        endHeight += parentData.paddingVertical;

        //margin
        Offset marginOffset = Offset(
            parentData.marginLeft - parentData.marginRight,
            parentData.marginTop - parentData.marginBottom);
        if (axis == Axis.horizontal) {
          startWidth -= parentData.marginHorizontal;
          endWidth -= parentData.marginHorizontal;
        } else {
          startHeight -= parentData.marginVertical;
          endHeight -= parentData.marginVertical;
        }

        //--
        if (parentData.itemConstraints?.isMatchParentWidth == true) {
          if (axis == Axis.vertical && parentData.alignmentParent == true) {
            startWidth =
                size.width - paddingHorizontal - parentData.marginHorizontal;
            endWidth = startWidth;
          }
        } else if (parentData.itemConstraints?.isFixedWidth == true) {
          startWidth =
              parentData.itemConstraints!.maxWidth.ensureValid(startWidth);
          endWidth = startWidth;
        }
        //--
        if (parentData.itemConstraints?.isMatchParentHeight == true) {
          if (axis == Axis.horizontal && parentData.alignmentParent == true) {
            startHeight =
                size.height - paddingVertical - parentData.marginVertical;
            endHeight = startHeight;
          }
        } else if (parentData.itemConstraints?.isFixedHeight == true) {
          startHeight =
              parentData.itemConstraints!.maxHeight.ensureValid(startHeight);
          endHeight = startHeight;
        }

        //对齐使用
        Rect startAnchorBounds = startRect;
        Rect endAnchorBounds = endRect;
        if (parentData.alignmentParent == true) {
          //debugger();
          if (axis == Axis.horizontal) {
            final offsetTop =
                parentData.itemConstraints?.isMatchParentHeight == true
                    ? 0.0
                    : paddingTop;
            final offsetBottom =
                parentData.itemConstraints?.isMatchParentHeight == true
                    ? 0.0
                    : paddingBottom;
            startAnchorBounds = Rect.fromLTRB(
              startRect.left,
              offsetTop,
              startRect.right,
              size.height - offsetBottom,
            );
            endAnchorBounds = Rect.fromLTRB(
              endRect.left,
              offsetTop,
              endRect.right,
              size.height - offsetBottom,
            );
          } else {
            final offsetLeft =
                parentData.itemConstraints?.isMatchParentWidth == true
                    ? 0.0
                    : paddingLeft;
            final offsetRight =
                parentData.itemConstraints?.isMatchParentWidth == true
                    ? 0.0
                    : paddingRight;
            startAnchorBounds = Rect.fromLTRB(
              offsetLeft,
              startRect.top,
              size.width - offsetRight,
              startRect.bottom,
            );
            endAnchorBounds = Rect.fromLTRB(
              offsetLeft,
              endRect.top,
              size.width - offsetRight,
              endRect.bottom,
            );
          }
        }

        //计算当前的大小
        double width = startWidth + (endWidth - startWidth) * progress;
        double height = startHeight + (endHeight - startHeight) * progress;

        //layout, 计算当前的位置
        final startOffset = alignRectOffset(parentData.alignment,
            startAnchorBounds, Size(startWidth, startHeight));
        final endOffset = alignRectOffset(
            parentData.alignment, endAnchorBounds, Size(endWidth, endHeight));
        //指示器的2个位置
        final startBounds = Rect.fromLTWH(
            startOffset.dx, startOffset.dy, startWidth, startHeight);
        final endBounds =
            Rect.fromLTWH(endOffset.dx, endOffset.dy, endWidth, endHeight);

        Offset offset = startOffset + (endOffset - startOffset) * progress;

        //debugger();

        if (parentData.enableIndicatorFlow &&
            (endIndex - startIndex).abs() <= parentData.indicatorFlowStep) {
          //流式变化, 前一半的进度, 放大到目标大小, 后一半的进度, 缩小到目标大小

          final step = (endIndex - startIndex).abs();
          if (endIndex >= startIndex) {
            //往右/往下 流动
            if (progress < step / 2) {
              //前一半, 放大
              final flowProgress = progress * 2;
              if (axis == Axis.horizontal) {
                offset = Offset(startBounds.left, offset.dy);
                width = startWidth +
                    (endBounds.right - startBounds.right) * flowProgress;
              } else {
                offset = Offset(offset.dx, startBounds.top);
                height = startHeight +
                    (endBounds.bottom - startBounds.bottom) * flowProgress;
              }
            } else {
              //后一半, 缩小
              final flowProgress = 1 - (progress - step / 2) * 2;
              if (axis == Axis.horizontal) {
                final leftDx =
                    (endBounds.left - startBounds.left) * flowProgress;
                offset = Offset(endBounds.left - leftDx, offset.dy);
                width = endWidth + leftDx;
              } else {
                final topDx = (endBounds.top - startBounds.top) * flowProgress;
                offset = Offset(offset.dx, endBounds.top - topDx);
                height = endHeight + topDx;
              }
            }
          } else {
            //往左/往上 流动
            if (progress < step / 2) {
              //前一半, 放大
              final flowProgress = progress * 2;
              if (axis == Axis.horizontal) {
                final leftDx =
                    (startBounds.left - endBounds.left) * flowProgress;
                offset = Offset(startBounds.left - leftDx, offset.dy);
                width = startWidth + leftDx;
              } else {
                final topDx = (startBounds.top - endBounds.top) * flowProgress;
                offset = Offset(offset.dx, startBounds.top - topDx);
                height = startHeight + topDx;
              }
            } else {
              //后一半, 缩小
              final flowProgress = 1 - (progress - step / 2) * 2;
              if (axis == Axis.horizontal) {
                offset = Offset(endBounds.left, offset.dy);
                width = endWidth +
                    (startBounds.right - endBounds.right) * flowProgress;
              } else {
                offset = Offset(offset.dx, endBounds.top);
                height = endHeight +
                    (startBounds.bottom - endBounds.bottom) * flowProgress;
              }
            }
          }
        }

        //debugger();
        child.layout(
          BoxConstraints.tightFor(
            width: width,
            height: height,
          ),
          parentUsesSize: true,
        );

        //debugger();
        parentData.offset = offset + marginOffset;

        //滚动到居中位置
        final scrollController = this.scrollController;
        if (scrollController is ScrollContainerController) {
          if (axis == Axis.horizontal) {
            scrollController.scrollTo(
              parentData.offset.dx + child.size.width / 2,
              center: true,
              animate: false,
            );
          } else {
            scrollController.scrollTo(
              parentData.offset.dy + child.size.height / 2,
              center: true,
              animate: false,
            );
          }
        }
      }
    }
  }

  /// 重新布局装饰
  void _relayoutDecoration() {
    //--
    final bgDecorationChildren = getIndicatorChildren(TabItemType.bgDecoration);
    for (final child in bgDecorationChildren) {
      final parentData = child.parentData as TabLayoutParentData;
      child.layout(
        parentData.getItemConstraints(size),
        parentUsesSize: true,
      );
      //parentData.offset = Offset.zero;
    }

    //--
    final scrollDecorationChildren =
        getIndicatorChildren(TabItemType.scrollDecoration);
    for (final child in scrollDecorationChildren) {
      final parentData = child.parentData as TabLayoutParentData;

      final extendHorizontal =
          axis == Axis.horizontal ? paddingHorizontal : 0.0;
      final extendVertical = axis == Axis.vertical ? paddingVertical : 0.0;
      final extend = Offset(extendHorizontal, extendVertical);
      child.layout(
        parentData.getItemConstraints(_scrollChildSize + extend),
        parentUsesSize: true,
      );
      //parentData.offset = Offset.zero;
    }
  }

  /// 重新布局堆叠
  void _relayoutStack() {
    final children = getChildren();
    final stackChildren = getIndicatorChildren(TabItemType.stack);

    // 获取stackChild之前的滚动内容child
    RenderBox? getStackBeforeChild(RenderBox stackChild) {
      RenderBox? result;
      for (final child in children) {
        final parentData = child.parentData as TabLayoutParentData;
        if (parentData.itemType == null) {
          result = child;
        }
        if (child == stackChild) {
          break;
        }
      }
      return result;
    }

    //--
    for (final child in stackChildren) {
      final parentData = child.parentData as TabLayoutParentData;

      final anchorIndex = parentData.stackAnchorIndex;
      RenderBox? anchorChild;
      if (anchorIndex != null) {
        anchorChild = children.getOrNull(anchorIndex);
      } else {
        anchorChild = getStackBeforeChild(child);
      }
      Rect? anchorRect = anchorChild?.getBoundsInParentOrNull();

      //debugger();
      BoxConstraints childConstraints = BoxConstraints(
        maxWidth: parentData.alignmentParent
            ? size.width
            : anchorRect?.width ?? size.width,
        maxHeight: parentData.alignmentParent
            ? size.height
            : anchorRect?.height ?? size.height,
      );
      if (parentData.itemConstraints != null) {
        childConstraints = parentData.getItemConstraints(size);
      }
      child.layout(childConstraints, parentUsesSize: true);
      //debugger();

      //layout
      if (anchorRect != null) {
        if (parentData.alignmentParent) {
          if (axis == Axis.horizontal) {
            anchorRect = Rect.fromLTRB(
                anchorRect.left, 0, anchorRect.right, size.height);
          } else {
            anchorRect =
                Rect.fromLTRB(0, anchorRect.top, size.width, anchorRect.bottom);
          }
        }
        final offset =
            alignRectOffset(parentData.alignment, anchorRect, child.size);
        //margin
        Offset marginOffset = Offset(
            parentData.marginLeft - parentData.marginRight,
            parentData.marginTop - parentData.marginBottom);
        parentData.offset = offset + marginOffset;
      } else {
        parentData.offset = Offset.zero;
      }
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    // 绘制指定类型的子节点
    // 这里绘制的内容, 不支持滚动
    // 需要支持滚动请使用[paintScrollContents]
    void paintChildren(List<RenderBox> children, TabItemPaintType paintType) {
      for (final child in children) {
        final parentData = child.parentData;
        if (parentData is TabLayoutParentData) {
          if (parentData.itemPaintType == paintType) {
            context.paintChild(child, offset + parentData.offset);
          }
        }
      }
    }

    //--
    final bgDecorationChildren = getIndicatorChildren(TabItemType.bgDecoration);
    paintChildren(bgDecorationChildren, TabItemPaintType.background);
    super.paint(context, offset);
    //--
    paintChildren(bgDecorationChildren, TabItemPaintType.foreground);
  }

  @override
  void paintScrollContents(PaintingContext context, ui.Offset offset) {
    //debugger();
    //_relayoutIndicator();
    final Offset paintOffset = _paintOffset;

    // 绘制指定类型的子节点
    // 这里的绘制支持滚动
    void paintChildren(List<RenderBox> children, TabItemPaintType paintType) {
      for (final child in children) {
        final parentData = child.parentData;
        if (parentData is TabLayoutParentData) {
          if (parentData.itemPaintType == paintType) {
            context.paintChild(child, offset + parentData.offset + paintOffset);
          }
        }
      }
    }

    //---
    final scrollDecorationChildren =
        getIndicatorChildren(TabItemType.scrollDecoration);
    final indicatorChildren = getIndicatorChildren(TabItemType.indicator);
    final stackChildren = getIndicatorChildren(TabItemType.stack);

    paintChildren(scrollDecorationChildren, TabItemPaintType.background);
    paintChildren(indicatorChildren, TabItemPaintType.background);
    paintChildren(stackChildren, TabItemPaintType.background);
    super.paintScrollContents(context, offset);
    //---
    paintChildren(indicatorChildren, TabItemPaintType.foreground);
    paintChildren(scrollDecorationChildren, TabItemPaintType.foreground);
    paintChildren(stackChildren, TabItemPaintType.foreground);
  }
}

enum TabItemType {
  /// 指示器,不占用布局空间
  indicator,

  /// 滚动装饰器,不占用布局空间, 作用于整个[TabLayout], 受滚动影响
  scrollDecoration,

  /// 背景装饰器,不占用布局空间,  作用于整个[TabLayout], 不受滚动影响
  bgDecoration,

  /// 间隙类型,占用布局空间, 和[TabLayout.gap]一起作用
  gap,

  /// 堆叠类型,不占用布局空间,将元素和锚点child堆叠在一起
  /// 可以用来实现new/消息提示等效果
  /// 如果不指定锚点, 则默认使用元素之前的第一个child作为锚点
  stack,
}

enum TabItemPaintType {
  /// 指示器绘制在背景
  background,

  /// 指示器绘制在前景
  foreground,
}

class TabLayoutData extends ParentDataWidget<TabLayoutParentData> {
  final TabItemType? itemType;
  final TabItemPaintType itemPaintType;
  final EdgeInsets? padding;
  final AlignmentGeometry alignment;
  final LayoutBoxConstraints? itemConstraints;
  final bool alignmentParent;
  final bool enableIndicatorFlow;
  final EdgeInsets? margin;
  final int? stackAnchorIndex;

  const TabLayoutData({
    super.key,
    required super.child,
    this.itemType,
    this.itemConstraints,
    this.itemPaintType = TabItemPaintType.background,
    this.padding,
    this.margin,
    this.alignmentParent = true,
    this.enableIndicatorFlow = false,
    this.alignment = Alignment.center,
    this.stackAnchorIndex,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! TabLayoutParentData) {
      renderObject.parentData = TabLayoutParentData();
    }
    final parentData = renderObject.parentData;
    if (parentData is TabLayoutParentData) {
      //debugger();
      parentData
        ..padding = padding
        ..margin = margin
        ..itemType = itemType
        ..alignment = alignment
        ..itemConstraints = itemConstraints
        ..alignmentParent = alignmentParent
        ..enableIndicatorFlow = enableIndicatorFlow
        ..stackAnchorIndex = stackAnchorIndex
        ..itemPaintType = itemPaintType;
      if (renderObject.parent is TabLayoutRender) {
        renderObject.parent?.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TabLayout;
}

class TabLayoutParentData extends ContainerBoxParentData<RenderBox> {
  /// 当前widget的类型
  TabItemType? itemType;

  /// 是否启用流式变化, 指示器在流向下一个位置时, 先放大到最大, 然后缩小到最小
  bool enableIndicatorFlow = false;

  /// 2个位置之间的间隔item必须小于此值, [enableIndicatorFlow]才有效
  int indicatorFlowStep = 1;

  /// 指示器绘制类型
  TabItemPaintType itemPaintType = TabItemPaintType.background;

  /// 当前指定[itemType]的约束
  LayoutBoxConstraints? itemConstraints;

  /// 当前指定[itemType]的对齐方式
  /// 只有当[itemType]不为null时, 才会生效
  AlignmentGeometry alignment = Alignment.center;

  /// 对齐参考父布局的大小, 否则参考自身的大小
  bool alignmentParent = true;

  //--

  /// 指示器的需要额外填充的大小
  /// 如果固定了宽高大小, 则此大小应该是包含了padding的大小
  EdgeInsets? padding;

  double get paddingHorizontal => (padding?.horizontal ?? 0);

  double get paddingVertical => (padding?.vertical ?? 0);

  //--

  /// 指示器布局后, 需要额外的偏移距离
  /// 如果是[ConstraintsType.matchParent]的测量方式, 则margin会影响大小
  EdgeInsets? margin;

  double get marginHorizontal => (margin?.horizontal ?? 0);

  double get marginVertical => (margin?.vertical ?? 0);

  double get marginLeft => (margin?.left ?? 0);

  double get marginTop => (margin?.top ?? 0);

  double get marginRight => (margin?.right ?? 0);

  double get marginBottom => (margin?.bottom ?? 0);

  //--

  /// [TabItemType.stack]
  /// 堆叠类型的锚点child索引
  int? stackAnchorIndex;

  /// 获取当前的约束
  BoxConstraints getItemConstraints(Size parentSize) {
    final itemConstraints = this.itemConstraints;
    double minWidth = parentSize.width;
    double maxWidth = minWidth;
    double minHeight = parentSize.height;
    double maxHeight = minHeight;
    if (itemConstraints != null) {
      return itemConstraints.constraintsWithParent(
        parentSize,
        padding: padding,
        margin: margin,
      );
    }
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }
}

extension TabLayoutEx on Widget {
  /// [TabLayoutData]
  /// [tabItemData]
  /// [tabStackItemData]
  Widget tabItemData({
    TabItemType? itemType,
    TabItemPaintType itemPaintType = TabItemPaintType.background,
    EdgeInsets? padding,
    EdgeInsets? margin,
    AlignmentGeometry alignment = Alignment.center,
    LayoutBoxConstraints? itemConstraints,
    ConstraintsType? widthConstraintsType,
    ConstraintsType? heightConstraintsType,
    bool? alignmentParent,
    bool enableIndicatorFlow = false,
    int? stackAnchorIndex,
  }) {
    if (itemConstraints == null) {
      if (widthConstraintsType != null || heightConstraintsType != null) {
        itemConstraints = LayoutBoxConstraints(
          widthType: widthConstraintsType,
          heightType: heightConstraintsType,
        );
      }
    }
    return TabLayoutData(
      itemType: itemType,
      itemPaintType: itemPaintType,
      padding: padding,
      margin: margin,
      alignment: alignment,
      alignmentParent: alignmentParent ??
          (itemConstraints?.isMatchParentWidth == true ||
                  itemConstraints?.isMatchParentHeight == true) ||
              (itemType != null && itemType != TabItemType.stack),
      enableIndicatorFlow: enableIndicatorFlow,
      itemConstraints: itemConstraints,
      stackAnchorIndex: stackAnchorIndex,
      child: this,
    );
  }

  /// [TabLayoutData]
  /// [tabItemData]
  /// [tabStackItemData]
  Widget tabStackItemData({
    int? stackAnchorIndex,
    EdgeInsets? padding,
    EdgeInsets? margin = const EdgeInsets.only(top: kL, right: kL),
    TabItemType? itemType = TabItemType.stack,
    TabItemPaintType itemPaintType = TabItemPaintType.foreground,
    AlignmentGeometry alignment = Alignment.topRight,
    LayoutBoxConstraints? itemConstraints,
    ConstraintsType? widthConstraintsType,
    ConstraintsType? heightConstraintsType,
    bool? alignmentParent = true,
  }) {
    if (itemConstraints == null) {
      if (widthConstraintsType != null || heightConstraintsType != null) {
        itemConstraints = LayoutBoxConstraints(
          widthType: widthConstraintsType,
          heightType: heightConstraintsType,
        );
      }
    }
    return TabLayoutData(
      itemType: itemType,
      itemPaintType: itemPaintType,
      padding: padding,
      margin: margin,
      alignment: alignment,
      alignmentParent: alignmentParent ??
          (itemConstraints?.isMatchParentWidth == true ||
                  itemConstraints?.isMatchParentHeight == true) ||
              (itemType != null && itemType != TabItemType.stack),
      itemConstraints: itemConstraints,
      stackAnchorIndex: stackAnchorIndex,
      child: this,
    );
  }
}

//region ---TabLayoutPageViewWrap---

/// [TabBarView]
class TabLayoutPageViewWrap extends StatefulWidget {
  const TabLayoutPageViewWrap({
    super.key,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction = 1.0,
    this.clipBehavior = Clip.hardEdge,
  });

  final TabController? controller;

  final List<Widget> children;
  final ScrollPhysics? physics;

  final DragStartBehavior dragStartBehavior;
  final double viewportFraction;
  final Clip clipBehavior;

  @override
  State<TabLayoutPageViewWrap> createState() => _TabLayoutPageViewWrapState();
}

class _TabLayoutPageViewWrapState extends State<TabLayoutPageViewWrap> {
  TabController? _tabController;
  PageController? _pageController;
  late List<Widget> _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;
  int _scrollUnderwayCount = 0;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _tabController?.animation != null;

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.maybeOf(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _tabController) {
      return;
    }

    if (_controllerIsValid) {
      _tabController!.animation!
          .removeListener(_handleTabControllerAnimationTick);
    }
    _tabController = newController;
    if (_tabController != null) {
      _tabController!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  void _updateChildren() {
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    if (_scrollUnderwayCount > 0 || !_tabController!.indexIsChanging) {
      return;
    } // This widget is driving the controller's animation.
    //debugger();
    if (_tabController!.index != _currentIndex) {
      _currentIndex = _tabController!.index;
      _warpToCurrentIndex();
    }
  }

  void _warpToCurrentIndex() {
    if (!mounted || _pageController!.page == _currentIndex!.toDouble()) {
      return;
    }

    final bool adjacentDestination =
        (_currentIndex! - _tabController!.previousIndex).abs() == 1;
    if (adjacentDestination) {
      _warpToAdjacentTab(_tabController!.animationDuration);
    } else {
      _warpToNonAdjacentTab(_tabController!.animationDuration);
    }
  }

  Future<void> _warpToAdjacentTab(Duration duration) async {
    if (duration == Duration.zero) {
      _jumpToPage(_currentIndex!);
    } else {
      await _animateToPage(_currentIndex!,
          duration: duration, curve: Curves.ease);
    }
    if (mounted) {
      setState(() {
        _updateChildren();
      });
    }
    return Future<void>.value();
  }

  Future<void> _warpToNonAdjacentTab(Duration duration) async {
    final int previousIndex = _tabController!.previousIndex;
    assert((_currentIndex! - previousIndex).abs() > 1);

    // initialPage defines which page is shown when starting the animation.
    // This page is adjacent to the destination page.
    final int initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;

    setState(() {
      // Needed for `RenderSliverMultiBoxAdaptor.move` and kept alive children.
      // For motivation, see https://github.com/flutter/flutter/pull/29188 and
      // https://github.com/flutter/flutter/issues/27010#issuecomment-486475152.
      _childrenWithKey = List<Widget>.of(_childrenWithKey, growable: false);
      final Widget temp = _childrenWithKey[initialPage];
      _childrenWithKey[initialPage] = _childrenWithKey[previousIndex];
      _childrenWithKey[previousIndex] = temp;
    });

    // Make a first jump to the adjacent page.
    _jumpToPage(initialPage);

    // Jump or animate to the destination page.
    if (duration == Duration.zero) {
      _jumpToPage(_currentIndex!);
    } else {
      await _animateToPage(_currentIndex!,
          duration: duration, curve: Curves.ease);
    }

    if (mounted) {
      setState(() {
        _updateChildren();
      });
    }
  }

  void _syncControllerOffset() {
    _tabController!.offset =
        clampDouble(_pageController!.page! - _tabController!.index, -1.0, 1.0);
  }

  void _jumpToPage(int page) {
    _warpUnderwayCount += 1;
    _pageController!.jumpToPage(page);
    _warpUnderwayCount -= 1;
  }

  Future<void> _animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    _warpUnderwayCount += 1;
    await _pageController!
        .animateToPage(page, duration: duration, curve: curve);
    _warpUnderwayCount -= 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _tabController!.index;
    if (_pageController == null) {
      _pageController = PageController(
        initialPage: _currentIndex!,
        viewportFraction: widget.viewportFraction,
      );
    } else {
      _pageController!.jumpToPage(_currentIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PageView(
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        controller: _pageController,
        physics: widget.physics == null
            ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
            : const PageScrollPhysics().applyTo(widget.physics),
        children: _childrenWithKey,
      ),
    );
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    //l.d('notification: $notification');
    if (_warpUnderwayCount > 0 || _scrollUnderwayCount > 0) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }

    if (!_controllerIsValid) {
      return false;
    }
    //debugger();

    _scrollUnderwayCount += 1;
    final double page = _pageController!.page!;
    if (notification is ScrollUpdateNotification &&
        !_tabController!.indexIsChanging) {
      final bool pageChanged = (page - _tabController!.index).abs() > 1.0;
      if (pageChanged) {
        _tabController!.index = page.round();
        _currentIndex = _tabController!.index;
      }
      _syncControllerOffset();
    } else if (notification is ScrollEndNotification) {
      _tabController!.index = page.round();
      _currentIndex = _tabController!.index;
      if (!_tabController!.indexIsChanging) {
        _syncControllerOffset();
      }
    }
    _scrollUnderwayCount -= 1;

    return false;
  }
}

//endregion ---TabLayoutPageViewWrap---
