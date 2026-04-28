import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLine extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonLine(
      {super.key,
      this.height = 12,
      this.width = double.infinity,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(6)),
      ),
    );
  }
}

