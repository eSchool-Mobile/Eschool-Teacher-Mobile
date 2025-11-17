import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/extracurricular/extracurricularCubit.dart';
import 'package:eschool_saas_staff/data/models/user.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';

class CreateExtracurricular extends StatefulWidget {
  @override
  _CreateExtracurricularState createState() => _CreateExtracurricularState();
}

class _CreateExtracurricularState extends State<CreateExtracurricular>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? selectedCoachId;
  String? selectedCoachName;
  List<User> allUsers = [];
  List<User> filteredUsers = [];
  late AnimationController _animationController;
  late AnimationController _pulseController;

  final Color _primaryColor = Color(0xFF7A1E23);
  final Color _highlightColor = Color(0xFFB84D4D);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Fetch teachers/staff list
    context.read<ExtracurricularCubit>().getTeachersStaffList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomModernAppBar(
        title: 'Buat Ekstrakurikuler',
        icon: Icons.sports_soccer,
        fabAnimationController: _animationController,
        primaryColor: _primaryColor,
        lightColor: _highlightColor,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildBasicInfoSection(),
                SizedBox(height: 20),
                _buildCoachSection(),
                SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Dasar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: 20),
            _buildAnimatedTextField(
              controller: _nameController,
              label: 'Nama Ekstrakurikuler',
              icon: Icons.sports_soccer,
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _descriptionController,
              label: 'Deskripsi',
              icon: Icons.description,
              maxLines: 4,
              minLines: 3,
              validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachSection() {
    return FadeInUp(
      duration: Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelatih/Pembina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: 20),
            BlocConsumer<ExtracurricularCubit, ExtracurricularState>(
              listener: (context, state) {
                if (state is TeachersStaffSuccess) {
                  setState(() {
                    allUsers = state.users;
                    filteredUsers = state.users;
                  });
                }
              },
              builder: (context, state) {
                if (state is TeachersStaffLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: _primaryColor),
                    ),
                  );
                }

                if (state is TeachersStaffFailure) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Gagal memuat daftar guru/staff',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<ExtracurricularCubit>()
                                .getTeachersStaffList();
                          },
                          child: Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Selected coach display
                    if (selectedCoachId != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primaryColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _primaryColor,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 20),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pelatih Terpilih',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    selectedCoachName ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedCoachId = null;
                                  selectedCoachName = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                    // Dropdown button
                    InkWell(
                      onTap: () => _showCoachSelectionDialog(),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedCoachId == null
                                ? Colors.grey.shade300
                                : _primaryColor,
                            width: selectedCoachId == null ? 1 : 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_search,
                              color: selectedCoachId == null
                                  ? Colors.grey.shade600
                                  : _primaryColor,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedCoachId == null
                                    ? 'Pilih Pelatih/Pembina'
                                    : 'Ganti Pelatih/Pembina',
                                style: TextStyle(
                                  color: selectedCoachId == null
                                      ? Colors.grey.shade600
                                      : _primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: selectedCoachId == null
                                  ? Colors.grey.shade600
                                  : _primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (selectedCoachId == null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Pilih guru atau staff yang akan menjadi pelatih/pembina ekstrakurikuler ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCoachSelectionDialog() {
    _searchController.clear();
    setState(() {
      filteredUsers = allUsers;
    });

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.person_search, color: _primaryColor, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pilih Pelatih/Pembina',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value.isEmpty) {
                        filteredUsers = allUsers;
                      } else {
                        filteredUsers = allUsers.where((user) {
                          final name = user.fullName?.toLowerCase() ?? '';
                          final search = value.toLowerCase();
                          return name.contains(search);
                        }).toList();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari guru/staff...',
                    prefixIcon: Icon(Icons.search, color: _primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                _searchController.clear();
                                filteredUsers = allUsers;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                SizedBox(height: 15),

                // User count
                Text(
                  '${filteredUsers.length} guru/staff ditemukan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),

                // User list
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off,
                                  size: 64, color: Colors.grey.shade400),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada guru/staff ditemukan',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isSelected = selectedCoachId == user.id;

                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _primaryColor.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _primaryColor
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isSelected
                                      ? _primaryColor
                                      : Colors.grey.shade300,
                                  backgroundImage: user.image != null &&
                                          user.image!.isNotEmpty
                                      ? NetworkImage(user.image!)
                                      : null,
                                  child:
                                      user.image == null || user.image!.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                              size: 24,
                                            )
                                          : null,
                                ),
                                title: Text(
                                  user.fullName ?? 'No Name',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? _primaryColor
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  user.role ?? 'No Role',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle,
                                        color: _primaryColor)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedCoachId = user.id;
                                    selectedCoachName = user.fullName;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: Duration(milliseconds: 700),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _highlightColor],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _submitForm,
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: Text(
                'Simpan Ekstrakurikuler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedCoachId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID Pelatih tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _primaryColor),
                SizedBox(height: 15),
                Text('Menyimpan ekstrakurikuler...'),
              ],
            ),
          ),
        ),
      );

      try {
        await context.read<ExtracurricularCubit>().createExtracurricular(
              name: _nameController.text,
              description: _descriptionController.text,
              coachId: selectedCoachId!,
            );

        Navigator.pop(context); // Close loading dialog

        Get.dialog(
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ekstrakurikuler berhasil ditambahkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.back(result: true); // Return to list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan ekstrakurikuler: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
