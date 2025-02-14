import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final bool showClose;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.showClose = true,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FadeInDown(
        duration: Duration(milliseconds: 500),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: _isExpanded
              ? MediaQuery.of(context).size.width - 40
              : MediaQuery.of(context).size.width - 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_isExpanded ? 15 : 25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                blurRadius: 15,
                offset: Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(_isExpanded ? 15 : 25),
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: _isExpanded || widget.controller.text.isNotEmpty
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        onChanged: (value) {
                          widget.onChanged(value);
                          setState(() {});
                        },
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    if (widget.showClose && widget.controller.text.isNotEmpty)
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              widget.controller.clear();
                              widget.onChanged('');
                              setState(() {
                                _isExpanded = false;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
