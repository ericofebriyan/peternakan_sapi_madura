import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'data/mock_data.dart';
import 'services/supabase_config.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian date formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize Supabase Cloud jika sudah diisi di SupabaseConfig
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  // Initialize Local SQLite Database & Load Data
  await MockDatabase().initializeFromDb();

  // Initialize Auto-Sync Service (Listener Network)
  await SyncService().initialize();

  // Set system UI overlay style for dark immersive mobile experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TernakProApp());
}

class TernakProApp extends StatelessWidget {
  const TernakProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TernakPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
