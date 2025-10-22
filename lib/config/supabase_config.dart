import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Valores padrão (fallback se .env não carregar)
  static const String _defaultUrl = 'https://ixyrxbbeetzoxznebrap.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4eXJ4YmJlZXR6b3h6bmVicmFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwODY4MDksImV4cCI6MjA3NjY2MjgwOX0.-5a2Y10ndzKJ7GFS1kEO158yoMSkmqSbh9aSYtsgf68';
  static const String _defaultServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4eXJ4YmJlZXR6b3h6bmVicmFwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MTA4NjgwOSwiZXhwIjoyMDc2NjYyODA5fQ.ieJgKnfSzlV-uCOBDgUxjRxRrQTmVoLNhpdO6wrfPGs';
  static const bool _defaultUseServiceRole = true;

  // Carregar variáveis do .env com fallback
  static String get url {
    try {
      return dotenv.env['SUPABASE_URL'] ?? _defaultUrl;
    } catch (e) {
      return _defaultUrl;
    }
  }

  static String get anonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? _defaultAnonKey;
    } catch (e) {
      return _defaultAnonKey;
    }
  }

  static String get serviceRoleKey {
    try {
      return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? _defaultServiceRoleKey;
    } catch (e) {
      return _defaultServiceRoleKey;
    }
  }

  static bool get useServiceRole {
    try {
      return dotenv.env['USE_SERVICE_ROLE']?.toLowerCase() == 'true' ||
          _defaultUseServiceRole;
    } catch (e) {
      return _defaultUseServiceRole;
    }
  }
}
