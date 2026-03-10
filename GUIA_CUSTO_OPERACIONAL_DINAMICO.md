# ?? SISTEMA DINÂMICO DE CUSTO OPERACIONAL

## ?? O que foi criado

Um sistema completo de gestáo de custo operacional **sem dados fixos no código** - totalmente dinâmico e extensível.

### Arquivos Criados

1. **`lib/sql/custo_operacional_supabase.pgsql`** ? Execute primeiro
   - 5 tabelas de catélogo (categorias, operações, máquinas, implementos, insumos)
   - Tabela principal `co_lancamentos` para salvar os lançamentos reais
   - Índices e triggers para performance

2. **`lib/services/custo_operacional_repository.dart`** ? Backend
   - Todas as operações CRUD (Create, Read, Update, Delete)
   - Busca por texto com `ilike` (case-insensitive)
   - Cálculos automáticos de margem, rendimento, etc
   - Métodos para cadastrar novos itens no catélogo dinamicamente

3. **`lib/screens/custo_operacional_lancamento_screen.dart`** ? Tela de Entrada
   - Widget `SearchField<T>` com autocomplete
   - Formulário completo com 5 campos dinamicamente buscados
   - Cálculos em tempo real (resumo com R$/ha)
   - Opção de digitar valores manualmente se não estiver no catélogo

4. **`lib/screens/custo_operacional_lancamentos_screen.dart`** ? Tela de Lista
   - 5 abas (Conservação, Preparo, Plantio, Manutenção, Colheita)
   - Resumo de custos por categoria
   - Edição e exclusão de lançamentos
   - View bonita com cardsMaterial Design

---

## ?? COMO USAR

### PASSO 1: Executar SQL no Supabase

1. Abra **Supabase Dashboard** ? seu projeto
2. Vê em **SQL Editor**
3. Cole o conteúdo do arquivo `custo_operacional_supabase.pgsql`
4. Clique **Run** ?
   - Isso cria todas as 5 tabelas + seed de dados!

### PASSO 2: Integrar no Flutter

Você pode acessar a tela de duas formas:

#### **Forma A: Button na propriedade**
```dart
// Num arquivo que você abre a propriedade
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalLancamentosScreen(
          propriedadeId: propriedade.id,
          propriedadeNome: propriedade.nome,
          safra: 2026,
        ),
      ),
    );
  },
  child: const Text('Custo Operacional Dinâmico'),
),
```

#### **Forma B: Na tela de talhão**
```dart
// Num drawer ou menu
ListTile(
  leading: const Icon(Icons.calculate),
  title: const Text('Custo Operacional'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalLancamentosScreen(
          propriedadeId: propriedade.id,
          propriedadeNome: propriedade.nome,
          talhaoId: talhao?.id,
          talhaoNome: talhao?.nome,
          safra: 2026,
        ),
      ),
    );
  },
)
```

### PASSO 3: Usar a Tela

1. **Abrir**: Toca em botão ? entra em `CustoOperacionalLancamentosScreen`
2. **Novo Lançamento**: Clica no FAB azul (+ Novo Lançamento)
3. **Selecionar Categoria**: Dropdown com 5 opções (Conservação, Preparo, etc)
4. **Buscar Operação**: 
   - Digita "sulc" ? aparece "Sulcação" da planilha
   - Ou deixa vazio e digita manualmente
5. **Buscar Máquina/Diária**:
   - Digita "trat" ? aparece "Trator 100 cv" E "Trator 180 cv"
   - Clica em uma ? preenche o valor automaticamente (R$ 125.65)
   - Ou digita manualmente
6. **Valores**:
   - Máquina: R$/und
   - Rendimento: und/ha
   - Insumo: preço + dose
   - **Tudo calcula automaticamente em tempo real!**
7. **Resumo**: Mostra operação R$/ha + insumo R$/ha + total
8. **Salvar**: Clica no botão verde ?

---

## ?? DADOS SALVOS

No Supabase:
```json
{
  "id": "uuid-gerado",
  "propriedade_id": "sua-propriedade",
  "talhao_id": "seu-talhao (opcional)",
  "categoria_id": "uuid-da-categoria",
  "safra": 2026,
  "operacao_id": "uuid-operacao (ou null se custom)",
  "operacao_custom": "Sulcação manual",
  "maquina_id": "uuid-trator",
  "maquina_custom": null,
  "maquina_valor": 125.65,
  "implemento_id": "uuid-implemento",
  "implemento_custom": null,
  "implemento_valor": 39.95,
  "rendimento": 0.13,
  "operacao_rha": 21.59,
  "insumo_id": "uuid-adubo",
  "insumo_custom": null,
  "insumo_preco": 3575.00,
  "insumo_dose": 1.2,
  "insumo_rha": 4290.00,
  "custo_total_rha": 4311.59,
  "observacao": "Aplicado em agosto"
}
```

---

## ?? CUSTOMIZAÇÃO

