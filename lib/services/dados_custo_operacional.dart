import '../models/operacao_custos.dart';

/// Dados de referência AFCRC — Jan-Fev/2026
/// CORRIGIDO: fórmulas alinhadas com planilha oficial
class DadosCustoOperacional {
  // ── PARÂMETROS TÉCNICOS PADRÃO ──────────────────────────────
  static final ParametrosCustoOperacional parametros =
      ParametrosCustoOperacional(
    produtividade: 84.6,
    atr: 138,
    longevidade: 5,
    doseMuda: 16,
    precoDiesel: 5.899,
    custoAdmin: 10.0, // Percentual (%) sobre subtotal operacional
    arrendamento: 16.5,
    atrArrend: 118,
    precoATR: 1.1945,
    periodoRef: 'Jan-Fev/2026',
  );

  // ── TABELAS OPERACIONAIS (R$/ha) ────────────────────────────

  static final EstagioCustos conservacaoSolo = EstagioCustos(
    titulo: 'Conservação de Solo',
    operacoes: [
      Operacao(
        operacao: 'Construção de curvas',
        maquina: 'Motoniveladora',
        maquinaVal: 315.09,
        implemento: '-',
        implVal: 0,
        operacaoVal: 315.09,
        rend: 0.5,
        operRHa: 157.545,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 157.545,
      ),
      Operacao(
        operacao: 'Terraceamento',
        maquina: 'Trator 180 cv',
        maquinaVal: 268.97,
        implemento: 'Terraceador',
        implVal: 64.59,
        operacaoVal: 333.56,
        rend: 0.8,
        operRHa: 266.848,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 266.848,
      ),
      Operacao(
        operacao: 'Manutenção de carreador',
        maquina: 'Motoniveladora',
        maquinaVal: 315.09,
        implemento: '-',
        implVal: 0,
        operacaoVal: 315.09,
        rend: 0.4,
        operRHa: 126.036,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 126.036,
      ),
      Operacao(
        operacao: 'Serviços topográficos',
        maquina: 'Manual',
        maquinaVal: 138.3,
        implemento: '-',
        implVal: 0,
        operacaoVal: 138.3,
        rend: 0.2,
        operRHa: 27.66,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 27.66,
      ),
    ],
    total: 578.089,
    obs: '* Custos expressos em R\$/t. Exceto serviços topográficos que está em diárias/ha',
  );

  static final EstagioCustos preparoSolo = EstagioCustos(
    titulo: 'Preparo de Solo',
    operacoes: [
      Operacao(
        operacao: 'Grade pesada',
        maquina: 'Trator 180 cv',
        maquinaVal: 268.97,
        implemento: 'Grade pesada',
        implVal: 70.37,
        operacaoVal: 339.34,
        rend: 0.94,
        operRHa: 318.9796,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 318.98,
      ),
      Operacao(
        operacao: 'Subsolagem',
        maquina: 'Trator 180 cv',
        maquinaVal: 268.97,
        implemento: 'Subsolador',
        implVal: 37.95,
        operacaoVal: 306.92,
        rend: 1.2,
        operRHa: 368.304,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 368.3,
      ),
      Operacao(
        operacao: 'Gradagem intermediária',
        maquina: 'Trator 180 cv',
        maquinaVal: 268.97,
        implemento: 'Grade intermediária',
        implVal: 41.9,
        operacaoVal: 310.87,
        rend: 0.66,
        operRHa: 205.1742,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 205.17,
      ),
      Operacao(
        operacao: 'Gradagem niveladora',
        maquina: 'Trator 180 cv',
        maquinaVal: 268.97,
        implemento: 'Grade niveladora',
        implVal: 37.46,
        operacaoVal: 306.43,
        rend: 0.52,
        operRHa: 159.3436,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 159.34,
      ),
      Operacao(
        operacao: 'Aplicação de calcário',
        maquina: 'Trator 100 cv',
        maquinaVal: 145.38,
        implemento: 'Distribuidor de corretivos',
        implVal: 45.14,
        operacaoVal: 190.52,
        rend: 0.5,
        operRHa: 95.26,
        insumo: 'Calcário',
        dose: 2,
        insumoRHa: 440,
        total: 535.26,
      ),
      Operacao(
        operacao: 'Aplicação de gesso',
        maquina: 'Trator 100 cv',
        maquinaVal: 145.38,
        implemento: 'Distribuidor de corretivos',
        implVal: 45.14,
        operacaoVal: 190.52,
        rend: 0.5,
        operRHa: 95.26,
        insumo: 'Gesso',
        dose: 1,
        insumoRHa: 240,
        total: 335.26,
      ),
    ],
    total: 1922.3214,
    obs: '* Custos expressos em R\$/h. No caso dos produtos, valores com frete.',
  );

