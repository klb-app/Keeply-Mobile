/// [AppConstants] - Classe para centralizar todas as constantes do aplicativo.
///
/// Esta classe contém constantes utilizadas em toda a aplicação, incluindo:
/// - Chaves de rotas para navegação
/// - Strings de UI (títulos, mensagens)
/// - Configurações de timeout e retry
///
/// Benefícios:
/// - Facilita a manutenção (mudar em um lugar só)
/// - Evita strings mágicas espalhadas pelo código
/// - Melhora a legibilidade do código
class AppConstants {
  // ==================== ROTAS ====================

  /// Rota da tela de Splash (tela inicial de carregamento)
  static const String routeSplash = '/splash';

  /// Rota da tela de Login
  static const String routeLogin = '/login';

  /// Rota da tela inicial de Backups
  static const String routeBackupList = '/backups';

  /// Rota para detalhes de um backup específico
  static const String routeBackupDetail = '/backup-detail';

  // ==================== STRINGS DE UI ====================

  /// Nome do aplicativo exibido em títulos e cabeçalhos
  static const String appName = 'Keeply';

  /// Slogan ou descrição curta do app
  static const String appSlogan = 'Gerenciamento Centralizado de Backups';

  /// Mensagem exibida quando não há backups cadastrados
  static const String noBackupsMessage = 'Nenhum backup encontrado';

  /// Mensagem de carregamento padrão
  static const String loadingMessage = 'Carregando...';

  // ==================== CONFIGURAÇÕES ====================

  /// Tempo de duração do Splash em milissegundos
  static const int splashDurationMillis = 2000;

  /// Timeout para chamadas de API em segundos
  static const int apiTimeoutSeconds = 30;

  /// Número máximo de tentativas para retry em caso de falha
  static const int maxRetryAttempts = 3;

  // ==================== CHAVES DE STORAGE ====================

  /// Chave para armazenar o token de autenticação
  static const String storageKeyToken = 'auth_token';

  /// Chave para armazenar dados do usuário logado
  static const String storageKeyUser = 'user_data';

  /// Chave para armazenar preferências do usuário
  static const String storageKeyPreferences = 'user_preferences';
}
