# Guia Prático: Corrigindo Skills com Baixo Recall/Precision

## Como Usar Este Guia

Para cada skill abaixo, você encontrará:
1. **Status atual** (métricas)
2. **Description atual** (problemática)
3. **Description sugerida** (corrigida)
4. **Diff visual** (o que mudou)
5. **Como testar** a correção

---

## 🔴 PRIORIDADE CRÍTICA

### 1. skillMaker (MAIS URGENTE)

**Status**: 0% recall, 0% precision (NUNCA funciona)

**Arquivo**: `.claude/skills/skillMaker/SKILL.md`

**Description ATUAL** (não funciona):
```yaml
description: Create new Claude Code skills following best practices.
```

**Description SUGERIDA** (corrigida):
```yaml
description: Create new Claude Code skills following best practices. Use when user asks to "create a skill", "make a new skill", "build a skill", "generate skill", "novo skill", "criar skill", mentions "skill maker", "skillMaker", discusses creating Claude Code automations, building custom skills, or wants help building custom Claude skills, skill development, skill generation, or custom automation.
```

**Diff**:
```diff
- description: Create new Claude Code skills following best practices.
+ description: Create new Claude Code skills following best practices. Use when user asks to "create a skill", "make a new skill", "build a skill", "generate skill", "novo skill", "criar skill", mentions "skill maker", "skillMaker", discusses creating Claude Code automations, building custom skills, or wants help building custom Claude skills, skill development, skill generation, or custom automation.
```

**Trigger phrases adicionadas**:
- "create a skill"
- "make a new skill"
- "build a skill"
- "generate skill"
- "novo skill" (português)
- "criar skill" (português)
- "skill maker"
- "skillMaker"
- "Claude Code automations"
- "custom skills"
- "skill development"
- "skill generation"

**Testar**:
```bash
./test_triggers.py --skills skillMaker --verbose
# Target: Recall ≥80%, Precision ≥90%
```

---

### 2. r-performance

**Status**: 11.1% recall, 50.0% precision

**Arquivo**: `.claude/skills/r-performance/SKILL.md`

**Description ATUAL**:
```yaml
description: R performance best practices including profiling, benchmarking, vctrs, and optimization strategies.
```

**Description SUGERIDA**:
```yaml
description: R performance best practices including profiling, benchmarking, vctrs, and optimization strategies. Use when mentions "profiling", "profvis", "benchmark", "bench::mark", "slow code", "código lento", "lento", "slow", "optimize R", "otimizar R", "otimizar código", "vectorization", "vectorizar", "vectorize", "performance", "memory usage", "bottleneck", "gargalo", "speed up", "acelerar", "parallel processing", "Rcpp", "system.time", or optimizing R code performance.
```

**Trigger phrases adicionadas**:
- "código lento" / "lento" / "slow code" / "slow"
- "otimizar R" / "otimizar código" / "optimize R"
- "vectorizar" / "vectorize" / "vectorization"
- "gargalo" / "bottleneck"
- "acelerar" / "speed up"
- "parallel processing"
- "memory usage"

**IMPORTANTE**: Adicionar filtro para evitar Python:
- NÃO ativar se prompt menciona "Python", "pandas", "numpy"

**Testar**:
```bash
./test_triggers.py --skills r-performance --verbose
# Target: Recall ≥70%, Precision ≥85%
```

---

### 3. r-datascience

**Status**: 12.5% recall, 50.0% precision

**Arquivo**: `.claude/skills/r-datascience/SKILL.md`

**Description ATUAL**:
```yaml
description: Expert R data science using tidyverse and tidymodels. Use when working with data in R, mentions "tidyverse", "dplyr", "data wrangling", "machine learning", "statistical modeling", "ggplot2", "data visualization", "predictive modeling", "feature engineering", "model training", "cross-validation", or any data science task in R.
```

**Description SUGERIDA**:
```yaml
description: Expert R data science using tidyverse and tidymodels. Use when working with data in R, mentions "tidyverse", "dplyr", "data wrangling", "análise de dados", "análise estatística", "data analysis", "statistical analysis", "machine learning in R", "ML em R", "statistical modeling", "modelagem estatística", "ggplot2", "data visualization", "visualização de dados", "predictive modeling", "feature engineering", "engenharia de features", "model training", "treinar modelo", "cross-validation", "validação cruzada", or any data science task in R. ONLY activate for R language tasks - do NOT activate for Python, pandas, scikit-learn, or other languages.
```

