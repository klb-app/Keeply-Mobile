# 📖 Referência Rápida - Keeply Mobile

## 🚀 Comandos Úteis

### Instalar Dependências
```bash
flutter pub get
```

### Rodar o App
```bash
flutter run
```

### Rodar em Dispositivo Específico
```bash
flutter devices                    # Lista dispositivos
flutter run -d chrome              # Web
flutter run -d windows             # Windows
flutter run -d android-device-id   # Android
flutter run -d ios-device-id       # iOS
```

### Limpar Projeto
```bash
flutter clean
flutter pub get
flutter run
```

### Verificar Erros
```bash
flutter analyze
```

### Atualizar Dependências
```bash
flutter pub upgrade
flutter pub outdated
```

---

## 🔧 Atalhos de Configuração

### Mudar URL do Supabase
**Arquivo:** `lib/core/config/supabase_config.dart`
```dart
static const String supabaseUrl = 'https://SEU-PROJETO.supabase.co';
```

### Mudar Chave Anon
**Arquivo:** `lib/core/config/supabase_config.dart`
```dart
static const String supabaseAnonKey = 'SUA-CHAVE-AQUI';
```

### Mudar Tempo da Splash
**Arquivo:** `lib/core/constants/app_constants.dart`
```dart
static const int splashDurationMillis = 3000; // 3 segundos
```

### Mudar Cor Primária
**Arquivo:** `lib/core/themes/app_theme.dart`
```dart
static const Color primaryColor = Color(0xFF1976D2);
```

### Adicionar Nova Rota
**Arquivo:** `lib/main.dart`
```dart
// 1. Adicione constante em app_constants.dart
static const String routeNova = '/nova';

// 2. Adicione rota no main.dart
routes: {
  AppConstants.routeNova: (context) => const NovaView(),
}

// 3. Navegue
Navigator.pushNamed(context, AppConstants.routeNova);
```

---

## 💻 Snippets de Código

### Acessar Controller na View

#### Forma 1: Consumer (Recomendado)
```dart
Consumer<BackupController>(
  builder: (context, controller, child) {
    return Text('${controller.backupCount} backups');
  },
)
```

#### Forma 2: Provider.of
```dart
final controller = Provider.of<BackupController>(context);
```

#### Forma 3: context.watch
```dart
final controller = context.watch<BackupController>();
```

#### Forma 4: context.read (apenas para ações)
```dart
final controller = context.read<BackupController>();
await controller.carregarBackups();
```

### Chamar Método do Controller
```dart
try {
  final controller = context.read<BackupController>();
  await controller.criarBackup(backup);
  
  // Feedback de sucesso
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sucesso!')),
  );
} catch (e) {
  // Feedback de erro
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e')),
  );
}
```

### Criar Novo Backup
```dart
final backup = BackupModel(
  id: '', // Será gerado pelo banco
  name: 'Nome do Backup',
  status: 'pending',
  sizeInBytes: 1024,
  createdAt: DateTime.now(),
  userName: 'Nome do Usuário',
  description: 'Descrição opcional',
);

await controller.criarBackup(backup);
```

### Atualizar Backup
```dart
final backupAtualizado = backup.copyWith(
  status: 'success',
  sizeInBytes: 2048,
);

await controller.atualizarBackup(backupAtualizado);
```

### Remover Backup
```dart
await controller.removerBackup(backupId);
```

### Mostrar Diálogo
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Título'),
    content: const Text('Conteúdo'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: () {
          // Ação
          Navigator.pop(context);
        },
        child: const Text('Ação'),
      ),
    ],
  ),
);
```

### Mostrar SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Mensagem'),
    backgroundColor: Colors.green, // ou Colors.red para erro
    duration: const Duration(seconds: 2),
  ),
);
```

---

## 🎨 Cores do Tema

