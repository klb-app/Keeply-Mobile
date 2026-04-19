import 'package:flutter/foundation.dart';
import '../models/backup_model.dart';
import '../services/backup_service.dart';

/// [BackupController] - Controlador responsável pela lógica de gerenciamento de backups.
///
/// Este Controller atua como intermediário entre a View (telas) e os Services (banco de dados).
/// Ele estende [ChangeNotifier] para permitir que a View seja atualizada automaticamente
/// quando os dados mudam (padrão Observer).
///
/// Responsabilidades:
/// - Gerenciar o estado da tela de backups
/// - Buscar dados do BackupService
/// - Tratar erros e loading
/// - Expor dados formatados para a View
///
/// Fluxo de uso na View:
/// ```dart
/// // 1. Cria o controller
/// final controller = BackupController();
///
/// // 2. Carrega os dados
/// await controller.carregarBackups();
///
/// // 3. Acessa os dados
/// final backups = controller.backups;
/// ```
///
/// Padrão de nomenclatura:
/// - Métodos públicos: verbos no infinitivo (carregar, criar, atualizar)
/// - Métodos privados: prefixo _ (_atualizarEstado, _buscarDados)
/// - Getters públicos: substantivos (backups, isLoading, temErro)
class BackupController extends ChangeNotifier {
  /// Instância do serviço de backups
  ///
  /// O service é privado porque a View não deve acessá-lo diretamente.
  /// Isso mantém o princípio de separação de responsabilidades.
  final BackupService _backupService = BackupService();

  /// Lista de backups carregados do banco de dados.
  ///
  /// Este campo é privado (_backups) para forçar o uso do getter público.
  /// Dessa forma, a View nunca modifica a lista diretamente.
  List<BackupModel> _backups = [];

  /// Getter público que retorna a lista de backups.
  ///
  /// A View usa este getter para acessar os dados:
  /// ```dart
  /// controller.backups // Retorna List<BackupModel>
  /// ```
  List<BackupModel> get backups => _backups;

  /// Indica se há uma operação em andamento (loading).
  ///
  /// Use este campo na View para mostrar um indicador de carregamento:
  /// ```dart
  /// if (controller.isLoading) {
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  bool _isLoading = false;

  /// Getter público do estado de loading.
  bool get isLoading => _isLoading;

  /// Armazena mensagem de erro, se houver.
  ///
  /// Null quando não há erro.
  String? _errorMessage;

  /// Getter público da mensagem de erro.
  String? get errorMessage => _errorMessage;

  /// Indica se há um erro armazenado.
  ///
  /// Útil para condicionais na View:
  /// ```dart
  /// if (controller.hasError) {
  ///   return Text('Erro: ${controller.errorMessage}');
  /// }
  /// ```
  bool get hasError => _errorMessage != null;

  /// Indica se a lista de backups está vazia.
  ///
  /// Útil para mostrar tela de "estado vazio" na View:
  /// ```dart
  /// if (controller.isEmpty) {
  ///   return Text('Nenhum backup encontrado');
  /// }
  /// ```
  bool get isEmpty => _backups.isEmpty;

  /// Retorna a quantidade de backups carregados.
  ///
  /// Útil para badges ou contadores na UI.
  int get backupCount => _backups.length;

  /// ==========================================
  /// MÉTODOS PÚBLICOS (chamados pela View)
  /// ==========================================

  /// Carrega todos os backups do banco de dados.
  ///
  /// Este é o método principal que a View deve chamar para popular a tela.
  /// Ele:
  /// 1. Define estado de loading
  /// 2. Busca dados do BackupService
  /// 3. Atualiza a lista de backups
  /// 4. Notifica a View para rebuildar
  ///
  /// Tratamento de erro:
  /// - Em caso de falha, armazena a mensagem de erro
  /// - A View pode verificar com hasError e errorMessage
  ///
  /// Exemplo de uso na View:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   controller.carregarBackups(); // Carrega ao iniciar
  /// }
  ///
  /// // Ou com refresh indicator:
  /// await controller.carregarBackups();
  /// ```
  Future<void> carregarBackups() async {
    try {
      debugPrint('🎮 BackupController: Iniciando carregamento de backups...');

      // Define estado de loading
      _setLoading(true);

      // Limpa erro anterior (se houver)
      _limparErro();

      // Busca dados do service
      _backups = await _backupService.getAllBackups();

      debugPrint('✅ BackupController: ${_backups.length} backups carregados');

      // Notifica a View que os dados mudaram
      // Isso faz o Consumer rebuildar a UI
      notifyListeners();
    } catch (e) {
      // Captura erro e armazena mensagem
      debugPrint('❌ BackupController: Erro ao carregar backups - $e');
      _setError('Falha ao carregar backups: ${e.toString()}');

      // Notifica a View mesmo em caso de erro
      // (para mostrar mensagem de erro na tela)
      notifyListeners();

      // Propaga erro se necessário
      rethrow;
    } finally {
      // Sempre sai do loading, mesmo com erro
      _setLoading(false);
    }
  }

