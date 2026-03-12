-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.
-- Migration: Tabela de Insumos com Doses Recomendadas para Tratos Culturais

-- ========================================
-- 1. CRIAR TABELA
-- ========================================
CREATE TABLE IF NOT EXISTS public.insumos_com_doses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    produto VARCHAR(100) NOT NULL UNIQUE,
    situacao VARCHAR(100),
    dose_minima NUMERIC(10,2) NOT NULL,
    dose_maxima NUMERIC(10,2) NOT NULL,
    unidade VARCHAR(20) NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL DEFAULT 0,
    observacoes TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dose_minima_menor_maxima CHECK (dose_minima <= dose_maxima)
);

-- ========================================
-- 2. ÍNDICES
-- ========================================
CREATE INDEX IF NOT EXISTS idx_insumos_categoria ON public.insumos_com_doses(categoria);
CREATE INDEX IF NOT EXISTS idx_insumos_tipo ON public.insumos_com_doses(tipo);
CREATE INDEX IF NOT EXISTS idx_insumos_produto ON public.insumos_com_doses(produto);

-- ========================================
-- 3. RLS (Row Level Security)
-- ========================================
ALTER TABLE public.insumos_com_doses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS insumos_com_doses_select ON public.insumos_com_doses;
CREATE POLICY insumos_com_doses_select ON public.insumos_com_doses
    FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS insumos_com_doses_insert ON public.insumos_com_doses;
CREATE POLICY insumos_com_doses_insert ON public.insumos_com_doses
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS insumos_com_doses_update ON public.insumos_com_doses;
CREATE POLICY insumos_com_doses_update ON public.insumos_com_doses
    FOR UPDATE USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS insumos_com_doses_delete ON public.insumos_com_doses;
CREATE POLICY insumos_com_doses_delete ON public.insumos_com_doses
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- ========================================
-- 4. SEED DATA — Insumos Agrícolas
-- ========================================