```dart
AppTheme.primaryColor      // 🔵 Azul principal
AppTheme.secondaryColor    // 🔵 Azul claro
AppTheme.successColor      // 🟢 Verde (sucesso)
AppTheme.warningColor      // 🟡 Laranja (atenção)
AppTheme.errorColor        // 🔴 Vermelho (erro)
AppTheme.surfaceLight      // ⚪ Branco (superfícies)
```

---

## 📍 Constantes Úteis

### Rotas
```dart
AppConstants.routeSplash       // '/splash'
AppConstants.routeLogin        // '/login'
AppConstants.routeBackupList   // '/backups'
```

### Strings
```dart
AppConstants.appName              // 'Keeply'
AppConstants.appSlogan            // 'Gerenciamento Centralizado de Backups'
AppConstants.noBackupsMessage     // 'Nenhum backup encontrado'
AppConstants.loadingMessage       // 'Carregando...'
```

### Configurações
```dart
AppConstants.splashDurationMillis    // 2000 (2 segundos)
AppConstants.apiTimeoutSeconds       // 30
AppConstants.maxRetryAttempts        // 3
```

---

## 🛠️ Helpers

### Formatar Data
```dart
final data = Helpers.formatDate(DateTime.now());
// Saída: "13/04/2026 14:30"
```

### Formatar Tamanho de Arquivo
```dart
final tamanho = Helpers.formatFileSize(1536);
// Saída: "1.5 KB"

Helpers.formatFileSize(1048576);  // "1 MB"
Helpers.formatFileSize(1073741824);  // "1 GB"
```

### Validar Email
```dart
final valido = Helpers.isValidEmail('teste@exemplo.com');
// true ou false
```

### Obter Ícone por Status
```dart
final icone = Helpers.getIconForStatus('success');
// Icons.check_circle_outline

Helpers.getIconForStatus('error');    // Icons.error_outline
Helpers.getIconForStatus('warning');  // Icons.warning_amber_outlined
```

---

## 🔄 Métodos do Controller

### BackupController

```dart
// Carregar todos os backups
await controller.carregarBackups();

// Criar novo backup
await controller.criarBackup(backup);

// Atualizar backup
await controller.atualizarBackup(backup);

// Remover backup
await controller.removerBackup(id);

// Recarregar (refresh)
await controller.refresh();

// Filtrar por status
final backupsErro = controller.filtrarPorStatus('error');

// Buscar por ID
final backup = controller.buscarBackupPorId(id);

// Estados
controller.isLoading      // true/false
controller.hasError       // true/false
controller.errorMessage   // String ou null
controller.isEmpty        // true/false
controller.backupCount    // int (quantidade)
controller.backups        // List<BackupModel>
```

---

## 📊 Métodos do Service

### BackupService

```dart
// CRUD
await backupService.getAllBackups();
await backupService.getBackupById(id);
await backupService.createBackup(backup);
await backupService.updateBackup(backup);
await backupService.deleteBackup(id);

// Filtros
await backupService.getBackupsByStatus('success');

// Contagem
final total = await backupService.countBackups();
```

### SupabaseService

```dart
// Inicialização
await supabaseService.initialize();

// Autenticação
await supabaseService.signInWithEmail(email: '...', password: '...');
await supabaseService.signUpWithEmail(email: '...', password: '...');
await supabaseService.signOut();

// Verificar auth
supabaseService.isAuthenticated  // true/false
supabaseService.currentUser      // User ou null

// Operações genéricas
await supabaseService.getAll(table: 'backups');
await supabaseService.getById(table: 'backups', id: '...');
await supabaseService.insert(table: 'backups', data: {...});
await supabaseService.update(table: 'backups', id: '...', data: {...});
await supabaseService.delete(table: 'backups', id: '...');

// Stream (realtime)
supabaseService.subscribeToTable(table: 'backups');
```

---

## 🎯 Estrutura do Model

### BackupModel

