import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    try {
      await _client.from('user_onboarding').insert(data);
    } catch (e) {
      print('Error saving to Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateLatestOnboardingData(Map<String, dynamic> data) async {
    try {
      // Find the latest record for this user and update it
      // Note: In a real app with auth, we would use user_id. 
      // For now, we'll match by the original name if provided, or just update the most recent one.
      final latest = await _client
          .from('user_onboarding')
          .select('id')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (latest != null) {
        await _client
            .from('user_onboarding')
            .update(data)
            .eq('id', latest['id']);
      } else {
        // Fallback to insert if nothing exists
        await saveOnboardingData(data);
      }
    } catch (e) {
      print('Error updating Supabase: $e');
    }
  }
}
