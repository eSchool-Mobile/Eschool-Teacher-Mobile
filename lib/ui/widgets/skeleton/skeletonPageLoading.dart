import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonPageLoading extends StatelessWidget {
  final int items;
  final double padding;
  final Axis axis;

  const SkeletonPageLoading({
    super.key,
    this.items = 6,
    this.padding = 16.0,
    this.axis = Axis.vertical,
  });

  Color _baseColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withValues(alpha: 0.95);
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor(context),
      highlightColor: _highlightColor(context),
      enabled: true,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: axis == Axis.vertical
            ? Column(
                children:
                    List.generate(items, (index) => _buildCard(context, index)),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                      items, (index) => _buildCard(context, index)),
                ),
              ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0, right: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8.0)),
                  Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.white),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(height: 10, width: 80, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 10, width: 80, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small skeleton widgets that can be composed inside screens when needed.