**Trigger phrases adicionadas**:
- "análise de dados" / "data analysis"
- "análise estatística" / "statistical analysis"
- "ML em R" / "machine learning in R"
- "modelagem estatística"
- "visualização de dados"
- "engenharia de features"
- "treinar modelo" / "model training"
- "validação cruzada" / "cross-validation"

**FILTRO CRÍTICO adicionado**:
- "ONLY activate for R language tasks - do NOT activate for Python, pandas, scikit-learn"

**Testar**:
```bash
./test_triggers.py --skills r-datascience --verbose
# Target: Recall ≥70%, Precision ≥85%
```

---

## 🟠 PRIORIDADE ALTA

### 4. r-tidymodels

**Status**: 22.2% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Expert R data science using tidymodels for machine learning. Use when working with tidymodels, recipes, parsnip, tune, workflows, user mentions "machine learning in R", "ML em R", "predictive modeling", "modelagem preditiva", "modelo de classificação", "classification model", "modelo de regressão", "regression model", "feature engineering", "engenharia de features", "model tuning", "tunear modelo", "hyperparameters", "hiperparâmetros", "cross-validation", "validação cruzada", "cv", discusses ML workflows, data preprocessing, recipe steps, or model development in R.
```

**Trigger phrases adicionadas**:
- "modelo de classificação" / "classification model"
- "modelo de regressão" / "regression model"
- "tunear modelo" / "tuning" / "tunar"
- "hiperparâmetros" / "hyperparameters"
- "validação cruzada" / "cv"
- "recipe steps"
- "data preprocessing"

---

### 5. ggplot2

**Status**: 33.3% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Expert ggplot2 data visualization in R - grammar of graphics, geoms, themes, scales, faceting, and styling. Use when user works with ggplot2, mentions "ggplot", "geom_", creates visualizations in R, asks about "plot customization", "customizar plot", "customizar theme", "customize theme", "themes", "faceting", "facet_wrap", "facet_grid", "anotações", "annotations", "annotate", "scales", "color scale", "gráfico", "plot", "visualização", or data visualization best practices in R.
```

**Trigger phrases adicionadas**:
- "customizar plot" / "customizar theme" / "customize theme"
- "facet_wrap" / "facet_grid" / "faceting"
- "anotações" / "annotations" / "annotate"
- "color scale" / "scales"
- "gráfico" / "plot" / "visualização"

---

### 6. r-text-mining

**Status**: 33.3% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Expert text mining and NLP in R using tidytext and textrecipes. Use when analyzing text data, mentions "text analysis", "análise de texto", "NLP", "processamento de linguagem natural", "sentiment analysis", "análise de sentimento", "topic modeling", "modelagem de tópicos", "tidytext", "textrecipes", "tokenization", "tokenização", "TF-IDF", "text classification", "classificação de texto", "word embeddings", "n-gram", "ngram", "natural language processing", or any text/NLP task in R.
```

**Trigger phrases adicionadas**:
- "análise de texto" / "text analysis"
- "processamento de linguagem natural" / "NLP"
- "análise de sentimento" / "sentiment analysis"
- "modelagem de tópicos" / "topic modeling"
- "tokenização" / "tokenization"
- "classificação de texto" / "text classification"
- "n-gram" / "ngram"

---

### 7. r-style-guide

**Status**: 33.3% recall, 75.0% precision

**Description SUGERIDA**:
```yaml
description: R style guide covering naming conventions, spacing, layout, and function design best practices. Use when mentions "snake_case", "camelCase", "code style", "estilo de código", "coding style", "naming convention", "convenção de nomes", "R style guide", "function design", "code formatting", "formatar código", "format code", "tidyverse style", "lintr", "styler", "best practices", "melhores práticas", or asks about R coding standards and conventions. ONLY for R language - do NOT activate for Python, JavaScript, or other languages.
```

**Trigger phrases adicionadas**:
- "estilo de código" / "code style" / "coding style"
- "convenção de nomes" / "naming convention"
- "formatar código" / "format code"
- "melhores práticas" / "best practices"
- "lintr" / "styler"

**FILTRO adicionado**:
- "ONLY for R language - do NOT activate for Python, JavaScript"

---

### 8. tdd-workflow

**Status**: 33.3% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Test-driven development workflow for R using testthat. Use when mentions "TDD", "test-driven", "test driven development", "testthat", "test_that", "expect_", "unit test", "unit testing", "testes unitários", "escrever testes", "write tests", "test coverage", "cobertura de testes", "covr", "red-green-refactor", "test first", or writing new features, fixing bugs, or refactoring code with tests. Enforces test-first development with 80%+ coverage.
```

