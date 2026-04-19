-- ============================================================================
-- SCHEMA DO BANCO DE DADOS - KEEPLY MOBILE
-- ============================================================================
-- 
-- Este arquivo contém o script SQL para criar as tabelas necessárias
-- no Supabase para o aplicativo Keeply Mobile.
-- 
-- Como usar:
-- 1. Acesse o Supabase SQL Editor: https://app.supabase.com/project/_/sql
-- 2. Copie este conteúdo e cole no editor
-- 3. Execute o script
-- 
-- Tabelas criadas:
-- - backups: Armazena todos os backups corporativos
-- - users: Perfis de usuário (extensão da auth do Supabase)
-- ============================================================================

-- ============================================================================
-- TABELA: BACKUPS
-- ============================================================================
-- 
-- Armazena informações sobre backups corporativos.
-- Cada registro representa um backup realizado por um usuário.
-- 
-- Colunas:
-- - id: UUID gerado automaticamente (primary key)
-- - name: Nome descritivo do backup
-- - status: Status atual (success, warning, error, pending)
-- - size: Tamanho em bytes
-- - created_at: Data de criação (timestamp com timezone)
-- - user_name: Nome do usuário que realizou o backup
-- - description: Descrição opcional
-- - storage_location: Caminho/local de armazenamento
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.backups (
  -- Identificador único (UUID v4 gerado automaticamente)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Nome do backup (obrigatório, máximo 255 caracteres)
  name VARCHAR(255) NOT NULL,
  
  -- Status do backup (obrigatório)
  -- Valores permitidos: 'success', 'warning', 'error', 'pending'
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  
  -- Tamanho do backup em bytes (obrigatório)
  size BIGINT NOT NULL DEFAULT 0,
  
  -- Data de criação (automático, com timezone)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Nome do usuário responsável (obrigatório)
  user_name VARCHAR(255) NOT NULL,
  
  -- Descrição opcional (texto longo)
  description TEXT,
  
  -- Localização de armazenamento (opcional)
  storage_location VARCHAR(500),
  
  -- Colunas de auditoria (opcionais, mas recomendadas)
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ, -- Soft delete (não remove permanentemente)
  
  -- Índice para busca por status (performance)
  CONSTRAINT valid_status CHECK (
    status IN ('success', 'warning', 'error', 'pending')
  )
);

-- ============================================================================
-- ÍNDICES (Performance)
-- ============================================================================
-- 
-- Índices melhoram a velocidade de consultas em colunas frequentemente
-- usadas em WHERE, ORDER BY, ou JOIN.
-- ============================================================================

-- Índice em status: útil para filtrar backups por status
CREATE INDEX IF NOT EXISTS idx_backups_status ON public.backups(status);

-- Índice em created_at: útil para ordenar por data (mais recentes primeiro)
CREATE INDEX IF NOT EXISTS idx_backups_created_at ON public.backups(created_at DESC);

-- Índice em user_name: útil para filtrar backups por usuário
CREATE INDEX IF NOT EXISTS idx_backups_user_name ON public.backups(user_name);

-- Índice composto (status + created_at): útil para queries combinadas
CREATE INDEX IF NOT EXISTS idx_backups_status_created ON public.backups(status, created_at DESC);

-- ============================================================================
-- TRIGGER: ATUALIZAR updated_at AUTOMATICAMENTE
-- ============================================================================
-- 
-- Este trigger atualiza o campo updated_at sempre que um registro é modificado.
-- Útil para auditoria e controle de versões.
-- ============================================================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger na tabela backups
CREATE TRIGGER update_backups_updated_at
  BEFORE UPDATE ON public.backups
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - SEGURANÇA
-- ============================================================================
-- 
-- RLS permite controlar quem pode acessar quais registros.
-- Isso é CRÍTICO para segurança dos dados!
-- 
-- Políticas criadas:
-- 1. SELECT: Usuários autenticados podem ver todos os backups
-- 2. INSERT: Usuários autenticados podem criar backups
-- 3. UPDATE: Usuários autenticados podem atualizar backups
-- 4. DELETE: Usuários autenticados podem remover backups
-- 
-- IMPORTANTE: Em produção, você deve criar políticas mais restritivas
-- baseadas no usuário (ex: cada usuário vê apenas seus próprios backups)
-- ============================================================================

-- Habilita RLS na tabela backups
ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;

