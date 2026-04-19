import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/backup_controller.dart';
import '../../models/backup_model.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/app_constants.dart';

/// [BackupListView] - Tela de listagem de backups do Keeply.
///
/// Esta View é responsável por:
/// - Exibir lista de backups carregados do banco de dados
/// - Mostrar estados de loading, erro e vazio
/// - Permitir refresh (pull-to-refresh)
/// - Fornecer ações (detalhes, remover, atualizar)
///
/// Arquitetura MVC:
/// - **View**: Apenas UI, sem lógica de negócio
/// - **Controller**: Gerencia estado e dados (BackupController)
/// - **Provider**: Conecta View ↔ Controller
///
/// Uso com Provider:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => BackupController(),
///   child: BackupListView(),
/// )
/// ```
class BackupListView extends StatefulWidget {
  /// Construtor da BackupListView.
  ///
  /// Constante porque não recebe parâmetros externos.
  const BackupListView({super.key});

  @override
  State<BackupListView> createState() => _BackupListViewState();
}

/// [_BackupListViewState] - Estado da tela de listagem de backups.
///
/// Usamos StatefulWidget porque:
/// - Precisa carregar dados ao iniciar (initState)
/// - Tem interação com usuário (pull-to-refresh, botões)
class _BackupListViewState extends State<BackupListView> {
  /// Instância do controller (inicializado em initState).
  ///
  /// Mantemos referência para chamar métodos e acessar dados.
  late BackupController _controller;

  /// Inicializa o controller quando a tela é criada.
  ///
  /// Este método é chamado uma vez quando o widget é inserido na árvore.
  @override
  void initState() {
    super.initState();
    // Cria a instância do controller
    _controller = BackupController();
    // Carrega os dados ao iniciar a tela
    _controller.carregarBackups();
  }

  /// Libera recursos quando a tela é removida.
  ///
  /// Importante descartar o controller para evitar memory leaks.
  @override
  void dispose() {
    // Descarta o controller e para listeners
    _controller.dispose();
    super.dispose();
  }

