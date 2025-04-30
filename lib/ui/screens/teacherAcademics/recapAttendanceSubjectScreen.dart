import 'package:eschool_saas_staff/ui/widgets/recapAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class RecapAttendanceSubjectScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ClassesCubit()..getClasses(),
      child: const RecapAttendanceSubjectScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const RecapAttendanceSubjectScreen({super.key});

  @override
  State<RecapAttendanceSubjectScreen> createState() =>
      _RecapAttendanceSubjectScreenState();
}

class _RecapAttendanceSubjectScreenState
    extends State<RecapAttendanceSubjectScreen> {
  // Replace _selectedDateTime with _selectedYear
  int _selectedYear = DateTime.now().year;
  ClassSection? _selectedClassSection;
  List<ClassSection> _filteredClassSections = [];
  int? teacherId;
  int? schoolId;
  String? email;
  // String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies called");
    _loadClassTeacherData();
  }

  void _loadClassTeacherData() {
    final userDetails = context.read<AuthCubit>().getUserDetails();
    // final authToken = AuthRepository.getAuthToken();

    setState(() {
      teacherId = userDetails.id;
      schoolId = userDetails.schoolId;
      email = userDetails.email ?? "";
      // token = authToken;
      print("Loaded teacher Id: $teacherId");
      print("Loaded school Id: $schoolId");
      print("Loaded school Id: $email");
      // print("Loaded token : $token");
    });
    context.read<ClassesCubit>().getClasses();
  }

  void getRecap({int? type}) {
    if (_selectedClassSection == null) {
      print("Invalid class section ID");
      return;
    }
    // Implement the logic to fetch recap data based on the selected class section and date
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Tahun'),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 1),
              selectedDate: DateTime(_selectedYear),
              onChanged: (DateTime dateTime) {
                setState(() {
                  _selectedYear = dateTime.year;
                });
                Navigator.pop(context);
                getRecap();
              },
            ),
          ),
        );
      },
    );
  }

  // Update download method to handle year
  void downloadRecap(int classId, int classSectionId, int month) async {
    if (schoolId == null || email == null) {
      print('Ada parameter yang kosong');
      return; // Add return to prevent further execution
    }

    final encodedEmail = Uri.encodeComponent(email!);

    // Debug logs
    print('Downloading recap for:');
    print('Year: $_selectedYear');
    print('Month: $month');
    print('Class ID: $classId');
    print('Class Section ID: $classSectionId');

    // final url = Uri.parse('https://eschool.ac.id/recap-download'
    final url = Uri.parse('https://eschool.ac.id/recap-download'
        '?school_id=$schoolId'
        '&class_id=$classId'
        '&class_section_id=$classSectionId'
        '&month=$month'
        '&year=$_selectedYear' // This ensures we use the selected year
        '&email=$encodedEmail'
        '&gm=naowndoianwodinaiwondaoiwnd');

    try {
      if (await canLaunchUrl(url)) {
        print('Launching URL: $url'); // Debug log
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void filterClassSections(List<ClassSection> classSections, int teacherId) {
    print("Filtering class sections for teacherId: $teacherId");

    _filteredClassSections = classSections.where((classSection) {
      print(
          "Checking class section: ${classSection.name} (ID: ${classSection.id})");

      if (classSection.classTeachers == null ||
          classSection.classTeachers!.isEmpty) {
        print("No class teachers found for ${classSection.name}");
        return false;
      }

      // Debug: Print all teachers in this section
      print("Class teachers for ${classSection.name}:");
      for (var teacher in classSection.classTeachers!) {
        print("- Teacher ID: ${teacher.teacherId}");
        print("- Teacher Detail ID: ${teacher.teacher?.id}");
        print("- Class Section ID: ${teacher.classSectionId}");
        print("- Current Section ID: ${classSection.id}");
      }

      // Loop through setiap class_teacher
      for (var classTeacher in classSection.classTeachers!) {
        // Step 1: Cek teacher.id
        if (classTeacher.teacher?.id == teacherId) {
          print("Found matching teacher.id for class ${classSection.name}");

          // Step 2: Cek teacher_id
          if (classTeacher.teacherId == teacherId) {
            print("Verified teacher_id match");

            // Step 3: Cek class_section_id dengan id class section
            if (classTeacher.classSectionId == classSection.id) {
              print("Verified as class teacher for ${classSection.name}:");
              print("- teacher.id: ${classTeacher.teacher?.id}");
              print("- teacher_id: ${classTeacher.teacherId}");
              print(
                  "- class_section_id: ${classTeacher.classSectionId} matches section.id: ${classSection.id}");
              return true;
            }
          }
        }
      }
      return false;
    }).toList();

    print(
        "Final filtered classes for teacher $teacherId: ${_filteredClassSections.map((e) => e.name).toList()}");
  }

  // Di RecapAttendanceSubjectScreen, update _buildRecapTable untuk mengirim schoolId
  Widget _buildRecapTable(List<ClassSection> classes) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: Utils.appContentTopScrollPadding(context: context) + 100,
        bottom: 25,
      ),
      child: RecapAttendanceContainer(
        classSections: classes,
        selectedYear: _selectedYear,
        email: email, // Tambahkan email
        schoolId: schoolId, // Tambahkan schoolId
        onDownload: (classSection, month) {
          final classId = classSection.classDetails?.id ?? 0;
          final classSectionId = classSection.id ?? 0;
          downloadRecap(classId, classSectionId, month);
        },
      ),
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassesFetchSuccess) {
            print("ClassesFetchSuccess state received");
            if (teacherId != null) {
              print("Teacher ID: $teacherId");
              print(
                  "Primary Classes: ${state.primaryClasses.map((e) => e.name).toList()}");

              filterClassSections(state.primaryClasses, teacherId!);

              if (_selectedClassSection == null &&
                  _filteredClassSections.isNotEmpty) {
                _selectedClassSection = _filteredClassSections.first;
                setState(() {});
                getRecap();
              }
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: recapAttendanceSubjectKey),
              AppbarFilterBackgroundContainer(
                height: Utils().getResponsiveHeight(context, 85),
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: FilterButton(
                          onTap: _showYearPicker,
                          titleKey: 'Tahun $_selectedYear',
                          width: boxConstraints.maxWidth * (0.98),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                return _buildRecapTable(_filteredClassSections);
              }
              if (state is ClassesFetchFailure) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer,
                    ),
                    child: Text('Failed to fetch classes data'),
                  ),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPaddingOfErrorAndLoadingContainer,
                  ),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