  static final EstagioCustos plantio = EstagioCustos(
    titulo: 'Plantio',
    operacoes: [
      Operacao(
        operacao: 'Sulcação',
        maquina: 'Trator 180 cv',
        maquinaVal: 211.43,
        implemento: 'Sulcador',
        implVal: 39.95,
        operacaoVal: 251.38,
        rend: 0.98,
        operRHa: 246.3524,
        insumo: '05-25-25',
        dose: 0.5,
        insumoRHa: 1787.5,
        total: 2033.8524,
      ),
      Operacao(
        operacao: 'Corte de muda',
        maquina: 'Mão-de-obra',
        maquinaVal: 26.04,
        implemento: '-',
        implVal: 0,
        operacaoVal: 26.04,
        rend: 16,
        operRHa: 416.64,
        insumo: 'Muda (1,5:1)',
        dose: 16,
        insumoRHa: 3956.16,
        total: 4372.8,
      ),
      Operacao(
        operacao: 'Transporte de muda',
        maquina: 'Caminhão',
        maquinaVal: 9.56,
        implemento: '-',
        implVal: 0,
        operacaoVal: 9.56,
        rend: 16,
        operRHa: 152.96,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 152.96,
      ),
      Operacao(
        operacao: 'Carga/Descarga muda',
        maquina: 'Carregadora',
        maquinaVal: 8.79,
        implemento: '-',
        implVal: 0,
        operacaoVal: 8.79,
        rend: 16,
        operRHa: 140.64,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 140.64,
      ),
      Operacao(
        operacao: 'Esparramação/Picação',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 6,
        operRHa: 601.98,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 601.98,
      ),
      Operacao(
        operacao: 'Cobrição',
        maquina: 'Trator 100 cv',
        maquinaVal: 145.89,
        implemento: 'Cobridor',
        implVal: 24.06,
        operacaoVal: 169.95,
        rend: 1,
        operRHa: 169.95,
        insumo: 'Regent 800 WG',
        dose: 0.25,
        insumoRHa: 146.25,
        total: 316.2,
      ),
      Operacao(
        operacao: 'Recobrição',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 3,
        operRHa: 300.99,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 300.99,
      ),
      Operacao(
        operacao: 'Aplicação de herbicida',
        maquina: 'Trator 100 cv',
        maquinaVal: 145.38,
        implemento: 'Pulverizador',
        implVal: 40.47,
        operacaoVal: 185.85,
        rend: 0.94,
        operRHa: 174.699,
        insumo: 'Thebutiuron + Ametrina',
        dose: null,
        insumoRHa: 226.86,
        total: 401.559,
      ),
      Operacao(
        operacao: 'Liberação de cotésia',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 0.05,
        operRHa: 5.0165,
        insumo: 'Cotesia',
        dose: 5,
        insumoRHa: 26.25,
        total: 31.2665,
      ),
      Operacao(
        operacao: 'Carpa manual',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 2,
        operRHa: 200.66,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 200.66,
      ),
      Operacao(
        operacao: 'Quebra-lombo',
        maquina: 'Trator 100 cv',
        maquinaVal: 125.65,
        implemento: 'Cultivador',
        implVal: 44.08,
        operacaoVal: 169.73,
        rend: 1,
        operRHa: 169.73,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 169.73,
      ),
    ],
    total: 8722.6379,
    obs: '* Custos dos maquinários expressos em R\$/h, exceto carregamento e transporte de mudas em R\$/t. No caso da mão-de-obra, corte de muda em R\$/t e demais operações em R\$/dia.',
  );

