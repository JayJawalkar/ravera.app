import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? bgColor;
  final Color? shadowColor;
  final double? radius;
  const BlurContainer({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    required this.blur,
    this.padding,
    this.bgColor,
    this.shadowColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      blur: blur,
      height: height,
      width: width,
      padding: padding ?? EdgeInsets.all(10),
      color: bgColor ?? Colors.transparent,
      shadowColor: shadowColor ?? Colors.black26,
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
      child: child,
    );
  }
}