**Trigger phrases adicionadas**:
- "test driven development"
- "unit testing" / "testes unitários"
- "escrever testes" / "write tests"
- "test coverage" / "cobertura de testes"
- "red-green-refactor"
- "test first"

---

### 9. dm-relational

**Status**: 33.3% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Relational data modeling with {dm} package - create, visualize, and manipulate multi-table data models with primary/foreign keys. Use when mentions "dm package", "{dm}", "relational data", "dados relacionais", "primary key", "chave primária", "foreign key", "chave estrangeira", "data model", "modelo de dados", "multi-table", "múltiplas tabelas", "multi table", "dm_from_data_frames", "dm_add_pk", "dm_add_fk", "dm_draw", "database schema", "esquema de banco", "schema", or working with related data frames or relational databases in R.
```

**Trigger phrases adicionadas**:
- "dados relacionais" / "relational data"
- "chave primária" / "primary key"
- "chave estrangeira" / "foreign key"
- "modelo de dados" / "data model"
- "múltiplas tabelas" / "multi-table" / "multi table"
- "esquema de banco" / "database schema" / "schema"
- Todas as funções dm_*

---

### 10. rlang-patterns

**Status**: 33.3% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: rlang metaprogramming patterns for data-masking, injection operators, and dynamic dots. Use when mentions "tidy evaluation", "tidy eval", "avaliação tidy", "rlang", "data-masking", "data masking", "máscara de dados", "embrace", "{{}}", "enquo", "!!", "!!!", "injection", "injeção", "dynamic dots", "...", "dot-dot-dot", "metaprogramming", "metaprogramação", "NSE", "non-standard evaluation", "avaliação não padrão", or writing functions that use tidy evaluation in R.
```

**Trigger phrases adicionadas**:
- "tidy eval" / "avaliação tidy"
- "data masking" / "máscara de dados"
- "embrace" / "{{}}"
- "enquo" / "!!" / "!!!"
- "injeção" / "injection"
- "dynamic dots" / "..." / "dot-dot-dot"
- "metaprogramação" / "metaprogramming"
- "avaliação não padrão" / "non-standard evaluation"

---

### 11. tidyverse-expert

**Status**: 44.4% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Expert R data manipulation with tidyverse - dplyr, tidyr, purrr, stringr, forcats, lubridate. Use when working with tidyverse, mentions "dplyr verbs", "dplyr", "filter", "select", "mutate", "summarize", "summarise", "arrange", "group_by", "join", "joins", "data wrangling", "data manipulation", "manipulação de dados", "tidyr pivoting", "pivot_longer", "pivot_wider", "pivot", "purrr map", "map", "map_dbl", "string manipulation", "manipulação de strings", "stringr", "factors", "forcats", "dates in R", "datas em R", "lubridate", or discusses advanced data transformation patterns, joins, nesting, functional programming, or complex data cleaning tasks in R. Recognizes pipe operators %>% and |>.
```

**Trigger phrases adicionadas**:
- Todos os verbos principais: "filter", "select", "mutate", "summarize", "arrange"
- "group_by" / "join" / "joins"
- "manipulação de dados" / "data manipulation"
- "pivot_longer" / "pivot_wider" / "pivot"
- "map" / "map_dbl"
- "manipulação de strings" / "string manipulation"
- "datas em R" / "dates in R"
- Pipe operators: %>% e |>

---

### 12. r-package-development

**Status**: 44.4% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: R package development guide covering dependencies, API design, testing, and documentation. Use when mentions "R package", "pacote R", "criar pacote", "create package", "devtools", "usethis", "roxygen2", "DESCRIPTION", "NAMESPACE", "pkgdown", "package structure", "estrutura de pacote", "vignette", "package documentation", "documentação de pacote", "R CMD check", "CRAN submission", "submissão CRAN", "submeter ao CRAN", or developing R packages.
```

**Trigger phrases adicionadas**:
- "pacote R" / "R package"
- "criar pacote" / "create package"
- "estrutura de pacote" / "package structure"
- "documentação de pacote" / "package documentation"
- "submissão CRAN" / "submeter ao CRAN" / "CRAN submission"
- Todos os packages: devtools, usethis, roxygen2, pkgdown

---

## 🟡 PRIORIDADE MÉDIA

### 13. tidyverse-patterns

**Status**: 50.0% recall, 100% precision

**Description SUGERIDA**:
```yaml
description: Modern tidyverse patterns for R including pipes, joins, grouping, purrr, and stringr. Use when mentions "native pipe", "pipe nativo", "|>", "pipe operator", "operador pipe", "join_by", ".by grouping", "per-operation grouping", "agrupamento por operação", "across()", "pick()", "reframe()", "list_rbind", "modern tidyverse", "tidyverse moderno", "dplyr 1.1", "latest dplyr", "new dplyr features", "novidades dplyr", or writing modern tidyverse R code with latest patterns.
```

