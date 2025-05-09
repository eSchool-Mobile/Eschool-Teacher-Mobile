import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/ui/widgets/appBarPainter.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedBottomNavigation extends StatefulWidget {
  final List<BottomNavItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AnimatedBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AnimatedBottomNavigation> createState() =>
      _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation>
    with TickerProviderStateMixin {
  double horizontalPadding = 40.0;
  double horizontalMargin = 15.0;
  late int noOfIcons;

  // Soft maroon color palette
  final Color softMaroon = const Color(0xFFAA4A6A); // Base soft maroon
  final Color lightMaroon =
      const Color(0xFFCF7A95); // Lighter variant for highlights
  final Color darkMaroon =
      const Color(0xFF8A3A54); // Darker variant for contrasts

  late double position;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    noOfIcons = widget.items.length;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 375));
  }

  @override
  void didChangeDependencies() {
    position = getEndPosition(widget.selectedIndex);
    animation = Tween(begin: position, end: position).animate(controller);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      animateDrop(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double getEndPosition(int index) {
    // Calculate the width of each item section
    double totalWidth =
        MediaQuery.of(context).size.width - (2 * horizontalMargin);
    double itemWidth = (totalWidth - (2 * horizontalPadding)) / noOfIcons;

    // Calculate the center position of the selected item
    double itemCenterX =
        horizontalPadding + (itemWidth * index) + (itemWidth / 2);

    // Center the circle on the item (subtract half the circle width)
    return itemCenterX - 70.0;
  }

  void animateDrop(int index) {
    double newPosition = getEndPosition(index);
    animation = Tween(begin: position, end: newPosition).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    controller.reset();
    controller.forward().then((value) {
      position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AppBarPainter(
            animation.value,
            circleColor: softMaroon,
            navigationBarColor: Colors.white,
            selectedIndex:
                widget.selectedIndex, // Pass the selected index to the painter
          ),
          size: Size(MediaQuery.of(context).size.width - (2 * horizontalMargin),
              100.0), // Meningkatkan tinggi dari 90 ke 100
          child: SizedBox(
            height: 140.0, // Meningkatkan tinggi dari 130 ke 140
            width: MediaQuery.of(context).size.width - (2 * horizontalMargin),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(noOfIcons, (index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      widget.onItemSelected(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 375),
                      curve: Curves.easeOut,
                      height: 125, // Meningkatkan tinggi dari 115 ke 125
                      width: (MediaQuery.of(context).size.width -
                              (2 * horizontalMargin) -
                              (2 * horizontalPadding)) /
                          noOfIcons,
                      padding: const EdgeInsets.only(top: 17.5, bottom: 22.5),
                      alignment: isSelected
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 35.0,
                            width: 35.0,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 375),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeOut,
                                child: SvgPicture.asset(
                                  Utils.getImagePath(isSelected
                                      ? item.selectedIconPath
                                      : item.iconPath),
                                  key: ValueKey(
                                      '${isSelected ? 'selected' : 'normal'}${item.iconPath}'),
                                  height: 28.0,
                                  width: 28.0,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          if (!isSelected) ...[
                            const SizedBox(height: 5),
                            CustomTextContainer(
                              textKey: item.title,
                              style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 14.0),
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
