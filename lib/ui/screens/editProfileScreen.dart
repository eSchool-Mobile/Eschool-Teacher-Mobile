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
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
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

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  @override
  void initState() {
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
    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(
        context: context, allowMultiple: false, type: FileType.image);
    if (result != null) {
      uploadedPicture = result.files.first.path;
      setState(() {});
    }
  }

  Widget _buildLabelWithTextEditingController(
      {required String labelTitle,
      required String textFieldHintTextKey,
      required TextEditingController textEditingController}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: labelTitle,
          style: TextStyle(
              fontSize: Utils.getScaledValue(context, 15.5),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.76)),
        ),
        SizedBox(height: screenWidth * 0.015),
        CustomTextFieldContainer(
          textEditingController: textEditingController,
          hintTextKey: textFieldHintTextKey,
        ),
      ],
    );
  }

  Widget _buildDateOfBirthContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: dateOfBirthKey,
          style: TextStyle(
              fontSize: Utils.getScaledValue(context, 15.5),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.76)),
        ),
        SizedBox(
          height: screenWidth * 0.015,
        ),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
                context: context,
                currentDate: _dateOfBirth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
            if (selectedDate != null) {
              _dateOfBirth = selectedDate;
              dateOfBirth.text = DateFormat("dd-MM-yyyy").format(_dateOfBirth);
              setState(() {});
            }
          },
          child: Container(
            height: screenWidth * 0.125,
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: Theme.of(context).colorScheme.tertiary)),
            alignment: AlignmentDirectional.centerStart,
            child: CustomTextContainer(
              textKey: dateOfBirth.text,
              style: TextStyle(fontSize: Utils.getScaledValue(context, 14.5)),
            ),
          ),
        ),
        SizedBox(
          height: screenWidth * 0.0375,
        ),
      ],
    );
  }

  Widget _buildRadioselection(String title, String apiValue) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.035),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.0125),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: appContentHorizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title.tr,
            style: TextStyle(
              fontSize: Utils.getScaledValue(context, 15),
            ),
          ),
          Radio(
            value: title,
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: genderKey,
          style: TextStyle(
            fontSize: Utils.getScaledValue(context, 15.5),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.76),
          ),
        ),
        SizedBox(height: screenWidth * 0.025),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 1, child: _buildRadioselection("male", "male")),
            SizedBox(width: screenWidth * 0.035),
            Expanded(flex: 1, child: _buildRadioselection("female", "female")),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateProfileButton(EditProfileState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
          ], color: Theme.of(context).colorScheme.surface),
          width: MediaQuery.of(context).size.width,
          height: screenWidth * 0.175,
          child: CustomRoundedButton(
            height: screenWidth * 0.1,
            widthPercentage: 1.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            buttonTitle: updateProfileKey,
            showBorder: false,
            child: state is EditProfileProgress
                ? const CustomCircularProgressIndicator()
                : null,
            onTap: () {
              if (state is EditProfileProgress) {
                return;
              }
              if (firstName.text.trim().isEmpty ||
                  lastName.text.trim().isEmpty ||
                  mobileNumber.text.trim().isEmpty ||
                  email.text.trim().isEmpty ||
                  dateOfBirth.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseAddNeededDetailsKey, context: context);
                return;
              }

              String apiDateFormat = "";
              try {
                final inputDate =
                    DateFormat("dd-MM-yyyy").parse(dateOfBirth.text.trim());
                apiDateFormat = DateFormat("yyyy-MM-dd").format(inputDate);
              } catch (e) {
                apiDateFormat = dateOfBirth.text.trim();
              }
              context.read<EditProfileCubit>().editProfile(
                  firstName: firstName.text.trim(),
                  lastName: lastName.text.trim(),
                  mobileNumber: mobileNumber.text.trim(),
                  email: email.text.trim(),
                  dateOfBirth: dateOfBirth.text.trim(),
                  currentAddress: currentAddress.text.trim(),
                  permanentAddress: permanentAddress.text.trim(),
                  gender: selectedGender,
                  image: uploadedPicture ?? "");
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
      if (state is EditProfileSuccess) {
        context.read<AuthCubit>().updateuserDetail(state.userDetails);
        Navigator.pop(context);
        Utils.showSnackBar(
            message: updateProfileSuccessfullyKey, context: context);
      } else if (state is EditProfileFailure) {
        Utils.showSnackBar(message: state.errorMessage, context: context);
      }
    }, builder: (context, state) {
      return PopScope(
        canPop: state is! EditProfileProgress,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: screenWidth * 0.25,
                    top: Utils.appContentTopScrollPadding(context: context) +
                        screenWidth * 0.0625),
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenWidth * 0.0375,
                      ),
                      SizedBox(
                        height: screenWidth * 0.3,
                        width: screenWidth * 0.3,
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                  image: profileImage.isEmpty
                                      ? null
                                      : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              profileImage)),
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              child: uploadedPicture != null
                                  ? Image.file(
                                      File(uploadedPicture!),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : profileImage.isEmpty
                                      ? const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 25,
                                          ),
                                        )
                                      : null,
                            ),
                            Align(
                              alignment: AlignmentDirectional.bottomEnd,
                              child: Container(
                                margin: const EdgeInsetsDirectional.only(
                                    bottom: 7.50, end: 7.50),
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2.50)),
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  onTap: () => _addFiles(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      _buildLabelWithTextEditingController(
                          labelTitle: firstNameKey,
                          textFieldHintTextKey: firstNameKey,
                          textEditingController: firstName),
                      _buildLabelWithTextEditingController(
                          labelTitle: lastNameKey,
                          textFieldHintTextKey: lastNameKey,
                          textEditingController: lastName),
                      _buildLabelWithTextEditingController(
                          labelTitle: mobileNumberKey,
                          textFieldHintTextKey: mobileNumberKey,
                          textEditingController: mobileNumber),
                      _buildLabelWithTextEditingController(
                          labelTitle: emailKey,
                          textFieldHintTextKey: emailKey,
                          textEditingController: email),
                      _buildDateOfBirthContainer(),
                      context.read<AuthCubit>().isTeacher()
                          ? _buildLabelWithTextEditingController(
                              labelTitle: currentAddressKey,
                              textFieldHintTextKey: currentAddressKey,
                              textEditingController: currentAddress)
                          : const SizedBox(),
                      context.read<AuthCubit>().isTeacher()
                          ? _buildLabelWithTextEditingController(
                              labelTitle: permanentAddressKey,
                              textFieldHintTextKey: permanentAddressKey,
                              textEditingController: permanentAddress)
                          : const SizedBox(),
                      _buildGenderSelector(),
                    ],
                  ),
                ),
              ),
            ),
            _buildUpdateProfileButton(state),
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(
                titleKey: editProfileKey,
                onBackButtonTap: () {
                  if (state is EditProfileProgress) {
                    return;
                  }
                  Get.back();
                },
              ),
            )
          ],
        ),
      );
    }));
  }
}
