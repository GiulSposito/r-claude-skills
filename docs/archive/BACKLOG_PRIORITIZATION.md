# Backlog Priorizado: Skills por Impacto/Facilidade

## 📊 Matriz de Priorização

### Critérios de Avaliação

**IMPACTO** (quanto vale corrigir):
- **Potencial de melhoria**: Gap até 90% recall
- **Importância funcional**: Quão core/essencial é o skill
- **Frequência de uso**: Quantas vezes usuários precisam dele
- **Efeito cascata**: Se melhora outros skills

**FACILIDADE** (quão fácil é corrigir):
- **Tipo de problema**: Apenas recall baixo (fácil) vs recall+precision baixos (médio)
- **Padrão aplicável**: Se padrão skillMaker resolve 100%
- **Complexidade do domínio**: Quantos conceitos cobrir
- **Overlaps**: Se tem conflitos com outros skills

### Pontuação

**Impacto**: 1 (baixo) a 5 (alto)
**Facilidade**: 1 (difícil) a 5 (fácil)
**Score Total**: Impacto × Facilidade (máx 25)

---

## 🎯 Matriz Impacto vs Facilidade

```
                    FACILIDADE
        1       2       3       4       5
      ┌─────┬─────┬─────┬─────┬─────┐
    5 │     │     │  2  │  1  │  ✅ │
      ├─────┼─────┼─────┼─────┼─────┤
I   4 │     │  6  │  4  │  3  │  5  │
M     ├─────┼─────┼─────┼─────┼─────┤
P   3 │     │  9  │ 10  │  7  │  8  │
A     ├─────┼─────┼─────┼─────┼─────┤
C   2 │     │     │ 13  │ 11  │ 12  │
T     ├─────┼─────┼─────┼─────┼─────┤
O   1 │     │     │     │ 14  │     │
      └─────┴─────┴─────┴─────┴─────┘

✅ = skillMaker (CONCLUÍDO)
```

**Legenda**:
- **Alta prioridade** (Impacto 4-5, Facilidade 3-5): Fix imediato
- **Média prioridade** (Score 9-15): Fix em 1-2 semanas
- **Baixa prioridade** (Score <9): Fix quando houver tempo

---

## 📋 Análise Detalhada por Skill

### ✅ CONCLUÍDO

#### 0. skillMaker (Score: 25 - Impacto 5, Facilidade 5)
- **Status**: ✅ 0% → 100% recall/precision
- **Impacto**: 5 (essencial para criar novos skills)
- **Facilidade**: 5 (padrão funcionou perfeitamente)
- **Resultado**: PERFEITO!

---

## 🔴 PRIORIDADE MÁXIMA (Score 20-25)

### 1. r-datascience (Score: 20 - Impacto 5, Facilidade 4)

**Recall atual**: 25.0% | **Precision**: 66.7%
**Gap**: 65 pontos até target | **Prioridade**: 🔴 **CRÍTICA**

**Por que Impacto 5 (máximo)**:
- ✅ **Skill orquestrador**: Coordena todos os outros skills de data science
- ✅ **Entrada principal**: Primeiro skill que usuários acionam
- ✅ **Frequência altíssima**: Usado em ~80% das tarefas de DS
- ✅ **Efeito cascata**: Se funciona bem, ativa os skills certos downstream

**Por que Facilidade 4 (fácil)**:
- ✅ Precision 66.7% indica apenas alguns overlaps (Python)
- ✅ Padrão skillMaker resolve 90% do problema
- ⚠️ Precisa filtros para evitar Python (pequeno esforço extra)

**Problemas identificados**:
1. ❌ Falta triggers: "análise de dados", "data wrangling", "análise estatística"
2. ❌ Ativa incorretamente para Python ML
3. ❌ Triggers muito genéricos

**Solução**:
```yaml
# Adicionar 15+ triggers bilíngues
# Adicionar filtro: "ONLY R - do NOT activate for Python, pandas, scikit-learn"
# Tempo estimado: 15 min
```

**Ganho esperado**: 25% → 80% recall (+55 pontos)

---

### 2. r-tidymodels (Score: 15 - Impacto 5, Facilidade 3)

**Recall atual**: 22.2% | **Precision**: 100.0%
**Gap**: 68 pontos até target | **Prioridade**: 🔴 **CRÍTICA**

