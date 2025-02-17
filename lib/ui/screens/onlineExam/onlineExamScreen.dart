import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart'; // Note: 'b' is lowercase
import 'package:eschool_saas_staff/data/models/onlineExam.dart' as exam;
import 'package:eschool_saas_staff/data/models/subjectDetail.dart';
import '../../../app/routes.dart';
import 'package:get/get.dart';

class OnlineExamScreen extends StatefulWidget {
  @override
  State<OnlineExamScreen> createState() => _OnlineExamScreenState();
}

class _OnlineExamScreenState extends State<OnlineExamScreen> {
  Map<String, dynamic>? selectedSubject;
  int? selectedSessionYearId;

  SubjectDetail? selectedSubjectDetail;
  List<SubjectDetail> subjectDetails = [];

  @override
  void initState() {
    super.initState();
    _refreshExams();
  }

  void _refreshExams() {
    context.read<OnlineExamCubit>().getOnlineExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titleKey: 'Ujian Online',
        showBackButton: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSearchBar(context),
            BlocBuilder<OnlineExamCubit, OnlineExamState>(
              builder: (context, state) {
                if (state is OnlineExamLoading) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is OnlineExamSuccess) {
                  return _buildExamGrid(state);
                }
                if (state is OnlineExamFailure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(state.message),
                          ElevatedButton(
                            onPressed: _refreshExams,
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(
            Routes.createOnlineExam,
          ),
          label: Text('Buat Ujian'),
          icon: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari ujian...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    context.read<OnlineExamCubit>().getOnlineExams(
                          search: value,
                          subjectId: selectedSubjectDetail?.subject.id,
                          classSectionId:
                              selectedSubjectDetail?.classSection.id,
                        );
                  },
                ),
              ),
              SizedBox(height: 12),
              // Filter Section
              BlocBuilder<OnlineExamCubit, OnlineExamState>(
                builder: (context, state) {
                  if (state is OnlineExamSuccess) {
                    subjectDetails = (state.subjectDetails as List)
                        .map((detail) => SubjectDetail.fromJson(detail))
                        .toList();

                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField<SubjectDetail>(
                            value: selectedSubjectDetail,
                            decoration: InputDecoration(
                              labelText: 'Pilih Kelas & Mata Pelajaran',
                              border: OutlineInputBorder(),
                            ),
                            items: subjectDetails.map((SubjectDetail detail) {
                              return DropdownMenuItem<SubjectDetail>(
                                value: detail,
                                child: Text(
                                  '${detail.classSection.name} - ${detail.subject.name}',
                                ),
                              );
                            }).toList(),
                            onChanged: (SubjectDetail? value) {
                              setState(() {
                                selectedSubjectDetail = value;
                              });
                              if (value != null) {
                                print(
                                    'Selected class_subject_id: ${value.id}'); // ID dari SubjectDetail
                                print(
                                    'Selected class_section_id: ${value.classSection.id}');
                                print(
                                    'Selected subject_id: ${value.subject.id}');

                                // Gunakan value.id sebagai class_subject_id
                                context.read<OnlineExamCubit>().getOnlineExams(
                                      subjectId: value
                                          .id, // Menggunakan id dari SubjectDetail
                                      classSectionId: value.classSection.id,
                                    );
                              } else {
                                context
                                    .read<OnlineExamCubit>()
                                    .getOnlineExams();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamGrid(OnlineExamSuccess state) {
    if (state.exams.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Tidak ada ujian yang ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildExamCard(context, state.exams[index]),
          childCount: state.exams.length,
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, exam.OnlineExam exam) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed('/exam-detail/${exam.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.add_circle_outline),
                          title: Text('Soal ujian online'),
                        ),
                        value: 'add_question',
                        onTap: () {
                          // Delay navigasi untuk menghindari error popup menu
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => Get.toNamed(
                              '/exam-questions/${exam.id}',
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Hapus'),
                        ),
                        value: 'delete',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'add_question') {
                        Get.toNamed('/exam-questions/${exam.id}/add');
                      } else if (value == 'edit') {
                        // Handle edit
                      } else if (value == 'delete') {
                        // Handle delete
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                exam.subjectName,
                style: TextStyle(color: Colors.white70),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${exam.duration} min',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exam.examKey,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateExamDialog(BuildContext context) {
    // We'll implement this in the next step
  }
}
