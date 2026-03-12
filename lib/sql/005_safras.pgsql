-- 005_safras.pgsql
-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.
-- Cria tabela de safras para contexto temporal do sistema AFCRC.
-- Safra = ciclo agrícola (ex: "2025/26" → abr/2025 a mar/2026)

-- ════════════════════════════════════════════════════════════════
-- 1. Tabela principal
-- ════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.safras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proprietario_id UUID NOT NULL REFERENCES public.proprietarios(id) ON DELETE CASCADE,

    safra VARCHAR(10) NOT NULL,            -- "2025/26"
    data_inicio DATE NOT NULL,             -- 01/04/2025
    data_fim DATE NOT NULL,                -- 31/03/2026
    status VARCHAR(20) DEFAULT 'ativa',    -- "ativa", "finalizada", "planejada"

    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ════════════════════════════════════════════════════════════════
-- 2. Índices
-- ════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_safras_proprietario ON public.safras(proprietario_id);
CREATE INDEX IF NOT EXISTS idx_safras_status ON public.safras(status);

-- ════════════════════════════════════════════════════════════════
-- 3. Constraint UNIQUE (proprietário + safra) — idempotente
-- ════════════════════════════════════════════════════════════════
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'safras_proprietario_safra_unique'
  ) THEN
    ALTER TABLE public.safras
      ADD CONSTRAINT safras_proprietario_safra_unique UNIQUE (proprietario_id, safra);
  END IF;
END $$;

-- ════════════════════════════════════════════════════════════════
-- 4. Constraint CHECK status válido — idempotente
-- ════════════════════════════════════════════════════════════════
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'safras_status_valido'
  ) THEN
    ALTER TABLE public.safras
      ADD CONSTRAINT safras_status_valido
      CHECK (status IN ('ativa', 'finalizada', 'planejada'));
  END IF;
END $$;

-- ════════════════════════════════════════════════════════════════
-- 5. Constraint CHECK data_fim > data_inicio — idempotente
-- ════════════════════════════════════════════════════════════════
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'safras_datas_validas'
  ) THEN
    ALTER TABLE public.safras
      ADD CONSTRAINT safras_datas_validas CHECK (data_fim > data_inicio);
  END IF;
END $$;

-- ════════════════════════════════════════════════════════════════
-- 6. RLS — Row Level Security
-- ════════════════════════════════════════════════════════════════
ALTER TABLE public.safras ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS safras_rls ON public.safras;
CREATE POLICY safras_rls ON public.safras FOR ALL
    USING (auth.uid() IS NOT NULL);
