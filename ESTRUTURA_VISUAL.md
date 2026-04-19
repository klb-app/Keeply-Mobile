# 📊 Estrutura Visual do Projeto - Keeply Mobile

## 🌳 Árvore Completa do Projeto

```
keeply_mobile/
│
├── 📱 lib/                              # Código Dart/Flutter
│   │
│   ├── main.dart                        ⭐ PONTO DE ENTRADA
│   ├── README.md                        📖 Documentação da arquitetura
│   ├── exemplos_uso.dart                💡 Exemplos de código
│   │
│   ├── 🏛️ core/                         # Núcleo do app
│   │   ├── config/
│   │   │   └── supabase_config.dart     🔑 Configuração Supabase
│   │   ├── themes/
│   │   │   └── app_theme.dart           🎨 Tema e cores
│   │   ├── constants/
│   │   │   └── app_constants.dart       📍 Constantes globais
│   │   └── utils/
│   │       └── helpers.dart             🛠️ Funções auxiliares
│   │
│   ├── 📦 models/                       # Modelos de dados
│   │   └── backup_model.dart            💾 Modelo Backup
│   │
│   ├── 🎮 controllers/                  # Controladores
│   │   └── backup_controller.dart       🎯 Lógica de negócio
│   │
│   ├── 🔌 services/                     # Serviços
│   │   ├── supabase_service.dart        ☁️ Serviço Supabase
│   │   └── backup_service.dart          🔄 Serviço Backups
│   │
│   └── 🖼️ views/                        # Telas (UI)
│       ├── splash/
│       │   └── splash_view.dart         ⏳ Tela Splash
│       └── backups/
│           └── backup_list_view.dart    📋 Lista de Backups
│
├── 🗄️ database/                         # Banco de dados
│   └── supabase_schema.sql              📝 Schema SQL
│
├── 📚 Documentação/
│   ├── README.md                        📘 Visão geral
│   ├── SUPABASE_SETUP.md                🔧 Guia Supabase
│   ├── ARQUITETURA_RESUMO.md            📊 Resumo arquitetura
│   ├── CHECKLIST_IMPLEMENTACAO.md       ✅ Checklist
│   ├── INICIO_RAPIDO.md                 🚀 Começo rápido
│   └── ESTRUTURA_VISUAL.md (este)       🌳 Esta árvore
│
├── ⚙️ Configuração/
│   ├── pubspec.yaml                     📦 Dependências
│   ├── analysis_options.yaml            🔍 Análise de código
│   └── .gitignore                       🚫 Arquivos ignorados
│
└── 📱 Plataformas/
    ├── android/                         🤖 Android
    ├── ios/                             🍎 iOS
    ├── web/                             🌐 Web
    ├── windows/                         🪟 Windows
    ├── linux/                           🐧 Linux
    └── macos/                           📱 macOS
```

## 🎯 Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                         USUÁRIO                              │
│                    (Interage com a UI)                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                          VIEW                                │
│                   (BackupListView.dart)                      │
│  • Exibe lista de backups                                    │
│  • Mostra loading/erro/vazio                                 │
│  • Captura cliques e gestos                                  │
│  • Delegada lógica para Controller                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ notifica
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       CONTROLLER                             │
│                (BackupController.dart)                       │
│  • Gerencia estado da tela                                   │
│  • Chama methods do Service                                  │
│  • Notifica View com notifyListeners()                       │
│  • Tratamento de erros                                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ usa
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICE                               │
│                 (BackupService.dart)                         │
│  • Operações CRUD no banco                                   │
│  • Conversão Model ↔ JSON                                    │
│  • Validações específicas                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ usa
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE SERVICE                          │
│               (SupabaseService.dart)                         │
│  • Conexão com banco de dados                                │
│  • Autenticação de usuários                                  │
│  • Queries SQL                                               │
│  • Realtime subscriptions                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ conecta
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      SUPABASE                                │
│                    (Banco de Dados)                          │
│  • Tabela: backups                                           │
│  • Tabela: profiles                                          │
│  • Auth: usuários                                            │
│  • Storage: arquivos                                         │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Ciclo de Vida de uma Requisição

