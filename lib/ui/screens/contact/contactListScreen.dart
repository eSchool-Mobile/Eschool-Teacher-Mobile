import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/contact/contactListCubit.dart';
import 'package:eschool_saas_staff/cubits/contact/contactStatsCubit.dart';
import 'package:eschool_saas_staff/data/repositories/contactRepository.dart';
import 'package:eschool_saas_staff/models/contact.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:math' as math;

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  String? _selectedType;
  String? _selectedStatus;
  String? _selectedSort = 'created_at:desc';

  final Color _primaryColor = const Color(0xFF800020);
  final Color _lightColor = const Color(0xFFAA6976);

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactListCubit>().getContacts(refresh: true);
      context.read<ContactStatsCubit>().getContactStats();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ContactListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          CustomModernAppBar(
            title: 'Kontakt & Laporan',
            icon: Icons.contact_support_rounded,
            fabAnimationController: _fabAnimationController,
            primaryColor: _primaryColor,
            lightColor: _lightColor,
            showAddButton: true,
            onAddPressed: _showSubmitContactDialog,
            showFilterButton: true,
            onFilterPressed: _showFilterBottomSheet,
            filterActive: _selectedType != null || _selectedStatus != null,
            showSearchButton: true,
            onSearchPressed: _showSearchDialog,
          ),
          Expanded(
            child: Column(
              children: [
                // Stats Cards
                _buildStatsSection(),

                // Contact List
                Expanded(
                  child: _buildContactList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<ContactStatsCubit, ContactStatsState>(
      builder: (context, state) {
        if (state is ContactStatsSuccess) {
          return Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    state.stats.totalContacts.toString(),
                    Icons.contact_page_rounded,
                    _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Baru',
                    state.stats.newContacts.toString(),
                    Icons.new_releases_rounded,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Dibalas',
                    state.stats.repliedContacts.toString(),
                    Icons.reply_rounded,
                    Colors.green,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildContactList() {
    return BlocBuilder<ContactListCubit, ContactListState>(
      builder: (context, state) {
        if (state is ContactListLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ContactListSuccess) {
          if (state.contacts.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ContactListCubit>().refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.contacts.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.contacts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildContactItem(state.contacts[index], index);
              },
            ),
          );
        } else if (state is ContactListFailure) {
          return _buildErrorState(state.errorMessage);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContactItem(Contact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToContactDetail(contact),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: contact.isInquiry
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        contact.isInquiry
                            ? Icons.help_outline_rounded
                            : Icons.report_problem_outlined,
                        color: contact.isInquiry ? Colors.blue : Colors.red,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.subject,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contact.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(contact.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  contact.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Utils.formatDateAndTime(
                          DateTime.parse(contact.createdAt)),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      contact.typeDisplayName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: contact.isInquiry ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'new':
        color = Colors.orange;
        text = 'Baru';
        break;
      case 'replied':
        color = Colors.green;
        text = 'Dibalas';
        break;
      case 'closed':
        color = Colors.grey;
        text = 'Ditutup';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.contact_support_rounded,
              size: 64,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Kontak',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada inquiry atau laporan\nyang masuk ke sistem',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ContactListCubit>().refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Kontak',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Type Filter
                Text(
                  'Tipe',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('Semua', _selectedType == null, () {
                      setState(() => _selectedType = null);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pertanyaan', _selectedType == 'inquiry',
                        () {
                      setState(() => _selectedType = 'inquiry');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Laporan', _selectedType == 'report', () {
                      setState(() => _selectedType = 'report');
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                // Status Filter
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('Semua', _selectedStatus == null, () {
                      setState(() => _selectedStatus = null);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Baru', _selectedStatus == 'new', () {
                      setState(() => _selectedStatus = 'new');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dibalas', _selectedStatus == 'replied',
                        () {
                      setState(() => _selectedStatus = 'replied');
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = null;
                            _selectedStatus = null;
                          });
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Kontak'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Ketik kata kunci...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _showSubmitContactDialog() {
    // Navigate to submit contact screen
    Get.toNamed(Routes.submitContactScreen);
  }

  void _applyFilters() {
    context.read<ContactListCubit>().getContacts(
          type: _selectedType,
          status: _selectedStatus,
          search:
              _searchController.text.isNotEmpty ? _searchController.text : null,
          sort: _selectedSort,
          refresh: true,
        );
  }

  void _navigateToContactDetail(Contact contact) {
    Get.toNamed(
      Routes.contactDetailScreen,
      arguments: contact.id,
    );
  }
}
