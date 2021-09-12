import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///说明！！！！！！！！！！！！！！
///LazyButtonA是宽按钮
///LazyButtonB是大按钮，计时器暂停和停止
///LazyButtonC是带模糊的按钮，用于计时器菜单
///LazyButtonCard是卡片样式的按钮

const double kMinInteractiveDimensionLazy = 44;

class LazyButton extends StatefulWidget {
  /// Creates an iOS-style button.
  const LazyButton({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.disabledColor,
    this.align = Alignment.center,
    this.minSize = kMinInteractiveDimensionLazy,
    this.pressedOpacity = 0.9,
    this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.onPressed,
    this.tooltip,
    this.margin,
    this.filled = false,
    this.mainAxisAlignment,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        hasIcon = false,
        isTile = false,
        super(key: key);

  const LazyButton.filled({
    Key? key,
    required this.child,
    this.padding,
    this.disabledColor,
    this.minSize = kMinInteractiveDimensionLazy,
    this.pressedOpacity = 0.9,
    this.align = Alignment.center,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.color,
    this.margin,
    this.mainAxisAlignment,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        filled = true,
        hasIcon = false,
        isTile = false,
        super(key: key);

  const LazyButton.icon({
    Key? key,
    this.child,
    this.padding,
    this.disabledColor,
    this.minSize = kMinInteractiveDimensionLazy,
    this.pressedOpacity = 0.9,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.align = Alignment.center,
    this.color,
    this.margin,
    this.mainAxisAlignment,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        filled = false,
        isTile = false,
        hasIcon = true,
        super(key: key);

  const LazyButton.tile({
    Key? key,
    this.child,
    this.padding,
    this.disabledColor,
    this.minSize = kMinInteractiveDimensionLazy,
    this.pressedOpacity = 0.9,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.align = Alignment.center,
    this.color,
    this.margin,
    this.filled = false,
    this.mainAxisAlignment,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        isTile = true,
        hasIcon = true,
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget? child;
  final Widget? icon;
  final String? tooltip;
  final Alignment align;
  final MainAxisAlignment? mainAxisAlignment;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? disabledColor;
  final VoidCallback? onPressed;
  final double minSize;
  final double pressedOpacity;
  final BorderRadius borderRadius;
  final bool filled;
  final bool hasIcon;
  final bool isTile;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  _LazyButtonState createState() => _LazyButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _LazyButtonState extends State<LazyButton>
    with SingleTickerProviderStateMixin {
  // Eyeballed values. Feel free to tweak.
  static const Duration kFadeOutDuration = Duration(milliseconds: 100);
  static const Duration kFadeInDuration = Duration(milliseconds: 150);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  AnimationController? _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _animation = _animationController!
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(LazyButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _animationController = null;
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController!.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController!.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController!.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final Color primaryColor = Theme.of(context).chipTheme.backgroundColor;
    final Color? backgroundColor = widget.color == null
        ? (widget.filled ? primaryColor : null)
        : CupertinoDynamicColor.resolve(widget.color!, context);

    final ThemeData theme = Theme.of(context);
    Color? currentColor = Theme.of(context).iconTheme.color;
    if (!enabled || widget.onPressed == null)
      currentColor = widget.disabledColor ?? theme.disabledColor;
    Widget c = Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: backgroundColor == null
            ? widget.disabledColor
            : ((enabled) ? backgroundColor : backgroundColor.withOpacity(0.05)),
      ),
      child: Padding(
        padding: widget.padding ??
            EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12,
            ),
        child: widget.hasIcon
            ? (widget.child == null)
                ? IconTheme.merge(
                    data: Theme.of(context).iconTheme.copyWith(
                          color: currentColor,
                        ),
                    child: widget.icon!,
                  )
                : (widget.isTile)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            widget.mainAxisAlignment ?? MainAxisAlignment.start,
                        children: [
                          widget.icon!,
                          const SizedBox(
                            width: 24,
                          ),
                          widget.child!,
                        ],
                      )
                    : widget.child
            : widget.child,
      ),
    );
    c = GestureDetector(
      onTapUp: enabled ? _handleTapUp : null,
      onTapDown: enabled ? _handleTapDown : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      behavior: HitTestBehavior.translucent,
      child: Semantics(
        button: true,
        focusable: true,
        child: Container(
          padding: widget.margin ?? EdgeInsets.zero,
          child: ScaleTransition(
            scale: _animation,
            child: (widget.icon == null || widget.isTile)
                ? InkWell(
                    borderRadius: widget.borderRadius,
                    onTap: widget.onPressed,
                    child: c,
                  )
                : InkResponse(onTap: widget.onPressed, child: c),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip ?? '', child: c);
    }
    return c;
  }
}

class LazyButtonS extends StatefulWidget {
  /// Creates an iOS-style button.
  const LazyButtonS({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.disabledColor,
    this.align = Alignment.center,
    this.pressedOpacity = 0.9,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.onPressed,
    this.icon,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        isIcon = false,
        super(key: key);

  const LazyButtonS.icon({
    Key? key,
    this.child,
    this.padding,
    this.disabledColor,
    this.pressedOpacity = 0.9,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.onPressed,
    this.icon,
    this.align = Alignment.center,
    this.onTapUp,
    this.onTapDown,
    this.onTapCancel,
  })  : assert((pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        color = null,
        isIcon = true,
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget? child;
  final Widget? icon;
  final Alignment align;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final VoidCallback? onPressed;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final double pressedOpacity;
  final BorderRadius borderRadius;
  final bool isIcon;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  _LazyButtonStateS createState() => _LazyButtonStateS();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _LazyButtonStateS extends State<LazyButtonS>
    with SingleTickerProviderStateMixin {
  // Eyeballed values. Feel free to tweak.
  static const Duration kFadeOutDuration = Duration(milliseconds: 100);
  static const Duration kFadeInDuration = Duration(milliseconds: 150);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  AnimationController? _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController!
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(LazyButtonS old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _animationController = null;
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    widget.onTapDown?.call(event);
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    widget.onTapUp?.call(event);
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    widget.onTapCancel?.call();
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController!.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController!.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController!.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    // final Color primaryColor = Theme.of(context).chipTheme.backgroundColor;

    final ThemeData theme = Theme.of(context);
    Color currentColor = Theme.of(context).primaryColor;
    if (!enabled) currentColor = widget.disabledColor ?? theme.disabledColor;

    var c = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _opacityAnimation,
        child: Padding(
          padding: widget.padding ??
              ((widget.isIcon)
                  ? EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    )
                  : EdgeInsets.only(left: 16, right: 16)),
          child: widget.isIcon
              ? (widget.child == null && widget.isIcon
                  ? IconTheme.merge(
                      data: Theme.of(context).primaryIconTheme.copyWith(
                            color: currentColor,
                          ),
                      child: widget.icon!,
                    )
                  : Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        IconTheme.merge(
                          data: Theme.of(context).primaryIconTheme.copyWith(
                                color: currentColor,
                              ),
                          child: widget.icon!,
                        ),
                        Expanded(
                          child: widget.child!,
                        ),
                      ],
                    ))
              : widget.child,
        ),
      ),
    );
    return c;
  }
}
