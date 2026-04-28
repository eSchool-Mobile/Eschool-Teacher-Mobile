import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonAvatar extends StatelessWidget {
  final double size;
  const SkeletonAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(size / 6)),
      ),
    );
  }
}

