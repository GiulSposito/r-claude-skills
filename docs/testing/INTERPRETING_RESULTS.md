# Interpretando Resultados dos Testes de Triggers

## Guia Visual para Análise de Resultados

Este guia explica como interpretar os resultados do `test_triggers.py` e tomar ações corretivas.

---

## Anatomia de um Resultado de Teste

### Exemplo de Output Completo

```
================================================================================
Testing skill: r-tidymodels
================================================================================

▶ Testing POSITIVE triggers (6 tests)...
▶ Testing CONTEXT triggers (3 tests)...
▶ Testing NEGATIVE triggers (3 tests)...

📊 Summary for r-tidymodels:
   Recall:    90.0% (9 TP, 1 FN)      ← Detectou 90% dos casos que deveria
   Precision: 100.0% (9 TP, 0 FP)     ← Nunca ativou incorretamente
   Accuracy:  91.7%                   ← Acurácia geral
```

---

## Entendendo as Métricas

### Matriz de Confusão

```
                    SKILL ATIVOU           SKILL NÃO ATIVOU
                    ═════════════════════════════════════════
DEVERIA ATIVAR │    TRUE POSITIVE (TP)    FALSE NEGATIVE (FN)
               │    ✅ Correto!            ❌ Perdeu!
               │
NÃO DEVERIA    │    FALSE POSITIVE (FP)   TRUE NEGATIVE (TN)
ATIVAR         │    ❌ Falso alarme!      ✅ Correto!
```

### Recall (Sensibilidade)

**O que mede**: "De todos os prompts que DEVERIAM ativar o skill, quantos % realmente ativaram?"

**Fórmula**: `TP / (TP + FN)`

**Interpretação**:
- ✅ **≥90%**: Excelente - skill ativa na maioria dos casos relevantes
- ⚠️ **70-89%**: Bom mas pode melhorar - perdendo alguns casos
- ❌ **<70%**: Problemático - skill frequentemente não ativa quando deveria

**Exemplo**:
```
Skill: r-tidymodels
Prompts que DEVERIAM ativar: 10
Ativou corretamente: 9 (TP)
Não ativou: 1 (FN)

Recall = 9 / (9 + 1) = 90%
```

**Quando recall é baixo**:
- Skill tem triggers muito específicos
- Description não tem frases-gatilho suficientes
- Overlapping com outros skills

### Precision (Precisão)

**O que mede**: "De todas as vezes que o skill ativou, quantos % foram corretos?"

**Fórmula**: `TP / (TP + FP)`

**Interpretação**:
- ✅ **≥95%**: Excelente - raramente ativa incorretamente
- ⚠️ **85-94%**: Bom - alguns falsos positivos
- ❌ **<85%**: Problemático - ativa em contextos errados

**Exemplo**:
```
Skill: ggplot2
Vezes que ativou: 10
Ativações corretas: 10 (TP)
Ativações incorretas: 0 (FP)

Precision = 10 / (10 + 0) = 100%
```

**Quando precision é baixa**:
- Triggers muito genéricos
- Overlap excessivo com outros skills
- Description com palavras ambíguas

### Accuracy (Acurácia)

**O que mede**: "No geral, quantos % de todos os testes foram corretos?"

**Fórmula**: `(TP + TN) / (TP + TN + FP + FN)`

**Interpretação**:
- ✅ **≥90%**: Excelente
- ⚠️ **75-89%**: Bom
- ❌ **<75%**: Problemático

### F1 Score

**O que mede**: Média harmônica entre Precision e Recall (equilíbrio)

**Fórmula**: `2 × (Precision × Recall) / (Precision + Recall)`

**Interpretação**:
- ✅ **≥85%**: Excelente equilíbrio
- ⚠️ **70-84%**: Bom
- ❌ **<70%**: Precisa balancear melhor

---

## Padrões Comuns e Soluções

### Padrão 1: Alta Precision, Baixa Recall

```
📊 Summary for r-performance:
   Recall:    60.0%    ← ❌ Muito baixo
   Precision: 100.0%   ← ✅ Perfeito
```