-- Política: SELECT (ler backups)
-- Permite que usuários autenticados leiam todos os backups
CREATE POLICY "Usuários autenticados podem ver backups"
  ON public.backups
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: INSERT (criar backups)
-- Permite que usuários autenticados criem backups
CREATE POLICY "Usuários autenticados podem criar backups"
  ON public.backups
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Política: UPDATE (atualizar backups)
-- Permite que usuários autenticados atualizem backups
CREATE POLICY "Usuários autenticados podem atualizar backups"
  ON public.backups
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Política: DELETE (remover backups)
-- Permite que usuários autenticados removam backups
CREATE POLICY "Usuários autenticados podem remover backups"
  ON public.backups
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- TABELA: USER PROFILES (OPCIONAL)
-- ============================================================================
-- 
-- Estende a tabela de autenticação do Supabase com informações adicionais
-- dos usuários (perfil, avatar, preferências, etc.)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  -- ID vinculado ao auth.users do Supabase
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Nome completo do usuário
  full_name VARCHAR(255),
  
  -- URL do avatar/foto de perfil
  avatar_url VARCHAR(500),
  
  -- Cargo/função do usuário
  role VARCHAR(100) DEFAULT 'user',
  
  -- Data de criação do perfil
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Data da última atualização
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_profiles_full_name ON public.profiles(full_name);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- RLS para profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver todos os perfis
CREATE POLICY "Perfis são visíveis para usuários autenticados"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: Usuários podem atualizar próprio perfil
CREATE POLICY "Usuários podem atualizar próprio perfil"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- ============================================================================
-- DADOS DE EXEMPLO (SEED)
-- ============================================================================
-- 
-- Insere alguns backups de exemplo para testes e desenvolvimento.
-- Remova ou comente esta seção em produção!
-- ============================================================================

-- Insere backups de exemplo
INSERT INTO public.backups (name, status, size, user_name, description, storage_location)
VALUES
  (
    'Backup Banco de Dados Diário',
    'success',
    1073741824, -- 1 GB
    'João Silva',
    'Backup automático do banco de dados principal',
    's3://keeply-backups/db/daily/2026-04-13.sql'
  ),
  (
    'Backup Arquivos de Mídia',
    'success',
    5368709120, -- 5 GB
    'Maria Santos',
    'Backup de imagens e vídeos do sistema',
    's3://keeply-backups/media/2026-04-13.zip'
  ),
  (
    'Backup Configurações do Sistema',
    'warning',
    10485760, -- 10 MB
    'Pedro Oliveira',
    'Backup das configurações e parâmetros',
    's3://keeply-backups/config/2026-04-13.json'
  ),
  (
    'Backup Logs de Auditoria',
    'pending',
    524288000, -- 500 MB
    'Ana Costa',
    'Backup dos logs de auditoria do sistema',
    's3://keeply-backups/logs/2026-04-13.tar.gz'
  ),
  (
    'Backup Emergencial',
    'error',
    2147483648, -- 2 GB
    'Carlos Ferreira',
    'Backup emergencial após falha crítica',
    's3://keeply-backups/emergency/2026-04-13.sql'
  );

-- ============================================================================
-- FUNÇÕES ÚTEIS
-- ============================================================================
-- 
-- Funções auxiliares para operações comuns.
-- ============================================================================

-- Função: Contar backups por status
CREATE OR REPLACE FUNCTION public.count_backups_by_status()
RETURNS TABLE (
  status VARCHAR,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT b.status, COUNT(*)::BIGINT
  FROM public.backups b
  WHERE b.deleted_at IS NULL
  GROUP BY b.status;
END;
$$ LANGUAGE plpgsql;

-- Função: Buscar backups recentes (últimos N dias)
CREATE OR REPLACE FUNCTION public.get_recent_backups(days INTEGER DEFAULT 7)
RETURNS SETOF public.backups AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.backups
  WHERE created_at >= NOW() - (days || ' days')::INTERVAL
    AND deleted_at IS NULL
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMENTÁRIOS (Documentação no Banco)
-- ============================================================================
-- 
-- Adiciona comentários às tabelas e colunas para documentação.
-- Estes comentários aparecem em ferramentas de administração.
-- ============================================================================

COMMENT ON TABLE public.backups IS 'Armazena backups corporativos do sistema Keeply';
COMMENT ON COLUMN public.backups.id IS 'UUID único gerado automaticamente';
COMMENT ON COLUMN public.backups.name IS 'Nome descritivo do backup';
COMMENT ON COLUMN public.backups.status IS 'Status: success, warning, error, pending';
COMMENT ON COLUMN public.backups.size IS 'Tamanho em bytes';
COMMENT ON COLUMN public.backups.created_at IS 'Data de criação do backup';
COMMENT ON COLUMN public.backups.user_name IS 'Nome do usuário responsável';
COMMENT ON COLUMN public.backups.description IS 'Descrição opcional do backup';
COMMENT ON COLUMN public.backups.storage_location IS 'Caminho/local de armazenamento';
COMMENT ON COLUMN public.backups.deleted_at IS 'Data de remoção lógica (soft delete)';

COMMENT ON TABLE public.profiles IS 'Perfis de usuário estendidos (além da auth)';

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
-- 
-- Script executado com sucesso!
-- 
-- Próximos passos:
-- 1. Verifique se as tabelas foram criadas no Supabase Dashboard
-- 2. Teste as queries no SQL Editor
-- 3. Configure as políticas de RLS conforme necessário
-- 4. Em produção, remova os dados de exemplo (seed)
-- ============================================================================
