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

class PermissionDetailsContainer extends StatefulWidget {
  final PermissionDetails permissionDetails;
  final bool? overflow;

  const PermissionDetailsContainer(
      {super.key, required this.permissionDetails, this.overflow});

  @override
  State<PermissionDetailsContainer> createState() =>
      _PermissionDetailsContainerState();
}

class _PermissionDetailsContainerState
    extends State<PermissionDetailsContainer> {
  @override
  void initState() {
    super.initState();
    context.read<ClassesCubit>().getClasses();
  }

  String getClassSectionName(int? classSectionId) {
    if (classSectionId == null) return '-';

    final classesCubit = context.read<ClassesCubit>();
    final allClasses = classesCubit.getAllClasses();
    print("Looking for class section ID: $classSectionId");
    print(
        "Available classes: ${allClasses.map((e) => "${e.name} (${e.id})").toList()}");

    // Cari di semua kelas
    final classSection = allClasses.firstWhere(
        (classSection) => classSection.id == classSectionId, orElse: () {
      print("Class section not found for ID: $classSectionId");
      return ClassSection(name: '-');
    });

    print("Found class section: ${classSection.name}");
    return classSection.name ?? 'Unknown Class';
  }

  String translateRole(String role) {
    final Map<String, String> roleTranslations = {
      "Teacher": "Guru",
    };

    return roleTranslations[role] ?? role;
  }

  Widget _buildLeaveTypeContainer(String type) {
    Color backgroundColor;
    Color textColor;
    String translatedType;

    switch (type) {
      case 'Sick':
        backgroundColor = Theme.of(context)
            .extension<CustomColors>()!
            .sickBackgroundColor!
            .withOpacity(0.1);
        textColor =
            Theme.of(context).extension<CustomColors>()!.sickBackgroundColor!;
        translatedType = 'Sakit';
        break;
      case 'Leave':
        backgroundColor = Theme.of(context)
            .extension<CustomColors>()!
            .permissionBackgroundColor!
            .withOpacity(0.1);
        textColor = Theme.of(context)
            .extension<CustomColors>()!
            .permissionBackgroundColor!;
        translatedType = 'Izin';
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.error.withOpacity(0.1);
        textColor = Theme.of(context).colorScheme.error;
        translatedType = type;
    }

    return DateWithFadedBackgroundContainer(
      backgroundColor: backgroundColor,
      textColor: textColor,
      titleKey: translatedType,
    );
  }

  void _showAttachments(BuildContext context) {
    final files = widget.permissionDetails.leaves.last.file;
    if (files == null || files.isEmpty) {
      Utils.showSnackBar(message: noAttachmentKey, context: context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: files.map((file) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(file.fileUrl ?? ''),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassesFetchSuccess) {
          return IntrinsicHeight(
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: appContentHorizontalPadding,
              ),
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildLeaveTypeContainer(
                        widget.permissionDetails.leaves.last.leaveDetail?.last
                                .type ??
                            '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Menggunakan Column sebagai container utama
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextContainer(
                        textKey: widget.permissionDetails.user?.fullName ?? "",
                        style: TextStyle(
                          fontSize: Utils.getScaledValue(context, 18.5),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextContainer(
                            textKey:
                                'Kelas : ${getClassSectionName(widget.permissionDetails.classSectionId)}',
                            style: TextStyle(
                              fontSize: Utils.getScaledValue(context, 17.0),
                            ),
                            maxLines: 2,
                          ),
                          CircleAvatar(
                            radius: screenWidth * 0.05,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            child: IconButton(
                              onPressed: () => _showAttachments(context),
                              icon: Icon(
                                Icons.attach_file_rounded,
                                size: screenWidth * 0.05,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomTextContainer(
                            textKey: 'Absen : ',
                            style: TextStyle(
                              fontSize: 17.0 / textScaleFactor,
                            ),
                          ),
                          CustomTextContainer(
                            textKey: '${widget.permissionDetails.rollNumber}',
                            style: TextStyle(
                                fontSize: Utils.getScaledValue(context, 17.0),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // SizedBox(height: 10),
                      Divider(thickness: 1),
                      // Container untuk alasan dengan wrapping text
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: CustomTextContainer(
                                textKey: "Keterangan : ",
                                style: TextStyle(
                                  fontSize: Utils.getScaledValue(context, 17.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: CustomTextContainer(
                                textKey: translateRole(widget
                                        .permissionDetails.leaves.last.reason ??
                                    ''),
                                style: TextStyle(
                                  fontSize: Utils.getScaledValue(context, 17.5),
                                ),
                                maxLines: null, // Allow unlimited lines
                                overflow: TextOverflow
                                    .visible, // Text will wrap to next line
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (state is ClassesFetchFailure) {
          return Center(
            child: Text('Failed to load classes'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
