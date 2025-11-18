import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' as supabase_core;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

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
    try {
      Logger.info('AuthService', 'Inicializando Supabase...');
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      Logger.info('AuthService', 'Supabase inicializado com sucesso');
    } catch (e, stackTrace) {
      Logger.error(
        'AuthService',
        'Falha ao inicializar Supabase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
      Logger.info(
        'AuthService',
        'Iniciando cadastro de usuário',
        extra: {'email': email},
      );
      final hashedPassword = _hashPassword(password);
      final serviceClient = createServiceRoleClient();

      final result = await serviceClient.from('users').insert({
        'email': email,
        'password': hashedPassword,
      }).select();

      if (result.isNotEmpty) {
        final user = result.first;
        Logger.info(
          'AuthService',
          'Usuário cadastrado com sucesso',
          extra: {'user_id': user['id']},
        );
        return {
          'success': true,
          'user_id': user['id'],
          'email': user['email'],
          'name': name,
          'created_at': user['created_at'],
          'message': 'Conta criada com sucesso!',
        };
      } else {
        throw Exception('Falha ao criar conta - resposta vazia do servidor');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'AuthService',
        'Erro ao criar conta',
        error: e,
        stackTrace: stackTrace,
        extra: {'email': email},
      );
      throw Exception(
        ErrorHandler.handleError(e, stackTrace: stackTrace, context: 'signUp'),
      );
    }
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('AuthService', 'Iniciando login', extra: {'email': email});
      final hashedPassword = _hashPassword(password);
      final serviceClient = createServiceRoleClient();

      final userData = await serviceClient
          .from('users')
          .select('*')
          .eq('email', email)
          .eq('password', hashedPassword);

      if (userData.isNotEmpty) {
        final user = userData.first;
        Logger.info(
          'AuthService',
          'Login realizado com sucesso',
          extra: {'user_id': user['id']},
        );
        return {
          'success': true,
          'user_id': user['id'],
          'email': user['email'],
          'created_at': user['created_at'],
          'message': 'Login realizado com sucesso!',
        };
      } else {
        Logger.warning(
          'AuthService',
          'Credenciais inválidas',
          extra: {'email': email},
        );
        throw Exception('Email ou senha incorretos');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'AuthService',
        'Erro ao fazer login',
        error: e,
        stackTrace: stackTrace,
        extra: {'email': email},
      );
      throw Exception(
        ErrorHandler.handleError(e, stackTrace: stackTrace, context: 'signIn'),
      );
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      Logger.debug(
        'AuthService',
        'Buscando perfil do usuário',
        extra: {'user_id': userId},
      );
      final serviceClient = createServiceRoleClient();

      final profileData = await serviceClient
          .from('user_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      Logger.info(
        'AuthService',
        'Perfil encontrado com sucesso',
        extra: {'user_id': userId},
      );
      return profileData as Map<String, dynamic>;
    } catch (e, stackTrace) {
      // Se a busca falhar (ex: perfil não existe ou erro de conexão), retorna null
      Logger.warning(
        'AuthService',
        'Perfil não encontrado ou erro ao buscar',
        error: e,
        stackTrace: stackTrace,
        extra: {'user_id': userId},
      );
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
