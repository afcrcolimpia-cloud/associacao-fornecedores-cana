-- 007_monitoramento_pragas.pgsql
-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.
-- Tabela para registro de monitoramento/levantamento de pragas em talhões.

-- ════════════════════════════════════════════════════════════════
-- 1. Criar tabela monitoramento_pragas
-- ════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.monitoramento_pragas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  talhao_id UUID NOT NULL REFERENCES public.talhoes(id) ON DELETE CASCADE,
  safra_id UUID REFERENCES public.safras(id) ON DELETE SET NULL,
  praga VARCHAR(100) NOT NULL,
  nivel_infestacao VARCHAR(20) NOT NULL
    CHECK (nivel_infestacao IN ('baixo', 'medio', 'alto', 'critico')),
  data_monitoramento DATE NOT NULL DEFAULT CURRENT_DATE,
  area_afetada_ha NUMERIC(10,2),
  metodo_avaliacao VARCHAR(100),
  acao_recomendada TEXT,
  acao_realizada TEXT,
  insumo_utilizado VARCHAR(200),
  dose_aplicada NUMERIC(10,3),
  unidade_dose VARCHAR(20),
  responsavel VARCHAR(150),
  observacoes TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════════════════════════════
-- 2. Índices
-- ════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_monitoramento_pragas_talhao
  ON public.monitoramento_pragas(talhao_id);

CREATE INDEX IF NOT EXISTS idx_monitoramento_pragas_safra
  ON public.monitoramento_pragas(safra_id);

CREATE INDEX IF NOT EXISTS idx_monitoramento_pragas_praga
  ON public.monitoramento_pragas(praga);

CREATE INDEX IF NOT EXISTS idx_monitoramento_pragas_data
  ON public.monitoramento_pragas(data_monitoramento);

-- ════════════════════════════════════════════════════════════════
-- 3. RLS (Row Level Security)
-- ════════════════════════════════════════════════════════════════

ALTER TABLE public.monitoramento_pragas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "monitoramento_pragas_select" ON public.monitoramento_pragas;
CREATE POLICY "monitoramento_pragas_select"
  ON public.monitoramento_pragas FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "monitoramento_pragas_insert" ON public.monitoramento_pragas;
CREATE POLICY "monitoramento_pragas_insert"
  ON public.monitoramento_pragas FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "monitoramento_pragas_update" ON public.monitoramento_pragas;
CREATE POLICY "monitoramento_pragas_update"
  ON public.monitoramento_pragas FOR UPDATE
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "monitoramento_pragas_delete" ON public.monitoramento_pragas;
CREATE POLICY "monitoramento_pragas_delete"
  ON public.monitoramento_pragas FOR DELETE
  TO authenticated
  USING (true);

-- ════════════════════════════════════════════════════════════════
-- 4. Trigger para atualizar atualizado_em
-- ════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.update_monitoramento_pragas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_monitoramento_pragas_updated_at ON public.monitoramento_pragas;
CREATE TRIGGER trg_monitoramento_pragas_updated_at
  BEFORE UPDATE ON public.monitoramento_pragas
  FOR EACH ROW
  EXECUTE FUNCTION public.update_monitoramento_pragas_updated_at();
