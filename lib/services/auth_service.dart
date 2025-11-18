import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' as supabase_core;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/supabase_config.dart';

class AuthService {
  static SupabaseClient? _supabase;

  static supabase_core.SupabaseClient createServiceRoleClient() {
    return supabase_core.SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.serviceRoleKey,
      headers: {
        'apikey': SupabaseConfig.serviceRoleKey,
        'Authorization': 'Bearer ${SupabaseConfig.serviceRoleKey}',
      },
    );
  }

  static SupabaseClient get client {
    _supabase ??= Supabase.instance.client;
    return _supabase!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      final serviceClient = createServiceRoleClient(); // Usa a função pública

      final result = await serviceClient.from('users').insert({
        'email': email,
        'password': hashedPassword,
      }).select();

      if (result.isNotEmpty) {
        final user = result.first;
        return {
          'success': true,
          'user_id': user['id'],
          'email': user['email'],
          'name': name,
          'created_at': user['created_at'],
          'message': 'Conta criada com sucesso!',
        };
      } else {
        throw Exception('Falha ao criar conta');
      }
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      final serviceClient = createServiceRoleClient(); // Usa a função pública

      final userData = await serviceClient
          .from('users')
          .select('*')
          .eq('email', email)
          .eq('password', hashedPassword);

      if (userData.isNotEmpty) {
        final user = userData.first;
        return {
          'success': true,
          'user_id': user['id'],
          'email': user['email'],
          'created_at': user['created_at'],
          'message': 'Login realizado com sucesso!',
        };
      } else {
        throw Exception('Email ou senha incorretos');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final serviceClient = createServiceRoleClient();

      final profileData = await serviceClient
          .from('user_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      // Converte o PostgrestMap (Map<String, dynamic>) para Map<String, dynamic>
      return profileData;
    } catch (e) {
      // Se a busca falhar (ex: perfil não existe ou erro de conexão), retorna null
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    clearCurrentUser();
  }

  static Map<String, dynamic>? _currentUser;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static Future<bool> isUserAuthenticated() async => _currentUser != null;

  static Future<Map<String, dynamic>?> getCurrentUserData() async =>
      _currentUser;

  static void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  static void clearCurrentUser() {
    _currentUser = null;
  }
}
