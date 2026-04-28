import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  const SkeletonCard(
      {super.key,
      this.height = 100,
      this.width,
      this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Skeleton untuk Class Section Card (sesuai dengan teacherClassSectionScreen)
