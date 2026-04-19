# 🔧 Configuração do Supabase - Keeply Mobile

## 📋 Passo a Passo para Configurar

### 1️⃣ Acesse seu Projeto Supabase Existente

1. Acesse **https://app.supabase.com**
2. Faça login com suas credenciais
3. Selecione o projeto existente que você vai usar

### 2️⃣ Obtenha as Credenciais

No painel do seu projeto:

1. Clique em **⚙️ Settings** (menu lateral esquerdo)
2. Clique em **API**
3. Copie as seguintes informações:

   ```
   Project URL: https://xxxxx.supabase.co
   anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

### 3️⃣ Atualize o Arquivo de Configuração

Abra o arquivo `lib/core/config/supabase_config.dart` e substitua:

```dart
class SupabaseConfig {
  // ❌ ANTES (placeholder)
  static const String supabaseUrl = 'SUA_SUPABASE_URL_AQUI';
  static const String supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY_AQUI';
  
  // ✅ DEPOIS (suas credenciais reais)
  static const String supabaseUrl = 'https://seu-projeto.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### 4️⃣ Verifique as Tabelas no seu Banco

O app espera que existam as seguintes tabelas:

#### Tabela: `backups`

| Coluna | Tipo | Obrigatório | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | ✅ | Primary key (gerada automaticamente) |
| `name` | VARCHAR(255) | ✅ | Nome do backup |
| `status` | VARCHAR(50) | ✅ | `success`, `warning`, `error`, `pending` |
| `size` | BIGINT | ✅ | Tamanho em bytes |
| `created_at` | TIMESTAMPTZ | ✅ | Data de criação |
| `user_name` | VARCHAR(255) | ✅ | Nome do usuário |
| `description` | TEXT | ❌ | Descrição opcional |
| `storage_location` | VARCHAR(500) | ❌ | Local de armazenamento |

#### Script SQL para criar a tabela (se necessário):

```sql
CREATE TABLE IF NOT EXISTS public.backups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  size BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_name VARCHAR(255) NOT NULL,
  description TEXT,
  storage_location VARCHAR(500),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  
  CONSTRAINT valid_status CHECK (
    status IN ('success', 'warning', 'error', 'pending')
  )
);

-- Índices para performance
CREATE INDEX idx_backups_status ON public.backups(status);
CREATE INDEX idx_backups_created_at ON public.backups(created_at DESC);
CREATE INDEX idx_backups_user_name ON public.backups(user_name);
```

### 5️⃣ Teste a Conexão

Execute o app e verifique no console:

```
✅ Keeply: Supabase inicializado com sucesso!
```

Se aparecer erro, verifique:

- [ ] URL está correta (incluindo `https://`)
- [ ] Chave anon está completa (copia tudo!)
- [ ] Projeto está ativo no Supabase
- [ ] Tabelas existem no banco

### 6️⃣ Habilitar Row Level Security (RLS)

No Supabase SQL Editor, execute:

```sql
-- Habilita RLS
ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;

-- Permite que usuários autenticados acessem
CREATE POLICY "Usuários autenticados podem ver backups"
  ON public.backups
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários autenticados podem criar backups"
  ON public.backups
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem atualizar backups"
  ON public.backups
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem remover backups"
  ON public.backups
  FOR DELETE
  TO authenticated
  USING (true);
```

### 7️⃣ Teste com Dados de Exemplo (Opcional)

Para testar o app com dados:

```sql
INSERT INTO public.backups (name, status, size, user_name, description)
VALUES
  ('Backup Banco de Dados', 'success', 1073741824, 'João Silva', 'Backup diário'),
  ('Backup Arquivos', 'pending', 5368709120, 'Maria Santos', 'Backup de mídia'),
  ('Backup Configurações', 'error', 10485760, 'Pedro Oliveira', 'Erro na execução');
```

## 🚨 Problemas Comuns

### Erro: "SupabaseClient não inicializado"

**Causa:** As credenciais não foram configuradas corretamente.

**Solução:** Verifique se substituiu os placeholders no `supabase_config.dart`.

### Erro: "relation 'backups' does not exist"

**Causa:** A tabela não existe no seu banco.

**Solução:** Execute o script SQL para criar a tabela.

### Erro: "JWT expired" ou "Invalid API key"

**Causa:** Chave anon incorreta ou expirada.

**Solução:** Gere uma nova chave em Settings > API e atualize no app.

### Erro: "permission denied for table backups"

**Causa:** RLS está bloqueando o acesso.

**Solução:** Configure as políticas de RLS conforme mostrado acima.

## 📚 Links Úteis

- **Dashboard Supabase:** https://app.supabase.com
- **Documentação Supabase:** https://supabase.com/docs
- **Docs Flutter:** https://supabase.com/docs/guides/getting-started/quickstarts/flutter

## ✅ Checklist de Configuração

- [ ] Copiou URL do projeto
- [ ] Copiou chave anon
- [ ] Atualizou `supabase_config.dart`
- [ ] Criou tabela `backups` no banco
- [ ] Configurou políticas de RLS
- [ ] Testou conexão (verificou logs no console)
- [ ] Inseriu dados de exemplo (opcional)

---

**Pronto!** Agora seu app está conectado ao Supabase existente! 🎉
