import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'cattle_screen.dart';
import 'scanner_screen.dart';
import 'finance_screen.dart';
import 'medical_screen.dart';
import 'quick_expense_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const CattleScreen(),
      const ScannerScreen(),
      const FinanceScreen(),
      const MedicalScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Global Quick Action Floating Button for Fast Incidental Expense
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton(
              heroTag: 'quick_expense_fab',
              mini: true,
              backgroundColor: AppColors.accent,
              tooltip: 'Input Kilat ⚡',
              onPressed: () => QuickExpenseModal.show(context),
              child: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 20),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.surfaceCardBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.grid_view_rounded,
                  label: 'Beranda',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.pets_rounded,
                  label: 'Ternak',
                ),
                _buildCenterScanButton(),
                _buildNavItem(
                  index: 3,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Keuangan',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.medication_rounded,
                  label: 'Medis',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _onTabSelected(2),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
