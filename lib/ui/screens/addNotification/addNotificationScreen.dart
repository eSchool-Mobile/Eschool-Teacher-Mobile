import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/sendNotificationCubit.dart';
import 'package:eschool_saas_staff/cubits/rolesCubit.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/manageNotificationScreen.dart';
import 'package:eschool_saas_staff/ui/screens/searchUsersScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/multiSelectionValueBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:math';
// Import pustaka animasi dan komponen visual
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:confetti/confetti.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RolesCubit(),
        ),
        BlocProvider(
          create: (context) => SendNotificationCubit(),
        ),
      ],
      child: const AddNotificationScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen>
    with TickerProviderStateMixin {
  String _sendToUserValue = "";

  final TextEditingController _titleTextEditingController =
      TextEditingController();

  final TextEditingController _messageTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomModernAppBar(
        title: 'Tambah Notifikasi',
        icon: Icons.notifications_active,
        fabAnimationController: _animationController,
        primaryColor: _primaryColor,
        lightColor: _accentColor,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildBasicInfoSection(),
                  SizedBox(height: 20),
                  _buildRecipientDetailsSection(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildAnimatedSubmitButton(),
        ],
      ),
    );
  }

  List<String> _selectedRoles = [];

  List<UserDetails> _selectedUsers = [];

  PlatformFile? _pickedFile;

  // Tambahkan controller animasi - sesuai dengan createOnlineExam
  late AnimationController _animationController;
  late AnimationController _pulseController;

  // Tema warna - Palette maroon yang lebih lembut - sesuai dengan createOnlineExam
  final Color _primaryColor =
      Color(0xFF7A1E23); // Maroon dalam yang lebih lembut
  final Color _accentColor =
      Color(0xFF9D3C3C); // Maroon medium yang lebih lembut

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<RolesCubit>().getRoles();
      }
    });

    // Inisialisasi controller animasi - sesuai dengan createOnlineExam
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _titleTextEditingController.dispose();
    _messageTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await Utils.openFilePicker(
        context: context, allowMultiple: false, type: FileType.image);
    if (result != null) {
      _pickedFile = result.files.first;
      setState(() {});
    }
  }

  void onTapSubmitButton() {
    if (_titleTextEditingController.text.trim().isEmpty) {
      Utils.showSnackBar(message: pleaseEnterTitleKey, context: context);
      return;
    }
    if (_messageTextEditingController.text.trim().isEmpty) {
      Utils.showSnackBar(message: pleaseEnterMessageKey, context: context);
      return;
    }
    if (_sendToUserValue.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectSendToKey, context: context);
      return;
    }

    if (_sendToUserValue == specificRolesKey && _selectedRoles.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectSendToKey, context: context);
      return;
    }

    if (_sendToUserValue == specificUsersKey && _selectedUsers.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectUserKey, context: context);
      return;
    }

    context.read<SendNotificationCubit>().sendNotification(
        title: _titleTextEditingController.text.trim(),
        userIds: _selectedUsers.map((e) => e.id ?? 0).toList(),
        filePath: _pickedFile?.path,
        message: _messageTextEditingController.text.trim(),
        roles: _selectedRoles,
        sendToType: _sendToUserValue);
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<RolesCubit, RolesState>(
      builder: (context, state) {
        if (state is RolesFetchSuccess) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                ], color: Theme.of(context).colorScheme.surface),
                width: MediaQuery.of(context).size.width,
                height: 70,
                child:
                    BlocConsumer<SendNotificationCubit, SendNotificationState>(
                  listener: (context, sendNotificationState) {
                    if (sendNotificationState is SendNotificationFailure) {
                      Utils.showSnackBar(
                          message: sendNotificationState.errorMessage,
                          context: context);
                    } else if (sendNotificationState
                        is SendNotificationSuccess) {
                      ManageNotificationScreen.screenKey.currentState
                          ?.getNotifications();
                      // Show auto-dismissing success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Notifikasi berhasil dikirim!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: Colors.green.shade400,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      );
                      _titleTextEditingController.clear();
                      _messageTextEditingController.clear();
                      _sendToUserValue = "";
                      _selectedRoles.clear();
                      _selectedUsers.clear();
                      _pickedFile = null;
                      setState(() {});
                    }
                  },
                  builder: (context, sendNotificationState) {
                    return PopScope(
                      canPop:
                          sendNotificationState is! SendNotificationInProgress,
                      child: CustomRoundedButton(
                        height: 40,
                        widthPercentage: 1.0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        buttonTitle: submitKey,
                        showBorder: false,
                        child:
                            sendNotificationState is SendNotificationInProgress
                                ? const CustomCircularProgressIndicator()
                                : null,
                        onTap: () {
                          if (sendNotificationState
                              is SendNotificationInProgress) {
                            return;
                          }
                          onTapSubmitButton();
                        },
                      ),
                    );
                  },
                ),
              ));
        }
        return const SizedBox();
      },
    );
  }

  // Metode untuk membuat TextField beranimasi yang identical dengan createOnlineExam.dart
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Color? iconColor,
    Color? labelColor,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor ?? Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  // Menambahkan section untuk Informasi Dasar - identik dengan createOnlineExam
  Widget _buildBasicInfoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
            controller: _titleTextEditingController,
            label: 'Judul Notifikasi',
            icon: Icons.title,
          ),
          SizedBox(height: 15),
          _buildAnimatedTextField(
            controller: _messageTextEditingController,
            label: 'Pesan Notifikasi',
            icon: Icons.message,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // Menambahkan section untuk Detail Penerima - identik dengan format createOnlineExam
  Widget _buildRecipientDetailsSection() {
    return BlocBuilder<RolesCubit, RolesState>(
      builder: (context, state) {
        if (state is RolesFetchSuccess) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Penerima',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 15),
                // Dropdown untuk memilih tipe penerima
                _buildSendToDropdown(),
                SizedBox(height: 20),

                // Render UI berdasarkan pilihan tipe penerima
                _sendToUserValue == specificRolesKey
                    ? _buildRoleSelectionUI(state)
                    : _sendToUserValue == specificUsersKey
                        ? _buildUserSelectionUI()
                        : SizedBox(),

                SizedBox(height: 20),
                // Upload file section
                _buildFileUploadSection(),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildSendToDropdown() {
    return GestureDetector(
      onTap: () {
        Utils.showBottomSheet(
          child: FilterSelectionBottomsheet<String>(
            onSelection: (value) {
              if (_sendToUserValue != value) {
                _sendToUserValue = value!;
                _selectedRoles.clear();
                setState(() {});
                Get.back();
              }
            },
            selectedValue: _sendToUserValue,
            titleKey: "Penerima",
            values: const [
              allUsersKey,
              overDueFeesKey,
              specificRolesKey,
              specificUsersKey
            ],
          ),
          context: context,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people,
              color: Color(0xFF8B0000),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                _sendToUserValue.isEmpty ? "Pilih Penerima" : _sendToUserValue,
                style: TextStyle(
                  fontSize: 14,
                  color: _sendToUserValue.isEmpty
                      ? Colors.grey[600]
                      : Colors.grey[800],
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionUI(RolesFetchSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            List<String> roles = [
              teacherRoleKey,
              studentRoleKey,
              guardianRoleKey
            ];
            roles.addAll(state.roles.map((role) => role.name ?? "-").toList());
            Utils.showBottomSheet(
              child: MultiSelectionValueBottomsheet<String>(
                values: roles,
                selectedValues: _selectedRoles,
                titleKey: roleKey,
              ),
              context: context,
            ).then((value) {
              if (value != null) {
                final updatedSelectedRoles = List<String>.from(value as List);
                _selectedRoles = updatedSelectedRoles;
                setState(() {});
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_ind,
                  color: Color(0xFF8B0000),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectRolesKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        _selectedRoles.isNotEmpty
            ? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedRoles.map((role) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            role,
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryColor,
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              _selectedRoles.remove(role);
                              setState(() {});
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildUserSelectionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(
              Routes.searchUsersScreen,
              arguments: SearchUsersScreen.buildArguments(
                selectedUsers: _selectedUsers,
              ),
            )?.then((value) {
              if (value != null) {
                _selectedUsers = value as List<UserDetails>;
                setState(() {});
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Color(0xFF8B0000),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectUsersKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        _selectedUsers.isNotEmpty
            ? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedUsers.map((user) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.fullName ?? "-",
                            style: TextStyle(
                              fontSize: 12,
                              color: _accentColor,
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              _selectedUsers.removeWhere(
                                (element) => element.id == user.id,
                              );
                              setState(() {});
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lampiran",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  color: _primaryColor,
                ),
                SizedBox(width: 10),
                Text(
                  "Upload Gambar",
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        _pickedFile != null
            ? Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: _accentColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pickedFile?.name ?? "-",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _pickedFile = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildAnimatedSubmitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 6,
          )
        ],
      ),
      child: FadeInUp(
        duration: Duration(milliseconds: 600),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: BlocConsumer<SendNotificationCubit, SendNotificationState>(
              listener: (context, sendNotificationState) {
                if (sendNotificationState is SendNotificationFailure) {
                  Utils.showSnackBar(
                    message: sendNotificationState.errorMessage,
                    context: context,
                  );
                } else if (sendNotificationState is SendNotificationSuccess) {
                  ManageNotificationScreen.screenKey.currentState
                      ?.getNotifications();
                  // Show success dialog
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 60,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Berhasil!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Notifikasi berhasil dikirim',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Get.back(); // Close dialog
                                Get.offAllNamed(Routes
                                    .manageNotificationScreen); // Navigate to notification list
                              },
                              child: Text(
                                'Lihat Daftar Notifikasi',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  _titleTextEditingController.clear();
                  _messageTextEditingController.clear();
                  _sendToUserValue = "";
                  _selectedRoles.clear();
                  _selectedUsers.clear();
                  _pickedFile = null;
                  setState(() {});
                }
              },
              builder: (context, sendNotificationState) {
                return PopScope(
                  canPop: sendNotificationState is! SendNotificationInProgress,
                  child: InkWell(
                    onTap: () {
                      if (sendNotificationState is SendNotificationInProgress) {
                        return;
                      }
                      onTapSubmitButton();
                    },
                    borderRadius: BorderRadius.circular(15),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child:
                            sendNotificationState is SendNotificationInProgress
                                ? const CustomCircularProgressIndicator(
                                    indicatorColor: Colors.white,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Kirim Notifikasi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ).animate(onPlay: (controller) {
                                        controller.repeat(reverse: true);
                                      }).slideX(
                                        begin: 0,
                                        end: 0.3,
                                        duration: Duration(milliseconds: 1000),
                                        curve: Curves.easeInOut,
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