**Trigger phrases adicionadas**:
- "pipe nativo" / "native pipe" / "|>"
- "operador pipe" / "pipe operator"
- "agrupamento por operação" / "per-operation grouping"
- "tidyverse moderno" / "modern tidyverse"
- "dplyr 1.1" / "latest dplyr" / "new dplyr features" / "novidades dplyr"
- Funções modernas: across(), pick(), reframe(), list_rbind

---

### 14. r-oop

**Status**: 55.6% recall, 83.3% precision

**Description SUGERIDA**:
```yaml
description: R object-oriented programming guide for S7, S3, S4, and vctrs. Use when mentions "S3 class", "S4 class", "S7", "vctrs", "new_class", "setClass", "setGeneric", "setMethod", "object-oriented", "orientação a objetos", "OOP in R", "OOP em R", "method dispatch", "despacho de métodos", "class definition", "definição de classe", "generic functions", "funções genéricas", "inheritance", "herança", or designing R classes and choosing an OOP system. ONLY for R - do NOT activate for Python classes, Java OOP, or other languages.
```

**Trigger phrases adicionadas**:
- "orientação a objetos" / "object-oriented"
- "OOP em R" / "OOP in R" (não apenas "OOP")
- "despacho de métodos" / "method dispatch"
- "definição de classe" / "class definition"
- "funções genéricas" / "generic functions"
- "herança" / "inheritance"

**FILTRO adicionado**:
- "ONLY for R - do NOT activate for Python classes, Java OOP"

---

### 15. r-shiny

**Status**: 66.7% recall, 100% precision (já está bom, mas pode melhorar)

**Description SUGERIDA**:
```yaml
description: Expert Shiny app development in R - reactive programming, UI design, modules, performance, and security. Use when working with shiny, shinydashboard, "dashboard interativo", "interactive dashboard", "dashboard em R", "R dashboard", "aplicativo R", "R app", "aplicação Shiny", "Shiny application", or building interactive R web applications. Triggers on shiny library imports, server/ui function patterns, "ui <- fluidPage", "server <- function", reactive expressions, "reactive", "observe", "renderPlot", or user requests for Shiny help.
```

**Trigger phrases adicionadas**:
- "dashboard interativo" / "interactive dashboard"
- "dashboard em R" / "R dashboard"
- "aplicativo R" / "R app"
- "aplicação Shiny" / "Shiny application"
- Code patterns: "ui <- fluidPage", "server <- function"

---

### 16. r-timeseries

**Status**: 66.7% recall, 75.0% precision

**Description SUGERIDA**:
```yaml
description: Expert time series forecasting and analysis in R using fable/tsibble. Use when forecasting, analyzing time series data, mentions "ARIMA", "ETS", "seasonality", "sazonalidade", "análise temporal", "time series analysis", "fable", "tsibble", "feasts", "forecast", "previsão", "forecasting in R", "temporal data", "dados temporais", "trend", "tendência", "prophet in R", "time-based prediction", "predição temporal", or any time series task in R. ONLY activate for R language - do NOT activate for Python statsmodels, Prophet Python, pandas time series, or other languages.
```

**Trigger phrases adicionadas**:
- "sazonalidade" / "seasonality"
- "análise temporal" / "time series analysis"
- "previsão" / "forecast"
- "forecasting in R" (não apenas "forecasting")
- "dados temporais" / "temporal data"
- "tendência" / "trend"
- "prophet in R" (não "prophet" genérico)
- "predição temporal" / "time-based prediction"

**FILTRO CRÍTICO adicionado**:
- "ONLY activate for R - do NOT activate for Python statsmodels, Prophet Python, pandas"

---

## 🟢 PRIORIDADE BAIXA (Já está bom)

### 17. r-bayes

**Status**: 88.9% recall, 88.9% precision ⭐ MELHOR SKILL!

**Ação**: Apenas ajuste fino

**Description SUGERIDA** (pequeno ajuste):
```yaml
description: Patterns for Bayesian inference in R using brms, including multilevel models, DAG validation, and marginal effects. Use when mentions "Bayesian", "Bayesiana", "Bayesian in R", "inferência Bayesiana", "brms", "Stan", "cmdstanr", "multilevel model", "hierarchical model", "modelo hierárquico", "random effects", "efeitos aleatórios", "prior specification", "especificação de priors", "posterior distribution", "distribuição posterior", "MCMC", "Markov Chain Monte Carlo", "DAG", "causal inference", "inferência causal", "marginal effects", "efeitos marginais", "tidybayes", "convergence", "convergência", or performing Bayesian statistical analysis in R. ONLY for R - do NOT activate for PyMC3, PyMC, or Python Bayesian tools.
```