```
1. USUÁRIO clica em "Carregar Backups"
   │
   ▼
2. VIEW (BackupListView) chama:
   controller.carregarBackups()
   │
   ▼
3. CONTROLLER (BackupController) define:
   _isLoading = true
   notifyListeners() → VIEW rebuilda (mostra loading)
   │
   ▼
4. CONTROLLER chama SERVICE:
   _backupService.getAllBackups()
   │
   ▼
5. SERVICE chama SUPABASE:
   _supabase.client.from('backups').select()
   │
   ▼
6. SUPABASE retorna dados do banco
   │
   ▼
7. SERVICE converte JSON → BackupModel
   │
   ▼
8. CONTROLLER recebe lista de BackupModel
   _backups = lista
   _isLoading = false
   notifyListeners() → VIEW rebuilda
   │
   ▼
9. VIEW mostra lista de backups na tela
```

## 📂 Mapeamento de Responsabilidades

### 🎨 Camada de Apresentação (UI)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `views/splash/splash_view.dart` | Tela de carregamento inicial |
| `views/backups/backup_list_view.dart` | Listagem de backups com CRUD |
| `core/themes/app_theme.dart` | Cores, tipografia, estilos |
| `core/constants/app_constants.dart` | Rotas, strings, configurações |

### 🧠 Camada de Lógica (Controladores)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `controllers/backup_controller.dart` | Gerencia estado de backups |

### 💼 Camada de Negócio (Models)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `models/backup_model.dart` | Estrutura de dados de backup |
| `core/utils/helpers.dart` | Funções auxiliares (formatar data, tamanho) |

### 🔌 Camada de Integração (Services)

| Arquivo | Responsabilidade |
|---------|-----------------|
| `services/supabase_service.dart` | Conexão com Supabase |
| `services/backup_service.dart` | Operações específicas de backups |

### ⚙️ Camada de Configuração

| Arquivo | Responsabilidade |
|---------|-----------------|
| `core/config/supabase_config.dart` | Credenciais do Supabase |
| `main.dart` | Inicialização do app |
| `pubspec.yaml` | Dependências do projeto |

## 🎯 Estado Atual vs Próximo Estado

### Estado Atual (✅ Implementado)

```
✅ main.dart limpo
✅ SplashView funcional
✅ LoginView (placeholder)
✅ BackupListView com CRUD
✅ BackupController com estado
✅ BackupService com operações
✅ SupabaseService configurado
✅ BackupModel com JSON
✅ Tema personalizado
✅ Helpers utilitários
✅ Constants globais
✅ Documentação completa
```

### Próximo Estado (🔜 A Implementar)

```
🔜 LoginView real com autenticação
🔜 BackupDetailView (detalhes do backup)
🔜 Editar backup existente
🔜 Upload de arquivos (Supabase Storage)
🔜 Filtros avançados (por data, status)
🔜 Busca de backups
🔜 Offline-first (cache local)
🔜 Testes unitários
🔜 Testes de widget
🔜 CI/CD pipeline
```

## 📊 Comparação: Antes vs Depois

### ❌ Antes (Código Original)

```dart
// main.dart fazia tudo
void main() {
  runApp(MaterialApp(home: MyHomePage()));
}

// Lógica misturada com UI
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  
  void _incrementCounter() {
    setState(() => _counter++);
  }
  
  // Tudo em um arquivo só...
}
```

### ✅ Depois (Arquitetura MVC)

```dart
// main.dart limpo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.initialize();
  runApp(
    MultiProvider(
      providers: [...],
      child: KeeplyApp(),
    ),
  );
}

// Separação clara de responsabilidades
// Model → Dados
// View → UI
// Controller → Lógica
// Service → Integração
```

## 🎨 Paleta de Cores do App

