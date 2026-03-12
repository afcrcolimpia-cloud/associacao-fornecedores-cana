-- 006_safra_id_tabelas_operacionais.pgsql
-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.
-- Adiciona coluna safra_id (nullable) às tabelas operacionais existentes.
-- Permite vincular registros a uma safra específica, mantendo compatibilidade
-- com dados antigos que não possuem safra associada.

-- ════════════════════════════════════════════════════════════════
-- 1. Adicionar safra_id nas tabelas operacionais
-- ════════════════════════════════════════════════════════════════

ALTER TABLE public.operacoes_cultivo
  ADD COLUMN IF NOT EXISTS safra_id UUID REFERENCES public.safras(id) ON DELETE SET NULL;

ALTER TABLE public.tratos_culturais
  ADD COLUMN IF NOT EXISTS safra_id UUID REFERENCES public.safras(id) ON DELETE SET NULL;

ALTER TABLE public.produtividade
  ADD COLUMN IF NOT EXISTS safra_id UUID REFERENCES public.safras(id) ON DELETE SET NULL;

ALTER TABLE public.precipitacao
  ADD COLUMN IF NOT EXISTS safra_id UUID REFERENCES public.safras(id) ON DELETE SET NULL;

-- ════════════════════════════════════════════════════════════════
-- 2. Índices para consultas por safra
-- ════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_operacoes_cultivo_safra
  ON public.operacoes_cultivo(safra_id);

CREATE INDEX IF NOT EXISTS idx_tratos_culturais_safra
  ON public.tratos_culturais(safra_id);

CREATE INDEX IF NOT EXISTS idx_produtividade_safra
  ON public.produtividade(safra_id);

CREATE INDEX IF NOT EXISTS idx_precipitacao_safra
  ON public.precipitacao(safra_id);