-- HERBICIDAS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Defensivo', 'Herbicida', 'Glifosato', 'Pós-emergência', 2.5, 4.0, 'L/ha', 11.70, 'Aplicar em pós-emergência em plantas de 2-4 folhas'),
('Defensivo', 'Herbicida', '2,4-D Amina', 'Pós-emergência', 1.0, 2.0, 'L/ha', 8.50, 'Ideal para dicotiledôneas'),
('Defensivo', 'Herbicida', 'Diuron', 'Pré-emergência', 2.0, 3.0, 'kg/ha', 18.00, 'Aplicar em pré-emergência no solo úmido'),
('Defensivo', 'Herbicida', 'Hexazinona', 'Pré-emergência', 1.5, 2.5, 'L/ha', 25.00, 'Usado em combinação com Diuron'),
('Defensivo', 'Herbicida', 'Metribuzin', 'Pré-emergência', 1.5, 2.0, 'kg/ha', 28.00, 'Controle de folhas largas'),
('Defensivo', 'Herbicida', 'Ametrina', 'Pré e pós-emergência', 2.0, 3.5, 'L/ha', 14.50, 'Indicado para cana-planta e soca'),
('Defensivo', 'Herbicida', 'MSMA', 'Pós-emergência', 1.5, 2.5, 'L/ha', 16.00, 'Controle de tiririca e capim-colonião'),
('Defensivo', 'Herbicida', 'Sulfentrazone', 'Pré-emergência', 0.8, 1.2, 'L/ha', 45.00, 'Longo período residual no solo'),
('Defensivo', 'Herbicida', 'Clomazone', 'Pré-emergência', 1.5, 2.5, 'L/ha', 22.00, 'Gramíneas e folhas largas'),
('Defensivo', 'Herbicida', 'Tebuthiuron', 'Pré-emergência', 1.0, 2.0, 'kg/ha', 35.00, 'Longo residual, solo arenoso cuidado')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- INSETICIDAS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Defensivo', 'Inseticida', 'Fipronil', 'Controle de cigarrinha', 0.75, 1.0, 'L/ha', 22.50, 'Aplicar em 2-3 pulverizações'),
('Defensivo', 'Inseticida', 'Tiametoxam', 'Controle de cigarrinha', 0.2, 0.4, 'kg/ha', 85.00, 'Sistêmico, absorção radicular'),
('Defensivo', 'Inseticida', 'Imidacloprido', 'Controle de cigarrinha', 0.3, 0.5, 'L/ha', 65.00, 'Neonicotinoide sistêmico'),
('Defensivo', 'Inseticida', 'Carbofurano', 'Controle de broca', 2.0, 3.0, 'kg/ha', 18.00, 'Aplicação no sulco de plantio'),
('Defensivo', 'Inseticida', 'Clorpirifós', 'Controle geral', 1.0, 2.0, 'L/ha', 15.00, 'Amplo espectro de ação'),
('Defensivo', 'Inseticida', 'Lambda-Cialotrina', 'Controle de cigarrinha', 0.15, 0.25, 'L/ha', 38.00, 'Piretroide de contato'),
('Defensivo', 'Inseticida', 'Metarhizium anisopliae', 'Controle biológico', 2.0, 5.0, 'kg/ha', 25.00, 'Fungo entomopatogênico para cigarrinha')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- FUNGICIDAS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Defensivo', 'Fungicida', 'Azoxistrobina', 'Controle de ferrugem', 0.5, 0.75, 'L/ha', 32.00, 'Pulverizar a partir da identificação'),
('Defensivo', 'Fungicida', 'Trifloxistrobina', 'Controle de ferrugem', 0.4, 0.6, 'L/ha', 45.00, 'Combinado com Epoxiconazol'),
('Defensivo', 'Fungicida', 'Fluxapiroxade', 'Controle de doenças foliares', 0.3, 0.5, 'L/ha', 55.00, 'Preventivo e curativo')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- FERTILIZANTES MINERAIS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Fertilizante', 'Mineral', 'Ureia', 'Adubação nitrogenada', 80.0, 150.0, 'kg/ha', 2.50, 'Parcelado em 2-3 aplicações'),
('Fertilizante', 'Mineral', 'DAP', 'Adubação NPK', 100.0, 200.0, 'kg/ha', 3.20, 'Excelente para plantio'),
('Fertilizante', 'Mineral', 'Cloreto de Potássio', 'Adubação potássica', 60.0, 120.0, 'kg/ha', 2.85, 'Parcelado em aplicações'),
('Fertilizante', 'Mineral', 'NPK 04-14-08', 'Adubação de base', 300.0, 600.0, 'kg/ha', 2.10, 'Plantio e soqueira'),
('Fertilizante', 'Mineral', 'NPK 20-05-20', 'Adubação de cobertura', 200.0, 400.0, 'kg/ha', 2.30, 'Cobertura em soqueira'),
('Fertilizante', 'Mineral', 'MAP', 'Adubação fosfatada', 100.0, 200.0, 'kg/ha', 3.50, 'Alto teor de fósforo'),
('Fertilizante', 'Mineral', 'Sulfato de Amônio', 'Adubação nitrogenada', 100.0, 200.0, 'kg/ha', 1.80, 'Fonte de N e S'),
('Fertilizante', 'Mineral', 'Superfosfato Simples', 'Adubação fosfatada', 200.0, 500.0, 'kg/ha', 1.20, 'Fonte de P e Ca'),
('Fertilizante', 'Mineral', 'Superfosfato Triplo', 'Adubação fosfatada', 100.0, 250.0, 'kg/ha', 2.80, 'Alta concentração de P')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- FERTILIZANTES FOLIARES
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Fertilizante', 'Foliar', 'NPK Foliar', 'Pulverização foliar', 2.0, 3.0, 'L/ha', 12.50, 'Aplicar em 3-4 pulverizações'),
('Fertilizante', 'Foliar', 'Boro Foliar', 'Correção de boro', 0.5, 1.0, 'L/ha', 18.00, 'Aplicar no perfilhamento'),
('Fertilizante', 'Foliar', 'Zinco Foliar', 'Correção de zinco', 0.5, 1.5, 'L/ha', 15.00, 'Importante para elongação'),
('Fertilizante', 'Foliar', 'Manganês Foliar', 'Correção de manganês', 0.5, 1.0, 'L/ha', 14.00, 'Solos arenosos com pH alto')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- CORRETIVOS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Corretivo', 'Calcário', 'Calcário Calcítico', 'Correção de acidez', 2.0, 4.0, 't/ha', 85.00, 'Para solos com pH < 5.5'),
('Corretivo', 'Calcário', 'Calcário Dolomítico', 'Correção de acidez', 2.0, 4.0, 't/ha', 95.00, 'Fonte de Ca e Mg'),
('Corretivo', 'Gesso', 'Gesso Agrícola', 'Condicionador subsuperficial', 1.0, 3.0, 't/ha', 55.00, 'Melhora camada subsuperficial'),
('Corretivo', 'Óxido', 'Óxido de Cálcio', 'Correção rápida', 0.5, 1.5, 't/ha', 120.00, 'Ação rápida na correção do pH')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- MATÉRIA ORGÂNICA
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Matéria Orgânica', 'Orgânico', 'Cama de Frango', 'Adubação orgânica', 10.0, 20.0, 't/ha', 65.00, 'Fresca ou compostada'),
('Matéria Orgânica', 'Orgânico', 'Torta de Filtro', 'Adubação orgânica', 15.0, 30.0, 't/ha', 25.00, 'Subproduto da usina'),
('Matéria Orgânica', 'Orgânico', 'Vinhaça', 'Fertirrigação', 80.0, 150.0, 'm³/ha', 5.00, 'Fonte de K e matéria orgânica'),
('Matéria Orgânica', 'Orgânico', 'Composto Orgânico', 'Adubação orgânica', 5.0, 15.0, 't/ha', 45.00, 'Melhora estrutura do solo')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- BIOLÓGICOS
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Biológico', 'Promotor', 'Azospirillum brasilense', 'Inoculante de solo', 200.0, 500.0, 'ml/ha', 0.18, 'Fixador de N'),
('Biológico', 'Promotor', 'Bacillus subtilis', 'Promotor de crescimento', 1.0, 2.0, 'L/ha', 35.00, 'Proteção radicular'),
('Biológico', 'Promotor', 'Trichoderma harzianum', 'Biodefensivo', 1.0, 2.0, 'kg/ha', 40.00, 'Controle de doenças de solo'),
('Biológico', 'Controle', 'Cotesia flavipes', 'Controle biológico da broca', 6000.0, 8000.0, 'parasitoides/ha', 0.01, 'Liberar em focos de infestação'),
('Biológico', 'Controle', 'Trichogramma galloi', 'Controle biológico da broca', 100000.0, 200000.0, 'parasitoides/ha', 0.0001, 'Parasitoides de ovos')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;

-- MATURADORES
INSERT INTO public.insumos_com_doses (categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Regulador', 'Maturador', 'Etefom', 'Maturação', 1.0, 2.0, 'L/ha', 42.00, '30-60 dias antes da colheita'),
('Regulador', 'Maturador', 'Glifosato (maturação)', 'Maturação', 0.3, 0.5, 'L/ha', 11.70, 'Subdose como maturador'),
('Regulador', 'Maturador', 'Sulfometurom-metílico', 'Maturação', 0.015, 0.02, 'kg/ha', 280.00, 'Inibidor de crescimento'),
('Regulador', 'Maturador', 'Trinexapac-etílico', 'Regulador de crescimento', 0.8, 1.5, 'L/ha', 65.00, 'Reduz crescimento vegetativo')
ON CONFLICT (produto) DO UPDATE SET
    dose_minima = EXCLUDED.dose_minima,
    dose_maxima = EXCLUDED.dose_maxima,
    preco_unitario = EXCLUDED.preco_unitario,
    observacoes = EXCLUDED.observacoes;
