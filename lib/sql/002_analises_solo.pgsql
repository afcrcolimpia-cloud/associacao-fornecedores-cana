-- =====================================================
-- Migration: 002_analises_solo
-- Descrição: Tabela para análises de solo com interpretação Boletim 100
-- Data: 2026-03-11
-- =====================================================

CREATE TABLE IF NOT EXISTS analises_solo (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    propriedade_id UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
    talhao_id UUID REFERENCES talhoes(id) ON DELETE SET NULL,

    -- Dados gerais
    laboratorio TEXT,
    numero_amostra TEXT,
    data_coleta DATE,
    data_resultado DATE,
    profundidade_cm INTEGER,

    -- Macronutrientes
    ph NUMERIC(4,2),                   -- pH CaCl2
    materia_organica NUMERIC(6,2),     -- g/dm³
    fosforo NUMERIC(8,2),              -- mg/dm³ (P resina)
    potassio NUMERIC(6,2),             -- mmolc/dm³
    calcio NUMERIC(6,2),               -- mmolc/dm³
    magnesio NUMERIC(6,2),             -- mmolc/dm³
    enxofre NUMERIC(6,2),              -- mg/dm³ (S-SO4)

    -- Acidez e CTC
    acidez_potencial NUMERIC(6,2),     -- H+Al mmolc/dm³
    aluminio NUMERIC(6,2),             -- mmolc/dm³
    somas_bases NUMERIC(8,2),          -- SB mmolc/dm³
    ctc NUMERIC(8,2),                  -- CTC mmolc/dm³
    saturacao_bases NUMERIC(5,2),      -- V%

    -- Micronutrientes
    boro NUMERIC(6,3),                 -- mg/dm³
    cobre NUMERIC(6,3),                -- mg/dm³
    ferro NUMERIC(8,2),                -- mg/dm³
    manganes NUMERIC(6,3),             -- mg/dm³
    zinco NUMERIC(6,3),                -- mg/dm³

    -- Textura
    argila NUMERIC(6,1),               -- g/kg
    silte NUMERIC(6,1),                -- g/kg
    areia NUMERIC(6,1),                -- g/kg

    observacoes TEXT,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_analises_solo_propriedade ON analises_solo(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_analises_solo_talhao ON analises_solo(talhao_id);
CREATE INDEX IF NOT EXISTS idx_analises_solo_data_coleta ON analises_solo(data_coleta);

-- RLS: somente usuários autenticados
ALTER TABLE analises_solo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários autenticados podem ler análises de solo"
    ON analises_solo FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Usuários autenticados podem inserir análises de solo"
    ON analises_solo FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem atualizar análises de solo"
    ON analises_solo FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem deletar análises de solo"
    ON analises_solo FOR DELETE
    TO authenticated
    USING (true);
