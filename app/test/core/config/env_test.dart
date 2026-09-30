import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/config/env.dart';

void main() {
  test('Env.isSupabaseConfigured validates real Supabase URL without trailing slash', () {
    dotenv.loadFromString(
      envString: '''
SUPABASE_URL=https://syrzrwbbmpenqurkcaon.supabase.co
SUPABASE_ANON_KEY=sb_publishable_ue2yAU78vmUpI8dOguDlrQ_Bt0tVb7U
''',
    );

    expect(Env.isSupabaseConfigured, isTrue);
    expect(Env.supabaseUrl, 'https://syrzrwbbmpenqurkcaon.supabase.co');
    expect(Env.supabaseAnonKey, 'sb_publishable_ue2yAU78vmUpI8dOguDlrQ_Bt0tVb7U');
  });

  test('Env.isSupabaseConfigured returns false for placeholder values', () {
    dotenv.loadFromString(
      envString: '''
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
''',
    );

    expect(Env.isSupabaseConfigured, isFalse);
  });
}