**Diagnóstico**: Skill é muito específico, perdendo casos válidos

**Sintomas**:
- Muitos false negatives (prompts relevantes não ativam)
- Zero false positives (nunca ativa incorretamente)

**Causa Raiz**:
```yaml
# Description muito restrita:
description: Use when mentions "profvis profiling benchmarking"
```

**Solução**: Expandir triggers na description

```yaml
# Before:
description: R performance optimization. Use when mentions "profvis".

# After:
description: R performance best practices including profiling, benchmarking,
  vctrs, and optimization strategies. Use when mentions "profiling", "profvis",
  "benchmark", "bench::mark", "slow code", "optimize R", "vectorization",
  "performance", "memory usage", "bottleneck", "speed up", "parallel processing",
  "Rcpp", "system.time", or optimizing R code performance.
```

**Verificação**:
```bash
# Testar com novos prompts
./test_triggers.py --skills r-performance --verbose
```

---

### Padrão 2: Baixa Precision, Alta Recall

```
📊 Summary for tidyverse-expert:
   Recall:    95.0%    ← ✅ Excelente
   Precision: 70.0%    ← ❌ Muito baixo
```

**Diagnóstico**: Skill ativa em contextos errados

**Sintomas**:
- Poucos false negatives (ativa quando deveria)
- Muitos false positives (ativa quando não deveria)

**Causa Raiz**:
```yaml
# Triggers genéricos demais:
description: Use when working with data, data manipulation, or data analysis
```

**Solução**: Tornar triggers mais específicos

```yaml
# Before:
description: Data manipulation in R. Use when "data manipulation".

# After:
description: Expert R data manipulation with tidyverse - dplyr, tidyr, purrr,
  stringr, forcats, lubridate. Use when working with tidyverse, mentions
  "dplyr verbs", "data wrangling", "tidyr pivoting", "purrr map",
  "string manipulation", "factors", "dates in R", or discusses advanced
  data transformation patterns, joins, nesting, functional programming,
  or complex data cleaning tasks in R.
```

**Verificação**:
```bash
# Verificar negative tests
./test_triggers.py --skills tidyverse-expert --verbose | grep "NEGATIVE"
```

---

### Padrão 3: Baixa Recall E Baixa Precision

```
📊 Summary for r-oop:
   Recall:    55.0%    ← ❌ Muito baixo
   Precision: 60.0%    ← ❌ Muito baixo
```

**Diagnóstico**: Skill mal configurado ou overlap com outros

**Sintomas**:
- Muitos false negatives E false positives
- Comportamento inconsistente

**Causas Possíveis**:

1. **Triggers ambíguos**:
```yaml
description: Object-oriented programming. Use when "OOP" or "classes".
# Problema: "classes" é genérico demais
```

2. **Overlap com outro skill**:
```yaml
# r-oop:
description: ... Use when mentions "classes" ...

# r-datascience:
description: ... Use when "data classes" ...
# Conflict!
```

3. **Triggers conflitantes com negativos**:
```yaml
description: Use when "creating classes"
# Mas negative test: "Python classes" também tem "classes"
```

**Solução**: Reestruturar description

```yaml
# Before:
description: OOP in R. Use when "OOP" or "classes".

# After:
description: R object-oriented programming guide for S7, S3, S4, and vctrs.
  Use when mentions "S3 class", "S4 class", "S7", "vctrs", "new_class",
  "setClass", "setGeneric", "setMethod", "object-oriented", "OOP in R",
  "method dispatch", "class definition", "generic functions", "inheritance",
  or designing R classes and choosing an OOP system.
```

**Verificação**:
```bash
# Testar isolation de outros skills
./test_triggers.py --skills r-oop r-datascience r-package-development
```

---

### Padrão 4: Alta Recall E Precision (Ideal!)

```
📊 Summary for ggplot2:
   Recall:    95.0%    ← ✅ Excelente
   Precision: 98.0%    ← ✅ Excelente
   Accuracy:  96.5%    ← ✅ Excelente
```

