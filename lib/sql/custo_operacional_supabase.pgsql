-- ============================================================
-- SCHEMA: CUSTO OPERACIONAL DINÂMICO - AFCRC
-- Execute no Supabase SQL Editor
-- ============================================================

-- -----------------------------------------
-- 1. TABELAS DE CATÁLOGO (dados de referência)
-- -----------------------------------------

-- Categorias das etapas de produção
CREATE TABLE IF NOT EXISTS co_categorias (
  id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE,
  ordem INT,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Operações disponíveis por categoria (ex: "Sulcação", "Terraceamento")
CREATE TABLE IF NOT EXISTS co_operacoes_catalogo (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria_id UUID REFERENCES co_categorias(id) ON DELETE CASCADE,
  nome         TEXT NOT NULL,
  ativo        BOOLEAN DEFAULT TRUE,
  criado_em    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (categoria_id, nome)
);

-- Máquinas/Diárias/Tratores disponíveis
CREATE TABLE IF NOT EXISTS co_maquinas_catalogo (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome      TEXT NOT NULL UNIQUE,
  valor_und NUMERIC(10,2),
  ativo     BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Implementos/Ferramentas disponíveis
CREATE TABLE IF NOT EXISTS co_implementos_catalogo (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome      TEXT NOT NULL UNIQUE,
  valor_und NUMERIC(10,2),
  ativo     BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Insumos (fertilizantes, defensivos, sementes, etc)
CREATE TABLE IF NOT EXISTS co_insumos_catalogo (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome      TEXT NOT NULL UNIQUE,
  valor_und NUMERIC(10,2),
  unidade   TEXT DEFAULT 'kg',
  ativo     BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------
-- 2. TABELA PRINCIPAL: LANÇAMENTOS REAIS
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS co_lancamentos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id  UUID REFERENCES propriedades(id) ON DELETE CASCADE,
  talhao_id       UUID REFERENCES talhoes(id) ON DELETE SET NULL,
  categoria_id    UUID REFERENCES co_categorias(id),
  safra           INT,

  -- OPERAÇÃO
  operacao_id     UUID REFERENCES co_operacoes_catalogo(id) ON DELETE SET NULL,
  operacao_custom TEXT,

  -- MÁQUINA/DIÁRIA
  maquina_id      UUID REFERENCES co_maquinas_catalogo(id) ON DELETE SET NULL,
  maquina_custom  TEXT,
  maquina_valor   NUMERIC(10,2),

  -- IMPLEMENTO
  implemento_id   UUID REFERENCES co_implementos_catalogo(id) ON DELETE SET NULL,
  implemento_custom TEXT,
  implemento_valor NUMERIC(10,2),

  -- CÁLCULOS OPERAÇÃO
  rendimento      NUMERIC(10,4),
  operacao_rha    NUMERIC(10,4),

  -- INSUMO
  insumo_id       UUID REFERENCES co_insumos_catalogo(id) ON DELETE SET NULL,
  insumo_custom   TEXT,
  insumo_preco    NUMERIC(10,2),
  insumo_dose     NUMERIC(10,4),
  insumo_rha      NUMERIC(10,4),

  -- TOTAL
  custo_total_rha NUMERIC(10,4),

  observacao      TEXT,
  criado_em       TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em   TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------
-- 3. ÍNDICES PARA PERFORMANCE
-- -----------------------------------------

CREATE INDEX IF NOT EXISTS idx_co_lancamentos_propriedade ON co_lancamentos(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_co_lancamentos_talhao ON co_lancamentos(talhao_id);
CREATE INDEX IF NOT EXISTS idx_co_lancamentos_categoria ON co_lancamentos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_co_lancamentos_safra ON co_lancamentos(safra);

-- -----------------------------------------
-- 4. TRIGGER updated_at
-- -----------------------------------------

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.atualizado_em = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_co_lancamentos_updated_at ON co_lancamentos;
CREATE TRIGGER trg_co_lancamentos_updated_at
BEFORE UPDATE ON co_lancamentos
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- -----------------------------------------
-- 5. SEED: CATEGORIAS
-- -----------------------------------------

INSERT INTO co_categorias (nome, ordem) VALUES
  ('Conservação de Solo', 1),
  ('Preparo de Solo', 2),
  ('Plantio', 3),
  ('Manutenção de Soqueira', 4),
  ('Sistema de Colheita', 5)
ON CONFLICT (nome) DO NOTHING;

-- -----------------------------------------
-- 6. SEED: OPERAÇÕES POR CATEGORIA
-- -----------------------------------------

WITH cats AS (
  SELECT id, nome FROM co_categorias
)
INSERT INTO co_operacoes_catalogo (categoria_id, nome)
SELECT cats.id, operacao FROM cats, (VALUES
  ('Conservação de Solo', 'Construção de curvas'),
  ('Conservação de Solo', 'Terraceamento'),
  ('Conservação de Solo', 'Manutenção de carreador'),
  ('Conservação de Solo', 'Serviços topográficos'),
  ('Preparo de Solo', 'Grade pesada'),
  ('Preparo de Solo', 'Subsolagem'),
  ('Preparo de Solo', 'Gradagem intermediária'),
  ('Preparo de Solo', 'Gradagem niveladora'),
  ('Preparo de Solo', 'Aplicação de calcário'),
  ('Preparo de Solo', 'Aplicação de gesso'),
  ('Plantio', 'Sulcação'),
  ('Plantio', 'Corte de muda'),
  ('Plantio', 'Transporte de muda'),
  ('Plantio', 'Carga/Descarga muda'),
  ('Plantio', 'Esparramação/Picação'),
  ('Plantio', 'Cobrição'),
  ('Plantio', 'Recobrição'),
  ('Plantio', 'Aplicação de herbicida'),
  ('Plantio', 'Liberação de cotésia'),
  ('Plantio', 'Carpa manual'),
  ('Plantio', 'Quebra-lombo'),
  ('Manutenção de Soqueira', 'Desleiramento'),
  ('Manutenção de Soqueira', 'Cultivo e adubação'),
  ('Manutenção de Soqueira', 'Aplicação de calcário'),
  ('Manutenção de Soqueira', 'Aplicação de herbicida'),
  ('Manutenção de Soqueira', 'Liberação de cotésia'),
  ('Manutenção de Soqueira', 'Aplicação de inseticida'),
  ('Manutenção de Soqueira', 'Corte de soqueira'),
  ('Manutenção de Soqueira', 'Carpa'),
  ('Sistema de Colheita', 'Corte'),
  ('Sistema de Colheita', 'Transbordo'),
  ('Sistema de Colheita', 'Transporte (até 25 km)')
) AS t(categoria, operacao)
WHERE cats.nome = t.categoria
ON CONFLICT (categoria_id, nome) DO NOTHING;

-- -----------------------------------------
-- 7. SEED: MÁQUINAS/DIÁRIAS
-- -----------------------------------------

INSERT INTO co_maquinas_catalogo (nome, valor_und) VALUES
  ('Trator 100 cv', 125.65),
  ('Trator 180 cv', 268.97),
  ('Motoniveladora', 315.09),
  ('Mão-de-obra (diária)', 150.00),
  ('Caminhão (diária)', 300.00),
  ('Carregadora (diária)', 250.00),
  ('Colhedora (aluguel)', 500.00),
  ('Trator + Transbordo', 450.00)
ON CONFLICT (nome) DO NOTHING;

-- -----------------------------------------
-- 8. SEED: IMPLEMENTOS
-- -----------------------------------------

INSERT INTO co_implementos_catalogo (nome, valor_und) VALUES
  ('Terraceador', 64.59),
  ('Sulcador', 39.95),
  ('Cobridor', 24.06),
  ('Pulverizador', 40.47),
  ('Cultivador', 44.08),
  ('Enleirador', 16.34),
  ('Distribuidor de Corretivos', 45.26),
  ('Cortador de Soqueira', 31.28),
  ('Grade pesada', 70.37),
  ('Subsolador', 37.95),
  ('Grade intermediária', 41.90),
  ('Grade niveladora', 37.46)
ON CONFLICT (nome) DO NOTHING;

-- -----------------------------------------
-- 9. SEED: INSUMOS
-- -----------------------------------------

INSERT INTO co_insumos_catalogo (nome, valor_und, unidade) VALUES
  ('Adubo NPK 05-25-25', 3575.00, 'sc 50kg'),
  ('Adubo NPK 25-00-25', 3250.00, 'sc 50kg'),
  ('Calcário dolomítico', 220.00, 't'),
  ('Gesso agrícola', 240.00, 't'),
  ('Muda (1,5:1)', 247.26, 't'),
  ('Regent 800 WG', 585.00, 'kg'),
  ('Thebutiuron', 62.50, 'kg'),
  ('Ametrina', 25.62, 'L'),
  ('Cotesia (parasitóide)', 5.25, 'un'),
  ('Plateau', 846.86, 'kg'),
  ('Provence Total', 678.00, 'L'),
  ('Inseticida geral', 165.00, 'L')
ON CONFLICT (nome) DO NOTHING;
