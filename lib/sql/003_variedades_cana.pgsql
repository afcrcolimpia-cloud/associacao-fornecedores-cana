-- 003_variedades_cana.pgsql
-- Migration: Atualizar tabela variedades com novos campos e seed de 54 variedades
-- Fonte: Tabela de Variedades 2024 — AFCRC Catanduva
-- NOTA: Todas as operações são seguras (idempotentes). Pode executar mais de uma vez sem risco.

-- =============================================
-- 1. Atualizar estrutura da tabela variedades
-- =============================================

-- Adicionar colunas novas (IF NOT EXISTS = seguro para re-execução)
ALTER TABLE variedades ADD COLUMN IF NOT EXISTS instituicao text DEFAULT '';
ALTER TABLE variedades ADD COLUMN IF NOT EXISTS destaque text DEFAULT '';
ALTER TABLE variedades ADD COLUMN IF NOT EXISTS epoca_colheita text DEFAULT '';

-- Migrar dados da coluna antiga 'caracteristicas' para 'destaque' (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'variedades' AND column_name = 'caracteristicas'
  ) THEN
    UPDATE variedades SET destaque = caracteristicas
    WHERE caracteristicas IS NOT NULL AND (destaque IS NULL OR destaque = '');
  END IF;
END $$;

-- Remover colunas antigas (IF EXISTS = seguro)
ALTER TABLE variedades DROP COLUMN IF EXISTS caracteristicas;
ALTER TABLE variedades DROP COLUMN IF EXISTS meses_colheita;

-- Remover CHECK constraints que restringem ambiente_producao a valor único
-- (constraint pode ter sido criada manualmente com typos no nome)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'variedades'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%ambiente_produc%'
  LOOP
    EXECUTE format('ALTER TABLE variedades DROP CONSTRAINT IF EXISTS %I', r.conname);
  END LOOP;
END $$;

-- =============================================
-- 2. Seed: 54 variedades oficiais AFCRC 2024
-- Usa INSERT ... ON CONFLICT para não duplicar
-- =============================================

-- Criar constraint única no codigo (se não existir) para ON CONFLICT funcionar
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'variedades_codigo_unique'
  ) THEN
    ALTER TABLE variedades ADD CONSTRAINT variedades_codigo_unique UNIQUE (codigo);
  END IF;
END $$;

