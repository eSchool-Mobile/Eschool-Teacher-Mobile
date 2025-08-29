import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customFilterModernAppbar.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentProfileScreen extends StatefulWidget {
  final StudentDetails studentDetails;
  final SessionYear sessionYear;
  final ClassSection classSection;
  const StudentProfileScreen({
    super.key,
    required this.studentDetails,
    required this.sessionYear,
    required this.classSection,
  });

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return StudentProfileScreen(
      classSection: arguments['classSection'],
      sessionYear: arguments['sessionYear'],
      studentDetails: arguments['studentDetails'],
    );
  }

  static Map<String, dynamic> buildArguments({
    required StudentDetails studentDetails,
    required SessionYear sessionYear,
    required ClassSection classSection,
  }) {
    return {
      "classSection": classSection,
      "studentDetails": studentDetails,
      "sessionYear": sessionYear
    };
  }

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late String _selectedTabTitleKey = generalKey;
  final ScrollController _scrollController = ScrollController();

  // Define theme colors with simplified palette
  final Color maroonPrimary = Color(0xFF8B1F41);
  final Color maroonLight = Color(0xFFAC3B5C);
  final Color maroonDark = Color(0xFF6A0F2A);
  final Color accentColor = Color(0xFFF5EBE0);
  final Color bgColor = Color(0xFFFAF6F2);
  final Color cardColor = Colors.white;
  final Color textDarkColor = Color(0xFF2D2D2D);
  final Color textMediumColor = Color(0xFF717171);
  final Color borderColor = Color(0xFFE8E8E8);
  final Color highlightColor = Color(0xFFFFD166);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void changeTab(String value) {
    if (_selectedTabTitleKey == value) return;

    setState(() {
      _selectedTabTitleKey = value;
    });
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            isActive ? activeKey.tr : inactiveKey.tr,
            style: TextStyle(
              color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetailsTitleAndValueContainer({
    required String titleKey,
    required String valueKey,
    bool isHighlighted = false,
    IconData? icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: isHighlighted ? maroonPrimary.withOpacity(0.08) : cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isHighlighted ? 0.08 : 0.05),
            blurRadius: isHighlighted ? 12 : 8,
            offset: Offset(0, isHighlighted ? 4 : 3),
            spreadRadius: 0,
          ),
        ],
        border: isHighlighted
            ? Border.all(color: maroonPrimary.withOpacity(0.2))
            : Border.all(color: borderColor.withOpacity(0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? maroonPrimary.withOpacity(0.15)
                    : accentColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isHighlighted ? maroonPrimary : maroonLight,
              ),
            ),
            SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleKey.tr,
                  style: TextStyle(
                    color: textMediumColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  valueKey.tr,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted ? maroonPrimary : textDarkColor,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianDetails() {
    final guardian = widget.studentDetails.student?.guardian;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          child: Column(
            children: [
              Row(
                children: [
                  _buildProfileImage(
                    imageUrl: guardian?.image ?? "",
                    nameInitials: guardian?.firstName?.isNotEmpty == true
                        ? guardian!.firstName!.substring(0, 1).toUpperCase()
                        : "G",
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guardian?.firstName ?? "-",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 6),
                        _buildBadge(guardianKey.tr),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email row: tappable to open mail app
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  color: maroonPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(color: maroonPrimary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: maroonPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        FontAwesomeIcons.envelope,
                        size: 18,
                        color: maroonPrimary,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            emailKey.tr,
                            style: TextStyle(
                              color: textMediumColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          InkWell(
                            onTap: (guardian?.email ?? "").isNotEmpty &&
                                    (guardian?.email ?? "-") != "-"
                                ? () {
                                    final email = guardian!.email!;
                                    Utils.openLinkInBrowser(
                                        url: 'mailto:$email', context: context);
                                  }
                                : null,
                            child: Text(
                              guardian?.email ?? "-",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: guardian?.email != null &&
                                        guardian!.email!.isNotEmpty &&
                                        guardian.email! != "-"
                                    ? maroonPrimary
                                    : textDarkColor,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.2,
                                decoration: guardian?.email != null &&
                                        guardian!.email!.isNotEmpty &&
                                        guardian.email! != "-"
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // no phone icon next to email
                  ],
                ),
              ),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: genderKey,
                valueKey: guardian?.getGender() ?? "-",
                icon: (guardian?.getGender() ?? "").toLowerCase() == "female"
                    ? FontAwesomeIcons.venus
                    : FontAwesomeIcons.mars,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FontAwesomeIcons.phoneVolume,
                      size: 20,
                      color: maroonPrimary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kontak Wali",
                          style: TextStyle(
                            fontSize: 13,
                            color: textMediumColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          guardian?.mobile ?? "-",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCallButton(guardian?.mobile ?? "-"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentGeneralDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          child: Column(
            children: [
              Row(
                children: [
                  _buildProfileImage(
                    imageUrl: widget.studentDetails.image ?? "",
                    nameInitials:
                        widget.studentDetails.firstName?.isNotEmpty == true
                            ? widget.studentDetails.firstName!
                                .substring(0, 1)
                                .toUpperCase()
                            : "S",
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentDetails.firstName ?? "-",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStatusBadge(widget.studentDetails.isActive()),
                          ],
                        ),
                        SizedBox(height: 6),
                        // Admission / registration number with copy-to-clipboard
                        Builder(builder: (context) {
                          final admissionNo =
                              widget.studentDetails.student?.admissionNo ?? '-';
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "No. Pendaftaran: $admissionNo",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textMediumColor,
                                    fontFamily: 'Poppins',
                                  ),
                                  // Ensure full text is visible/wraps
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                              if (admissionNo != '-')
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: admissionNo));
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'No. Pendaftaran disalin ke clipboard'),
                                        backgroundColor: maroonPrimary,
                                        duration: Duration(seconds: 2),
                                      ));
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: maroonPrimary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.copy,
                                        size: 18,
                                        color: maroonPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FontAwesomeIcons.phoneVolume,
                      size: 20,
                      color: maroonPrimary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emergencyContactKey.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: textMediumColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          widget.studentDetails.mobile ?? "-",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCallButton(widget.studentDetails.mobile ?? "-"),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Informasi Siswa"),
              Divider(color: borderColor, thickness: 1),
              SizedBox(height: 12),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: sessionYearKey,
                valueKey: widget.sessionYear.name ?? "-",
                isHighlighted: true,
                icon: FontAwesomeIcons.calendarDays,
              ),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: admissionDateKey,
                valueKey:
                    (widget.studentDetails.student?.admissionDate ?? "").isEmpty
                        ? "-"
                        : Utils.formatDate(DateTime.parse(
                            widget.studentDetails.student!.admissionDate!)),
                icon: FontAwesomeIcons.calendar,
              ),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: classSectionKey,
                valueKey: widget.classSection.name ?? "-",
                isHighlighted: true,
                icon: FontAwesomeIcons.graduationCap,
              ),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: rollNoKey,
                valueKey:
                    widget.studentDetails.student?.rollNumber?.toString() ??
                        "-",
                icon: FontAwesomeIcons.idCard,
              ),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: genderKey,
                valueKey: widget.studentDetails.getGender(),
                icon:
                    widget.studentDetails.getGender().toLowerCase() == "female"
                        ? FontAwesomeIcons.venus
                        : FontAwesomeIcons.mars,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            maroonPrimary,
            maroonLight,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildProfileImage(
      {required String imageUrl, required String nameInitials}) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [maroonPrimary, maroonLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: imageUrl.isEmpty
              ? Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [maroonLight, maroonPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      nameInitials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : ProfileImageContainer.circular(
                  imageUrl: imageUrl,
                  size: 70,
                ),
        ),
      ),
    );
  }

  Widget _buildCallButton(String phoneNumber) {
    if (phoneNumber.isEmpty || phoneNumber == "-") {
      return SizedBox(width: 0);
    }

    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () => Utils.launchCallLog(mobile: phoneNumber),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [maroonLight, maroonPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: maroonPrimary.withOpacity(0.25),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.call,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Tab button removed - now using AppBar filter items instead

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomFilterModernAppBar(
        title: studentProfileKey.tr,
        primaryColor: maroonPrimary,
        secondaryColor: maroonLight,
        titleIcon: Icons.person,
        onBackPressed: () => Navigator.of(context).pop(),
        showFiltersRow: true,
        height:
            200, // Increased height of the AppBar to create more spacing between title and filters
        firstFilterItem: FilterItemConfig(
          title: _selectedTabTitleKey == generalKey
              ? "${generalKey.tr} ✓"
              : generalKey.tr,
          icon: _selectedTabTitleKey == generalKey
              ? Icons.person_rounded
              : Icons.person_outline_rounded,
          onTap: () => changeTab(generalKey),
        ),
        secondFilterItem: FilterItemConfig(
          title: _selectedTabTitleKey == guardianKey
              ? "${guardianKey.tr} ✓"
              : guardianKey.tr,
          icon: _selectedTabTitleKey == guardianKey
              ? Icons.family_restroom
              : Icons.family_restroom_outlined,
          onTap: () => changeTab(guardianKey),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 32,
            top: 20, // Increased top padding for better spacing from the AppBar
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content based on selected tab
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _selectedTabTitleKey == generalKey
                      ? _buildStudentGeneralDetails()
                      : _buildGuardianDetails(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: maroonPrimary,
        fontFamily: 'Poppins',
      ),
    );
  }
}
