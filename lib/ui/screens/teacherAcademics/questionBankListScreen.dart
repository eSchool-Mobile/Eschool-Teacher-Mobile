import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';
import '../../../data/models/questionBank.dart';
import '../../../data/models/subjectQuestion.dart';
import 'package:eschool_saas_staff/data/repositories/questionBankRepository.dart';

class QuestionBankListScreen extends StatefulWidget {
  final SubjectQuestion subject;

  static Widget getRouteInstance(SubjectQuestion subject) {
    return BlocProvider(
      create: (context) => QuestionBankCubit(
        repository: QuestionBankRepository(),
      )..fetchBankSoal(subject.subject.id),
      child: QuestionBankListScreen(subject: subject),
    );
  }

  const QuestionBankListScreen({super.key, required this.subject});
  @override
  State<QuestionBankListScreen> createState() => _QuestionBankListScreenState();
}

class _QuestionBankListScreenState extends State<QuestionBankListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController(text: 'multiple_choice');
  final _defaultPointController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<QuestionBankCubit>()
          .fetchBankSoal(widget.subject.subject.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _defaultPointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        'Bank Soal ${widget.subject.subjectWithName}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<QuestionBankCubit, QuestionBankState>(
                    builder: (context, state) {
                      if (state is QuestionBankLoading) {
                        return _buildLoadingView();
                      }

                      if (state is BankSoalFetchSuccess) {
                        if (state.bankSoal.isEmpty) {
                          return _buildEmptyView();
                        }
                        return _buildBankList(state);
                      }

                      if (state is QuestionBankError) {
                        return _buildErrorView(state.message);
                      }

                      return SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FadeInUp(
        duration: Duration(milliseconds: 600),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE53935), // Light red
                Color(0xFFC62828), // Darker red
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFC62828).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: MaterialButton(
            onPressed: () => _showAddBankDialog(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Tambah Bank Soal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.source_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada bank soal',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankList(BankSoalFetchSuccess state) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: state.bankSoal.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final bank = state.bankSoal[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  Routes.bankQuestionScreen,
                  arguments: {
                    'bankSoal': bank,
                    'subjectId': widget.subject.subject.id,
                    'subject': widget.subject,
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Jumlah Soal: ${bank.soalCount}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () =>
                                    _showEditBankDialog(state, index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () =>
                                    _showDeleteConfirmation(context, bank),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddBankDialog() {
    final questionBankCubit = context.read<QuestionBankCubit>();
    BuildContext dialogContext;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOutCubic,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_box_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Tambah Bank Soal',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Bank Soal',
                      prefixIcon: Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nama bank soal tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await questionBankCubit.createQuestionBank(
                          subjectId: widget.subject.subject.id,
                          name: _nameController.text.trim(),
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                        _nameController.clear();

                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Bank soal berhasil dibuat'),
                          backgroundColor: Colors.green,
                        ));
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Gagal membuat bank soal: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBankDialog(BankSoalFetchSuccess state, int index) {
    final bank = state.bankSoal[index];
    final _editController = TextEditingController(text: bank.name);
    final _editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Bank Soal'),
        content: Form(
          key: _editFormKey,
          child: TextFormField(
            controller: _editController,
            decoration: InputDecoration(
              labelText: 'Nama Bank Soal',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Nama bank soal tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editFormKey.currentState?.validate() ?? false) {
                try {
                  await context.read<QuestionBankCubit>().updateQuestionBank(
                        subjectId: widget.subject.subject.id,
                        banksoalId: bank.id,
                        name: _editController.text.trim(),
                      );

                  Navigator.pop(dialogContext);

                  // Refresh bank soal list
                  context.read<QuestionBankCubit>().fetchBankSoal(
                        widget.subject.subject.id,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bank soal berhasil diperbarui')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext dialogContext, BankSoal bank) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final cubit = context.read<QuestionBankCubit>();

    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red),
              ),
              SizedBox(width: 16),
              Text(
                'Hapus Bank Soal',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus bank soal "${bank.name}"? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[700]!],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: MaterialButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context);
                    await cubit.deleteBankSoal(
                      subjectId: widget.subject.subject.id,
                      banksoalId: bank.id!,
                    );

                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Bank soal berhasil dihapus')),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content:
                            Text('Gagal menghapus bank soal: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'Hapus',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        );
      },
    );
  }
}