INSERT INTO variedades (codigo, nome, instituicao, destaque, ambiente_producao, epoca_colheita, ativa)
VALUES
  ('SP80-1842', 'SP80-1842', 'SP', 'Soqueira', 'B C', 'Jun Jul Ago Set', true),
  ('SP87-365', 'SP87-365', 'SP', 'Rica, produtividade', 'A B C', 'Jul Ago Set', true),
  ('SP83-5073', 'SP83-5073', 'SP', 'Alto teor de sacarose', 'A B', 'Abr Mai Jun Jul', true),
  ('CTC2', 'CTC2', 'CTC', 'Soqueira, rusticidade', 'A B C', 'Jun Jul Ago Set', true),
  ('CTC4', 'CTC4', 'CTC', 'Rica, produtividade', 'A B C', 'Jun Jul Ago Set', true),
  ('CTC20', 'CTC20', 'CTC', 'Perfilhamento, colheita mecanizada', 'A B C D E', 'Mai Jun Jul Ago Out', true),
  ('CTC9001', 'CTC9001', 'CTC', 'Rusticidade, PUI longo', 'A B C D', 'Abr Mai Jun Jul Ago Out', true),
  ('CTC9002', 'CTC9002', 'CTC', 'Crescimento rápido, porte ereto', 'C D', 'Jul Ago Set Out Nov', true),
  ('CTC9003', 'CTC9003', 'CTC', 'Produtividade, perfilhamento', 'A B C D', 'Mai Jun Jul Ago Set', true),
  ('CTC9005HP', 'CTC9005HP', 'CTC', 'Precocidade, ATR elevado', 'A B C', 'Abr Mai Jun', true),
  ('CTC9006', 'CTC9006', 'CTC', 'Alto TCH, rusticidade', 'B C D', 'Jun Jul Ago Set', true),
  ('CTC9007', 'CTC9007', 'CTC', 'Rusticidade', 'A B C', 'Abr Mai Jun Jul Ago', true),
  ('CTC9008', 'CTC9008', 'CTC', 'Produtividade, perfilhamento', 'C D', 'Mai Jun Jul Ago Set', true),
  ('CTC9009', 'CTC9009', 'CTC', 'ATR elevado, produtividade', 'A B C', 'Abr Mai Jun Jul Ago', true),
  ('CTC3445', 'CTC3445', 'CTC', 'Produtividade, rusticidade', 'C D E', 'Jun Jul Ago Set Out', true),
  ('CT02-2994', 'CT02-2994', 'CT', 'Tolerância à seca', 'A B C E', 'Ago Set Out', true),
  ('CT96-1007', 'CT96-1007', 'CT', 'TCH elevado', 'D E', 'Jun Jul Ago Set', true),
  ('IACCTC07-2361', 'IACCTC07-2361', 'IAC', 'TCH elevado', 'A B C D', 'Jun Jul Ago Set', true),
  ('IACSP95-5094', 'IACSP95-5094', 'IAC', 'Produtividade, brotação', 'A B C', 'Mai Jun Jul Ago Set', true),
  ('IACSP04-6007', 'IACSP04-6007', 'IAC', 'Crescimento rápido', 'B C D', 'Jun Jul Ago', true),
  ('IACSP015503', 'IACSP015503', 'IAC', 'Produtividade, mecanizada', 'B C D', 'Abr Mai Jun Jul Ago Set', true),
  ('IACSP974039', 'IACSP974039', 'IAC', 'Perfilhamento', 'C D', 'Abr Mai Jun Jul Ago', true),
  ('IACCTC07-7207', 'IACCTC07-7207', 'IAC', 'Alta produtividade', 'A B C', 'Jun Jul Ago Set', true),
  ('IACCT078008', 'IACCT078008', 'IAC', 'Longevidade', 'A B C', 'Jun Jul Ago Set', true),
  ('IACCT07-8044', 'IACCT07-8044', 'IAC', 'Alto teor de sacarose', 'A B C', 'Abr Mai Jun Jul Ago Set', true),
  ('RB92-579', 'RB92-579', 'RB', 'Responsiva à irrigação', 'A B C', 'Jul Ago Set Out Nov', true),
  ('RB00-5014', 'RB00-5014', 'RB', 'Produtividade', 'A B C', 'Jul Ago Set Out', true),
  ('RB97-5033', 'RB97-5033', 'RB', 'Precocidade, tolerância à seca', 'A B C D', 'Abr Mai Jun Jul', true),
  ('RB06-5084', 'RB06-5084', 'RB', 'Riqueza e produtividade', 'A B', 'Jul Ago Set Out Nov', true),
  ('RB03-5151', 'RB03-5151', 'RB', 'Produtividade, rusticidade', 'B C D E', 'Jun Jul Ago Set Out', true),
  ('RB85-5156', 'RB85-5156', 'RB', 'Precocidade', 'B C D', 'Abr Mai', true),
  ('RB01-5177', 'RB01-5177', 'RB', 'Produtiva, rica', 'A B C', 'Jun Jul Ago Set', true),
  ('RB97-5201', 'RB97-5201', 'RB', 'Produtividade, sanidade', 'A B C D', 'Jul Ago Set Out Nov', true),
  ('RB97-5242', 'RB97-5242', 'RB', 'Rusticidade', 'C D', 'Ago Set Out Nov', true),
  ('RB07-5253', 'RB07-5253', 'RB', 'Produtiva', 'A B C', 'Mai Jul Ago Set Out', true),
  ('RB01-5279', 'RB01-5279', 'RB', 'Tolerância à seca', 'B C D E', 'Abr Mai Jun Jul Ago', true),
  ('RB07-5322', 'RB07-5322', 'RB', 'Boa performance', 'C D E', 'Jul Ago Set Out', true),
  ('RB97-5375', 'RB97-5375', 'RB', 'Rica, perfilhamento', 'C D', 'Mai Jun Jul Ago', true),
  ('RB85-5453', 'RB85-5453', 'RB', 'Rica, precoce', 'A B C', 'Mai Jun Jul', true),
  ('RB98-5476', 'RB98-5476', 'RB', 'Brotação', 'A B C', 'Jul Ago Set', true),
  ('RB85-5536', 'RB85-5536', 'RB', 'Soqueira', 'A B', 'Jul Ago Set Out', true),
  ('RB04-5836', 'RB04-5836', 'RB', 'Riqueza, brotação', 'A B', 'Abr Mai Jun', true),
  ('RB96-5902', 'RB96-5902', 'RB', 'Bom teor de sacarose', 'B C D', 'Jun Jul Ago Set', true),
  ('RB01-5935', 'RB01-5935', 'RB', 'Precoce', 'A B C', 'Mai Jun Jul Ago', true),
  ('RB97-5952', 'RB97-5952', 'RB', 'Precoce, rica', 'A B C', 'Abr Mai Jun Jul', true),
  ('RB03-6152', 'RB03-6152', 'RB', 'Tardia', 'A B C', 'Set Out Nov', true),
  ('RB96-6928', 'RB96-6928', 'RB', 'Precoce', 'A B C', 'Abr Mai Jun', true),
  ('RB86-7515', 'RB86-7515', 'RB', 'Produtiva', 'C D E', 'Jul Ago Set Out', true),
  ('RB12-7825', 'RB12-7825', 'RB', 'Alto TCH', 'A B C D', 'Set Out Nov', true),
  ('RB92-8064', 'RB92-8064', 'RB', 'Boa brotação', 'A B C', 'Ago Set Out', true),
  ('RB98-8082', 'RB98-8082', 'RB', 'Alta produtividade', 'A B C', 'Jul Ago Set', true),
  ('CV7870', 'CV7870', 'CV', 'Produtividade', 'B C D', 'Jun Jul Ago', true),
  ('CV6654', 'CV6654', 'CV', 'Perfilhamento', 'B C D', 'Abr Mai Jun Jul Ago', true),
  ('CV0618', 'CV0618', 'CV', 'Produtividade e rusticidade', 'B C D', 'Mai Jun Jul Ago', true)