  /// Build da interface da tela de backups.
  ///
  /// Retorna a árvore de widgets que compõe a tela.
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider cria o controller e disponibiliza para árvore
    // Isso permite que widgets filhos acessem o controller via Provider.of ou Consumer
    return ChangeNotifierProvider.value(
      // Fornece a instância existente do controller
      value: _controller,

      // Consumer escuta mudanças no controller e rebuilda quando notificado
      // Isso é mais eficiente que setState para atualizações parciais
      child: Consumer<BackupController>(
        // builder é chamado sempre que notifyListeners() é chamado no controller
        builder: (context, controller, child) {
          // Scaffold cria a estrutura básica da tela:
          // - appBar: barra superior
          // - body: conteúdo principal
          // - floatingActionButton: botão flutuante
          return Scaffold(
            // AppBar com título e ações
            appBar: AppBar(
              // Título da tela
              title: const Text('Backups'),
              // Ações na direita da AppBar
              actions: [
                // Botão de refresh
                IconButton(
                  // Ícone de atualizar
                  icon: const Icon(Icons.refresh),
                  // Tooltip (texto ao segurar)
                  tooltip: 'Atualizar lista',
                  // Ação ao clicar
                  onPressed: () {
                    // Chama refresh no controller
                    controller.refresh();
                    // Mostra feedback visual
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Atualizando lista...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Corpo da tela com conteúdo dinâmico
            body: _buildBody(controller),

            // Botão flutuante para criar novo backup
            floatingActionButton: FloatingActionButton(
              // Ícone de adicionar
              child: const Icon(Icons.add),
              // Tooltip
              tooltip: 'Novo Backup',
              // Ação ao clicar
              onPressed: () => _mostrarDialogoNovoBackup(context),
            ),
          );
        },
      ),
    );
  }

  /// Constrói o corpo da tela baseado no estado do controller.
  ///
  /// Este método decide qual widget exibir baseado no estado atual:
  /// - Loading: mostra CircularProgressIndicator
  /// - Erro: mostra mensagem de erro
  /// - Vazio: mostra tela de "sem dados"
  /// - Sucesso: mostra lista de backups
  ///
  /// Parâmetros:
  /// - [controller]: Instância do BackupController com estado atual
  ///
  /// Retorna:
  /// - Widget apropriado para o estado atual
  Widget _buildBody(BackupController controller) {
    // Verifica estado de loading primeiro
    if (controller.isLoading) {
      // Mostra spinner de carregamento centralizado
      return const Center(child: CircularProgressIndicator());
    }

    // Verifica se há erro
    if (controller.hasError) {
      // Mostra mensagem de erro com botão de tentar novamente
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de erro
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            // Mensagem de erro
            Text(
              controller.errorMessage ?? 'Erro desconhecido',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Botão para tentar novamente
            ElevatedButton.icon(
              onPressed: () => controller.carregarBackups(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // Verifica se lista está vazia
    if (controller.isEmpty) {
      // Mostra tela de "sem dados"
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone ilustrativo
            Icon(Icons.cloud_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            // Mensagem de lista vazia
            Text(
              AppConstants.noBackupsMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Subtítulo
            Text(
              'Clique no + para criar um backup',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            // Botão de ação
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoNovoBackup(context),
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeiro Backup'),
            ),
          ],
        ),
      );
    }

    // Se chegou aqui, tem dados para mostrar
    // RefreshIndicator permite pull-to-refresh
    return RefreshIndicator(
      // Callback chamado ao puxar para baixo
      onRefresh: () => controller.refresh(),
      // Cor do spinner de refresh
      color: AppTheme.primaryColor,

      // Lista de backups
      child: _buildListaBackups(controller),
    );
  }

  /// Constrói a lista de backups com ListView.builder.
  ///
  /// ListView.builder é eficiente para listas grandes porque:
  /// - Cria apenas os widgets visíveis na tela
  /// - Reutiliza widgets que saem da viewport
  ///
  /// Parâmetros:
  /// - [controller]: Controller com lista de backups
  ///
  /// Retorna:
  /// - ListView com cards de backups
  Widget _buildListaBackups(BackupController controller) {
    return ListView.builder(
      // Padding nas bordas da lista
      padding: const EdgeInsets.all(16),
      // Quantidade de itens na lista
      itemCount: controller.backupCount,
      // Constrói cada item da lista
      itemBuilder: (context, index) {
        // Pega o backup do índice atual
        final backup = controller.backups[index];

        // Retorna o card do backup
        return _buildCardBackup(backup, context, controller);
      },
    );
  }

  /// Constrói um card individual para um backup.
  ///
  /// Este método cria um Card com todas as informações de um backup:
  /// - Nome e status
  /// - Tamanho e data
  /// - Usuário responsável
  /// - Ações (detalhes, remover)
  ///
  /// Parâmetros:
  /// - [backup]: Modelo do backup a ser exibido
  /// - [context]: Contexto do Flutter para navegação e temas
  /// - [controller]: Controller para ações
  ///
  /// Retorna:
  /// - Card widget com informações do backup
  Widget _buildCardBackup(
    BackupModel backup,
    BuildContext context,
    BackupController controller,
  ) {
    // Card com elevação e bordas arredondadas
    return Card(
      // Margem inferior para separar dos outros cards
      margin: const EdgeInsets.only(bottom: 12),
      // Elevação (sombra)
      elevation: 2,
      // Clique no card inteiro
      child: ListTile(
        // Ícone baseado no status
        leading: CircleAvatar(
          // Cor de fundo baseada no status
          backgroundColor: _getCorStatus(backup.status),
          // Ícone baseado no status
          child: Icon(
            Helpers.getIconForStatus(backup.status),
            color: Colors.white,
            size: 24,
          ),
        ),
        // Título: nome do backup
        title: Text(
          backup.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // Subtítulo: informações secundárias
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Tamanho do backup formatado
            Text(
              '📦 ${Helpers.formatFileSize(backup.sizeInBytes)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 2),
            // Data de criação formatada
            Text(
              '🕒 ${Helpers.formatDate(backup.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 2),
            // Usuário responsável
            Text(
              '👤 ${backup.userName}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        // Trailing: ações na direita
        trailing: PopupMenuButton<String>(
          // Ícone de três pontos
          icon: const Icon(Icons.more_vert),
          // Tooltip
          tooltip: 'Opções',
          // Callback quando seleciona opção
          onSelected: (value) =>
              _handleMenuAction(value, backup, controller, context),
          // Opções do menu
          itemBuilder: (context) => [
            // Opção: Ver detalhes
            const PopupMenuItem(
              value: 'detalhes',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver Detalhes'),
              ),
            ),
            // Opção: Remover
            const PopupMenuItem(
              value: 'remover',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remover', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        // Clique no card
        onTap: () => _handleMenuAction('detalhes', backup, controller, context),
      ),
    );
  }

  /// Retorna a cor apropriada para o status do backup.
  ///
  /// Parâmetros:
  /// - [status]: Status do backup ('success', 'error', 'warning', 'pending')
  ///
  /// Retorna:
  /// - Color do tema baseada no status
  Color _getCorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'concluído':
        return AppTheme.successColor;
      case 'error':
      case 'falha':
        return AppTheme.errorColor;
      case 'warning':
      case 'pendente':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }

  /// Mostra diálogo para criar novo backup.
  ///
  /// Este método exibe um AlertDialog com formulário para criar backup.
  ///
  /// Parâmetros:
  /// - [context]: Contexto para mostrar o diálogo
  void _mostrarDialogoNovoBackup(BuildContext context) {
    // Controladores de texto dos campos
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    // Mostra diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Título do diálogo
        title: const Text('Novo Backup'),
        // Conteúdo do diálogo
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de nome
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Backup',
                  hintText: 'Ex: Backup Banco de Dados',
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              // Campo de descrição
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Ex: Backup diário do sistema',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        // Ações do diálogo
        actions: [
          // Botão cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Botão criar
          ElevatedButton(
            onPressed: () async {
              // Fecha diálogo
              Navigator.pop(context);
              // Cria backup se nome não estiver vazio
              if (nomeController.text.isNotEmpty) {
                await _criarBackup(
                  nomeController.text,
                  descricaoController.text,
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  /// Cria um novo backup no banco de dados.
  ///
  /// Parâmetros:
  /// - [nome]: Nome do backup
  /// - [descricao]: Descrição opcional
  ///
  /// Este método:
  /// 1. Cria modelo BackupModel com dados
  /// 2. Chama controller para salvar
  /// 3. Mostra feedback para usuário
  Future<void> _criarBackup(String nome, String descricao) async {
    try {
      // Cria modelo com dados do formulário
      final backup = BackupModel(
        id: '', // Será gerado pelo banco
        name: nome,
        status: 'pending', // Começa como pendente
        sizeInBytes: 0, // Será atualizado após backup
        createdAt: DateTime.now(),
        userName: 'Usuário', // Em app real, viria da autenticação
        description: descricao.isNotEmpty ? descricao : null,
      );

      // Chama controller para criar
      await _controller.criarBackup(backup);

      // Mostra feedback de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Backup criado com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      // Mostra feedback de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar backup: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Gerencia ações do menu popup do card.
  ///
  /// Parâmetros:
  /// - [action]: Ação selecionada ('detalhes', 'remover')
  /// - [backup]: Backup em questão
  /// - [controller]: Controller para ações
  /// - [context]: Contexto para navegação e feedback
  void _handleMenuAction(
    String action,
    BackupModel backup,
    BackupController controller,
    BuildContext context,
  ) {
    switch (action) {
      case 'detalhes':
        // Navega para tela de detalhes (não implementada neste exemplo)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Detalhes de: ${backup.name}')));
        break;

      case 'remover':
        // Mostra confirmação antes de remover
        _confirmarRemocao(backup, controller, context);
        break;
    }
  }

  /// Mostra diálogo de confirmação para remover backup.
  ///
  /// Parâmetros:
  /// - [backup]: Backup a ser removido
  /// - [controller]: Controller para remover
  /// - [context]: Contexto para mostrar diálogo e feedback
  void _confirmarRemocao(
    BackupModel backup,
    BackupController controller,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Título de confirmação
        title: const Text('Remover Backup?'),
        // Mensagem de confirmação
        content: Text(
          'Tem certeza que deseja remover "${backup.name}"? Esta ação não pode ser desfeita.',
        ),
        // Ações
        actions: [
          // Botão cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Botão remover (vermelho)
          ElevatedButton(
            onPressed: () async {
              // Fecha diálogo
              Navigator.pop(context);
              try {
                // Remove backup
                await controller.removerBackup(backup.id);
                // Feedback de sucesso
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Backup removido com sucesso!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                // Feedback de erro
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
