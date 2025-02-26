import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:html/parser.dart' show parse;

class PreviewQuestionBankSoal extends StatefulWidget {
  final BankSoalQuestion bank;

  const PreviewQuestionBankSoal({
    Key? key,
    required this.bank,
  }) : super(key: key);

  @override
  State<PreviewQuestionBankSoal> createState() =>
      _PreviewQuestionBankSoalState();
}

class _PreviewQuestionBankSoalState extends State<PreviewQuestionBankSoal>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredQuestions = [];
  bool _showSearch = false;
  Set<int> _selectedQuestions = {};
  late AnimationController _selectionController;
  bool _hasShownTooltip = false;

  @override
  void initState() {
    super.initState();
    _filteredQuestions = widget.bank.soal;
    _selectionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? htmlString;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return Colors.blue;
      case 'essay':
        return Colors.green;
      case 'true_false':
        return Colors.orange;
      case 'short_answer':
        return Colors.purple;
      case 'numeric':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'essay':
        return Icons.edit_note;
      case 'true_false':
        return Icons.check_circle;
      case 'short_answer':
        return Icons.short_text;
      case 'numeric':
        return Icons.numbers;
      default:
        return Icons.help;
    }
  }

  String _getTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'Pilihan Ganda';
      case 'essay':
        return 'Essay';
      case 'true_false':
        return 'Benar/Salah';
      case 'short_answer':
        return 'Jawaban Singkat';
      case 'numeric':
        return 'Numerik';
      default:
        return 'Lainnya';
    }
  }

  void _filterQuestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuestions = widget.bank.soal;
      } else {
        _filteredQuestions = widget.bank.soal
            .where((question) =>
                question.question.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleQuestionSelection(int index) {
    setState(() {
      if (_selectedQuestions.contains(index)) {
        _selectedQuestions.remove(index);
      } else {
        _selectedQuestions.add(index);
      }
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bank.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bank Soal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: _buildHeader(),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedQuestions.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SlideInLeft(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      margin: EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Soal Terpilih',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jumlah soal yang dipilih:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${_selectedQuestions.length} Soal',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('Tutup'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_selectedQuestions.length}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Terpilih',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SlideInRight(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            if (_selectedQuestions.isEmpty) {
                              Get.snackbar(
                                'Peringatan',
                                'Pilih minimal 1 soal untuk disimpan',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                margin: EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            List<dynamic> selectedQuestions = _selectedQuestions
                                .map((index) => _filteredQuestions[index])
                                .toList();

                            Get.back(result: selectedQuestions);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
            )
          : null,
    );
  }

  Widget _buildContent() {
    _showSearch = widget.bank.soal.length > 5;

    return Column(
      children: [
        if (!_hasShownTooltip)
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ketuk kartu soal untuk memilih',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _hasShownTooltip = true;
                    });
                  },
                ),
              ],
            ),
          ),
        if (_showSearch)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterQuestions,
              decoration: InputDecoration(
                hintText: 'Cari soal...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredQuestions.length,
            itemBuilder: (context, index) {
              final question = _filteredQuestions[index];
              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: _buildQuestionCard(question, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(dynamic question, int index) {
    bool isSelected = _selectedQuestions.contains(index);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: isSelected ? 0.0 : 1.0,
        end: isSelected ? 1.0 : 0.0,
      ),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 - (value * 0.02),
          child: InkWell(
            onTap: () => _toggleQuestionSelection(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: isSelected ? 15 : 10,
                    spreadRadius: isSelected ? 2 : 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getTypeColor(question.type).withOpacity(0.8),
                                _getTypeColor(question.type).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getTypeIcon(question.type),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getTypeName(question.type),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber[100],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${question.marks} poin',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
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
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parseHtmlString(question.question)
                                      .split('\n')
                                      .first,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    height: 1.3,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[100]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            parseHtmlString(question.question),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              height: 1.5,
                                              letterSpacing: 0.1,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Divider(
                                              height: 16,
                                              thickness: 1,
                                              color: Colors.grey[200],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle_outline,
                                                    size: 16,
                                                    color: Colors.green[400]),
                                                SizedBox(width: 6),
                                                Text(
                                                  '${question.options.length} Opsi',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[100]!),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Point: ${question.marks}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _toggleQuestionSelection(index),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        highlightColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.05),
                        child: Container(),
                      ),
                    ),
                  ),
                  if (!isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