**Por que Impacto 5 (máximo)**:
- ✅ **Core de ML**: Único framework moderno de ML em R
- ✅ **Uso intenso**: Todo projeto de ML em R usa
- ✅ **Complexo**: Muitos sub-skills (recipe, parsnip, tune, workflow)
- ✅ **Diferencial**: O que torna R competitivo com Python ML

**Por que Facilidade 3 (média)**:
- ✅ Precision perfeita (100%) = sem overlaps
- ⚠️ Domínio grande: precisa cobrir 100+ recipe steps, 50+ models
- ⚠️ Muitos sinônimos: classification/regression, tuning/tuning, cv/cross-validation

**Problemas identificados**:
1. ❌ Falta: "modelo de classificação", "modelo de regressão"
2. ❌ Falta: "cross-validation", "validação cruzada", "cv"
3. ❌ Falta: "tunear", "tuning", "hiperparâmetros"

**Solução**:
```yaml
# Adicionar 20+ triggers (ML terminology é extensa)
# Incluir português: "modelo", "treinar", "tunear", "validação"
# Tempo estimado: 20 min
```

**Ganho esperado**: 22% → 85% recall (+63 pontos)

---

### 3. r-performance (Score: 16 - Impacto 4, Facilidade 4)

**Recall atual**: 11.1% | **Precision**: 50.0%
**Gap**: 79 pontos até target | **Prioridade**: 🔴 **CRÍTICA**

**Por que Impacto 4 (alto)**:
- ✅ **Pain point comum**: Performance é problema frequente
- ✅ **Alto valor**: Pode economizar horas de processamento
- ✅ **Diferencial técnico**: Separa código bom de excelente

**Por que Facilidade 4 (fácil)**:
- ✅ Padrão skillMaker aplicável
- ⚠️ Precisa filtro forte para Python/C++

**Problemas identificados**:
1. ❌ Falta: "lento", "slow", "otimizar", "optimize"
2. ❌ Falta: "vectorizar", "vectorize"
3. ❌ Ativa para Python incorretamente

**Solução**:
```yaml
# Adicionar 15+ triggers de performance
# Filtro forte: "ONLY R - NOT Python/C++"
# Tempo estimado: 15 min
```

**Ganho esperado**: 11% → 75% recall (+64 pontos)

---

## 🟠 ALTA PRIORIDADE (Score 15-19)

### 4. ggplot2 (Score: 16 - Impacto 4, Facilidade 4)

**Recall atual**: 33.3% | **Precision**: 100.0%
**Gap**: 57 pontos | **Prioridade**: 🟠 **ALTA**

**Por que Impacto 4**:
- ✅ Visualização é core em DS
- ✅ Usado em ~70% dos projetos
- ✅ Único framework de viz moderno em R

**Por que Facilidade 4**:
- ✅ Precision perfeita
- ✅ Padrão direto

**Problemas**: Falta "customizar theme", "facet_wrap", "anotações"

**Ganho esperado**: 33% → 85% (+52 pontos)

---

### 5. r-shiny (Score: 20 - Impacto 4, Facilidade 5)

**Recall atual**: 77.8% | **Precision**: 100.0%
**Gap**: 12 pontos | **Prioridade**: 🟢 **BAIXA** (já bom!)

**Por que Impacto 4**:
- ✅ Aplicações interativas são valiosas
- ✅ Diferencial único do R

**Por que Facilidade 5**:
- ✅ Já está em 77.8% (quase lá!)
- ✅ Precision perfeita
- ✅ Fix rápido

**Problemas**: Apenas "dashboard interativo"

**Ganho esperado**: 78% → 90% (+12 pontos) - **Quick win!**

---

### 6. r-bayes (Score: 8 - Impacto 4, Facilidade 2)

**Recall atual**: 100.0% | **Precision**: 90.0%
**Gap**: 5 pontos precision | **Prioridade**: 🟢 **MANUTENÇÃO**

**Status**: 🎯 **JÁ NO TARGET!**

**Por que Impacto 4**:
- ✅ Bayesian é técnica avançada e valiosa

**Por que Facilidade 2**:
- ⚠️ Precisa apenas filtro para PyMC3/Python
- ✅ Já funciona bem

**Ação**: Adicionar filtro Python, mas não urgente

---

### 7. tidyverse-expert (Score: 12 - Impacto 3, Facilidade 4)

**Recall atual**: 44.4% | **Precision**: 100.0%
**Gap**: 46 pontos | **Prioridade**: 🟠 **MÉDIA**

