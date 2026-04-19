import 'package:flutter/foundation.dart';
import '../models/backup_model.dart';
import '../services/supabase_service.dart';

/// [BackupService] - Serviço responsável pelas operações de backup com o Supabase.
///
/// Esta classe atua como uma camada de abstração entre o Controller e o Supabase,
/// fornecendo métodos específicos para operações de backup.
///
/// Por que usar um Service específico se já temos o SupabaseService?
/// - Centraliza regras de negócio específicas de backups
/// - Facilita testes unitários (mock de uma única classe)
/// - Permite trocar de banco de dados sem mexer no Controller
/// - Transforma dados brutos do banco em Models prontos para uso
///
/// Fluxo típico:
/// ```
/// Controller → BackupService → SupabaseService → Supabase
/// ```
class BackupService {
  /// Instância singleton do SupabaseService
  ///
  /// Usamos singleton para garantir que haja apenas uma conexão com o banco
  final SupabaseService _supabase = SupabaseService();

  /// Nome da tabela no Supabase onde os backups são armazenados
  ///
  /// Esta tabela deve existir no seu projeto Supabase com as colunas:
  /// - id (uuid, primary key)
  /// - name (text)
  /// - status (text)
  /// - size (int8)
  /// - created_at (timestamptz)
  /// - user_name (text)
  /// - description (text, nullable)
  /// - storage_location (text, nullable)
  static const String _tableName = 'backups';

  /// Busca todos os backups do banco de dados.
  ///
  /// Este método consulta a tabela no Supabase e converte os dados brutos
  /// em uma lista de [BackupModel] prontos para uso na aplicação.
  ///
  /// Retorna:
  /// - [Future<List<BackupModel>>] com todos os backups encontrados
  /// - Lista vazia se não houver backups
  ///
  /// Throws:
  /// - [Exception] se houver erro de conexão ou permissão
  ///
  /// Exemplo de uso no Controller:
  /// ```dart
  /// try {
  ///   final backups = await backupService.getAllBackups();
  ///   // Atualiza estado da View
  /// } catch (e) {
  ///   // Mostra erro para o usuário
  /// }
  /// ```
  Future<List<BackupModel>> getAllBackups() async {
    try {
      debugPrint('📡 BackupService: Buscando todos os backups...');

      // Chama o SupabaseService para buscar dados brutos da tabela
      final data = await _supabase.getAll(table: _tableName);

      debugPrint('📦 BackupService: ${data.length} backups encontrados');

      // Converte cada registro bruto em um BackupModel
      // O operador spread (...) espalha a lista convertida
      return data
          .cast<Map<String, dynamic>>() // Garante tipo correto
          .map((json) => BackupModel.fromJson(json)) // Converte para Model
          .toList(); // Converte Iterable em List
    } catch (e) {
      // Log do erro para debug
      debugPrint('❌ BackupService: Erro ao buscar backups - $e');
      // Propaga o erro para o Controller lidar
      rethrow;
    }
  }

  /// Busca um backup específico pelo ID.
  ///
  /// Parâmetros:
  /// - [id]: Identificador único do backup (UUID)
  ///
  /// Retorna:
  /// - [BackupModel?] com os dados do backup, ou null se não existir
  Future<BackupModel?> getBackupById(String id) async {
    try {
      debugPrint('🔍 BackupService: Buscando backup $id...');

      // Busca registro específico no Supabase
      final data = await _supabase.getById(table: _tableName, id: id);

      // Se não encontrou, retorna null
      if (data == null) {
        debugPrint('⚠️ BackupService: Backup $id não encontrado');
        return null;
      }

      debugPrint('✅ BackupService: Backup encontrado');
      return BackupModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao buscar backup - $e');
      rethrow;
    }
  }

  /// Cria um novo backup no banco de dados.
  ///
  /// Parâmetros:
  /// - [backup]: Modelo de backup com os dados a serem salvos
  ///
  /// Retorna:
  /// - [Future<BackupModel>] com o backup criado (incluindo ID gerado)
  ///
  /// Observação:
  /// O ID é gerado automaticamente pelo Supabase (UUID).
  ///
  /// Exemplo:
  /// ```dart
  /// final novoBackup = BackupModel(
  ///   id: '', // Será gerado pelo banco
  ///   name: 'Backup Diário',
  ///   status: 'pending',
  ///   sizeInBytes: 1024,
  ///   createdAt: DateTime.now(),
  ///   userName: 'Admin',
  /// );
  ///
  /// final criado = await backupService.createBackup(novoBackup);
  /// print('ID gerado: ${criado.id}');
  /// ```
  Future<BackupModel> createBackup(BackupModel backup) async {
    try {
      debugPrint('💾 BackupService: Criando backup "${backup.name}"...');

      // Converte Model para JSON no formato esperado pelo Supabase
      final jsonData = backup.toJson();

      // Remove ID se estiver vazio (será gerado pelo banco)
      if (jsonData['id'] == null || jsonData['id'] == '') {
        jsonData.remove('id');
      }

      // Insere no banco e retorna o registro criado (com ID gerado)
      final created = await _supabase.insert(table: _tableName, data: jsonData);

      debugPrint('✅ BackupService: Backup criado com ID ${created['id']}');

      // Converte resposta do banco em Model
      return BackupModel.fromJson(created);
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao criar backup - $e');
      rethrow;
    }
  }

