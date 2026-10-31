import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_db_service.dart';
import 'supabase_config.dart';
import '../models/cattle.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDbService _localDb = LocalDbService();
  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> initialize() async {
    // Check initial connectivity
    final results = await Connectivity().checkConnectivity();
    _updateOnlineStatus(results);

    // Listen to network changes
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      _updateOnlineStatus(results);
      if (_isOnline) {
        syncNow();
      }
    });

    // Run first sync if configured
    if (SupabaseConfig.isConfigured && _isOnline) {
      syncNow();
    }
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing || !_isOnline || !SupabaseConfig.isConfigured) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;

      // 1. PUSH unsynced cattles
      final unsyncedCattles = await _localDb.getUnsyncedCattles();
      for (var row in unsyncedCattles) {
        final payload = Map<String, dynamic>.from(row)..remove('is_synced');
        await client.from('cattles').upsert(payload, onConflict: 'eartag_id');
        await _localDb.markCattleSynced(row['eartag_id']);
      }

      // 2. PUSH unsynced transactions
      final unsyncedTxs = await _localDb.getUnsyncedTransactions();
      for (var row in unsyncedTxs) {
        final payload = Map<String, dynamic>.from(row)..remove('is_synced');
        await client.from('financial_transactions').upsert(payload, onConflict: 'id');
        await _localDb.markTransactionSynced(row['id']);
      }

      // 3. PUSH unsynced medical records
      final unsyncedMed = await _localDb.getUnsyncedMedicalRecords();
      for (var row in unsyncedMed) {
        final payload = Map<String, dynamic>.from(row)..remove('is_synced');
        await client.from('medical_records').upsert(payload, onConflict: 'id');
        await _localDb.markMedicalRecordSynced(row['id']);
      }

      // 4. PULL latest from Supabase
      try {
        final cloudCattles = await client.from('cattles').select();
        for (var c in cloudCattles) {
          await _localDb.insertCattle(Cattle.fromMap(c), isSynced: true);
        }

        final cloudTxs = await client.from('financial_transactions').select();
        for (var tx in cloudTxs) {
          await _localDb.insertTransaction(FinancialTransaction.fromMap(tx), isSynced: true);
        }

        final cloudMed = await client.from('medical_records').select();
        for (var m in cloudMed) {
          await _localDb.insertMedicalRecord(MedicalRecord.fromMap(m), isSynced: true);
        }
      } catch (e) {
        debugPrint('Pull error from Supabase: $e');
      }

      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

