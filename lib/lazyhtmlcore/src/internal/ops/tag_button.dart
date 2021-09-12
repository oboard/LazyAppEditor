part of '../core_ops.dart';

class TagButton {
  final LazyWidgetFactory wf;

  TagButton(this.wf);

  BuildOp get buildOp => BuildOp(
        defaultStyles: (_) {
          final styles = {kCssTextDecoration: kCssTextDecorationNone};

          return styles;
        },
        onTree: (meta, tree) {
          if (meta.willBuildSubtree == true) return;

          final onTap = _gestureTapCallback(meta);
          if (onTap == null) return;

          for (final bit in tree.bits.toList(growable: false)) {
            if (bit is WidgetBit) {
              bit.child
                  .wrapWith((_, child) => wf.buildButton(meta, child, onTap));
              tree.add(bit);
            } else if (bit is! WhitespaceBit) {
              _TagButtonBit(bit.parent, bit.tsb, onTap).insertAfter(bit);
            }
          }
        },
        onWidgets: (meta, widgets) {
          if (meta.willBuildSubtree == false) return widgets;

          final onTap = _gestureTapCallback(meta);
          if (onTap == null) return widgets;

          return listOrNull(wf
              .buildColumnPlaceholder(meta, widgets)
              ?.wrapWith((_, child) => wf.buildButton(meta, child, onTap)));
        },
        onWidgetsIsOptional: true,
      );

  GestureTapCallback? _gestureTapCallback(BuildMetadata meta) {
    final href = meta.element.attributes[kAttributeAHref];
    return href != null
        ? wf.gestureTapCallback(wf.urlFull(href) ?? href)
        : null;
  }
}

class _TagButtonBit extends BuildBit<GestureRecognizer?, GestureRecognizer> {
  final GestureTapCallback onTap;

  _TagButtonBit(BuildTree? parent, TextStyleBuilder tsb, this.onTap)
      : super(parent, tsb);

  @override
  bool? get swallowWhitespace => null;

  @override
  GestureRecognizer buildBit(GestureRecognizer? recognizer) {
    if (recognizer is TapGestureRecognizer) {
      recognizer.onTap = onTap;
      return recognizer;
    }

    return TapGestureRecognizer()..onTap = onTap;
  }

  @override
  BuildBit copyWith({BuildTree? parent, TextStyleBuilder? tsb}) =>
      _TagButtonBit(parent ?? this.parent, tsb ?? this.tsb, onTap);
}
