# 🚀 Início Rápido - Keeply Mobile

## ⚡ 3 Passos para Começar

### Passo 1: Configurar Supabase (5 minutos)

1. Acesse https://app.supabase.com
2. Selecione seu projeto existente
3. Vá em **Settings** → **API**
4. Copie as credenciais

### Passo 2: Atualizar Código (2 minutos)

Abra `lib/core/config/supabase_config.dart` e substitua:

```dart
// ❌ DE
static const String supabaseUrl = 'SUA_SUPABASE_URL_AQUI';
static const String supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY_AQUI';

// ✅ PARA
static const String supabaseUrl = 'https://seu-projeto.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### Passo 3: Rodar o App (1 minuto)

```bash
flutter run
```

---

## 📁 O que Você Tem Agora

### ✅ Arquitetura MVC Completa

```
✅ main.dart limpo e organizado
✅ SplashView com animação
✅ LoginView (placeholder demo)
✅ BackupListView com CRUD completo
✅ BackupController com gerenciamento de estado
✅ BackupService com operações de banco
✅ SupabaseService com autenticação
✅ BackupModel com serialização JSON
✅ AppTheme com cores e estilos
✅ Helpers com funções utilitárias
✅ Constants com rotas e configurações
```

### ✅ Funcionalidades Implementadas

```
✅ Listagem de backups
✅ Criar novo backup
✅ Atualizar backup
✅ Remover backup
✅ Pull-to-refresh
✅ Loading state
✅ Error state
✅ Empty state
✅ Cores por status (success, warning, error)
✅ Formatação de tamanho (KB, MB, GB)
✅ Formatação de data (DD/MM/YYYY HH:mm)
✅ Navegação entre telas
✅ Feedback visual (SnackBar)
✅ Confirmação para remover
✅ Popup menu com ações
```

### ✅ Documentação Completa

```
✅ README.md - Visão geral da arquitetura
✅ SUPABASE_SETUP.md - Guia do Supabase
✅ ARQUITETURA_RESUMO.md - Resumo completo
✅ CHECKLIST_IMPLEMENTACAO.md - Verificação
✅ exemplos_uso.dart - Exemplos de código
✅ database/supabase_schema.sql - Schema do banco
```

---

## 🎯 Como Usar Cada Parte

### View (BackupListView)

A View já está pronta! Ela:
- Mostra lista de backups
- Atualiza automaticamente quando dados mudam
- Mostra loading, erro ou vazio
- Permite criar, ver e remover backups

**Localização:** `lib/views/backups/backup_list_view.dart`

### Controller (BackupController)

O Controller gerencia todo o estado:
- `carregarBackups()` - Busca dados
- `criarBackup(backup)` - Cria novo
- `atualizarBackup(backup)` - Atualiza existente
- `removerBackup(id)` - Remove
- `refresh()` - Recarrega

**Localização:** `lib/controllers/backup_controller.dart`

### Service (BackupService)

O Service faz operações no banco:
- `getAllBackups()` - SELECT *
- `getBackupById(id)` - SELECT WHERE id
- `createBackup(backup)` - INSERT
- `updateBackup(backup)` - UPDATE
- `deleteBackup(id)` - DELETE

**Localização:** `lib/services/backup_service.dart`

---

## 🔧 Personalização

### Mudar Cores do Tema

Edite `lib/core/themes/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF1976D2);  // Sua cor
static const Color secondaryColor = Color(0xFF42A5F5); // Sua cor
```

### Mudar Tempo da Splash

Edite `lib/core/constants/app_constants.dart`:

```dart
static const int splashDurationMillis = 3000; // 3 segundos
```

### Adicionar Nova Rota

1. Adicione constante em `app_constants.dart`:
```dart
static const String routeDetalhes = '/detalhes';
```

2. Adicione rota no `main.dart`:
```dart
AppConstants.routeDetalhes: (context) => const DetalhesView(),
```

3. Navegue:
```dart
Navigator.pushNamed(context, AppConstants.routeDetalhes);
```

### Adicionar Novo Campo no Model

Edite `lib/models/backup_model.dart`:

```dart
class BackupModel {
  // ... campos existentes ...
  
  final String novoCampo; // Adicione aqui
  
  const BackupModel({
    // ... parâmetros existentes ...
    required this.novoCampo, // Adicione aqui
  });
  
  // Atualize fromJson e toJson
}
```

---

## 🐛 Debug

### Ver Logs do Supabase

No console, procure por:
```
✅ Keeply: Supabase inicializado com sucesso!
📡 BackupService: Buscando todos os backups...
📦 BackupService: 5 backups encontrados
```

### Verificar Erros

Se aparecer erro vermelho:
1. Leia a mensagem de erro
2. Verifique se credenciais do Supabase estão corretas
3. Verifique se tabela `backups` existe
4. Consulte `SUPABASE_SETUP.md`

### Testar sem Internet

O app mostra erro amigável se não tiver conexão:
```
❌ Erro ao carregar backups
[Botão] Tentar Novamente
```

---

## 📚 Próximos Passos

### Imediatos

1. ✅ Configurar credenciais do Supabase
2. ✅ Executar schema SQL no banco
3. ✅ Testar app com `flutter run`

### Curto Prazo

4. Implementar LoginView real
5. Criar BackupDetailView
6. Adicionar upload de arquivos

### Longo Prazo

7. Implementar offline-first
8. Adicionar testes unitários
9. Configurar CI/CD

---

## 💡 Dicas de Ouro

### 1. Sempre use o Controller

❌ Errado:
```dart
final service = BackupService();
final backups = await service.getAllBackups();
```

✅ Certo:
```dart
final controller = context.read<BackupController>();
await controller.carregarBackups();
```

### 2. Consumer rebuild automaticamente

```dart
Consumer<BackupController>(
  builder: (context, controller, _) {
    // Rebuilda quando notifyListeners() é chamado
    return Text('${controller.backupCount} backups');
  },
)
```

### 3. Feedback visual é importante

Sempre mostre SnackBar após ações:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Sucesso!')),
);
```

### 4. Tratamento de erro

Sempre use try-catch em operações assíncronas:
```dart
try {
  await controller.criarBackup(backup);
} catch (e) {
  // Mostra erro para usuário
}
```

---

## 🎉 Você Está Pronto!

Agora você tem:
- ✅ Arquitetura MVC profissional
- ✅ Código limpo e comentado
- ✅ Integração com Supabase
- ✅ CRUD completo de backups
- ✅ UI moderna e responsiva

**Bora codar!** 🚀

---

## 📞 Precisa de Ajuda?

Consulte estes arquivos:

| Dúvida | Arquivo |
|--------|---------|
| Como configurar Supabase? | `SUPABASE_SETUP.md` |
| Como usar cada componente? | `exemplos_uso.dart` |
| Qual a estrutura completa? | `ARQUITETURA_RESUMO.md` |
| O que já foi implementado? | `CHECKLIST_IMPLEMENTACAO.md` |
| Visão geral | `README.md` (na raiz e em lib/) |