  static final EstagioCustos manutencaoSoqueira = EstagioCustos(
    titulo: 'Manutenção de Soqueira',
    operacoes: [
      Operacao(
        operacao: 'Desleiramento',
        maquina: 'Trator 100 cv',
        maquinaVal: 125.65,
        implemento: 'Enleirador',
        implVal: 16.34,
        operacaoVal: 141.99,
        rend: 0.26,
        operRHa: 36.9174,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 36.9174,
      ),
      Operacao(
        operacao: 'Cultivo e adubação',
        maquina: 'Trator 180 cv',
        maquinaVal: 211.43,
        implemento: 'Cultivador',
        implVal: 44.08,
        operacaoVal: 255.51,
        rend: 0.75,
        operRHa: 191.6325,
        insumo: '25-00-25',
        dose: 0.4,
        insumoRHa: 1300,
        total: 1491.6325,
      ),
      Operacao(
        operacao: 'Aplicação de calcário',
        maquina: 'Trator 100 cv',
        maquinaVal: 125.65,
        implemento: 'Dist. de Corretivos',
        implVal: 45.26,
        operacaoVal: 170.91,
        rend: 0.5,
        operRHa: 85.455,
        insumo: 'Calcário',
        dose: 2,
        insumoRHa: 440,
        total: 525.455,
      ),
      Operacao(
        operacao: 'Aplicação de herbicida',
        maquina: 'Trator 100 cv',
        maquinaVal: 145.38,
        implemento: 'Pulverizador',
        implVal: 40.47,
        operacaoVal: 185.85,
        rend: 0.6,
        operRHa: 111.51,
        insumo: 'Plateau + Provence',
        dose: null,
        insumoRHa: 213.4804,
        total: 324.9904,
      ),
      Operacao(
        operacao: 'Liberação de cotésia',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 0.05,
        operRHa: 5.0165,
        insumo: 'Cotesia',
        dose: 5,
        insumoRHa: 26.25,
        total: 31.2665,
      ),
      Operacao(
        operacao: 'Aplicação de inseticida',
        maquina: 'Trator 100 cv',
        maquinaVal: 125.65,
        implemento: 'Pulverizador',
        implVal: 34.51,
        operacaoVal: 160.16,
        rend: 0.6,
        operRHa: 96.096,
        insumo: 'Inseticida',
        dose: 1.7,
        insumoRHa: 280.5,
        total: 376.596,
      ),
      Operacao(
        operacao: 'Corte de soqueira',
        maquina: 'Trator 100 cv',
        maquinaVal: 125.65,
        implemento: 'Cortador Soqueira',
        implVal: 31.28,
        operacaoVal: 156.93,
        rend: 0.45,
        operRHa: 70.6185,
        insumo: 'Inseticida',
        dose: 2,
        insumoRHa: 360,
        total: 430.6185,
      ),
      Operacao(
        operacao: 'Carpa',
        maquina: 'Mão-de-obra',
        maquinaVal: 100.33,
        implemento: '-',
        implVal: 0,
        operacaoVal: 100.33,
        rend: 2,
        operRHa: 200.66,
        insumo: '-',
        dose: 0,
        insumoRHa: 0,
        total: 200.66,
      ),
    ],
    total: 3418.1363,
    obs: '* Custos dos maquinários expressos em R\$/h e da mão-de-obra em R\$/dia.',
  );

  static final EstagioCustos colheita = EstagioCustos(
    titulo: 'Sistema de Colheita',
    operacoes: [
      Operacao(
        operacao: 'Corte',
        maquina: 'Colhedora',
        maquinaVal: 27.01,
        implemento: '',
        implVal: 0,
        operacaoVal: 0,
        rend: 84.6,
        operRHa: 2285.046,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 2285.046,
      ),
      Operacao(
        operacao: 'Transbordo',
        maquina: 'Trator + Transbordo',
        maquinaVal: 4.34,
        implemento: '',
        implVal: 0,
        operacaoVal: 0,
        rend: 84.6,
        operRHa: 367.164,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 367.164,
      ),
      Operacao(
        operacao: 'Transporte (25 km)',
        maquina: 'Cana picada',
        maquinaVal: 14.69,
        implemento: '',
        implVal: 0,
        operacaoVal: 0,
        rend: 84.6,
        operRHa: 1242.774,
        insumo: null,
        dose: null,
        insumoRHa: null,
        total: 1242.774,
      ),
    ],
    total: 3894.984,
    obs: '* Valores obtidos de tabela de prestação de serviço.',
  );

  /// Todos os estágios operacionais
  static List<EstagioCustos> obterEstagios() => [
        conservacaoSolo,
        preparoSolo,
        plantio,
        manutencaoSoqueira,
        colheita,
      ];

  // ── RESUMO CALCULADO DINAMICAMENTE ─────────────────────────
  // Estes valores são calculados com as fórmulas corretas da planilha AFCRC.
  // Para parâmetros customizados use calcularEstagio().