**Diagnóstico**: Skill bem configurado! 🎉

**Por que funciona**:
```yaml
description: Expert ggplot2 data visualization in R - grammar of graphics,
  geoms, themes, scales, faceting, and styling. Use when user works with ggplot2,
  mentions "ggplot", "geom_", creates visualizations in R, asks about plot
  customization, themes, or data visualization best practices.
```

**Características de boas descriptions**:
1. ✅ Específico ao domínio ("ggplot2", não "plotting")
2. ✅ Múltiplos triggers (5-8 frases diferentes)
3. ✅ Inclui função names ("geom_", "theme_")
4. ✅ Inclui conceitos ("grammar of graphics")
5. ✅ Inclui casos de uso ("plot customization")

**Manter o bom trabalho**:
- Adicionar testes para novos edge cases
- Monitorar false positives/negatives em produção
- Atualizar quando novos packages surgem

---

## Workflow de Diagnóstico

### Passo 1: Rodar Testes

```bash
./test_triggers.py --output results.json
```

### Passo 2: Identificar Problem Skills

```
⚠️  r-performance:
   - Low recall (60.0%)
   False negatives (4):
      • Este código está lento, como otimizar?
      • Como vectorizar este loop?
```

### Passo 3: Analisar Prompts que Falharam

**Para False Negatives** (deveria ativar mas não ativou):

```bash
# Ver prompts em detalhes
jq '.skills["r-performance"].positive[] | select(.success == false)' results.json

# Output:
{
  "prompt": "Este código está lento, como otimizar?",
  "expected": "r-performance",
  "detected": ["r-datascience"],  ← Ativou skill errado!
  "success": false
}
```

**Insight**: "otimizar" ativa r-datascience em vez de r-performance

**Ação**: Adicionar "otimizar código" e "lento" à description de r-performance

### Passo 4: Atualizar Description

```bash
# Editar skill
vim .claude/skills/r-performance/SKILL.md

# Atualizar frontmatter:
description: R performance best practices including profiling, benchmarking,
  vctrs, and optimization strategies. Use when mentions "profiling", "profvis",
  "benchmark", "bench::mark", "slow code", "optimize R", "vectorization",
  "lento", "código lento", "otimizar código", ...
```

### Passo 5: Re-testar

```bash
./test_triggers.py --skills r-performance --verbose
```

### Passo 6: Verificar Regression

```bash
# Testar TODOS os skills para garantir que não quebrou nada
./test_triggers.py --output results_after.json

# Comparar
python3 compare_results.py results.json results_after.json
```

---

## Analisando Relatório JSON

### Encontrar Worst Performers

```bash
# Skills com recall < 80%
jq '.skills | to_entries | map(select(.value.metrics.recall < 0.8)) |
    .[] | {skill: .key, recall: .value.metrics.recall}' results.json

# Output:
{"skill": "r-performance", "recall": 0.6}
{"skill": "rlang-patterns", "recall": 0.75}
```

### Listar Todos os False Negatives

```bash
jq '.skills | to_entries[] |
    {skill: .key, false_negatives: [
      .value.positive[], .value.context[] | select(.success == false)
    ]} | select(.false_negatives | length > 0)' results.json
```

### Gerar Relatório de Prompts Problemáticos

```bash
# Criar arquivo de prompts que falharam para re-teste manual
jq -r '.skills | to_entries[] |
    .value.positive[], .value.context[] |
    select(.success == false) | .prompt' results.json > failing_prompts.txt
```

---

## Checklist de Análise

Ao analisar resultados, verificar:

### ✅ Métricas Globais

- [ ] Recall médio ≥ 90%?
- [ ] Precision médio ≥ 95%?
- [ ] Algum skill com F1 < 70%?
- [ ] Mais de 3 skills abaixo do target?

### ✅ Skills Individuais

Para cada skill problemático:

