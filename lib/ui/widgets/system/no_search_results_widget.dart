import 'package:flutter/material.dart';

class NoSearchResultsWidget extends StatefulWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;
  final Color? primaryColor;
  final Color? accentColor;
  final String? title;
  final String? description;
  final String? clearButtonText;
  final IconData? icon;

  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
    this.primaryColor,
    this.accentColor,
    this.title,
    this.description,
    this.clearButtonText,
    this.icon,
  });

  @override
  State<NoSearchResultsWidget> createState() => _NoSearchResultsWidgetState();
}

class _NoSearchResultsWidgetState extends State<NoSearchResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  Color get _primaryColor =>
      widget.primaryColor ?? Theme.of(context).primaryColor;
  Color get _accentColor =>
      widget.accentColor ?? Theme.of(context).colorScheme.secondary;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Top padding

            // Animated search icon with modern styling
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_breathingAnimation.value * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(24), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _primaryColor.withValues(alpha: 0.1),
                          _accentColor.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      widget.icon ?? Icons.search_off_rounded,
                      size: 48, // Reduced size
                      color: _primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20), // Reduced spacing

            // Main message
            Text(
              widget.title ?? 'Tidak Ada Hasil',
              style: TextStyle(
                fontSize: 20, // Reduced font size
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 10), // Reduced spacing

            // Search query display
            if (widget.searchQuery.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6), // Reduced padding
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: 14, // Reduced size
                      color: _primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '"${widget.searchQuery}"',
                        style: TextStyle(
                          fontSize: 12, // Reduced font size
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12), // Reduced spacing
            ],

            // Description
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32), // Reduced padding
              child: Text(
                widget.description ??
                    'Tidak ditemukan hasil yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, // Reduced font size
                  color: Colors.grey[600],
                  height: 1.3, // Reduced line height
                ),
              ),
            ),
            const SizedBox(height: 18), // Reduced spacing

            // Clear search button
            ElevatedButton.icon(
              onPressed: widget.onClearSearch,
              icon: const Icon(Icons.clear_rounded, size: 16), // Reduced size
              label: Text(widget.clearButtonText ?? 'Hapus Pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10), // Reduced padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}
