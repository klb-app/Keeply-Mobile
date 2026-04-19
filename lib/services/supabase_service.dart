import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// [SupabaseService] - Serviço responsável por todas as operações com Supabase.
///
/// Esta classe encapsula o cliente Supabase e fornece métodos para:
/// - Inicialização da conexão
/// - Operações de banco de dados (CRUD)
/// - Autenticação de usuários
/// - Storage de arquivos
/// - Realtime subscriptions
///
/// Padrão Singleton: Garante que haja apenas uma instância do cliente Supabase.
///
/// Uso:
/// ```dart
/// final supabase = SupabaseService.instance;
/// await supabase.initialize();
/// final data = await supabase.getBackups();
/// ```
class SupabaseService {
  /// Instância singleton do serviço Supabase
  static final SupabaseService _instance = SupabaseService._internal();

  /// Getter para acessar a instância singleton
  static SupabaseService get instance => _instance;

  /// Construtor privado para padrão singleton
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Cliente Supabase inicializado
  ///
  /// Use este cliente para todas as operações com o Supabase.
  /// Exemplo:
  /// ```dart
  /// final client = SupabaseService.instance.client;
  /// final response = await client.from('backups').select();
  /// ```
  SupabaseClient? _client;

  /// Getter para o cliente Supabase
  ///
  /// Retorna o cliente Supabase inicializado.
  ///
  /// Throws:
  /// - [StateError] se o cliente não estiver inicializado.
  SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseClient não inicializado. Chame initialize() primeiro.',
      );
    }
    return _client!;
  }

  /// Inicializa o cliente Supabase com as credenciais configuradas.
  ///
  /// Este método deve ser chamado uma única vez no início do aplicativo.
  ///
  /// Exemplo:
  /// ```dart
  /// WidgetsFlutterBinding.ensureInitialized();
  /// await SupabaseService.instance.initialize();
  /// ```
  ///
  /// Throws:
  /// - [ArgumentError] se as credenciais não estiverem configuradas.
  /// - [Exception] se houver erro na inicialização.
  Future<void> initialize() async {
    try {
      // Verifica se as credenciais estão configuradas
      final error = SupabaseConfig.getConfigurationError();
      if (error != null) {
        throw ArgumentError(error);
      }

      // Inicializa o Supabase com URL e chave anon
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode, // Habilita logs apenas em debug
      );

      _client = Supabase.instance.client;

      debugPrint('✅ Supabase inicializado com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Supabase: $e');
      rethrow;
    }
  }

  /// Verifica se o cliente está inicializado
  bool get isInitialized => _client != null;

  /// ==========================================
  /// MÉTODOS DE AUTENTICAÇÃO
  /// ==========================================

  /// Realiza login com email e senha
  ///
  /// Parâmetros:
  /// - [email]: Email do usuário
  /// - [password]: Senha do usuário
  ///
  /// Retorna:
  /// - [AuthResponse] com dados do usuário e sessão
  ///
  /// Throws:
  /// - [AuthException] em caso de erro na autenticação
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Login realizado com sucesso: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('❌ Erro no login: ${e.message}');
      rethrow;
    }
  }

  /// Realiza cadastro de novo usuário
  ///
  /// Parâmetros:
  /// - [email]: Email do novo usuário
  /// - [password]: Senha (mínimo 6 caracteres)
  ///
  /// Retorna:
  /// - [AuthResponse] com dados do usuário criado
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      debugPrint('✅ Usuário criado com sucesso: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('❌ Erro no cadastro: ${e.message}');
      rethrow;
    }
  }

  /// Realiza logout do usuário atual
  ///
  /// Limpa a sessão e remove tokens armazenados.
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      rethrow;
    }
  }

  /// Verifica se há um usuário autenticado
  ///
  /// Retorna true se houver uma sessão ativa.
  bool get isAuthenticated {
    return client.auth.currentSession != null;
  }

  /// Retorna o usuário atualmente autenticado
  ///
  /// Retorna null se não houver usuário logado.
  User? get currentUser {
    return client.auth.currentUser;
  }

  /// ==========================================
  /// MÉTODOS DE BANCO DE DADOS
  /// ==========================================

  /// Busca todos os registros de uma tabela
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela no Supabase
  ///
  /// Retorna:
  /// - [List<Map<String, dynamic>>] com os registros
  Future<List<Map<String, dynamic>>> getAll({required String table}) async {
    try {
      final response = await client.from(table).select();
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados da tabela $table: $e');
      rethrow;
    }
  }

  /// Busca um registro específico pelo ID
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela
  /// - [id]: ID do registro
  ///
  /// Retorna:
  /// - [Map<String, dynamic>] com os dados do registro
  Future<Map<String, dynamic>?> getById({
    required String table,
    required String id,
  }) async {
    try {
      final response = await client.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao buscar registro $id da tabela $table: $e');
      return null;
    }
  }

  /// Insere um novo registro na tabela
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela
  /// - [data]: Dados a serem inseridos
  ///
  /// Retorna:
  /// - [Map<String, dynamic>] com o registro criado (incluindo ID gerado)
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      debugPrint('✅ Registro inserido em $table: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao inserir em $table: $e');
      rethrow;
    }
  }

  /// Atualiza um registro existente
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela
  /// - [id]: ID do registro a atualizar
  /// - [data]: Dados a serem atualizados
  ///
  /// Retorna:
  /// - [Map<String, dynamic>] com o registro atualizado
  Future<Map<String, dynamic>> update({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ Registro atualizado em $table: $id');
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar $table.$id: $e');
      rethrow;
    }
  }

  /// Remove um registro da tabela
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela
  /// - [id]: ID do registro a remover
  ///
  /// Retorna:
  /// - true se removido com sucesso, false caso contrário
  Future<bool> delete({required String table, required String id}) async {
    try {
      await client.from(table).delete().eq('id', id);
      debugPrint('✅ Registro removido de $table: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao remover de $table.$id: $e');
      return false;
    }
  }

  /// ==========================================
  /// STREAMS E REALTIME
  /// ==========================================

  /// Cria um stream para ouvir mudanças em uma tabela
  ///
  /// Parâmetros:
  /// - [table]: Nome da tabela
  /// - [schema]: Schema do banco (padrão: 'public')
  ///
  /// Retorna:
  /// - [Stream<List<Map<String, dynamic>>>] com atualizações em tempo real
  Stream<List<Map<String, dynamic>>> subscribeToTable({
    required String table,
    String schema = 'public',
  }) {
    return client
        .from('$schema.$table')
        .stream(primaryKey: ['id'])
        .map((events) => events.map((e) => e as Map<String, dynamic>).toList());
  }
}