**Por que Impacto 3**:
- ✅ Manipulação de dados é frequente
- ⚠️ Overlap com r-datascience (menor impacto isolado)

**Por que Facilidade 4**:
- ✅ Precision perfeita
- ✅ Só adicionar verbs

**Problemas**: Falta "join", "mutate", "filter", "select", pipe operators

**Ganho esperado**: 44% → 85% (+41 pontos)

---

### 8. r-text-mining (Score: 15 - Impacto 3, Facilidade 5)

**Recall atual**: 44.4% | **Precision**: 100.0%
**Gap**: 46 pontos | **Prioridade**: 🟠 **MÉDIA**

**Por que Impacto 3**:
- ✅ NLP é crescente
- ⚠️ Nicho (não todo projeto precisa)

**Por que Facilidade 5**:
- ✅ Precision perfeita
- ✅ Padrão direto

**Problemas**: Falta "sentiment analysis", "topic modeling", "n-gram"

**Ganho esperado**: 44% → 85% (+41 pontos)

---

### 9. r-timeseries (Score: 6 - Impacto 3, Facilidade 2)

**Recall atual**: 77.8% | **Precision**: 77.8%
**Gap**: 22 pontos | **Prioridade**: 🟢 **BAIXA** (já bom)

**Por que Impacto 3**:
- ✅ Forecasting é valioso
- ⚠️ Nicho

**Por que Facilidade 2**:
- ⚠️ Precisa filtro forte para Python (Statsmodels, Prophet)
- ⚠️ Ambos recall e precision precisam melhorar

**Problemas**: Ativa para Python, falta "sazonalidade"

**Ganho esperado**: 78% → 85% (+7 pontos)

---

### 10. tdd-workflow (Score: 9 - Impacto 3, Facilidade 3)

**Recall atual**: 33.3% | **Precision**: 100.0%
**Gap**: 57 pontos | **Prioridade**: 🟠 **MÉDIA**

**Por que Impacto 3**:
- ✅ TDD é best practice importante
- ⚠️ Não essencial para análises rápidas

**Por que Facilidade 3**:
- ✅ Precision perfeita
- ⚠️ Precisa cobrir workflow completo

**Problemas**: Falta "escrever testes", "testthat", "unit testing"

**Ganho esperado**: 33% → 80% (+47 pontos)

---

## 🟡 MÉDIA PRIORIDADE (Score 8-14)

### 11. r-package-development (Score: 8 - Impacto 2, Facilidade 4)

**Recall atual**: 44.4% | **Precision**: 100.0%
**Gap**: 46 pontos | **Prioridade**: 🟡 **MÉDIA-BAIXA**

**Por que Impacto 2**:
- ⚠️ Apenas developers criam pacotes (não todo usuário)
- ✅ Mas para quem cria, é essencial

**Ganho esperado**: 44% → 80% (+36 pontos)

---

### 12. r-style-guide (Score: 10 - Impacto 2, Facilidade 5)

**Recall atual**: 33.3% | **Precision**: 75.0%
**Gap**: 57 pontos recall + 20 precision | **Prioridade**: 🟡 **MÉDIA**

**Por que Impacto 2**:
- ⚠️ Style não afeta funcionalidade
- ✅ Mas melhora maintainability

**Por que Facilidade 5 (mas precisa filtros)**:
- ✅ Conceitos simples
- ⚠️ Ativa para JavaScript (precisa filtro)

**Ganho esperado**: 33% → 80% recall, 75% → 95% precision

---

### 13. rlang-patterns (Score: 6 - Impacto 2, Facilidade 3)

**Recall atual**: 33.3% | **Precision**: 100.0%
**Gap**: 57 pontos | **Prioridade**: 🟡 **MÉDIA-BAIXA**

**Por que Impacto 2**:
- ⚠️ Metaprogramação é avançado (poucos usuários)
- ✅ Essencial para package developers

**Ganho esperado**: 33% → 80% (+47 pontos)

---

### 14. dm-relational (Score: 4 - Impacto 1, Facilidade 4)

**Recall atual**: 33.3% | **Precision**: 100.0%
**Gap**: 57 pontos | **Prioridade**: 🟢 **BAIXA**

**Por que Impacto 1**:
- ⚠️ Muito nicho (poucos usam {dm})
- ⚠️ Alternativas comuns (SQL direto)

