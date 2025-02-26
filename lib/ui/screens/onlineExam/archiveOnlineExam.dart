import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';

class ArchiveOnlineExam extends StatefulWidget {
  @override
  State<ArchiveOnlineExam> createState() => _ArchiveOnlineExamState();
}

class _ArchiveOnlineExamState extends State<ArchiveOnlineExam> {
  @override
  void initState() {
    super.initState();
    // Load archived exams explicitly
    context.read<OnlineExamCubit>().getArchivedExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arsip Ujian'),
        backgroundColor: Color(0xFF8B0000),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B0000).withOpacity(0.9),
              Color(0xFF6B0000),
              Color(0xFF4B0000),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: [0.2, 0.4, 0.6, 1.0],
          ),
        ),
        child: BlocBuilder<OnlineExamCubit, OnlineExamState>(
          builder: (context, state) {
            if (state is OnlineExamLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is OnlineExamSuccess) {
              // Only show archived exams
              if (state.archivedExams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive_outlined,
                          size: 80, color: Colors.white70),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada ujian yang diarsipkan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.archivedExams.length,
                itemBuilder: (context, index) {
                  final exam = state.archivedExams[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        exam.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 16),
                              SizedBox(width: 4),
                              Text('${exam.duration} Menit'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.subject, size: 16),
                              SizedBox(width: 4),
                              Text(exam.subjectName),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.restore),
                              title: Text('Pulihkan'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            value: 'restore',
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading:
                                  Icon(Icons.delete_forever, color: Colors.red),
                              title: Text('Hapus Permanen',
                                  style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                            value: 'delete',
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'restore') {
                            // TODO: Implement restore functionality
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, exam);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text(
                'Terjadi kesalahan',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, OnlineExam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Permanen'),
        content: Text('Anda yakin ingin menghapus ujian ini secara permanen? '
            'Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<OnlineExamCubit>().deleteOnlineExam(
                      examId: exam.id,
                      mode: 'permanent',
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ujian berhasil dihapus permanen')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus ujian'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