```
🔵 Primary:   #1976D2 (Azul corporativo)
🔵 Secondary: #42A5F5 (Azul claro)
🟢 Success:   #4CAF50 (Verde)
🟡 Warning:   #FF9800 (Laranja)
🔴 Error:     #F44336 (Vermelho)
⚪ Surface:   #FAFAFA (Branco gelo)
```

## 📱 Telas Implementadas

### 1️⃣ SplashView
```
┌─────────────────┐
│                 │
│    ☁️           │  ← Ícone (120px)
│                 │
│   Keeply        │  ← Nome (48px, bold)
│                 │
│ Gerenciamento   │  ← Slogan (18px)
│   Centralizado  │
│   de Backups    │
│                 │
│    ⏳           │  ← Loading spinner
│                 │
└─────────────────┘
```

### 2️⃣ LoginView (Placeholder)
```
┌─────────────────┐
│   ← Login       │  ← AppBar
├─────────────────┤
│                 │
│    🔒           │
│                 │
│  Tela de Login  │
│                 │
│ Implementar     │
│ autenticação    │
│ com Supabase    │
│                 │
│  [ Entrar ]     │  ← Botão demo
│    (Demo)       │
│                 │
└─────────────────┘
```

### 3️⃣ BackupListView
```
┌─────────────────┐
│   🔄  Backups   │  ← AppBar + refresh
├─────────────────┤
│                 │
│ ┌─────────────┐ │
│ │ ✅ Backup 1 │ │  ← Card (success)
│ │ 1.5 GB      │ │
│ │ 13/04/2026  │ │
│ │ João Silva  │ │
│ └─────────────┘ │
│                 │
│ ┌─────────────┐ │
│ │ ⚠️ Backup 2 │ │  ← Card (warning)
│ │ 5.0 GB      │ │
│ │ 13/04/2026  │ │
│ │ Maria S.    │ │
│ └─────────────┘ │
│                 │
│ ┌─────────────┐ │
│ │ ❌ Backup 3 │ │  ← Card (error)
│ │ 500 MB      │ │
│ │ 13/04/2026  │ │
│ │ Pedro O.    │ │
│ └─────────────┘ │
│                 │
│      [+]        │  ← FAB (novo backup)
└─────────────────┘
```

## 🔢 Números do Projeto

| Métrica | Valor |
|---------|-------|
| **Arquivos Dart** | 10 |
| **Linhas de Código** | ~2500+ |
| **Dependências** | 3 principais |
| **Telas** | 3 (Splash, Login, List) |
| **Controllers** | 1 (BackupController) |
| **Models** | 1 (BackupModel) |
| **Services** | 2 (Supabase, Backup) |
| **Arquivos de Doc** | 6 |

## 🎓 Como Estudar Esta Estrutura

### Ordem Recomendada

1. **Comece pelo main.dart**
   - Entenda a inicialização
   - Veja como os providers são configurados

2. **Estude o BackupModel**
   - Entenda a estrutura de dados
   - Veja fromJson/toJson

3. **Analise o BackupController**
   - Veja como gerencia estado
   - Entenda notifyListeners()

4. **Explore o BackupService**
   - Veja operações CRUD
   - Entenda conversão Model ↔ JSON

5. **Estude o SupabaseService**
   - Entenda conexão com banco
   - Veja autenticação

6. **Finalize com as Views**
   - Veja como usa Provider
   - Entenda Consumer

## 📞 Quick Reference

| Quero... | Arquivo para editar |
|----------|---------------------|
| Mudar cor do app | `core/themes/app_theme.dart` |
| Mudar tempo da splash | `core/constants/app_constants.dart` |
| Adicionar nova tela | `main.dart` (rotas) |
| Adicionar campo no backup | `models/backup_model.dart` |
| Mudar query do banco | `services/backup_service.dart` |
| Adicionar novo estado | `controllers/backup_controller.dart` |
| Mudar layout da lista | `views/backups/backup_list_view.dart` |

---

**Estrutura completa e organizada!** 🎉

Consulte este arquivo sempre que precisar entender onde cada coisa está!