  /// Atualiza um backup existente no banco de dados.
  ///
  /// Parâmetros:
  /// - [backup]: Modelo com os dados atualizados (deve ter ID válido)
  ///
  /// Retorna:
  /// - [Future<BackupModel>] com o backup atualizado
  ///
  /// Throws:
  /// - [Exception] se o backup não existir
  ///
  /// Exemplo de uso comum:
  /// ```dart
  /// // Atualiza status de um backup
  /// final backupAtualizado = backup.copyWith(status: 'success');
  /// await backupService.updateBackup(backupAtualizado);
  /// ```
  Future<BackupModel> updateBackup(BackupModel backup) async {
    try {
      debugPrint('🔄 BackupService: Atualizando backup ${backup.id}...');

      // Valida que tem ID
      if (backup.id.isEmpty) {
        throw ArgumentError('Backup deve ter ID válido para atualização');
      }

      // Converte para JSON
      final jsonData = backup.toJson();

      // Remove ID dos dados a atualizar (não pode atualizar a primary key)
      jsonData.remove('id');

      // Atualiza no banco
      final updated = await _supabase.update(
        table: _tableName,
        id: backup.id,
        data: jsonData,
      );

      debugPrint('✅ BackupService: Backup atualizado com sucesso');
      return BackupModel.fromJson(updated);
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao atualizar backup - $e');
      rethrow;
    }
  }

  /// Remove um backup do banco de dados.
  ///
  /// Parâmetros:
  /// - [id]: ID do backup a ser removido
  ///
  /// Retorna:
  /// - [true] se removido com sucesso
  /// - [false] se houve erro ou backup não existia
  ///
  /// Importante:
  /// Esta operação é irreversível! Considere usar um campo "deleted_at"
  /// para soft delete em vez de remoção permanente.
  Future<bool> deleteBackup(String id) async {
    try {
      debugPrint('🗑️ BackupService: Removendo backup $id...');

      final deleted = await _supabase.delete(table: _tableName, id: id);

      if (deleted) {
        debugPrint('✅ BackupService: Backup removido com sucesso');
      }

      return deleted;
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao remover backup - $e');
      return false;
    }
  }

  /// Busca backups filtrados por status.
  ///
  /// Parâmetros:
  /// - [status]: Status a filtrar ('success', 'warning', 'error', 'pending')
  ///
  /// Retorna:
  /// - [Future<List<BackupModel>>] com backups do status especificado
  ///
  /// Exemplo:
  /// ```dart
  /// // Busca apenas backups com falha
  /// final falhas = await backupService.getBackupsByStatus('error');
  /// ```
  Future<List<BackupModel>> getBackupsByStatus(String status) async {
    try {
      debugPrint('🔍 BackupService: Buscando backups com status "$status"...');

      // Query com filtro WHERE no Supabase
      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('status', status);

      final data = response as List;

      debugPrint('📦 BackupService: ${data.length} backups encontrados');

      return data
          .cast<Map<String, dynamic>>()
          .map((json) => BackupModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao filtrar backups - $e');
      rethrow;
    }
  }

  /// Conta quantos backups existem no banco.
  ///
  /// Retorna:
  /// - [Future<int>] com a quantidade total de backups
  ///
  /// Útil para:
  /// - Mostrar estatísticas no dashboard
  /// - Paginação de listas
  Future<int> countBackups() async {
    try {
      debugPrint('📊 BackupService: Contando backups...');

      // Count no Supabase
      final response = await _supabase.client
          .from(_tableName)
          .select('*', count: 'exact');

      // Pega o count da resposta
      final count = response.count ?? 0;

      debugPrint('📦 BackupService: Total de $count backups');
      return count;
    } catch (e) {
      debugPrint('❌ BackupService: Erro ao contar backups - $e');
      return 0;
    }
  }
}
