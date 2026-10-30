import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/cattle.dart';
import '../data/mock_data.dart';
import 'add_medical_record_modal.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  String _selectedTab = 'Semua'; // 'Semua', 'Resep Mantri', 'Mandiri'
  String _selectedEartagFilter = 'Semua Eartag';
  String _searchQuery = '';
  String _sortOrder = 'Terbaru (April 2026)';

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: db,
          builder: (context, _) {
            // Filter medical records
            final records = db.medicalRecords.where((m) {
              if (_selectedTab == 'Resep Mantri' &&
                  m.jenisPenanganan != MedicalHandlingType.resepMantri) {
                return false;
              }
              if (_selectedTab == 'Mandiri' &&
                  m.jenisPenanganan != MedicalHandlingType.mandiri) {
                return false;
              }
              if (_selectedEartagFilter != 'Semua Eartag' &&
                  m.eartagId != _selectedEartagFilter) {
                return false;
              }
              if (_searchQuery.trim().isNotEmpty) {
                final q = _searchQuery.toLowerCase().trim();
                final matchDiagnosis = m.diagnosis.toLowerCase().contains(q);
                final matchTindakan = m.tindakan.toLowerCase().contains(q);
                final matchObat = m.obat.toLowerCase().contains(q);
                final matchPetugas = m.petugas.toLowerCase().contains(q);
                final matchTag = m.eartagId.toLowerCase().contains(q);
                final matchNote = (m.catatanKhusus ?? '').toLowerCase().contains(q);
                if (!matchDiagnosis &&
                    !matchTindakan &&
                    !matchObat &&
                    !matchPetugas &&
                    !matchTag &&
                    !matchNote) {
                  return false;
                }
              }
              return true;
            }).toList();

            // Sort
            if (_sortOrder == 'Terbaru (April 2026)') {
              records.sort((a, b) => b.tanggal.compareTo(a.tanggal));
            } else {
              records.sort((a, b) => a.tanggal.compareTo(b.tanggal));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 768;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Header
                    _buildTopHeader(context, isWide),

                    // Scrollable content area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 4 Top Summary Cards
                            _buildSummaryCards(isWide),

                            const SizedBox(height: 16),

                            // Filter Tabs + Sort
                            _buildFilterTabsAndSort(isWide),

                            const SizedBox(height: 12),

                            // Search bar + Filter Sapi Dropdown
                            _buildSearchAndDropdownBar(db, isWide),

                            const SizedBox(height: 16),

                            // List Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.assignment_outlined, size: 16, color: Color(0xFFBAC7D5)),
                                    SizedBox(width: 6),
                                    Text(
                                      'DAFTAR CATATAN KLINIS TERKINI',
                                      style: TextStyle(
                                        color: Color(0xFFBAC7D5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Menampilkan ${records.length} entri aktif',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Medical Record Cards List
                            if (records.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: const Center(
                                  child: Text(
                                    'Belum ada catatan rekam medis yang sesuai filter.',
                                    style: TextStyle(color: AppColors.textMuted),
                                  ),
                                ),
                              )
                            else
                              ...records.map((r) => _buildClinicalRecordCard(r, dateFormatter, isWide)),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Header matching Image 1
  Widget _buildTopHeader(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF090E17),
        border: Border(
          bottom: BorderSide(color: Color(0xFF162232), width: 1),
        ),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderBrand(),
                _buildHeaderActions(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBrand(),
                const SizedBox(height: 12),
                _buildHeaderActions(context),
              ],
            ),
    );
  }

  Widget _buildHeaderBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Green icon container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
          ),
          child: const Center(
            child: Icon(
              Icons.assignment_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Rekam Medis Digital',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Sinkron Aktif',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Manajemen Riwayat Kesehatan, Resep Mantri, & Pengobatan Ternak',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bell icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0E1624),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1F2E42)),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFFBAC7D5),
                  size: 20,
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // + Catat Penanganan Baru button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _showAddMedicalRecordSheet(context),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.black),
          label: const Text(
            'Catat Penanganan Baru',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // 4 Top Summary Cards (TOTAL TINDAKAN, RESEP MANTRI, RAWAT MANDIRI, JADWAL KONTROL)
  Widget _buildSummaryCards(bool isWide) {
    final card1 = _buildSingleSummaryCard(
      title: 'TOTAL TINDAKAN',
      val: '48',
      unit: 'Sapi',
      icon: Icons.description_outlined,
      iconColor: const Color(0xFFBAC7D5),
      iconBg: const Color(0xFF172436),
    );

    final card2 = _buildSingleSummaryCard(
      title: 'RESEP MANTRI',
      val: '18',
      unit: 'Tindakan',
      icon: Icons.person_outline_rounded,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFF1E3A8A).withOpacity(0.35),
    );

    final card3 = _buildSingleSummaryCard(
      title: 'RAWAT MANDIRI',
      val: '30',
      unit: 'Kasus',
      icon: Icons.healing_rounded,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFF064E3B).withOpacity(0.35),
    );

    final card4 = _buildSingleSummaryCard(
      title: 'JADWAL KONTROL',
      val: '2',
      unit: 'Ekor Sapi',
      icon: Icons.calendar_month_outlined,
      iconColor: const Color(0xFFF59E0B),
      iconBg: const Color(0xFF78350F).withOpacity(0.35),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
          Expanded(child: card2),
          const SizedBox(width: 12),
          Expanded(child: card3),
          const SizedBox(width: 12),
          Expanded(child: card4),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 10),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 10),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSingleSummaryCard({
    required String title,
    required String val,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C131E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A283A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7A8B9E),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    val,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Color(0xFF7A8B9E),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  // Filter Tabs + Urutan
  Widget _buildFilterTabsAndSort(bool isWide) {
    final tabs = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabPill(
          title: 'Semua Rekam Medis',
          count: '48',
          icon: null,
          isSelected: _selectedTab == 'Semua',
          onTap: () => setState(() => _selectedTab = 'Semua'),
          accentColor: const Color(0xFF10B981),
        ),
        const SizedBox(width: 8),
        _buildTabPill(
          title: 'Resep Mantri',
          count: '18',
          icon: Icons.edit_outlined,
          isSelected: _selectedTab == 'Resep Mantri',
          onTap: () => setState(() => _selectedTab = 'Resep Mantri'),
          accentColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 8),
        _buildTabPill(
          title: 'Mandiri / Herbal',
          count: '30',
          icon: Icons.eco_rounded,
          isSelected: _selectedTab == 'Mandiri',
          onTap: () => setState(() => _selectedTab = 'Mandiri'),
          accentColor: const Color(0xFF10B981),
        ),
      ],
    );

    final sortWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Urutan: ',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1624),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1F2E42)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_vert_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: _sortOrder,
                dropdownColor: const Color(0xFF141F2F),
                underline: const SizedBox(),
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B9CB2), size: 16),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                items: ['Terbaru (April 2026)', 'Terlama'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _sortOrder = val);
                },
              ),
            ],
          ),
        ),
      ],
    );

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tabs,
          sortWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: tabs,
          ),
          const SizedBox(height: 8),
          sortWidget,
        ],
      );
    }
  }

  Widget _buildTabPill({
    required String title,
    required String count,
    required IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF0C131E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1C2B3C),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.black),
              const SizedBox(width: 5),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 5),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withOpacity(0.18)
                    : const Color(0xFF152233),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.black : accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search input and Filter Sapi Dropdown
  Widget _buildSearchAndDropdownBar(MockDatabase db, bool isWide) {
    final eartagDropdown = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C131E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1C2B3C)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEartagFilter,
          dropdownColor: const Color(0xFF141F2F),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8B9CB2), size: 18),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: [
            'Semua Eartag',
            ...db.cattleList.map((c) => c.eartagId),
          ].map((tag) {
            final text = tag == 'Semua Eartag' ? 'Filter Sapi: Semua Eartag' : 'Filter Sapi: $tag';
            return DropdownMenuItem(value: tag, child: Text(text));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedEartagFilter = val);
          },
        ),
      ),
    );

    final searchInput = Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0C131E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1C2B3C)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
              decoration: const InputDecoration(
                hintText: 'Cari keluhan sapi, nama obat (misal: Ivomec), atau catatan pemeriksaan...',
                hintStyle: TextStyle(color: Color(0xFF5A6678), fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(flex: 7, child: searchInput),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: eartagDropdown),
        ],
      );
    } else {
      return Column(
        children: [
          searchInput,
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: eartagDropdown),
        ],
      );
    }
  }

  // Clinical Record Card matching Image 1
  Widget _buildClinicalRecordCard(MedicalRecord record, DateFormat dateFormatter, bool isWide) {
    final isMandiri = record.jenisPenanganan == MedicalHandlingType.mandiri;

    // Card accent border color:
    // Card 1 (#007): Green
    // Card 2 (#019): Amber
    // Card 3 (#012): Blue
    Color accentBorder;
    if (record.eartagId == '#007') {
      accentBorder = const Color(0xFF10B981);
    } else if (record.eartagId == '#019') {
      accentBorder = const Color(0xFFF59E0B);
    } else {
      accentBorder = const Color(0xFF3B82F6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C131E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF182536)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentBorder, width: 3.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Badges (Eartag, Type, Kandang) & Right (Status, Date)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Badges
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Eartag badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.35)),
                        ),
                        child: Text(
                          record.eartagId,
                          style: const TextStyle(
                            color: Color(0xFF22D3EE),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type badge (Mandiri / Resep Mantri)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMandiri
                              ? const Color(0xFF10B981).withOpacity(0.18)
                              : const Color(0xFF3B82F6).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isMandiri
                                ? const Color(0xFF10B981).withOpacity(0.35)
                                : const Color(0xFF3B82F6).withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMandiri ? Icons.eco_rounded : Icons.person_rounded,
                              size: 12,
                              color: isMandiri ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMandiri ? 'Mandiri' : 'Resep Mantri',
                              style: TextStyle(
                                color: isMandiri ? const Color(0xFF34D399) : const Color(0xFF60A5FA),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Kandang Location badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162232),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.lokasiKandang,
                          style: const TextStyle(
                            color: Color(0xFF8B9CB2),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Right Badges (Status & Date)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFollowUpStatusBadge(record.statusTindakLanjut),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(
                            dateFormatter.format(record.tanggal),
                            style: const TextStyle(
                              color: Color(0xFF7A8B9E),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title (Diagnosis)
              Text(
                record.diagnosis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              // 3-Column Info Box (TINDAKAN DILAKUKAN, OBAT / TERAPI, PEMERIKSA / PETUGAS)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF080D15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF141F2D)),
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildInfoColumn(
                              icon: Icons.vaccines_rounded,
                              iconColor: const Color(0xFF06B6D4),
                              title: 'TINDAKAN DILAKUKAN',
                              content: record.tindakan,
                              contentColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildInfoColumn(
                              icon: Icons.soup_kitchen_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                  ? 'OBAT / TERAPI MEDIS'
                                  : 'OBAT / TERAPI',
                              content: record.obat,
                              contentColor: const Color(0xFFFBBF24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildInfoColumn(
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              title: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                  ? 'PETUGAS MEDIS HEWAN'
                                  : 'PEMERIKSA / PETUGAS',
                              content: record.petugas,
                              contentColor: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                  ? const Color(0xFF60A5FA)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoColumn(
                            icon: Icons.vaccines_rounded,
                            iconColor: const Color(0xFF06B6D4),
                            title: 'TINDAKAN DILAKUKAN',
                            content: record.tindakan,
                            contentColor: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoColumn(
                            icon: Icons.soup_kitchen_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                ? 'OBAT / TERAPI MEDIS'
                                : 'OBAT / TERAPI',
                            content: record.obat,
                            contentColor: const Color(0xFFFBBF24),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoColumn(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            title: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                ? 'PETUGAS MEDIS HEWAN'
                                : 'PEMERIKSA / PETUGAS',
                            content: record.petugas,
                            contentColor: record.jenisPenanganan == MedicalHandlingType.resepMantri
                                ? const Color(0xFF60A5FA)
                                : Colors.white,
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 10),

              // Bottom Notes Row (Evaluasi / Perhatian / Resep) + Right Action Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left note with icon
                  Expanded(
                    child: _buildBottomNote(record),
                  ),
                  const SizedBox(width: 10),
                  // Right action icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 16, color: Color(0xFF6B7280)),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF6B7280)),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpStatusBadge(String status) {
    Color color;
    IconData icon;
    if (status.contains('Membaik') || status.contains('Selesai')) {
      color = const Color(0xFF10B981);
      icon = Icons.check_circle_outline_rounded;
    } else if (status.contains('Kontrol') && !status.contains('Terjadwal')) {
      color = const Color(0xFFF59E0B);
      icon = Icons.access_time_rounded;
    } else {
      color = const Color(0xFF3B82F6);
      icon = Icons.sync_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: contentColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNote(MedicalRecord record) {
    if (record.catatanKhusus == null || record.catatanKhusus!.isEmpty) {
      return const SizedBox();
    }

    IconData icon;
    Color iconColor;
    Color textColor;
    FontStyle fontStyle = FontStyle.normal;

    if (record.jenisCatatanKhusus == 'evaluasi') {
      icon = Icons.campaign_outlined;
      iconColor = const Color(0xFF38BDF8);
      textColor = const Color(0xFF93C5FD);
      fontStyle = FontStyle.italic;
    } else if (record.jenisCatatanKhusus == 'perhatian') {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFE5E7EB);
    } else {
      icon = Icons.description_outlined;
      iconColor = const Color(0xFF38BDF8);
      textColor = const Color(0xFF38BDF8);
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            record.catatanKhusus!,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontStyle: fontStyle,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAddMedicalRecordSheet(BuildContext context) {
    AddMedicalRecordModal.show(context);
  }
}
