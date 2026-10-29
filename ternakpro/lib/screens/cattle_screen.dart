import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/cattle.dart';
import '../data/mock_data.dart';
import 'cattle_detail_screen.dart';

class CattleScreen extends StatefulWidget {
  const CattleScreen({super.key});

  @override
  State<CattleScreen> createState() => _CattleScreenState();
}

class _CattleScreenState extends State<CattleScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  String _selectedBreed = 'Semua Ras';
  String _selectedSort = 'Masuk Terbaru';

  final List<String> _breedFilters = [
    'Semua Ras',
    'Madura',
    'Limosin',
    'Simental',
    'Peranakan Ongole (PO)',
  ];

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();

    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: db,
          builder: (context, _) {
            // Apply filtering
            final filteredCattle = db.cattleList.where((c) {
              final query = _searchQuery.toLowerCase().trim();
              if (query.isNotEmpty) {
                final matchTag = c.eartagId.toLowerCase().contains(query);
                final matchBreed = c.ras.toLowerCase().contains(query);
                final matchPen = c.kandangPen.toLowerCase().contains(query);
                if (!matchTag && !matchBreed && !matchPen) return false;
              }

              // Filter status
              if (_selectedStatus != 'Semua') {
                if (_selectedStatus == 'Sehat' &&
                    !c.statusKesehatan.toLowerCase().contains('sehat')) {
                  return false;
                }
                if (_selectedStatus == 'Dalam Pemulihan' &&
                    !c.statusKesehatan.toLowerCase().contains('pemulihan')) {
                  return false;
                }
                if (_selectedStatus == 'Stunted' &&
                    !c.statusKesehatan.toLowerCase().contains('stunted') &&
                    !c.statusKesehatan.toLowerCase().contains('lambat')) {
                  return false;
                }
              }

              // Filter breed
              if (_selectedBreed != 'Semua Ras') {
                if (_selectedBreed == 'Madura' && !c.ras.contains('Madura')) return false;
                if (_selectedBreed == 'Limosin' && !c.ras.contains('Limosin')) return false;
                if (_selectedBreed == 'Simental' && !c.ras.contains('Simental')) return false;
                if (_selectedBreed == 'Peranakan Ongole (PO)' &&
                    !c.ras.contains('PO') &&
                    !c.ras.contains('Ongole')) {
                  return false;
                }
              }

              return true;
            }).toList();

            // Sort logic
            if (_selectedSort == 'Masuk Terbaru') {
              filteredCattle.sort((a, b) => b.tanggalMasuk.compareTo(a.tanggalMasuk));
            } else if (_selectedSort == 'Bobot Tertinggi') {
              filteredCattle.sort((a, b) => b.beratTerakhir.compareTo(a.beratTerakhir));
            } else if (_selectedSort == 'ADG Tertinggi') {
              filteredCattle.sort((a, b) => b.adg.compareTo(a.adg));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 768;

                return Column(
                  children: [
                    // Top App Header
                    _buildTopHeader(context, isWide),

                    // Search and Filters
                    _buildSearchAndFilters(context, isWide),

                    // Cattle Cards List
                    Expanded(
                      child: filteredCattle.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada data ternak yang sesuai kriteria pencarian',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredCattle.length,
                              itemBuilder: (context, index) {
                                final cattle = filteredCattle[index];
                                return _buildCattleCard(context, cattle, isWide);
                              },
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

  // Header matching Image 2
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
                _buildHeaderBrandAndTitle(),
                _buildHeaderRightActions(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBrandAndTitle(),
                const SizedBox(height: 12),
                _buildHeaderRightActions(context),
              ],
            ),
    );
  }

  Widget _buildHeaderBrandAndTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App / OS Logo
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
              Icons.agriculture_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'TERNAKPRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Farm Intelligence OS',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Container(
          width: 1,
          height: 32,
          color: const Color(0xFF1F2D3D),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Data Ternak Kandang',
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
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
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
                        'Live',
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
              'Blok A & B • Farm Central Pasuruan',
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

  Widget _buildHeaderRightActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary pill badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1624),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1F2E42)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '• Total: 142',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Text(
                '• 138 Sehat',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Text(
                '• 3 Rawat',
                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Text(
                '• 1 Stunted',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // + Tambah Sapi Button
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
          onPressed: () => _showAddCattleDialog(context),
          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.black),
          label: const Text(
            'Tambah Sapi',
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

  // Search and 2-Row Filters Section
  Widget _buildSearchAndFilters(BuildContext context, bool isWide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0C131E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1C2B3C)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Cari Eartag ID (#012), Ras Sapi, atau Lokasi Pen...',
                      hintStyle: TextStyle(color: Color(0xFF5A6678), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15202E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF22344A)),
                  ),
                  child: const Text(
                    '⌘ K',
                    style: TextStyle(color: Color(0xFF8B9CB2), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Row 1: Status
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusPill('Semua', '142', _selectedStatus == 'Semua', null),
                      const SizedBox(width: 8),
                      _buildStatusPill('Sehat', '138', _selectedStatus == 'Sehat', const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildStatusPill('Dalam Pemulihan', '3', _selectedStatus == 'Dalam Pemulihan', const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      _buildStatusPill('Stunted', '1', _selectedStatus == 'Stunted', const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Urutkan dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Urutkan: ',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1624),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1F2E42)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      dropdownColor: const Color(0xFF141F2F),
                      underline: const SizedBox(),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B9CB2), size: 18),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      items: ['Masuk Terbaru', 'Bobot Tertinggi', 'ADG Tertinggi'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSort = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Filter Row 2: Ras
          Row(
            children: [
              const Text(
                'Ras:     ',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _breedFilters.map((breed) {
                      final isSelected = _selectedBreed == breed;
                      final isAll = breed == 'Semua Ras';

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedBreed = breed),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isAll ? const Color(0xFF06B6D4) : const Color(0xFF16253A))
                                  : const Color(0xFF0C131E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (isAll ? const Color(0xFF06B6D4) : const Color(0xFF06B6D4))
                                    : const Color(0xFF1B283A),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: isAll ? Colors.black : const Color(0xFF06B6D4),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  breed,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isAll ? Colors.black : Colors.white)
                                        : const Color(0xFF8B9CB2),
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String title, String count, bool isSelected, Color? statusColor) {
    return InkWell(
      onTap: () => setState(() => _selectedStatus = title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF0C131E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1B283A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 13, color: Colors.black),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF8B9CB2),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : (statusColor ?? const Color(0xFF8B9CB2)),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cattle Card matching Image 2
  Widget _buildCattleCard(BuildContext context, Cattle cattle, bool isWide) {
    final isStunted = cattle.statusKesehatan.toLowerCase().contains('stunted') ||
        cattle.statusKesehatan.toLowerCase().contains('lambat');
    final isRecovery = cattle.statusKesehatan.toLowerCase().contains('pemulihan');
    final isOptimal = cattle.statusKesehatan.toLowerCase().contains('optimal');

    // Theme colors per cattle status
    Color badgeColor;
    Color avatarColor;
    Color cardBorder;
    if (isStunted) {
      badgeColor = const Color(0xFFEF4444);
      avatarColor = const Color(0xFFEF4444);
      cardBorder = const Color(0xFF7F1D1D);
    } else if (isRecovery) {
      badgeColor = const Color(0xFFF59E0B);
      avatarColor = const Color(0xFFF59E0B);
      cardBorder = const Color(0xFF27354A);
    } else if (isOptimal) {
      badgeColor = const Color(0xFF10B981);
      avatarColor = const Color(0xFF10B981);
      cardBorder = const Color(0xFF1C2B3C);
    } else {
      badgeColor = const Color(0xFF10B981);
      avatarColor = const Color(0xFF10B981);
      cardBorder = const Color(0xFF1C2B3C);
    }

    // ADG formatting
    final adgVal = cattle.adg;
    final adgString = adgVal >= 0 ? '+${adgVal.toStringAsFixed(2)} kg/h' : '${adgVal.toStringAsFixed(2)} kg/h';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C131E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isStunted ? cardBorder : const Color(0xFF182434),
          width: isStunted ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CattleDetailScreen(cattle: cattle)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: isWide
                ? Row(
                    children: [
                      // Left Section: Avatar + Details
                      Expanded(
                        flex: 6,
                        child: _buildCattleLeftSection(cattle, badgeColor, avatarColor, isStunted, isRecovery),
                      ),
                      // Right Section: Weight, Gain, Action
                      Expanded(
                        flex: 4,
                        child: _buildCattleRightSection(context, cattle, adgString, isStunted),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCattleLeftSection(cattle, badgeColor, avatarColor, isStunted, isRecovery),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF182434), height: 1),
                      const SizedBox(height: 10),
                      _buildCattleRightSection(context, cattle, adgString, isStunted),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCattleLeftSection(
    Cattle cattle,
    Color badgeColor,
    Color avatarColor,
    bool isStunted,
    bool isRecovery,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar Box
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isStunted
                    ? const Color(0xFF450A0A).withOpacity(0.5)
                    : (isRecovery
                        ? const Color(0xFF451A03).withOpacity(0.5)
                        : const Color(0xFF064E3B).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: avatarColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.pets_rounded,
                  color: avatarColor,
                  size: 26,
                ),
              ),
            ),
            // Small status dot at bottom right
            Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0C131E), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        // Text details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1: Eartag + Status badge + Kandang Pen
              Row(
                children: [
                  Text(
                    cattle.eartagId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cattle.statusKesehatan == 'Pertumbuhan Lambat / Stunted'
                              ? 'Stunted'
                              : cattle.statusKesehatan,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162232),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cattle.kandangPen,
                      style: const TextStyle(
                        color: Color(0xFF8B9CB2),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Line 2: Breed + Age
              Row(
                children: [
                  Text(
                    cattle.ras,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (cattle.umurDeskripsi != null) ...[
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: Color(0xFF5A6678), fontSize: 11)),
                    const SizedBox(width: 6),
                    Text(
                      cattle.umurDeskripsi!,
                      style: const TextStyle(
                        color: Color(0xFF8B9CB2),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),

              // Line 3: Kelompok + Pakan + Masuk
              Row(
                children: [
                  Text(
                    'Kelompok: ${cattle.kelompokUmur}',
                    style: const TextStyle(
                      color: Color(0xFF7A8B9E),
                      fontSize: 11,
                    ),
                  ),
                  if (cattle.pakan != null) ...[
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Pakan: ',
                            style: TextStyle(color: Color(0xFF7A8B9E), fontSize: 11),
                          ),
                          TextSpan(
                            text: cattle.pakan!,
                            style: TextStyle(
                              color: isStunted
                                  ? const Color(0xFFF87171)
                                  : (isRecovery ? const Color(0xFFFBBF24) : const Color(0xFF34D399)),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    'Masuk: ${cattle.daysInFeedlot} hari lalu',
                    style: const TextStyle(
                      color: Color(0xFF7A8B9E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCattleRightSection(
    BuildContext context,
    Cattle cattle,
    String adgString,
    bool isStunted,
  ) {
    final weightGain = cattle.weightGain;
    final gainText = weightGain >= 0 ? '+${weightGain.toStringAsFixed(1)} kg' : '${weightGain.toStringAsFixed(1)} kg';

    // Action button label
    String btnLabel = cattle.customActionButtonText ?? 'Detail';
    Color btnBorder = const Color(0xFF22344A);
    Color btnTextColor = Colors.white;

    if (cattle.customActionButtonText == 'Catatan Medis') {
      btnBorder = const Color(0xFFF59E0B).withOpacity(0.4);
      btnTextColor = const Color(0xFFF59E0B);
    } else if (cattle.customActionButtonText == 'Cek Nutrisi') {
      btnBorder = const Color(0xFFEF4444).withOpacity(0.5);
      btnTextColor = const Color(0xFFEF4444);
    } else if (cattle.customActionButtonText == 'Timbang Ulang') {
      btnBorder = const Color(0xFF22344A);
      btnTextColor = const Color(0xFFBAC7D5);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Metrics
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'BOBOT SAAT INI',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  cattle.beratTerakhir.toStringAsFixed(1),
                  style: TextStyle(
                    color: isStunted ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  'kg',
                  style: TextStyle(
                    color: Color(0xFF7A8B9E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gain pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isStunted
                        ? const Color(0xFFF59E0B).withOpacity(0.18)
                        : const Color(0xFF10B981).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 11,
                        color: isStunted ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        gainText,
                        style: TextStyle(
                          color: isStunted ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (cattle.adgCustom != null || cattle.adgStatus != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    'ADG: $adgString ${cattle.adgStatus ?? ""}'.trim(),
                    style: TextStyle(
                      color: isStunted ? const Color(0xFFEF4444) : const Color(0xFF7A8B9E),
                      fontSize: 10,
                      fontWeight: isStunted ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(width: 14),

        // Action Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: btnBorder),
            backgroundColor: const Color(0xFF0E1724),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CattleDetailScreen(cattle: cattle)),
            );
          },
          child: Text(
            btnLabel,
            style: TextStyle(
              color: btnTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Chevron
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF5A6678),
          size: 20,
        ),
      ],
    );
  }

  void _showAddCattleDialog(BuildContext context) {
    final eartagCtrl = TextEditingController();
    final breedCtrl = TextEditingController(text: 'Sapi Madura Asli');
    final weightCtrl = TextEditingController(text: '200');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1624),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Ternak Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: eartagCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nomor Eartag (Contoh: #026)',
                  labelStyle: TextStyle(color: Color(0xFF8B9CB2)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breedCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ras Sapi',
                  labelStyle: TextStyle(color: Color(0xFF8B9CB2)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Bobot Awal (kg)',
                  labelStyle: TextStyle(color: Color(0xFF8B9CB2)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ternak ${eartagCtrl.text} berhasil ditambahkan!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  child: const Text(
                    'Simpan Ternak',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