```dart
final backup = BackupModel(
  id: 'uuid-gerado-pelo-banco',
  name: 'Nome do Backup',
  status: 'success',  // 'success', 'warning', 'error', 'pending'
  sizeInBytes: 1048576,
  createdAt: DateTime.now(),
  userName: 'Nome do Usuário',
  description: 'Descrição opcional',
  storageLocation: 's3://bucket/backup.sql',
);

// Converter para JSON
final json = backup.toJson();

// Converter de JSON
final backup = BackupModel.fromJson(json);

// Copiar com modificações
final atualizado = backup.copyWith(status: 'success');
```

---

## 🐛 Debug

### Ver Logs

Procure no console:
```
✅ Keeply: Supabase inicializado com sucesso!
📡 BackupService: Buscando todos os backups...
📦 BackupService: 5 backups encontrados
✅ BackupController: 5 backups carregados
```

### Habilitar Debug Mode

No `main.dart`:
```dart
await Supabase.initialize(
  url: ...,
  anonKey: ...,
  debug: true,  // Habilita logs detalhados
);
```

### Verificar Erros Comuns

```dart
// Supabase não inicializado
// ❌ Erro: "SupabaseClient não inicializado"
// ✅ Solução: Configure credenciais no supabase_config.dart

// Tabela não existe
// ❌ Erro: "relation 'backups' does not exist"
// ✅ Solução: Execute o schema SQL no banco

// Permissão negada
// ❌ Erro: "permission denied for table backups"
// ✅ Solução: Configure RLS no Supabase

// Chave inválida
// ❌ Erro: "Invalid API key"
// ✅ Solução: Verifique se copiou a chave anon completa
```

---

## 📱 Estados da View

### Loading
```dart
if (controller.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Erro
```dart
if (controller.hasError) {
  return Center(
    child: Column(
      children: [
        const Icon(Icons.error, color: Colors.red),
        Text(controller.errorMessage ?? 'Erro'),
        ElevatedButton(
          onPressed: () => controller.carregarBackups(),
          child: const Text('Tentar Novamente'),
        ),
      ],
    ),
  );
}
```

### Vazio
```dart
if (controller.isEmpty) {
  return const Center(
    child: Text('Nenhum backup encontrado'),
  );
}
```

### Sucesso (com dados)
```dart
return ListView.builder(
  itemCount: controller.backups.length,
  itemBuilder: (context, index) {
    final backup = controller.backups[index];
    return Card(child: ListTile(title: Text(backup.name)));
  },
);
```

---

## 🎨 Widgets de UI

### Card de Backup
```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 2,
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: _getCorStatus(backup.status),
      child: Icon(Helpers.getIconForStatus(backup.status)),
    ),
    title: Text(backup.name),
    subtitle: Text(
      '📦 ${Helpers.formatFileSize(backup.sizeInBytes)}',
    ),
    trailing: PopupMenuButton(
      onSelected: (value) => _handleAction(value, backup),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'detalhes', child: Text('Ver Detalhes')),
        const PopupMenuItem(value: 'remover', child: Text('Remover')),
      ],
    ),
  ),
)
```

### Botão Flutuante (FAB)
```dart
FloatingActionButton(
  onPressed: () => _mostrarDialogoNovoBackup(context),
  child: const Icon(Icons.add),
  tooltip: 'Novo Backup',
)
```

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () => controller.refresh(),
  color: AppTheme.primaryColor,
  child: ListView(...),
)
```

---

## 📚 Links Úteis

| Recurso | URL |
|---------|-----|
| Supabase Dashboard | https://app.supabase.com |
| Documentação Supabase | https://supabase.com/docs |
| Flutter Docs | https://flutter.dev/docs |
| Provider Package | https://pub.dev/packages/provider |
| Material Design | https://material.io/design |

---

## 🎯 Checklist Rápido

Antes de rodar o app:

```
[ ] Credenciais do Supabase configuradas
[ ] Tabela backups existe no banco
[ ] RLS configurado no Supabase
[ ] Dependências instaladas (flutter pub get)
[ ] main.dart sem erros
[ ] Dispositivo/emulador conectado
```

---

**Guia de Referência Rápida - Keeply Mobile** 🚀

Salve este arquivo e consulte sempre que precisar!