ON CONFLICT (codigo) DO UPDATE SET
  nome = EXCLUDED.nome,
  instituicao = EXCLUDED.instituicao,
  destaque = EXCLUDED.destaque,
  ambiente_producao = EXCLUDED.ambiente_producao,
  epoca_colheita = EXCLUDED.epoca_colheita,
  ativa = EXCLUDED.ativa;

-- =============================================
-- 3. RLS (Row Level Security)
-- =============================================

-- Garantir que RLS está ativa
ALTER TABLE variedades ENABLE ROW LEVEL SECURITY;

-- Policy: leitura para todos autenticados
DROP POLICY IF EXISTS "Variedades leitura autenticados" ON variedades;
CREATE POLICY "Variedades leitura autenticados" ON variedades
  FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: inserção para autenticados
DROP POLICY IF EXISTS "Variedades inserção autenticados" ON variedades;
CREATE POLICY "Variedades inserção autenticados" ON variedades
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: atualização para autenticados
DROP POLICY IF EXISTS "Variedades atualização autenticados" ON variedades;
CREATE POLICY "Variedades atualização autenticados" ON variedades
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Policy: exclusão para autenticados
DROP POLICY IF EXISTS "Variedades exclusão autenticados" ON variedades;
CREATE POLICY "Variedades exclusão autenticados" ON variedades
  FOR DELETE USING (auth.role() = 'authenticated');