**Ganho esperado**: 33% → 75% (+42 pontos)

---

### Outros Skills Já Razoáveis:

- **tidyverse-patterns** (50% recall): Complementar, não crítico
- **r-oop** (55.6% recall): Avançado, poucos usuários

---

## 📊 Backlog Priorizado Final

### Sprint 1: Critical Blockers (Semana 1) - **4 skills**

| Prioridade | Skill | Recall | Gap | Tempo | Ganho Esperado |
|------------|-------|--------|-----|-------|----------------|
| ✅ P0 | skillMaker | 0% | - | - | ✅ CONCLUÍDO (100%) |
| 🔴 P1 | **r-datascience** | 25% | 65 pts | 15 min | → 80% (+55) |
| 🔴 P2 | **r-tidymodels** | 22% | 68 pts | 20 min | → 85% (+63) |
| 🔴 P3 | **r-performance** | 11% | 79 pts | 15 min | → 75% (+64) |

**Total Sprint 1**: 50 min, +182 pontos recall, 4 skills corrigidos

**Impacto no recall médio**:
- Antes: 48.2%
- Depois: **~60%** (+11.8 pontos)

---

### Sprint 2: High Value Quick Wins (Semana 2) - **5 skills**

| Prioridade | Skill | Recall | Gap | Tempo | Ganho Esperado |
|------------|-------|--------|-----|-------|----------------|
| 🟠 P4 | **ggplot2** | 33% | 57 pts | 15 min | → 85% (+52) |
| 🟠 P5 | **r-shiny** | 78% | 12 pts | 10 min | → 90% (+12) ⚡ |
| 🟠 P6 | **tidyverse-expert** | 44% | 46 pts | 15 min | → 85% (+41) |
| 🟠 P7 | **r-text-mining** | 44% | 46 pts | 15 min | → 85% (+41) |
| 🟠 P8 | **tdd-workflow** | 33% | 57 pts | 15 min | → 80% (+47) |

**Total Sprint 2**: 70 min, +193 pontos recall, 5 skills corrigidos

**Impacto no recall médio**:
- Antes: ~60%
- Depois: **~72%** (+12 pontos)

---

### Sprint 3: Polish & Maintenance (Semana 3) - **6 skills**

| Prioridade | Skill | Recall | Gap | Tempo | Ganho Esperado |
|------------|-------|--------|-----|-------|----------------|
| 🟡 P9 | **r-package-development** | 44% | 46 pts | 15 min | → 80% (+36) |
| 🟡 P10 | **r-style-guide** | 33% | 57 pts | 20 min | → 80% (+47) |
| 🟡 P11 | **rlang-patterns** | 33% | 57 pts | 15 min | → 80% (+47) |
| 🟡 P12 | **tidyverse-patterns** | 50% | 40 pts | 10 min | → 85% (+35) |
| 🟡 P13 | **r-oop** | 56% | 34 pts | 15 min | → 85% (+29) |
| 🟢 P14 | **r-timeseries** | 78% | 12 pts | 15 min | → 85% (+7) ⚡ |

**Total Sprint 3**: 90 min, +201 pontos recall, 6 skills corrigidos

**Impacto no recall médio**:
- Antes: ~72%
- Depois: **~84%** (+12 pontos)

---

### Sprint 4: Final Touches (Semana 4) - **2 skills**

| Prioridade | Skill | Recall | Gap | Tempo | Ganho Esperado |
|------------|-------|--------|-----|-------|----------------|
| 🟢 P15 | **dm-relational** | 33% | 57 pts | 15 min | → 75% (+42) |
| 🟢 P16 | **r-bayes** (filtro) | 100% | 5 pts prec | 10 min | → 95% prec |

**Total Sprint 4**: 25 min, +42 pontos recall

**Impacto no recall médio**:
- Antes: ~84%
- Depois: **~87%** (+3 pontos)

---

## 📈 Projeção Completa

### Progresso por Sprint

```
Sprint 0 (Inicial):      39.0% recall  ████░░░░░░░░░░░░░░░░
Sprint 1 (skillMaker):   48.2% recall  █████░░░░░░░░░░░░░░░
Sprint 2 (Critical):    ~60.0% recall  ██████░░░░░░░░░░░░░░
Sprint 3 (High Value):  ~72.0% recall  ████████░░░░░░░░░░░░
Sprint 4 (Polish):      ~84.0% recall  █████████░░░░░░░░░░░
Sprint 5 (Final):       ~87.0% recall  ██████████░░░░░░░░░░
Target:                  90.0% recall  ██████████░░░░░░░░░░
```

