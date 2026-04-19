/// [SupabaseConfig] - Configuração do cliente Supabase para o aplicativo Keeply.
///
/// Esta classe contém as credenciais e configurações necessárias para conectar
/// ao Supabase. Os dados sensíveis (URL e Anon Key) devem ser obtidos do painel
/// do Supabase em: https://app.supabase.com/project/_/settings/api
///
/// COMO OBTER AS CREDENCIAIS:
/// 1. Acesse https://app.supabase.com e faça login
/// 2. Selecione seu projeto existente na lista
/// 3. Clique em "Settings" (engrenagem no menu lateral)
/// 4. Clique em "API"
/// 5. Copie:
///    - Project URL (URL do projeto)
///    - anon/public key (chave pública)
///
/// IMPORTANTE: Para maior segurança em produção, considere usar:
/// - dart_dotenv para carregar variáveis de ambiente
/// - flutter_dotenv para arquivos .env
/// - Code generation com build_runner
///
/// Exemplo de uso:
/// ```dart
/// await SupabaseConfig.initialize();
/// final client = SupabaseConfig.client;
/// ```
class SupabaseConfig {
  /// URL do projeto Supabase
  ///
  /// Obtida em: Settings > API > Project URL
  /// Exemplo: 'https://xyzcompany.supabase.co'
  ///
  /// TODO: Substitua pelo URL do seu projeto Supabase existente!
  static const String supabaseUrl = 'SUA_SUPABASE_URL_AQUI';

  /// Chave Anon (pública) do projeto Supabase
  ///
  /// Obtida em: Settings > API > anon/public key
  /// Esta chave é segura para uso no client-side
  ///
  /// TODO: Substitua pela chave anon do seu projeto Supabase existente!
  ///
  /// Exemplo no main.dart:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await SupabaseConfig.initialize();
  ///   runApp(...);
  /// }
  /// ```
  static Future<void> initialize() async {
    // A inicialização real será feita pelo SupabaseService
    // Este método é um placeholder para futura expansão
  }

  /// Valida se as credenciais do Supabase foram configuradas corretamente.
  ///
  /// Retorna true se as credenciais forem diferentes dos placeholders.
  /// Use este método para verificar se a configuração está completa.
  static bool isConfigured() {
    return supabaseUrl != 'SUA_SUPABASE_URL_AQUI' &&
        supabaseAnonKey != 'SUA_SUPABASE_ANON_KEY_AQUI';
  }

  /// Retorna uma mensagem de erro se as credenciais não estiverem configuradas.
  ///
  /// Retorna null se estiver tudo configurado corretamente.
  static String? getConfigurationError() {
    if (supabaseUrl == 'SUA_SUPABASE_URL_AQUI') {
      return 'URL do Supabase não configurada. Atualize em lib/core/config/supabase_config.dart';
    }
    if (supabaseAnonKey == 'SUA_SUPABASE_ANON_KEY_AQUI') {
      return 'Anon Key do Supabase não configurada. Atualize em lib/core/config/supabase_config.dart';
    }
    return null;
  }
}
