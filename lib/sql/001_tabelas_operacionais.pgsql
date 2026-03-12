-- ============================================================
-- MIGRATION 001: TABELAS OPERACIONAIS — AFCRC
-- Sistema de Gestão de Cana-de-açúcar
-- Execute no Supabase SQL Editor
-- ============================================================

-- -----------------------------------------
-- 1. PROPRIETÁRIOS
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS proprietarios (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome           TEXT NOT NULL,
  cpf_cnpj       TEXT NOT NULL UNIQUE,
  telefone       TEXT,
  email          TEXT,
  endereco       TEXT,
  cidade         TEXT,
  estado         TEXT DEFAULT 'SP',
  cep            TEXT,
  ativo          BOOLEAN DEFAULT TRUE,
  criado_em      TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_proprietarios_nome ON proprietarios(nome);
CREATE INDEX IF NOT EXISTS idx_proprietarios_cpf_cnpj ON proprietarios(cpf_cnpj);

-- -----------------------------------------
-- 2. PROPRIEDADES
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS propriedades (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proprietario_id   UUID NOT NULL REFERENCES proprietarios(id) ON DELETE CASCADE,
  nome_propriedade  TEXT NOT NULL,
  numero_fa         TEXT NOT NULL,
  endereco          TEXT,
  cidade            TEXT,
  estado            TEXT DEFAULT 'SP',
  cep               TEXT,
  area_ha           NUMERIC(10,2),
  area_alqueires    NUMERIC(10,2),
  ativa             BOOLEAN DEFAULT TRUE,
  criado_em         TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_propriedades_proprietario ON propriedades(proprietario_id);
CREATE INDEX IF NOT EXISTS idx_propriedades_numero_fa ON propriedades(numero_fa);

-- -----------------------------------------
-- 3. TALHÕES
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS talhoes (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id   UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  numero_talhao    TEXT NOT NULL,
  area_ha          NUMERIC(10,2),
  area_alqueires   NUMERIC(10,2),
  variedade        TEXT,
  cultura          TEXT,
  ano_plantio      INT,
  corte            INT,
  data_plantio     DATE,
  tipo_talhao      TEXT DEFAULT 'producao',
  ativo            BOOLEAN DEFAULT TRUE,
  observacoes      TEXT,
  criado_em        TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_talhoes_propriedade ON talhoes(propriedade_id);

-- -----------------------------------------
-- 4. VARIEDADES (Tabela de Referência)
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS variedades (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo             TEXT NOT NULL UNIQUE,
  nome               TEXT NOT NULL,
  caracteristicas    TEXT,
  ambiente_producao  TEXT DEFAULT 'A',
  meses_colheita     INT DEFAULT 0,
  ativa              BOOLEAN DEFAULT TRUE,
  criado_em          TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_variedades_codigo ON variedades(codigo);

-- -----------------------------------------
-- 5. PRODUTIVIDADE
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS produtividade (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id           UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  talhao_id                UUID REFERENCES talhoes(id) ON DELETE SET NULL,
  ano_safra                TEXT NOT NULL,
  variedade                TEXT,
  estagio                  TEXT,
  mes_colheita             INT,
  peso_liquido_toneladas   NUMERIC(12,2),
  media_atr                NUMERIC(8,2),
  observacoes              TEXT,
  created_at               TIMESTAMPTZ DEFAULT NOW(),
  updated_at               TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_produtividade_propriedade ON produtividade(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_produtividade_talhao ON produtividade(talhao_id);
CREATE INDEX IF NOT EXISTS idx_produtividade_ano_safra ON produtividade(ano_safra);

-- -----------------------------------------
-- 6. PRECIPITAÇÕES
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS precipitacoes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id  UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  municipio       TEXT NOT NULL,
  data            DATE NOT NULL,
  mes             INT NOT NULL,
  ano             INT NOT NULL,
  milimetros      NUMERIC(8,2) NOT NULL DEFAULT 0,
  observacoes     TEXT,
  criado_em       TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_precipitacoes_propriedade ON precipitacoes(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_precipitacoes_municipio ON precipitacoes(municipio);
CREATE INDEX IF NOT EXISTS idx_precipitacoes_ano_mes ON precipitacoes(ano, mes);

-- -----------------------------------------
-- 7. OPERAÇÕES DE CULTIVO
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS operacoes_cultivo (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id             UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  talhao_id                  UUID NOT NULL REFERENCES talhoes(id) ON DELETE CASCADE,
  data_plantio               DATE NOT NULL,
  data_quebra_lombo          DATE,
  data_colheita              DATE,
  data_1a_aplic_herbicida    DATE,
  data_2a_aplic_herbicida    DATE,
  observacoes                TEXT,
  created_at                 TIMESTAMPTZ DEFAULT NOW(),
  updated_at                 TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_operacoes_cultivo_propriedade ON operacoes_cultivo(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_operacoes_cultivo_talhao ON operacoes_cultivo(talhao_id);

-- -----------------------------------------
-- 8. TRATOS CULTURAIS
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS tratos_culturais (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id   UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  talhao_id        UUID REFERENCES talhoes(id) ON DELETE SET NULL,
  ano_safra        TEXT NOT NULL,
  adubos           JSONB,
  herbicidas       JSONB,
  inseticidas      JSONB,
  maturadores      JSONB,
  calagem          NUMERIC(10,2),
  gessagem         NUMERIC(10,2),
  oxido_de_calcio  NUMERIC(10,2),
  campos_extras    JSONB,
  data_aplicacao   DATE,
  observacoes      TEXT,
  criado_em        TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tratos_propriedade ON tratos_culturais(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_tratos_talhao ON tratos_culturais(talhao_id);
CREATE INDEX IF NOT EXISTS idx_tratos_ano_safra ON tratos_culturais(ano_safra);

-- -----------------------------------------
-- 9. ANEXOS
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS anexos (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id    UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  tipo_anexo        TEXT DEFAULT 'Documento',
  nome_arquivo      TEXT NOT NULL,
  url_arquivo       TEXT,
  caminho_storage   TEXT NOT NULL,
  tamanho_bytes     INT DEFAULT 0,
  tipo_mime         TEXT,
  criado_em         TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_anexos_propriedade ON anexos(propriedade_id);
CREATE INDEX IF NOT EXISTS idx_anexos_tipo ON anexos(tipo_anexo);

-- -----------------------------------------
-- 10. CUSTO OPERACIONAL — CENÁRIOS
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS custo_operacional_cenarios (
  id                           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propriedade_id               UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  periodo_ref                  TEXT NOT NULL,
  nome_cenario                 TEXT NOT NULL,
  produtividade                NUMERIC(10,2) NOT NULL,
  atr                          INT NOT NULL DEFAULT 138,
  longevidade                  INT,
  dose_muda                    NUMERIC(10,2),
  preco_diesel                 NUMERIC(10,4),
  custo_administrativo         NUMERIC(10,2),
  arrendamento                 NUMERIC(10,2),
  atr_arrend                   NUMERIC(10,4),
  preco_atr                    NUMERIC(10,6),
  total_operacional            NUMERIC(12,2),
  margem_lucro                 NUMERIC(10,4),
  margem_lucro_por_tonelada    NUMERIC(10,4),
  ativo                        BOOLEAN DEFAULT TRUE,
  criado_por                   UUID,
  criado_em                    TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em                TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cenarios_propriedade ON custo_operacional_cenarios(propriedade_id);

-- -----------------------------------------
-- 11. CUSTO OPERACIONAL — HISTÓRICO
-- -----------------------------------------

CREATE TABLE IF NOT EXISTS custo_operacional_historico (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cenario_id       UUID NOT NULL REFERENCES custo_operacional_cenarios(id) ON DELETE CASCADE,
  propriedade_id   UUID NOT NULL REFERENCES propriedades(id) ON DELETE CASCADE,
  campo_alterado   TEXT NOT NULL,
  valor_anterior   TEXT,
  valor_novo       TEXT,
  alterado_por     UUID,
  alterado_em      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_historico_cenario ON custo_operacional_historico(cenario_id);
CREATE INDEX IF NOT EXISTS idx_historico_propriedade ON custo_operacional_historico(propriedade_id);

-- ============================================================
-- TRIGGERS: updated_at / atualizado_em automático
-- ============================================================

CREATE OR REPLACE FUNCTION update_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tabelas com criado_em/atualizado_em
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_proprietarios_updated') THEN
    CREATE TRIGGER trg_proprietarios_updated BEFORE UPDATE ON proprietarios FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_propriedades_updated') THEN
    CREATE TRIGGER trg_propriedades_updated BEFORE UPDATE ON propriedades FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_talhoes_updated') THEN
    CREATE TRIGGER trg_talhoes_updated BEFORE UPDATE ON talhoes FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_variedades_updated') THEN
    CREATE TRIGGER trg_variedades_updated BEFORE UPDATE ON variedades FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_precipitacoes_updated') THEN
    CREATE TRIGGER trg_precipitacoes_updated BEFORE UPDATE ON precipitacoes FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_tratos_updated') THEN
    CREATE TRIGGER trg_tratos_updated BEFORE UPDATE ON tratos_culturais FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_anexos_updated') THEN
    CREATE TRIGGER trg_anexos_updated BEFORE UPDATE ON anexos FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_cenarios_updated') THEN
    CREATE TRIGGER trg_cenarios_updated BEFORE UPDATE ON custo_operacional_cenarios FOR EACH ROW EXECUTE FUNCTION update_atualizado_em();
  END IF;
END $$;

-- Tabelas com created_at/updated_at
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_produtividade_updated') THEN
    CREATE TRIGGER trg_produtividade_updated BEFORE UPDATE ON produtividade FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_operacoes_cultivo_updated') THEN
    CREATE TRIGGER trg_operacoes_cultivo_updated BEFORE UPDATE ON operacoes_cultivo FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE proprietarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE propriedades ENABLE ROW LEVEL SECURITY;
ALTER TABLE talhoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE variedades ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtividade ENABLE ROW LEVEL SECURITY;
ALTER TABLE precipitacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE operacoes_cultivo ENABLE ROW LEVEL SECURITY;
ALTER TABLE tratos_culturais ENABLE ROW LEVEL SECURITY;
ALTER TABLE anexos ENABLE ROW LEVEL SECURITY;
ALTER TABLE custo_operacional_cenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE custo_operacional_historico ENABLE ROW LEVEL SECURITY;

-- Políticas: usuário autenticado tem acesso total
-- (em produção, filtrar por user_id ou org_id)


-- Policies: padrão idempotente
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: proprietarios' AND tablename = 'proprietarios') THEN
    EXECUTE 'CREATE POLICY "Autenticados: proprietarios" ON proprietarios FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: propriedades' AND tablename = 'propriedades') THEN
    EXECUTE 'CREATE POLICY "Autenticados: propriedades" ON propriedades FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: talhoes' AND tablename = 'talhoes') THEN
    EXECUTE 'CREATE POLICY "Autenticados: talhoes" ON talhoes FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: variedades' AND tablename = 'variedades') THEN
    EXECUTE 'CREATE POLICY "Autenticados: variedades" ON variedades FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: produtividade' AND tablename = 'produtividade') THEN
    EXECUTE 'CREATE POLICY "Autenticados: produtividade" ON produtividade FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: precipitacoes' AND tablename = 'precipitacoes') THEN
    EXECUTE 'CREATE POLICY "Autenticados: precipitacoes" ON precipitacoes FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: operacoes_cultivo' AND tablename = 'operacoes_cultivo') THEN
    EXECUTE 'CREATE POLICY "Autenticados: operacoes_cultivo" ON operacoes_cultivo FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: tratos_culturais' AND tablename = 'tratos_culturais') THEN
    EXECUTE 'CREATE POLICY "Autenticados: tratos_culturais" ON tratos_culturais FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: anexos' AND tablename = 'anexos') THEN
    EXECUTE 'CREATE POLICY "Autenticados: anexos" ON anexos FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: cenarios' AND tablename = 'custo_operacional_cenarios') THEN
    EXECUTE 'CREATE POLICY "Autenticados: cenarios" ON custo_operacional_cenarios FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Autenticados: historico' AND tablename = 'custo_operacional_historico') THEN
    EXECUTE 'CREATE POLICY "Autenticados: historico" ON custo_operacional_historico FOR ALL USING (auth.role() = ''authenticated'')';
  END IF;
END $$;

-- ============================================================
-- STORAGE: Bucket para anexos
-- ============================================================

-- Criar bucket para anexos (executar como service_role)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('anexos-propriedades', 'anexos-propriedades', false);

-- Policy de storage: autenticados podem upload/download
-- CREATE POLICY "Autenticados: upload" ON storage.objects FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND bucket_id = 'anexos-propriedades');
-- CREATE POLICY "Autenticados: download" ON storage.objects FOR SELECT USING (auth.role() = 'authenticated' AND bucket_id = 'anexos-propriedades');
-- CREATE POLICY "Autenticados: delete" ON storage.objects FOR DELETE USING (auth.role() = 'authenticated' AND bucket_id = 'anexos-propriedades');