### Resumo de Esforço

| Sprint | Skills | Tempo Total | Ganho Recall | Recall Final |
|--------|--------|-------------|--------------|--------------|
| 0 (Baseline) | - | - | - | 39.0% |
| 1 (Done) | 1 | 10 min | +9.2% | 48.2% |
| 2 | 3 | 50 min | +11.8% | 60.0% |
| 3 | 5 | 70 min | +12.0% | 72.0% |
| 4 | 6 | 90 min | +12.0% | 84.0% |
| 5 | 2 | 25 min | +3.0% | 87.0% |
| **TOTAL** | **17** | **~4h 15m** | **+48%** | **87.0%** |

---

## 🎯 Estratégia de Execução

### Sessão 1 (HOJE) - 1 hora
- ✅ skillMaker (FEITO)
- 🔄 r-datascience (15 min)
- 🔄 r-tidymodels (20 min)
- 🔄 r-performance (15 min)
- 🔄 Validação (10 min)

**Ganho esperado**: 48% → 60% recall (+11.8 pontos)

### Sessão 2 (AMANHÃ) - 1.5 horas
- ggplot2, r-shiny, tidyverse-expert, r-text-mining, tdd-workflow

**Ganho esperado**: 60% → 72% recall (+12 pontos)

### Sessão 3 (DIA 3) - 1.5 horas
- r-package-dev, r-style-guide, rlang-patterns, tidyverse-patterns, r-oop, r-timeseries

**Ganho esperado**: 72% → 84% recall (+12 pontos)

### Sessão 4 (DIA 4) - 30 min
- dm-relational, r-bayes (polish)

**Ganho esperado**: 84% → 87% recall (+3 pontos)

---

## 💡 Quick Wins (ROI Máximo)

Se tiver apenas **30 minutos hoje**:

1. **r-shiny** (10 min) → 78% → 90% (+12 pontos) ⚡
2. **r-timeseries** (15 min) → 78% → 85% (+7 pontos) ⚡

**Total: 25 min, +19 pontos recall**

Se tiver **1 hora hoje**:

1. r-shiny (10 min)
2. r-datascience (15 min) → +55 pontos
3. r-performance (15 min) → +64 pontos
4. r-timeseries (15 min)

**Total: 55 min, +138 pontos recall acumulado**

---

## 🔍 Decisões Estratégicas

### Por que r-datascience é P1?

É o **skill orquestrador** - quando funciona bem, ativa os outros skills corretos (tidymodels, ggplot2, etc.). É o "ponto de entrada" principal.

**Efeito cascata**:
```
User: "Faça ML em R"
→ r-datascience (25% chance agora, deveria ser 90%)
  → r-tidymodels (se r-datascience detectar corretamente)
    → recipe steps
    → parsnip models
```

Se r-datascience não ativa, **nenhum dos downstream skills ativa**.

### Por que r-tidymodels é P2?

É o **core de ML moderno em R** - diferencial competitivo vs Python. Fix aqui torna R viável para projetos sérios de ML.

### Por que r-performance é P3?

**Alta frequência + alto valor**. Todo código pode ser otimizado. Usuários perguntam "por que está lento?" constantemente.

---

## 📋 Checklist por Skill

Para cada fix:
- [ ] Backup: `cp SKILL.md SKILL.md.backup`
- [ ] Expandir description (10-20 triggers)
- [ ] Adicionar português + inglês
- [ ] Adicionar filtros se precision <95%
- [ ] Testar: `./test_triggers.py --skills <name>`
- [ ] Validar: Recall ≥80%, Precision ≥90%
- [ ] Regression: Testar todos skills
- [ ] Commit com métricas

---

## 🎯 Meta Final

**Objetivo**: ≥85% recall médio, ≥90 skills no target

**Esforço total**: ~4-5 horas

**Resultado esperado**:
- Recall médio: 39% → 87% (+48 pontos, +123% improvement)
- Skills no target: 1 → 12-15 (70-88%)
- Skills perfeitos (100%): 1 → 3-4

**ROI**: ~15 min por skill, +40-60 pontos recall cada

---

*Quer começar com o Sprint 2 (r-datascience, r-tidymodels, r-performance)?* 🚀
