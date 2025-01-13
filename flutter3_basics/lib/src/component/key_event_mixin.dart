part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/12/27
///
/// 键盘事件监听
/// [HardwareKeyboard]
/// [KeyboardListener]
/// [ServicesBinding.instance.keyEventManager.keyMessageHandler]
///
/// [KeyEventStateMixin]
/// [KeyEventRenderObjectMixin]
///
mixin KeyEventStateMixin<T extends StatefulWidget> on State<T>, KeyEventMixin {
  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(onKeyEventHandleMixin);
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(onKeyEventHandleMixin);
    _keyEventRegisterList.clear();
    super.dispose();
  }
}

/// [KeyEventStateMixin]
/// [KeyEventRenderObjectMixin]
mixin KeyEventRenderObjectMixin on RenderObject, KeyEventMixin {
  @override
  void attach(PipelineOwner owner) {
    HardwareKeyboard.instance.addHandler(onKeyEventHandleMixin);
    super.attach(owner);
  }

  @override
  void detach() {
    HardwareKeyboard.instance.removeHandler(onKeyEventHandleMixin);
    _keyEventRegisterList.clear();
    super.detach();
  }
}

mixin KeyEventMixin {
  //--

  /// 键盘事件监听
  final List<KeyEventRegister> _keyEventRegisterList = [];

  /// 注册一个键盘事件监听
  @api
  void registerKeyEvent(List<List<LogicalKeyboardKey>>? eventGroupKeys,
      KeyEventHandleAction? onKeyEventAction, {
        bool matchKeyCount = true,
        bool stopPropagation = true,
      }) {
    addKeyEventRegister(KeyEventRegister(
      eventGroupKeys,
      stopPropagation: stopPropagation,
      matchKeyCount: matchKeyCount,
      onKeyEventAction: onKeyEventAction,
    ));
  }

  /// 添加键盘事件监听
  @api
  void addKeyEventRegister(KeyEventRegister register) {
    _keyEventRegisterList.add(register);
  }

  /// 移除键盘事件监听
  @api
  void removeKeyEventRegister(KeyEventRegister register) {
    _keyEventRegisterList.remove(register);
  }

  /// 移除所有键盘事件监听
  @api
  void removeAllKeyEventRegister() {
    _keyEventRegisterList.clear();
  }

  @overridePoint
  bool onKeyEventHandleMixin(KeyEvent event) {
    bool handle = false;
    if (event.isKeyDownOrRepeat) {
      for (final register in _keyEventRegisterList) {
        final onKeyEvent = register.onKeyEventAction;
        if (onKeyEvent == null) {
          continue;
        }
        //--
        final eventGroupKeys = register.eventGroupKeys;
        if (eventGroupKeys != null) {
          //中断
          bool interrupt = false;
          for (final keys in eventGroupKeys) {
            if (isKeysPressedAll(keys, matchKeyCount: register.matchKeyCount)) {
              handle = onKeyEvent(KeyEventHitInfo(keys, event.isKeyRepeat));
              assert(() {
                l.d("按键命中->[${keys.connect(
                    " + ", (e) => e.debugName ?? e.keyLabel)}] $handle");
                return true;
              }());
              if (handle && register.stopPropagation) {
                interrupt = true;
                break;
              }
            }
          }
          if (interrupt) {
            break;
          }
        }
      }
    }
    return handle;
  }
}

typedef KeyEventHandleAction = bool Function(KeyEventHitInfo);

/// 键盘事件, 注册信息
class KeyEventRegister {
  /// 事件按键
  final List<List<LogicalKeyboardKey>>? eventGroupKeys;

  /// 回调
  final KeyEventHandleAction? onKeyEventAction;

  /// 事件被处理之后, 是否阻止冒泡
  final bool stopPropagation;

  /// 是否要匹配按键的数量
  final bool matchKeyCount;

  const KeyEventRegister(this.eventGroupKeys, {
    this.onKeyEventAction,
    this.stopPropagation = true,
    this.matchKeyCount = true,
  });
}

/// 键盘事件, 命中信息
/// [KeyEventRegister]
class KeyEventHitInfo {
  /// 命中的按键组合
  final List<LogicalKeyboardKey> keys;

  /// 是否是重复事件
  final bool isKeyRepeat;

  const KeyEventHitInfo(this.keys, this.isKeyRepeat);

  @override
  String toString() {
    return 'KeyEventHitInfo{keys: $keys, isKeyRepeat: $isKeyRepeat}';
  }
}
