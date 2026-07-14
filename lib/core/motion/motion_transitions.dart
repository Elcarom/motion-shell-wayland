import 'package:flutter/animation.dart';

abstract final class MotionTransitions {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration short = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration long = Duration(milliseconds: 520);

  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  static Duration resolve(Duration duration, {required bool reduceMotion}) {
    return reduceMotion ? Duration.zero : duration;
  }
}
