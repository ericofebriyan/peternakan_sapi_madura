/// Konfigurasi Supabase Cloud untuk TernakPro
///
/// CARA MENGISI:
/// 1. Buka https://supabase.com dan buat proyek baru (Region Singapore).
/// 2. Buka Project Settings -> API.
/// 3. Salin Project URL dan anon public key ke variabel di bawah ini.
class SupabaseConfig {
  // Ganti dengan Project URL dari Supabase Anda
  static const String supabaseUrl = '';

  // Ganti dengan Project anon key dari Supabase Anda
  static const String supabaseAnonKey = '';

  /// Cek apakah Supabase sudah diisi dengan benar
  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty &&
      supabaseUrl.startsWith('https://');
}