  static List<ResumoEstagio> get resumo {
    final p = parametros;
    final conservHa = conservacaoSolo.total;
    final prepHa    = preparoSolo.total;
    final plantHa   = plantio.total;
    final manutHa   = manutencaoSoqueira.total;
    final colhHa    = colheita.total;
    final subtotalHa = conservHa + prepHa + plantHa + manutHa + colhHa;
    final admHa     = subtotalHa * (p.custoAdmin / 100); // Admin em %
    final arrendHa  = p.arrendamento * p.atrArrend * p.precoATR;
    final formHa    = conservHa + prepHa + plantHa;
    final totHa     = formHa + manutHa + colhHa + admHa + arrendHa;
    final prod      = p.produtividade;
    final atr       = p.atr.toDouble();
    final lon       = p.longevidade;

    // Amortizados (formação)
    double amort(double ha) => (ha / prod) / lon;
    // Recorrentes
    double dir(double ha) => ha / prod;

    String pct(double ha) => '${(ha / totHa * 100).toStringAsFixed(1)}%';

    return [
      ResumoEstagio(
        estagio: 'Conservação de solo',
        rHa: conservHa,
        rT: amort(conservHa),
        rKgATR: amort(conservHa) / atr,
        pct: pct(conservHa),
      ),
      ResumoEstagio(
        estagio: 'Preparo de solo',
        rHa: prepHa,
        rT: amort(prepHa),
        rKgATR: amort(prepHa) / atr,
        pct: pct(prepHa),
      ),
      ResumoEstagio(
        estagio: 'Plantio',
        rHa: plantHa,
        rT: amort(plantHa),
        rKgATR: amort(plantHa) / atr,
        pct: pct(plantHa),
      ),
      ResumoEstagio(
        estagio: 'Manutenção de soqueira',
        rHa: manutHa,
        rT: dir(manutHa),
        rKgATR: dir(manutHa) / atr,
        pct: pct(manutHa),
      ),
      ResumoEstagio(
        estagio: 'Sistema de colheita',
        rHa: colhHa,
        rT: dir(colhHa),
        rKgATR: dir(colhHa) / atr,
        pct: pct(colhHa),
      ),
      ResumoEstagio(
        estagio: 'Administrativo',
        rHa: admHa,
        rT: dir(admHa),
        rKgATR: dir(admHa) / atr,
        pct: pct(admHa),
      ),
      ResumoEstagio(
        estagio: 'Arrendamento',
        rHa: arrendHa,
        rT: dir(arrendHa),
        rKgATR: dir(arrendHa) / atr,
        pct: pct(arrendHa),
      ),
    ];
  }

  // ── TOTAIS CALCULADOS ───────────────────────────────────────
  // Total R$/ha = Formação + Manutenção + Colheita + Adm + Arrendamento
  // Total R$/t  = mesmos 5 itens (formação amortizada por longevidade)
  // Resultado correto: R$/ha=21.041,69  R$/t=142,59  Margem=22,25

  static TotalOperacional get totalOperacional {
    final p = parametros;
    final formHa   = conservacaoSolo.total + preparoSolo.total + plantio.total;
    final manutHa  = manutencaoSoqueira.total;
    final colhHa   = colheita.total;
    final subtotalHa = formHa + manutHa + colhHa;
    final admHa    = subtotalHa * (p.custoAdmin / 100); // Admin em %
    final arrendHa = p.arrendamento * p.atrArrend * p.precoATR;
    final prod     = p.produtividade;
    final atr      = p.atr.toDouble();
    final lon      = p.longevidade;

    // Custo anualizado R$/ha = (Formação / longevidade) + restante
    final custoAnualizadoHa = (formHa / lon) + manutHa + colhHa + admHa + arrendHa;

    final totRpt = (formHa / prod) / lon
        + manutHa / prod
        + colhHa  / prod
        + admHa   / prod
        + arrendHa / prod;

    return TotalOperacional(
      rHa: custoAnualizadoHa,
      rT: totRpt,
      rKgATR: totRpt / atr,
    );
  }

  static TotalOperacional get precoRecebido {
    final p = parametros;
    final rpt = p.atr * p.precoATR;
    return TotalOperacional(
      rHa: rpt * p.produtividade,
      rT: rpt,
      rKgATR: p.precoATR,
    );
  }

  static TotalOperacional get margemLucro {
    final tot   = totalOperacional;
    final preco = precoRecebido;
    return TotalOperacional(
      rHa: preco.rHa - tot.rHa,
      rT: preco.rT - tot.rT,
      rKgATR: preco.rKgATR - tot.rKgATR,
    );
  }
}