- [ ] Qual métrica está baixa? (Recall/Precision/ambos)
- [ ] Quantos false negatives/positives?
- [ ] Que prompts falharam?
- [ ] Há padrão nos falhas? (palavras específicas, contextos)
- [ ] Overlap com outro skill?

### ✅ Patterns de Falha

- [ ] Falhas concentradas em contexto tests?
- [ ] Falhas em prompts não-inglês?
- [ ] Falhas quando prompt menciona múltiplos conceitos?
- [ ] Falhas quando código sem contexto?

### ✅ Ações Corretivas

- [ ] Description atualizada?
- [ ] Triggers adicionados?
- [ ] Exemplos adicionados ao SKILL.md?
- [ ] Negative tests adicionados para novos triggers?
- [ ] Re-teste executado?
- [ ] Regression check feito?

---

## Targets de Qualidade

### Mínimo Aceitável (MVP)

```
Skill                Recall    Precision
────────────────────────────────────────
CADA skill           ≥ 80%     ≥ 90%
MÉDIA geral          ≥ 85%     ≥ 93%
```

### Production-Ready

```
Skill                Recall    Precision
────────────────────────────────────────
CADA skill           ≥ 90%     ≥ 95%
MÉDIA geral          ≥ 92%     ≥ 97%
F1 Score médio       ≥ 90%
```

### Excelência

```
Skill                Recall    Precision
────────────────────────────────────────
CADA skill           ≥ 95%     ≥ 98%
MÉDIA geral          ≥ 96%     ≥ 99%
Zero skills < 90%    ✓
```

---

## Exemplos Práticos de Análise

### Exemplo 1: Skill com Baixa Recall

**Resultado**:
```
r-text-mining: Recall 70%, Precision 100%
```

**Análise**:
```bash
# Ver quais prompts falharam
jq '.skills["r-text-mining"].positive[] | select(.success == false)' results.json

# Descoberta: Prompts com "análise de texto" não ativam, apenas "text mining"
```

**Fix**:
```yaml
# Adicionar triggers em português
description: ... Use when mentions "análise de texto", "mineração de texto", ...
```

**Verificação**:
```bash
./test_triggers.py --skills r-text-mining
# Novo recall: 92% ✅
```

### Exemplo 2: Overlap entre Skills

**Resultado**:
```
tidyverse-expert: Precision 85%
r-datascience: Precision 87%
```

**Análise**:
```bash
# Encontrar prompts onde ambos ativaram
jq '.skills | with_entries(select(.key == "tidyverse-expert" or .key == "r-datascience")) |
    ... análise de overlap ...'
```

**Descoberta**: Ambos ativam para "data wrangling"

**Fix**:
```yaml
# r-datascience (orquestrador)
description: ... Use when working with data in R, mentions "tidyverse", "data wrangling" ...

# tidyverse-expert (específico)
description: ... Use when ... "dplyr verbs", "advanced data wrangling" ...
# Tornar mais específico
```

---

## Próximos Passos

Após análise e fixes:

1. **Documentar mudanças**:
   ```bash
   git commit -m "Improve r-performance triggers (recall 60%→92%)"
   ```

2. **Atualizar CHANGELOG**:
   ```markdown
   ## 2026-03-09 - Trigger Improvements
   - r-performance: Added "código lento", "otimizar" triggers (+32% recall)
   - rlang-patterns: Made triggers more specific (+15% precision)
   ```

3. **Adicionar regression tests**:
   - Adicionar prompts que falharam aos test cases permanentes

4. **Monitorar em produção**:
   - Coletar logs de invocações reais
   - Identificar novos patterns de falha
   - Iterar continuamente

5. **Testar em integração**:
   ```bash
   # Testar workflow completo
   ./test_integration.sh
   ```

---

## Recursos Adicionais

- **Test Strategy**: `TESTING_STRATEGY.md` - Estratégia completa
- **Test Suite**: `test_triggers.py` - Script de testes
- **Usage Guide**: `TEST_TRIGGERS_README.md` - Como usar o script
- **Example Output**: `examples/trigger_test_example_output.json` - Exemplo de saída
