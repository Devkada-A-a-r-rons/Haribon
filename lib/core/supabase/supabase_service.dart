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

  Future<Map<String, dynamic>?> getOnboardingData(String userName) async {
    try {
      final response = await _client
          .from('user_onboarding')
          .select()
          .eq('user_name', userName)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching from Supabase: $e');
      return null;
    }
  }
}