  /// Cria um novo backup no banco de dados.
  ///
  /// Parâmetros:
  /// - [backup]: Modelo com os dados do backup a ser criado
  ///
  /// Retorna:
  /// - [Future<BackupModel>] com o backup criado
  ///
  /// Após criar com sucesso:
  /// - Adiciona o backup na lista local
  /// - Notifica a View para atualizar a tela
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final novoBackup = BackupModel(
  ///   id: '',
  ///   name: 'Backup Manual',
  ///   status: 'pending',
  ///   sizeInBytes: 0,
  ///   createdAt: DateTime.now(),
  ///   userName: 'Usuário',
  /// );
  ///
  /// try {
  ///   final criado = await controller.criarBackup(novoBackup);
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Backup criado!')),
  ///   );
  /// } catch (e) {
  ///   // Mostra erro
  /// }
  /// ```
  Future<BackupModel> criarBackup(BackupModel backup) async {
    try {
      debugPrint('🎮 BackupController: Criando backup "${backup.name}"...');

      _setLoading(true);
      _limparErro();

      // Chama o service para criar no banco
      final criado = await _backupService.createBackup(backup);

      // Adiciona na lista local
      _backups.add(criado);

      debugPrint('✅ BackupController: Backup criado com sucesso');

      // Notifica View da mudança
      notifyListeners();

      return criado;
    } catch (e) {
      debugPrint('❌ BackupController: Erro ao criar backup - $e');
      _setError('Falha ao criar backup: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um backup existente.
  ///
  /// Parâmetros:
  /// - [backup]: Modelo com dados atualizados (deve ter ID válido)
  ///
  /// Após atualizar:
  /// - Encontra o backup na lista local
  /// - Substitui pelo backup atualizado
  /// - Notifica a View
  ///
  /// Caso de uso comum:
  /// ```dart
  /// // Atualiza status após operação de backup
  /// final backupAtualizado = backup.copyWith(status: 'success');
  /// await controller.atualizarBackup(backupAtualizado);
  /// ```
  Future<BackupModel> atualizarBackup(BackupModel backup) async {
    try {
      debugPrint('🎮 BackupController: Atualizando backup ${backup.id}...');

      _setLoading(true);
      _limparErro();

      // Atualiza no banco via service
      final atualizado = await _backupService.updateBackup(backup);

      // Encontra índice do backup na lista local
      final index = _backups.indexWhere((b) => b.id == backup.id);

      if (index != -1) {
        // Substitui na lista
        _backups[index] = atualizado;
        debugPrint('✅ BackupController: Backup atualizado na lista');
      }

      notifyListeners();

      return atualizado;
    } catch (e) {
      debugPrint('❌ BackupController: Erro ao atualizar backup - $e');
      _setError('Falha ao atualizar backup: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove um backup do banco de dados.
  ///
  /// Parâmetros:
  /// - [id]: ID do backup a ser removido
  ///
  /// Após remover:
  /// - Remove da lista local
  /// - Notifica a View
  ///
  /// Exemplo:
  /// ```dart
  /// showDialog(
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Remover backup?'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () async {
  ///           await controller.removerBackup(backup.id);
  ///           // Mostra feedback de sucesso
  ///         },
  ///         child: Text('Remover'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<void> removerBackup(String id) async {
    try {
      debugPrint('🎮 BackupController: Removendo backup $id...');

      _setLoading(true);
      _limparErro();

      // Remove do banco
      final removido = await _backupService.deleteBackup(id);

      if (removido) {
        // Remove da lista local
        _backups.removeWhere((b) => b.id == id);
        debugPrint('✅ BackupController: Backup removido com sucesso');

        notifyListeners();
      } else {
        throw Exception('Falha ao remover backup');
      }
    } catch (e) {
      debugPrint('❌ BackupController: Erro ao remover backup - $e');
      _setError('Falha ao remover backup: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega os dados e atualiza a View.
  ///
  /// Método útil para pull-to-refresh ou botão de atualizar.
  ///
  /// Exemplo com RefreshIndicator:
  /// ```dart
  /// RefreshIndicator(
  ///   onRefresh: controller.refresh,
  ///   child: ListView(...),
  /// )
  /// ```
  Future<void> refresh() async {
    debugPrint('🔄 BackupController: Refreshing data...');
    await carregarBackups();
  }

  /// ==========================================
  /// MÉTODOS PRIVADOS (auxiliares internos)
  /// ==========================================

  /// Define o estado de loading e notifica a View.
  ///
  /// Método privado para centralizar a lógica de loading.
  ///
  /// Parâmetros:
  /// - [loading]: true para iniciar loading, false para parar
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Não notifica aqui para evitar rebuilds desnecessários
    // A notificação é feita no final do método público
  }

  /// Define uma mensagem de erro.
  ///
  /// Parâmetros:
  /// - [message]: Mensagem de erro a ser armazenada
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Limpa a mensagem de erro.
  ///
  /// Deve ser chamado antes de cada nova operação.
  void _limparErro() {
    _errorMessage = null;
  }

  /// Filtra backups por status.
  ///
  /// Método útil para a View mostrar apenas backups de um tipo.
  ///
  /// Parâmetros:
  /// - [status]: Status a filtrar ('success', 'error', 'warning', 'pending')
  ///
  /// Retorna:
  /// - [List<BackupModel>] com backups filtrados
  ///
  /// Exemplo:
  /// ```dart
  /// final backupsComErro = controller.filtrarPorStatus('error');
  /// ```
  List<BackupModel> filtrarPorStatus(String status) {
    return _backups.where((b) => b.status == status).toList();
  }

  /// Busca um backup específico na lista local pelo ID.
  ///
  /// Método mais rápido que buscar no banco (já está em memória).
  ///
  /// Parâmetros:
  /// - [id]: ID do backup a buscar
  ///
  /// Retorna:
  /// - [BackupModel?] se encontrado, null caso contrário
  BackupModel? buscarBackupPorId(String id) {
    try {
      return _backups.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Método chamado quando o Controller é descartado.
  ///
  /// Override do ChangeNotifier para limpeza de recursos.
  @override
  void dispose() {
    // Limpa a lista para liberar memória
    _backups.clear();
    debugPrint('🎮 BackupController: Dispose chamado');
    super.dispose();
  }
}