**Ajustes mínimos**:
- Adicionar "convergência" / "convergence"
- Adicionar "Bayesian in R" (não apenas "Bayesian")
- Adicionar filtro para PyMC/Python

---

## 🔄 Workflow de Correção

Para cada skill:

### 1. Backup
```bash
cp .claude/skills/<skill-name>/SKILL.md .claude/skills/<skill-name>/SKILL.md.backup
```

### 2. Editar
```bash
vim .claude/skills/<skill-name>/SKILL.md
# Atualizar o campo description: no frontmatter YAML
```

### 3. Testar
```bash
./test_triggers.py --skills <skill-name> --verbose
```

### 4. Validar
- ✅ Recall aumentou ≥20 pontos?
- ✅ Precision manteve ≥90%?
- ✅ Zero false positives para outras linguagens?

### 5. Testar Regression
```bash
# Testar TODOS os skills para garantir não quebrou outros
./test_triggers.py --output results_after_fix.json
```

### 6. Comparar
```bash
# Comparar antes e depois
python3 -c "
import json
before = json.load(open('full_test_results.json'))
after = json.load(open('results_after_fix.json'))

for skill in before['skills']:
    if skill in after['skills']:
        b = before['skills'][skill]['metrics']
        a = after['skills'][skill]['metrics']
        print(f'{skill}:')
        print(f'  Recall:    {b[\"recall\"]:.1%} → {a[\"recall\"]:.1%} ({a[\"recall\"]-b[\"recall\"]:+.1%})')
        print(f'  Precision: {b[\"precision\"]:.1%} → {a[\"precision\"]:.1%} ({a[\"precision\"]-b[\"precision\"]:+.1%})')
"
```

### 7. Commit
```bash
git add .claude/skills/<skill-name>/SKILL.md
git commit -m "Fix <skill-name> triggers: recall ${OLD}% → ${NEW}%

- Added trigger phrases: ...
- Added language filters: ...
- Test results: recall ${NEW}%, precision ${NEW_P}%"
```

---

## 📊 Tracking Progress

Criar arquivo `FIXES_TRACKING.md`:

```markdown
# Skill Fixes Progress

## Sprint 1 - Critical Fixes

- [ ] skillMaker (0% → 80% target)
  - [ ] Update description
  - [ ] Test
  - [ ] Validate
  - [ ] Commit
  - Result: ___% recall, ___% precision

- [ ] r-performance (11% → 70% target)
  - [ ] Update description
  - [ ] Add R filter
  - [ ] Test
  - [ ] Validate
  - [ ] Commit
  - Result: ___% recall, ___% precision

- [ ] r-datascience (12% → 70% target)
  - [ ] Update description
  - [ ] Add Python filter
  - [ ] Test
  - [ ] Validate
  - [ ] Commit
  - Result: ___% recall, ___% precision

## Sprint 2 - High Priority Fixes

- [ ] r-tidymodels (22% → 80% target)
- [ ] ggplot2 (33% → 80% target)
- [ ] r-text-mining (33% → 80% target)
- [ ] r-style-guide (33% → 80% target)
- [ ] tdd-workflow (33% → 80% target)
- [ ] dm-relational (33% → 80% target)
- [ ] rlang-patterns (33% → 80% target)
- [ ] tidyverse-expert (44% → 80% target)
- [ ] r-package-development (44% → 80% target)

## Sprint 3 - Polish

- [ ] tidyverse-patterns (50% → 85% target)
- [ ] r-oop (56% → 85% target)
- [ ] r-shiny (67% → 90% target)
- [ ] r-timeseries (67% → 90% target)
- [ ] r-bayes (89% → 95% target) ⭐
```

---

## ✅ Checklist Final

Antes de considerar um skill "fixed":

- [ ] Description tem 8+ trigger phrases?
- [ ] Inclui português E inglês?
- [ ] Inclui package names?
- [ ] Inclui function names?
- [ ] Inclui conceitos do domínio?
- [ ] Tem filtro para outras linguagens (se aplicável)?
- [ ] Recall ≥80%?
- [ ] Precision ≥90%?
- [ ] Zero regression em outros skills?
- [ ] Testado com prompts reais de usuários?
- [ ] Committed com mensagem descritiva?

---

*Use este guia como referência durante o processo de correção dos skills. Bom trabalho!* 🚀
