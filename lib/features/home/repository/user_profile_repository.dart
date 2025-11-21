import 'package:ravera/features/home/model/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRepository {
  final SupabaseClient supabase;

  UserProfileRepository({required this.supabase});

  Future<UserProfile> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(response);
  }
}
