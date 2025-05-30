import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/route_manager.dart';

class TeacherProfileScreen extends StatefulWidget {
  final UserDetails teacher;
  const TeacherProfileScreen({super.key, required this.teacher});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return TeacherProfileScreen(
      teacher: arguments['teacher'] as UserDetails,
    );
  }

  static Map<String, dynamic> buildArguments(
      {required UserDetails userDetails}) {
    return {"teacher": userDetails};
  }

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Color primaryMaroonColor = const Color(0xFF800020);
  final Color lightMaroonColor = const Color(0xFFAA6976);

  // Kamus terjemahan Bahasa Indonesia
  final Map<String, String> _translations = {
    joiningDateKey: "Tanggal Bergabung",
    emailKey: "Email",
    phoneKey: "Nomor Telepon",
    dateOfBirthKey: "Tanggal Lahir",
    genderKey: "Jenis Kelamin",
    qualificationKey: "Kualifikasi",
    salaryKey: "Gaji",
    teacherDetailsKey: "Detail Pengajar",
    activeKey: "Aktif",
    inactiveKey: "Tidak Aktif",
    teacherProfileKey: "Profil Pengajar"
  };

  // Map untuk ikon yang sesuai dengan setiap jenis data
  final Map<String, IconData> _detailIcons = {
    joiningDateKey: Icons.calendar_month_rounded,
    emailKey: Icons.email_rounded,
    phoneKey: Icons.phone_android_rounded,
    dateOfBirthKey: Icons.cake_rounded,
    genderKey: Icons.person_rounded,
    qualificationKey: Icons.school_rounded,
    salaryKey: Icons.payments_rounded,
  };

  // Fungsi untuk menerjemahkan label ke Bahasa Indonesia
  String _getIndonesianTitle(String titleKey) {
    // Menghapus "Key" dari akhir string jika ada
    String key = titleKey;
    if (titleKey.endsWith('Key')) {
      key = titleKey.substring(0, titleKey.length - 3);
    }

    return _translations[key] ?? titleKey;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///[To show modern contact buttons]
  Widget _buildContactButton({
    required BuildContext context,
    required IconData iconData,
    required String label,
    required Color backgroundColor,
    required Function onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => onTap.call(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primaryMaroonColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTeacherDetailCard(
      {required String titleKey, required String valueKey, IconData? icon}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryMaroonColor.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(-3, -3),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F4F6),
          ],
        ),
        border: Border.all(
          color: primaryMaroonColor.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryMaroonColor.withOpacity(0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  if (icon != null)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryMaroonColor.withOpacity(0.8),
                            primaryMaroonColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryMaroonColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(right: 14),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getIndonesianTitle(titleKey),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: primaryMaroonColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          valueKey,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryMaroonColor,
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
    )
        .animate(delay: 100.ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F7),
      body: Stack(
        children: [
          // Main content
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context) + 40,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Teacher Profile Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroonColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Decorative header
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                primaryMaroonColor.withOpacity(0.7),
                                primaryMaroonColor.withOpacity(0.9),
                                primaryMaroonColor,
                                primaryMaroonColor.withOpacity(0.9),
                                primaryMaroonColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        // Content padding
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Hero(
                                    tag: 'teacher_image_${widget.teacher.id}',
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryMaroonColor
                                              .withOpacity(0.2),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryMaroonColor
                                                .withOpacity(0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: ProfileImageContainer(
                                          imageUrl: widget.teacher.image ?? "",
                                        ),
                                      ),
                                    ),
                                  ).animate().scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1, 1),
                                        duration: 500.ms,
                                      ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              LinearGradient(
                                            colors: [
                                              primaryMaroonColor,
                                              Color(0xFFAA3855),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(bounds),
                                          child: Text(
                                            widget.teacher.fullName ?? "",
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: widget.teacher.isActive()
                                                    ? Colors.green
                                                        .withOpacity(0.1)
                                                    : Colors.red
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    widget.teacher.isActive()
                                                        ? Icons.check_circle
                                                        : Icons.cancel,
                                                    color: widget.teacher
                                                            .isActive()
                                                        ? Colors.green
                                                        : Colors.red,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    widget.teacher.isActive()
                                                        ? _getIndonesianTitle(
                                                            activeKey)
                                                        : _getIndonesianTitle(
                                                            inactiveKey),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: widget.teacher
                                                              .isActive()
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.school,
                                              size: 16,
                                              color: primaryMaroonColor
                                                  .withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                widget.teacher.staff
                                                        ?.qualification ??
                                                    "-",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: 0.1, end: 0),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contact Buttons
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroonColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Decorative header
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                lightMaroonColor.withOpacity(0.7),
                                lightMaroonColor.withOpacity(0.9),
                                lightMaroonColor,
                                lightMaroonColor.withOpacity(0.9),
                                lightMaroonColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(
                            "Kontak Pengajar",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: lightMaroonColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              _buildContactButton(
                                context: context,
                                iconData: Icons.email_outlined,
                                label: _getIndonesianTitle(emailKey),
                                backgroundColor: primaryMaroonColor,
                                onTap: () {
                                  Utils.launchEmailLog(
                                      email: widget.teacher.email ?? "");
                                },
                              ),
                              _buildContactButton(
                                context: context,
                                iconData: Icons.call,
                                label: _getIndonesianTitle(phoneKey),
                                backgroundColor: lightMaroonColor,
                                onTap: () {
                                  Utils.launchCallLog(
                                      mobile: widget.teacher.mobile ?? "");
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Teacher Details Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroonColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primaryMaroonColor.withOpacity(0.9),
                                      primaryMaroonColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          primaryMaroonColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person_pin,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ).animate().scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.0, 1.0),
                                    duration: 400.ms,
                                  ),
                              const SizedBox(width: 12),
                              Text(
                                _getIndonesianTitle(teacherDetailsKey),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: primaryMaroonColor,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideX(begin: 0.2, end: 0),
                            ],
                          ),
                        ),
                        Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                primaryMaroonColor.withOpacity(0.05),
                                primaryMaroonColor.withOpacity(0.3),
                                primaryMaroonColor.withOpacity(0.5),
                                primaryMaroonColor.withOpacity(0.3),
                                primaryMaroonColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .slideX(begin: -0.1, end: 0),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildTeacherDetailCard(
                                titleKey: joiningDateKey,
                                valueKey: Utils.formatDate(
                                    DateTime.parse(widget.teacher.createdAt!)),
                                icon: _detailIcons[joiningDateKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: emailKey,
                                valueKey: widget.teacher.email ?? "-",
                                icon: _detailIcons[emailKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: phoneKey,
                                valueKey: widget.teacher.mobile ?? "-",
                                icon: _detailIcons[phoneKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: dateOfBirthKey,
                                valueKey: (widget.teacher.dob ?? "").isEmpty
                                    ? "-"
                                    : Utils.formatDate(
                                        DateTime.parse(widget.teacher.dob!)),
                                icon: _detailIcons[dateOfBirthKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: genderKey,
                                valueKey: widget.teacher.getGender(),
                                icon: _detailIcons[genderKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: qualificationKey,
                                valueKey:
                                    widget.teacher.staff?.qualification ?? "-",
                                icon: _detailIcons[qualificationKey],
                              ),
                              _buildTeacherDetailCard(
                                titleKey: salaryKey,
                                valueKey: widget.teacher.staff?.salary
                                        ?.toStringAsFixed(2) ??
                                    "-",
                                icon: _detailIcons[salaryKey],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Custom Modern AppBar
          Align(
            alignment: Alignment.topCenter,
            child: CustomModernAppBar(
              title: _getIndonesianTitle(teacherProfileKey),
              icon: Icons.person,
              fabAnimationController: _animationController,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
