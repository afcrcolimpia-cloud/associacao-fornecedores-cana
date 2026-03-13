-- ============================================================
-- 005_tratos_culturais_add_campos.pgsql
-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.
-- Adiciona colunas desnormalizadas e índice em tratos_culturais
-- AFCRC Catanduva · 2026
-- ============================================================

-- 1. Adicionar colunas se não existirem
ALTER TABLE public.tratos_culturais 
ADD COLUMN IF NOT EXISTS oxido_de_calcio NUMERIC(10,2);

ALTER TABLE public.tratos_culturais 
ADD COLUMN IF NOT EXISTS talhao_numero VARCHAR(10);

ALTER TABLE public.tratos_culturais 
ADD COLUMN IF NOT EXISTS variedade_nome VARCHAR(100);

ALTER TABLE public.tratos_culturais 
ADD COLUMN IF NOT EXISTS area_ha_talhao NUMERIC(10,2);

-- 2. Índices para performance
CREATE INDEX IF NOT EXISTS idx_tratos_oxido_de_calcio 
ON public.tratos_culturais(oxido_de_calcio);

CREATE INDEX IF NOT EXISTS idx_tratos_talhao_numero 
ON public.tratos_culturais(talhao_numero);

CREATE INDEX IF NOT EXISTS idx_tratos_variedade_nome 
ON public.tratos_culturais(variedade_nome);

CREATE INDEX IF NOT EXISTS idx_tratos_area_ha_talhao 
ON public.tratos_culturais(area_ha_talhao);

-- 3. Recarregar cache do PostgREST/Supabase
NOTIFY pgrst, 'reload schema';
