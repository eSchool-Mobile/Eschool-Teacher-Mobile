import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/editProfileCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: const EditProfileScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController currentAddress = TextEditingController();
  TextEditingController permanentAddress = TextEditingController();
  late DateTime _dateOfBirth = DateTime.now();
  String selectedGender = '';
  String profileImage = '';
  String? uploadedPicture;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Soft maroon color scheme
  final Color primaryMaroon = const Color(0xFF8B1F41);
  final Color lightMaroon = const Color(0xFFBF6680);
  final Color accentMaroon = const Color(0xFF5D1429);
  final Color backgroundMaroon = const Color(0xFFFDF6F8);

  @override
  void initState() {
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );

    // Start animation
    _animationController.forward();

    firstName = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().firstName ?? "");
    lastName = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().lastName ?? "");
    mobileNumber = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().mobile ?? "");
    email = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().email ?? "");

    final initialDate = context.read<AuthCubit>().getUserDetails().dob;
    if (initialDate != null && initialDate.isNotEmpty) {
      try {
        // Parse the initial date assuming it's in yyyy-MM-dd format
        final parsedDate = DateTime.parse(initialDate);
        dateOfBirth = TextEditingController(
            text: DateFormat("dd-MM-yyyy").format(parsedDate));
        _dateOfBirth = parsedDate;
      } catch (e) {
        dateOfBirth = TextEditingController(text: initialDate);
      }
    } else {
      dateOfBirth = TextEditingController();
    }

    currentAddress = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().currentAddress ?? "");
    permanentAddress = TextEditingController(
        text:
            context.read<AuthCubit>().getUserDetails().permanentAddress ?? "");
    selectedGender = context.read<AuthCubit>().getUserDetails().gender ?? "";
    profileImage = context.read<AuthCubit>().getUserDetails().image ?? "";
    super.initState();
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    mobileNumber.dispose();
    email.dispose();
    dateOfBirth.dispose();
    currentAddress.dispose();
    permanentAddress.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addFiles() async {
    HapticFeedback.mediumImpact();
   await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pilih Sumber Gambar',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryMaroon,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryMaroon),
                title: Text(
                  'Galeri',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await Utils.openFilePicker(
                      context: context,
                      allowMultiple: false,
                      type: FileType.image);
                  if (result != null) {
                    uploadedPicture = result.files.first.path;
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryMaroon),
                title: Text(
                  'Kamera',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    uploadedPicture = image.path;
                    setState(() {});
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: primaryMaroon,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelWithTextEditingController(
      {required String labelTitle,
      required String textFieldHintTextKey,
      required TextEditingController textEditingController,
      IconData? prefixIcon}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  prefixIcon ?? Icons.person_outline,
                  size: 18,
                  color: primaryMaroon,
                ),
                SizedBox(width: 8),
                Text(
                  labelTitle.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: accentMaroon,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ],
            ),
            child: TextFormField(
              controller: textEditingController,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: textFieldHintTextKey.tr,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black26,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryMaroon, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  size: 18,
                  color: primaryMaroon,
                ),
                SizedBox(width: 8),
                Text(
                  dateOfBirthKey.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: accentMaroon,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final selectedDate = await showDatePicker(
                context: context,
                currentDate: _dateOfBirth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryMaroon,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: primaryMaroon,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (selectedDate != null) {
                _dateOfBirth = selectedDate;
                dateOfBirth.text =
                    DateFormat("dd-MM-yyyy").format(_dateOfBirth);
                setState(() {});
              }
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateOfBirth.text.isEmpty
                          ? dateOfBirthKey.tr
                          : dateOfBirth.text,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: dateOfBirth.text.isEmpty
                            ? Colors.black26
                            : Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: primaryMaroon,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: primaryMaroon,
                ),
                SizedBox(width: 8),
                Text(
                  genderKey.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: accentMaroon,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption("male", Icons.male),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderOption("female", Icons.female),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? primaryMaroon.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryMaroon : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryMaroon.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryMaroon : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender.tr,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryMaroon : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateProfileButton(EditProfileState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryMaroon, accentMaroon],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (state is EditProfileProgress) {
                return;
              }

              HapticFeedback.mediumImpact();

              if (firstName.text.trim().isEmpty ||
                  mobileNumber.text.trim().isEmpty ||
                  email.text.trim().isEmpty ||
                  dateOfBirth.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseAddNeededDetailsKey, context: context);
                return;
              }

              String formattedDate = "";
              try {
                final inputDate =
                    DateFormat("dd-MM-yyyy").parse(dateOfBirth.text.trim());
                formattedDate = DateFormat("yyyy-MM-dd").format(inputDate);
              } catch (e) {
                formattedDate = dateOfBirth.text.trim();
              }
              context.read<EditProfileCubit>().editProfile(
                  firstName: firstName.text.trim(),
                  lastName: lastName.text.trim(),
                  mobileNumber: mobileNumber.text.trim(),
                  email: email.text.trim(),
                  dateOfBirth: formattedDate,
                  currentAddress: currentAddress.text.trim(),
                  permanentAddress: permanentAddress.text.trim(),
                  gender: selectedGender,
                  image: uploadedPicture ?? "");
            },
            child: Center(
              child: state is EditProfileProgress
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          updateProfileKey.tr,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundMaroon,
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
        if (state is EditProfileSuccess) {
          context.read<AuthCubit>().updateuserDetail(state.userDetails);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Profil berhasil diperbarui!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.green.shade400,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          );
        } else if (state is EditProfileFailure) {
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      }, builder: (context, state) {
        return PopScope(
          canPop: state is! EditProfileProgress,
          child: Stack(
            children: [
              // Custom app bar with elegant design
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryMaroon, primaryMaroon.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Title and back button at the very top
                      Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                            left: 8.0,
                            right: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () {
                                if (state is EditProfileProgress) {
                                  return;
                                }
                                Get.back();
                              },
                            ),
                            Text(
                              editProfileKey.tr,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Empty space for the profile image that will overlap
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
              // Loading indicator
              if (state is EditProfileProgress)
                const Center(
                  child: CustomCircularProgressIndicator(),
                ),
              // Background gradient
              Positioned.fill(
                top: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backgroundMaroon,
                        backgroundMaroon.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Top shadow

              // Bottom shadow

              // Main content
              Positioned.fill(
                top: 150,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF6F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                            top: 80, bottom: 40, left: 24, right: 24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Text(
                                "Informasi Pribadi",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: accentMaroon,
                                ),
                              ),
                            ),
                            _buildLabelWithTextEditingController(
                              labelTitle: firstNameKey,
                              textFieldHintTextKey: firstNameKey,
                              textEditingController: firstName,
                              prefixIcon: Icons.person_outline,
                            ),
                            _buildLabelWithTextEditingController(
                              labelTitle: lastNameKey,
                              textFieldHintTextKey: lastNameKey,
                              textEditingController: lastName,
                              prefixIcon: Icons.person_outline,
                            ),
                            _buildLabelWithTextEditingController(
                              labelTitle: emailKey,
                              textFieldHintTextKey: emailKey,
                              textEditingController: email,
                              prefixIcon: Icons.email_outlined,
                            ),
                            _buildLabelWithTextEditingController(
                              labelTitle: mobileNumberKey,
                              textFieldHintTextKey: mobileNumberKey,
                              textEditingController: mobileNumber,
                              prefixIcon: Icons.phone_outlined,
                            ),
                            _buildDateOfBirthContainer(),
                            _buildGenderSelector(),
                            if (context.read<AuthCubit>().isTeacher()) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  "Address Information",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: accentMaroon,
                                  ),
                                ),
                              ),
                              _buildLabelWithTextEditingController(
                                labelTitle: currentAddressKey,
                                textFieldHintTextKey: currentAddressKey,
                                textEditingController: currentAddress,
                                prefixIcon: Icons.home_outlined,
                              ),
                              _buildLabelWithTextEditingController(
                                labelTitle: permanentAddressKey,
                                textFieldHintTextKey: permanentAddressKey,
                                textEditingController: permanentAddress,
                                prefixIcon: Icons.location_on_outlined,
                              ),
                            ],
                            const SizedBox(height: 24),
                            _buildUpdateProfileButton(state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Profile image with hero animation
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Hero(
                    tag: "profileImage",
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: uploadedPicture != null
                                  ? Image.file(
                                      File(uploadedPicture!),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : profileImage.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: profileImage,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: lightMaroon.withOpacity(0.3),
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: lightMaroon.withOpacity(0.3),
                                            child: const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: lightMaroon.withOpacity(0.3),
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                        ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _addFiles,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [primaryMaroon, accentMaroon],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryMaroon.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
            ],
          ),
        );
      }),
    );
  }
}