### Adicionar nova categoria
```dart
// No Supabase SQL
INSERT INTO co_categorias (nome, ordem) VALUES ('Colheita Manual', 6);
```

### Adicionar nova operação
```dart
// No código ao salvar
await _repo.cadastrarOperacao(
  categoriaId, 
  'Colheita mecanizada'
);
```

### Mudar cores
```dart
// Em AppColors ou no arquivo
backgroundColor: Colors.green[700], // ao invés de primary
```

---

## ?? BUSCA FUNCIONA ASSIM

Nome de máquina: "Trator 100 cv"
Você digita: "trat" ? ? aparece
Você digita: "100" ? ? aparece  
Você digita: "cv" ? ? aparece
Você digita: "trator pq" ? ? não aparece (busca por PALAVRA, não substring)

---

## ?? VISTA DOS DADOS

**Por Categoria:**
```
PREPARO DE SOLO                        Total: R$ 485,32/ha
+- Grade pesada          R$ 315.09/ha    ?? Trator | ?? Grade
+- Subsolagem            R$ 127.90/ha    ?? Trator | ?? Subsolador
+- Gradagem niveladora   R$ 42.33/ha     ?? Trator
```

**Cada lançamento mostra:**
- Operação principal (título em negrito)
- Custo total R$/ha (em cor destaque)
- Máquina + implemento usados
- Insumo aplicado (se houver)
- Breakdown: Operação R$/ha + Insumo R$/ha
- Botões: Editar | Excluir

---

## ?? RELATÓRIO DE ERROS

Se algo der erro:

**"Erro: 404 co_lancamentos not found"**
? Você não executou o SQL. Faça novamente.

**"Campo vazio em talhao_id"**
? Já corrigido! Agora valida e usa `null` se vazio.

**"Carregando vazio"**
? Seu Supabase pode estar offline. Cheque internet.

---

## ?? ESTRUTURA DE CADASTRO INTEGRADO

Se o técnico não encontra uma operação:

```dart
// Forma 1: Digita manualmente
_operacaoCustomCtrl.text = "Colheita manual (especial)";

// Forma 2: Cadastra Na Hora (futuro)
onTap: () async {
  final novaOp = await _repo.cadastrarOperacao(
    categoriaId, 
    "Colheita manual (especial)"
  );
  setState(() => _operacao = ...);
}
```

---

## ?? SEGURANºA NO SUPABASE

Adicione RLS (Row Level Security) se necessário:

```sql
CREATE POLICY "Users can only see their own properties"
ON co_lancamentos
FOR SELECT
USING (propriedade_id IN (
  SELECT id FROM propriedades WHERE user_id = auth.uid()
));
```

---

## ?? PRINT ESPERADO

```
-----------------------------------
    CUSTO OPERACIONAL DINÂMICO
    Fazenda ABC - Talhão 5 - 2026
-----------------------------------
[Conservação] [Preparo] [Plantio] ...    ? ABAS
-----------------------------------
Total Conservação: R$ 250,00/ha
3 itens    R$ 83,33/média
-----------------------------------

+---------------------------------+
- Terraceamento       R$ 150,00/ha
- ?? Motoniveladora               -
- ?? Terraceador                  -
- Operação: R$ 150,00/ha          -
- Insumo: R$ 0,00/ha              -
-              [??] [???]            -
+---------------------------------+

+---------------------------------+
- Aplicação de calcário R$ 100/ha -
- ?? Trator                       -
- ?? Calcário: 2,5 t/ha           -
- Operação: R$ 50,00/ha           -
- Insumo: R$ 50,00/ha             -
-              [??] [???]            -
+---------------------------------+

+--------------------------------+
- ? Novo Lançamento             -
+--------------------------------+
```

---

## ? CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Execute SQL do Supabase
- [ ] Importe `custo_operacional_repository.dart`
- [ ] Importe `custo_operacional_lancamento_screen.dart`
- [ ] Importe `custo_operacional_lancamentos_screen.dart`
- [ ] Adicione button/menu em alguma tela (propriedade, talhão, etc)
- [ ] Teste: Novo lançamento ? busca operação ? salva
- [ ] Teste: Lista mostra na aba correta
- [ ] Teste: Edita lançamento
- [ ] Teste: Deleta lançamento
- [ ] Customizar cores se quiser (AppColors)

---

## ?? PERGUNTAS FREQUENTES

**P: Posso adicionar mais categorias?**
R: Sim! SQL direto ou pelo código.

**P: Os valores das máquinas de semana são diferentes?**
R: Crie duas máquinas: "Trator 100 cv (semana)" e "Trator 100 cv (fds)"

**P: Quero que cada técnico veja só suas operações?**
R: Implemente RLS no Supabase (Row Level Security)

**P: Como faço relatério de tudo que foi feito?**
R: A tabela `co_lancamentos` tem todos os dados. Exporte SQL ou crie uma tela de exportação PDF.

---

**Qualquer dúvida, - só me chamar!** ??
