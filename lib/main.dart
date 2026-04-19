import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/supabase_service.dart';
import 'views/splash/splash_view.dart';
import 'views/backups/backup_list_view.dart';

// ============================================================================
// PONTO DE ENTRADA DO APLICATIVO
// ============================================================================
// 
// Este arquivo é o primeiro código executado quando o app inicia.
// 
// Responsabilidades:
// 1. Inicializar bindings do Flutter (necessário para plugins antes do runApp)
// 2. Inicializar serviços globais (Supabase, autenticação, etc.)
// 3. Configurar provedores de estado (Provider)
// 4. Inicializar o MaterialApp com rotas e temas
// 
// IMPORTANTE: Este arquivo deve ser o mais limpo possível.
// Toda lógica deve ser delegada para controllers e services.
// ============================================================================

/// Função main - Ponto de entrada da aplicação.
/// 
/// Esta função é executada quando o app é iniciado.
/// 
/// Passos de inicialização:
/// 1. Garante que o Flutter está totalmente inicializado
/// 2. Inicializa o Supabase (banco de dados)
/// 3. Inicia o app com providers configurados
void main() async {
  // Garante que o Flutter está completamente inicializado
  // Necessário chamar antes de qualquer código assíncrono
  // que use plugins ou canais de plataforma
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Supabase (banco de dados e autenticação)
  // Isso deve ser feito antes de runApp() para garantir que
  // o cliente esteja pronto quando as telas forem carregadas
  try {
    await SupabaseService.instance.initialize();
    debugPrint('✅ Keeply: Supabase inicializado com sucesso!');
  } catch (e) {
    // Se falhar, loga o erro mas continua (app pode funcionar offline)
    debugPrint('❌ Keeply: Erro ao inicializar Supabase - $e');
  }
  
  // Inicia o aplicativo com providers configurados
  // MultiProvider permite usar múltiplos provedores de estado
  runApp(
    MultiProvider(
      // Lista de providers disponíveis em todo o app
      // Adicione novos providers aqui conforme necessário
      providers: [
        // Provider para BackupController
        // create: função que cria a instância do controller
        // dispose: função chamada quando o provider é descartado
        ChangeNotifierProvider(
          create: (_) => BackupController(),
          dispose: (_, controller) => controller.dispose(),
        ),
        // Adicione mais providers aqui:
        // ChangeNotifierProvider(create: (_) => AuthController()),
        // ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      // Widget filho (o app em si)
      child: const KeeplyApp(),
    ),
  );
}

// ============================================================================
// WIDGET PRINCIPAL DO APLICATIVO
// ============================================================================

/// [KeeplyApp] - Widget raiz do aplicativo Keeply Mobile.
/// 
/// Este widget configura o MaterialApp com:
/// - Tema visual (cores, tipografia, etc.)
/// - Rotas de navegação
/// - Configurações globais
/// 
/// É um StatelessWidget porque não gerencia estado interno.
/// Todas as mudanças de estado são feitas via Providers.
class KeeplyApp extends StatelessWidget {
  /// Construtor constante do KeeplyApp.
  /// 
  /// Usa const porque não recebe parâmetros externos,
  /// permitindo otimizações do Flutter.
  const KeeplyApp({super.key});

  /// Build do widget raiz.
  /// 
  /// Retorna o MaterialApp configurado com todas as rotas e temas.
  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget principal para apps Flutter
    // Ele gerencia navegação, temas, rotas e configurações globais
    return MaterialApp(
      // Título exibido no gerenciador de tarefas do dispositivo
      title: AppConstants.appName,
      
      // Debug mode: mostra informações de debug no canto da tela
      // Desabilitado em produção automaticamente
      debugShowCheckedModeBanner: false,
      
      // Tema do aplicativo (cores, tipografia, etc.)
      // Definido em AppTheme para centralizar configurações
      theme: AppTheme.lightTheme,
      
      // Rota inicial: primeira tela exibida ao abrir o app
      // Neste caso, a SplashView (tela de carregamento)
      initialRoute: AppConstants.routeSplash,
      
      // Definição de todas as rotas do aplicativo
      // Cada rota mapeia um nome de rota para um builder de widget
      routes: {
        // Rota da SplashView (tela inicial)
        AppConstants.routeSplash: (context) => const SplashView(),
        
        // Rota da LoginView (tela de login)
        // Em app real, você criaria este arquivo
        AppConstants.routeLogin: (context) => const LoginViewPlaceholder(),
        
        // Rota da BackupListView (listagem de backups)
        AppConstants.routeBackupList: (context) => const BackupListView(),
      },
      
      // Rota para páginas não encontradas (404)
      // Opcional, mas recomendado para melhor UX
      onGenerateRoute: (settings) {
        // Se a rota não existir, volta para a Splash
        return MaterialPageRoute(
          builder: (context) => const SplashView(),
        );
      },
    );
  }
}

// ============================================================================
// PLACEHOLDERS (Telas temporárias para exemplo)
// ============================================================================
// 
// Estas classes são temporárias para demonstrar o fluxo de navegação.
// Em um app real, você implementaria as telas completas.
// ============================================================================

/// [LoginViewPlaceholder] - Placeholder temporário para tela de Login.
/// 
/// Esta tela será substituída por uma implementação real de login
/// com autenticação via Supabase.
class LoginViewPlaceholder extends StatelessWidget {
  /// Construtor constante.
  const LoginViewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tela de Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Implementar autenticação com Supabase',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navega para lista de backups (simula login bem-sucedido)
                Navigator.pushReplacementNamed(
                  context,
                  AppConstants.routeBackupList,
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Entrar (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
          children: <Widget>[
            const Text(
              'Você apertou o botão tantas vezes:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
