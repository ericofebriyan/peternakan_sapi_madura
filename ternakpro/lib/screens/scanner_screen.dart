import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  bool _isScanning = false;
  bool _hasResult = false;
  String _selectedEartag = '#012';

  // Mitigasi Jarak Kamera (Fase 1, 2, 4: Jarak Standar 1.5 – 2.0 meter)
  double _currentDistance = 1.8;

  double _estimatedWeight = 246.5;
  double _groundTruthWeight = 248.0;
  double _confidence = 0.942;
  String _detectedBreed = 'Sapi Madura Asli';
  double _estimatedPB = 142.0;
  double _estimatedLD = 178.0;
  double _calculatedAdg = 0.85;

  bool get _isDistanceOptimal => _currentDistance >= 1.5 && _currentDistance <= 2.0;

  double get _calculatedMape {
    if (_groundTruthWeight <= 0) return 0.0;
    return ((_groundTruthWeight - _estimatedWeight).abs() / _groundTruthWeight) * 100.0;
  }

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  void _triggerScan() {
    setState(() {
      _isScanning = true;
      _hasResult = false;
    });

    final db = MockDatabase();
    final cattle = db.cattleList.firstWhere(
      (c) => c.eartagId == _selectedEartag,
      orElse: () => db.cattleList.first,
    );

    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        // Dynamic intelligent simulation for TA demo:
        // Sapi Sehat: ADG ~ 0.85 kg/hari (Hijau > 0.5)
        // Sapi Pemulihan: ADG ~ 0.36 kg/hari (Kuning 0.2 - 0.5)
        // Sapi Stunted: ADG ~ 0.12 kg/hari (Merah < 0.2)
        double targetAdg;
        double confidence;
        if (cattle.statusKesehatan == 'Sehat') {
          targetAdg = 0.85;
          confidence = 0.954;
        } else if (cattle.statusKesehatan.contains('Pemulihan')) {
          targetAdg = 0.36;
          confidence = 0.915;
        } else {
          // Stunted
          targetAdg = 0.12;
          confidence = 0.887;
        }

        // Weight gain in 7 days
        final double gain = targetAdg * 7.0;
        final double newWeight = cattle.beratTerakhir + gain;
        // Ground truth slightly offset to demonstrate MAPE calculation
        final double groundTruth = newWeight + 1.2;

        // Formula Schoorl: Berat = (LD^2 * PB) / 10840 => LD = sqrt((Berat * 10840) / PB)
        final double pb = 95.0 + (newWeight * 0.18);
        final double ld = math.sqrt((newWeight * 10840.0) / pb);

        setState(() {
          _isScanning = false;
          _hasResult = true;
          _estimatedWeight = newWeight;
          _groundTruthWeight = groundTruth;
          _confidence = confidence;
          _detectedBreed = cattle.ras;
          _estimatedPB = pb;
          _estimatedLD = ld;
          _calculatedAdg = targetAdg;
        });
      }
    });
  }

  void _saveScanResult() {
    final db = MockDatabase();
    db.updateCattleWeight(_selectedEartag, _estimatedWeight);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bobot ${_estimatedWeight.toStringAsFixed(1)} kg berhasil dicatat ke eartag $_selectedEartag!',
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _hasResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          children: [
            Text('Edge AI Scanner'),
            SizedBox(width: 8),
            Text(
              'YOLOv8n TFLite',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulasi Jarak Kamera',
            icon: const Icon(Icons.straighten_rounded, color: AppColors.accent),
            onPressed: () {
              // Cycle distance: 1.2m -> 1.8m -> 2.5m
              setState(() {
                if (_currentDistance == 1.8) {
                  _currentDistance = 2.4;
                } else if (_currentDistance == 2.4) {
                  _currentDistance = 1.2;
                } else {
                  _currentDistance = 1.8;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated Camera Preview Viewport with Ghost Guide & Mitigasi Jarak
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161F2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isDistanceOptimal ? AppColors.primaryLight : AppColors.accent,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cattle Illustration (Side-view)
                    Opacity(
                      opacity: 0.85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🐄', style: TextStyle(fontSize: 130)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Posisikan sapi tegak menyamping (side-view)',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ghost Guide Overlay: Siluet Panduan Morfologi & Jarak (Fase 1 & 4)
                    CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _GhostGuidePainter(
                        isOptimal: _isDistanceOptimal,
                        isScanning: _isScanning,
                      ),
                    ),

                    // Bounding Box & YOLOv8n Anotasi Morfologi
                    Container(
                      margin: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isScanning
                              ? AppColors.primaryLight
                              : _isDistanceOptimal
                                  ? AppColors.primary.withOpacity(0.7)
                                  : AppColors.accent.withOpacity(0.7),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Label Deteksi YOLOv8n
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'YOLOv8n: COW 95.4% [LATERAL]',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          // Mitigasi Jarak Kamera (Fase 1 & 2: 1,5 - 2,0 m)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isDistanceOptimal
                                    ? AppColors.primary.withOpacity(0.2)
                                    : AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isDistanceOptimal ? AppColors.primary : AppColors.accent,
                                ),
                              ),
                              child: Text(
                                _isDistanceOptimal
                                    ? '✅ Jarak: ${_currentDistance.toStringAsFixed(1)}m (Optimal)'
                                    : _currentDistance < 1.5
                                        ? '⚠️ Jarak: ${_currentDistance.toStringAsFixed(1)}m (Mundur)'
                                        : '⚠️ Jarak: ${_currentDistance.toStringAsFixed(1)}m (Maju)',
                                style: TextStyle(
                                  color: _isDistanceOptimal ? AppColors.primaryLight : AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // Garis Bantu Morfologi (Panjang Badan & Lingkar Dada)
                          if (_isScanning)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 1,
                                    width: 160,
                                    color: AppColors.secondary.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'PB: Scapula - Tuber Ischii',
                                    style: TextStyle(color: AppColors.secondary, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),

                          // Laser Scan Animation
                          if (_isScanning)
                            AnimatedBuilder(
                              animation: _scanLineAnimation,
                              builder: (context, child) {
                                return Align(
                                  alignment: Alignment(0.0, (_scanLineAnimation.value * 2) - 1.0),
                                  child: Container(
                                    height: 3,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Controls (Pilih Sapi Target)
          Positioned(
            top: 14,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Target Eartag Sapi:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  DropdownButton<String>(
                    value: _selectedEartag,
                    dropdownColor: AppColors.surfaceCard,
                    underline: const SizedBox(),
                    isDense: true,
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    items: db.cattleList.map((c) {
                      return DropdownMenuItem(
                        value: c.eartagId,
                        child: Text('${c.eartagId} (${c.ras})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedEartag = val;
                          _hasResult = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet / Hasil Estimasi
          Positioned(
            bottom: 20,
            left: 18,
            right: 18,
            child: _hasResult ? _buildResultCard() : _buildScannerControl(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerControl() {
    return Column(
      children: [
        if (_isScanning)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'YOLOv8n: Ekstraksi fitur & inferensi Schoorl...',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: _isScanning ? null : _triggerScan,
          child: Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDistanceOptimal ? Colors.white : AppColors.accent,
                width: 3.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _isScanning ? AppColors.textMuted : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isDistanceOptimal
              ? 'Ketuk untuk Memindai (Jarak 1.8m Pas)'
              : 'Sesuaikan Jarak Kamera ke 1.5 - 2.0 m',
          style: TextStyle(
            color: _isDistanceOptimal ? Colors.white70 : AppColors.accent,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YOLOv8n TFLite RESULT',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedEartag,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _detectedBreed,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Text(
                  'Conf: ${(_confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large Weight Display & Ground Truth Comparison
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _estimatedWeight.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'kg',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Morphometric Dimensions (Formula Schoorl)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMorphoItem('Panjang Badan', '${_estimatedPB.toStringAsFixed(0)} cm', Icons.straighten_rounded),
                Container(width: 1, height: 26, color: AppColors.surfaceCardBorder),
                _buildMorphoItem('Lingkar Dada', '${_estimatedLD.toStringAsFixed(0)} cm', Icons.crop_free_rounded),
                Container(width: 1, height: 26, color: AppColors.surfaceCardBorder),
                _buildAdgItem(_calculatedAdg),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Validasi Akurasi Lapangan & Nilai MAPE (Fase 3 & 5 TA)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceCardBorder.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ground Truth: ${_groundTruthWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
                Text(
                  'MAPE: ${_calculatedMape.toStringAsFixed(2)}% (Sangat Akurat)',
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Lat: 48ms',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.surfaceCardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _hasResult = false;
                    });
                  },
                  child: const Text('Scan Ulang', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _saveScanResult,
                  child: const Text(
                    'Simpan ke Rekam Medis',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMorphoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 15),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildAdgItem(double adg) {
    // Ambang Batas ADG (Fase 3 & 4: hijau >0.5, kuning 0.2-0.5, merah <0.2)
    final Color adgColor = adg > 0.5
        ? AppColors.primary
        : adg >= 0.2
            ? AppColors.accent
            : AppColors.danger;

    return Column(
      children: [
        Icon(Icons.trending_up_rounded, color: adgColor, size: 15),
        const SizedBox(height: 2),
        Text(
          '+${adg.toStringAsFixed(2)} kg/hr',
          style: TextStyle(
            color: adgColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'ADG (7 hari)',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk Ghost Guide (Siluet Panduan Kamera Sisi Samping)
class _GhostGuidePainter extends CustomPainter {
  final bool isOptimal;
  final bool isScanning;

  _GhostGuidePainter({required this.isOptimal, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isOptimal
          ? (isScanning ? AppColors.primaryLight : AppColors.primary.withOpacity(0.4))
          : AppColors.accent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Center Crosshairs for alignment
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horizontal guideline
    canvas.drawLine(Offset(cx - 80, cy), Offset(cx + 80, cy), dashPaint);
    // Vertical guideline for chest girth
    canvas.drawLine(Offset(cx - 20, cy - 60), Offset(cx - 20, cy + 60), dashPaint);

    // Outline silhouette box markers
    const markerLen = 12.0;
    // Top-left
    canvas.drawLine(const Offset(35, 35), const Offset(35 + markerLen, 35), paint);
    canvas.drawLine(const Offset(35, 35), const Offset(35, 35 + markerLen), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - 35, 35), Offset(size.width - 35 - markerLen, 35), paint);
    canvas.drawLine(Offset(size.width - 35, 35), Offset(size.width - 35, 35 + markerLen), paint);
    // Bottom-left
    canvas.drawLine(Offset(35, size.height - 35), Offset(35 + markerLen, size.height - 35), paint);
    canvas.drawLine(Offset(35, size.height - 35), Offset(35, size.height - 35 - markerLen), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 35, size.height - 35), Offset(size.width - 35 - markerLen, size.height - 35), paint);
    canvas.drawLine(Offset(size.width - 35, size.height - 35), Offset(size.width - 35, size.height - 35 - markerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _GhostGuidePainter oldDelegate) {
    return oldDelegate.isOptimal != isOptimal || oldDelegate.isScanning != isScanning;
  }
}
