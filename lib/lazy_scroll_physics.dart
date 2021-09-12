import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

// ignore: non_constant_identifier_names
ScrollPhysics LazyScrollPhysics() {
  // if (lowSpecification??false) return AlwaysScrollableScrollPhysics();
  return _LazyScrollPhysics();
}

class _LazyScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that bounce back from the edge.
  const _LazyScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  _LazyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _LazyScrollPhysics(
        parent: buildParent(AlwaysScrollableScrollPhysics()));
  }

  /// The multiple applied to overScroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overScroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overScrollFraction` which starts at 0 when there is no overScroll).
  double frictionFactor(double overScrollFraction) =>
      0.52 * math.pow(1 - overScrollFraction, 2);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) return offset;

    final double overScrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overScrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overScrollPast =
        math.max(overScrollPastStart, overScrollPastEnd);
    final bool easing = (overScrollPastStart > 0.0 && offset < 0.0) ||
        (overScrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overScroll vs tensioning.
        ? frictionFactor(
            (overScrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overScrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overScrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) => 0.0;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }
}
