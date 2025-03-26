import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/permissionDetails.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/dateWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' as ui;

class PermissionDetailsContainer extends StatefulWidget {
  final PermissionDetails permissionDetails;
  final bool? overflow;

  const PermissionDetailsContainer(
      {super.key, required this.permissionDetails, this.overflow});

  @override
  State<PermissionDetailsContainer> createState() =>
      _PermissionDetailsContainerState();
}

class _PermissionDetailsContainerState extends State<PermissionDetailsContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  // Palet warna yang lebih elegan
  final Color maroonDark = const Color(0xFF6D1923);
  final Color maroonMedium = const Color(0xFF9A2D37);
  final Color maroonLight = const Color(0xFFF7EBEC);
  final Color maroonAccent = const Color(0xFFD33F4F);
  final Color maroonDeep = const Color(0xFF4A111A);
  final Color textDark = const Color(0xFF2D2D2D);
  final Color textMedium = const Color(0xFF505050);
  final Color textLight = const Color(0xFF757575);
  final Color goldAccent = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    context.read<ClassesCubit>().getClasses();

    // Setup animasi
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getClassSectionName(int? classSectionId) {
    if (classSectionId == null) return '-';

    final classesCubit = context.read<ClassesCubit>();
    final allClasses = classesCubit.getAllClasses();

    final classSection = allClasses.firstWhere(
        (classSection) => classSection.id == classSectionId,
        orElse: () => ClassSection(name: '-'));

    return classSection.name ?? 'Kelas Tidak Diketahui';
  }

  String translateRole(String role) {
    final Map<String, String> roleTranslations = {
      "Teacher": "Guru",
    };

    return roleTranslations[role] ?? role;
  }

  Widget _buildLeaveTypeContainer(String type) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData iconData;
    String translatedType;

    switch (type) {
      case 'Sick':
        backgroundColor = const Color(0xFFF4E5EA);
        iconColor = const Color(0xFFBA445A);
        textColor = const Color(0xFF7D1E28);
        translatedType = 'Sakit';
        iconData = Icons.healing_rounded;
        break;
      case 'Leave':
        backgroundColor = const Color(0xFFEBEFFA);
        iconColor = const Color(0xFF4460BA);
        textColor = const Color(0xFF1E2D7D);
        translatedType = 'Izin';
        iconData = Icons.event_available_rounded;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.error.withOpacity(0.1);
        iconColor = Theme.of(context).colorScheme.error;
        textColor = Theme.of(context).colorScheme.error;
        translatedType = type;
        iconData = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            translatedType,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(
        begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  void _showAttachments(BuildContext context) {
    final files = widget.permissionDetails.leaves.last.file;
    if (files == null || files.isEmpty) {
      Utils.showSnackBar(
          message: 'Tidak ada lampiran yang tersedia', context: context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: maroonDark.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header yang lebih menarik
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: maroonLight,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: maroonLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(
                            Icons.description_rounded,
                            color: maroonDark,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lampiran Dokumen',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: maroonDark,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Dokumen Pendukung Izin',
                              style: TextStyle(
                                fontSize: 14,
                                color: textMedium,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: maroonLight.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: maroonDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Galeri lampiran
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: files.map((file) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.network(
                                  file.fileUrl ?? '',
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      maroonMedium),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                            if (loadingProgress
                                                    .expectedTotalBytes !=
                                                null)
                                              Text(
                                                "${(loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! * 100).toInt()}%",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: maroonDark,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: maroonLight.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image_rounded,
                                            size: 56,
                                            color:
                                                maroonMedium.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Gambar tidak dapat dimuat',
                                            style: TextStyle(
                                              color: textMedium,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Silakan coba lagi nanti',
                                            style: TextStyle(
                                              color: textLight,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Overlay untuk efek glassmorphism di sudut kanan bawah
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.photo_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Dokumen ${files.indexOf(file) + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(
                                delay: (100 + files.indexOf(file) * 100).ms)
                            .fadeIn(
                              duration: 400.ms,
                            )
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                            );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol unduh dan tutup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Fungsionalitas unduh
                        Utils.showSnackBar(
                          message: 'Fitur unduh akan segera tersedia',
                          context: context,
                        );
                      },
                      icon: Icon(
                        Icons.download_rounded,
                        size: 20,
                      ),
                      label: Text('Unduh Semua'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: maroonDark,
                        side: BorderSide(color: maroonMedium),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                      ),
                      label: Text('Tutup'),
                      style: TextButton.styleFrom(
                        backgroundColor: maroonDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.85, 0.85));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassesFetchSuccess) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: maroonDark.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      splashColor: maroonLight.withOpacity(0.3),
                      highlightColor: maroonLight.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan pola dekoratif dan avatar
                          Stack(
                            children: [
                              // Background pattern
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      maroonDeep,
                                      maroonDark,
                                    ],
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: PatternPainter(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                  size: Size.infinite,
                                ),
                              ),

                              // Header content
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar dengan efek dekoratif
                                    Hero(
                                      tag:
                                          'avatar-${widget.permissionDetails.user?.id ?? 0}',
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: goldAccent.withOpacity(0.7),
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: maroonLight,
                                          child: Text(
                                            (widget
                                                        .permissionDetails
                                                        .user
                                                        ?.fullName
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? widget.permissionDetails.user!
                                                    .fullName![0]
                                                    .toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              color: maroonDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.permissionDetails.user
                                                    ?.fullName ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.school_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    getClassSectionName(widget
                                                        .permissionDetails
                                                        .classSectionId),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Badge type izin
                                    _buildLeaveTypeContainer(
                                      widget.permissionDetails.leaves.last
                                              .leaveDetail?.last.type ??
                                          '',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Badge status persetujuan
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 0, left: 20, right: 20),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      const Color(0xFF2E7D32).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Disetujui',
                                    style: TextStyle(
                                      color: const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 300.ms)
                                .slideY(
                                  begin: -0.3,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ),

                          // Konten utama
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Informasi nomor absen dengan desain elegan
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        maroonLight,
                                        maroonLight.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: maroonDark.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: maroonAccent.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: maroonDark,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.format_list_numbered_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Nomor Absen: ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: textDark,
                                        ),
                                      ),
                                      Text(
                                        '${widget.permissionDetails.rollNumber}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: maroonDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 400.ms)
                                    .moveY(
                                        begin: 10,
                                        end: 0,
                                        delay: 300.ms,
                                        duration: 400.ms),

                                const SizedBox(height: 20),

                                // Bagian durasi izin dengan desain card premium
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: goldAccent.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            color: goldAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Periode Ketidakhadiran",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textDark,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          // Tanggal mulai
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Mulai",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: textMedium,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.event_rounded,
                                                        color: maroonDark,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        "20 Maret 2025",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Tanggal selesai
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Selesai",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: textMedium,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.event_rounded,
                                                        color: maroonDark,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        "22 Maret 2025",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Durasi
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: maroonDark.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.timelapse_rounded,
                                              color: maroonDark,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Total Durasi: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textMedium,
                                              ),
                                            ),
                                            Text(
                                              "3 hari",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: maroonDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 400.ms, duration: 400.ms)
                                    .moveY(
                                        begin: 10,
                                        end: 0,
                                        delay: 400.ms,
                                        duration: 400.ms),

                                const SizedBox(height: 20),

                                // Bagian keterangan dengan desain premium
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: maroonLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: maroonLight,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.description_rounded,
                                                  color: maroonDark,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "Keterangan",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: textDark,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isExpanded = !_isExpanded;
                                              });
                                            },
                                            icon: Icon(
                                              _isExpanded
                                                  ? Icons
                                                      .keyboard_arrow_up_rounded
                                                  : Icons
                                                      .keyboard_arrow_down_rounded,
                                              color: maroonMedium,
                                            ),
                                            splashRadius: 24,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Konten keterangan dengan animasi expand/collapse
                                      AnimatedCrossFade(
                                        firstChild: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            translateRole(widget
                                                    .permissionDetails
                                                    .leaves
                                                    .last
                                                    .reason ??
                                                ''),
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                              color: textMedium,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                        secondChild: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translateRole(widget
                                                        .permissionDetails
                                                        .leaves
                                                        .last
                                                        .reason ??
                                                    ''),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  height: 1.5,
                                                  color: textMedium,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: maroonLight
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: maroonLight,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.notes_rounded,
                                                      color: maroonDark,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Catatan Tambahan",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: maroonDark,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            "Siswa telah melampirkan surat keterangan dokter sebagai bukti.",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: textMedium,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        crossFadeState: _isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 500.ms, duration: 400.ms)
                                    .moveY(
                                        begin: 10,
                                        end: 0,
                                        delay: 500.ms,
                                        duration: 400.ms),

                                const SizedBox(height: 24),

                                // Tombol lampiran dengan desain premium
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Info terakhir diperbarui
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Terakhir diperbarui",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textLight,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "23 Maret 2025, 14:30",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Tombol lampiran
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: maroonDark.withOpacity(0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            maroonDark,
                                            maroonMedium,
                                          ],
                                        ),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _showAttachments(context),
                                        icon: const Icon(
                                          Icons.attachment_rounded,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          "Lihat Lampiran",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 400.ms)
                                    .moveX(
                                        begin: 20,
                                        end: 0,
                                        delay: 600.ms,
                                        duration: 400.ms),
                              ],
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
        } else if (state is ClassesFetchFailure) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: maroonLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: maroonMedium,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gagal Memuat Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak dapat mengambil informasi kelas. Silakan coba lagi nanti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: textMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      context.read<ClassesCubit>().getClasses();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: TextButton.styleFrom(
                      backgroundColor: maroonMedium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(maroonMedium),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Memuat data...",
                  style: TextStyle(
                    fontSize: 16,
                    color: textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

// Custom Painter untuk pola dekoratif
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double rowHeight = 10;
    final double columnWidth = 10;

    // Gambar pola diagonal
    for (double i = 0; i < size.width + size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(i, 0),
        paint,
      );
    }

    // Gambar titik-titik
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += columnWidth * 2) {
      for (double y = 0; y < size.height; y += rowHeight * 2) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
