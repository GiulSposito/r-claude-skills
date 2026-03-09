# Estratégia de Testes para Skills de R & Data Science

## Objetivo

Avaliar se os skills transformam o Claude em um especialista completo em Data Science e R Programming, verificando:
1. **Abrangência**: Cobertura completa dos domínios
2. **Ativação Correta**: Triggers funcionam nos contextos apropriados
3. **Agregação de Valor**: Orientações levam a código de qualidade production-ready

---

## Inventário de Skills (17 skills R/Data Science)

### Skills Core de Data Science
1. **r-datascience** - Orquestrador geral tidyverse/tidymodels
2. **tidyverse-expert** - Manipulação de dados (dplyr, tidyr, purrr, stringr, forcats, lubridate)
3. **tidyverse-patterns** - Padrões modernos (pipe nativo, join_by, .by grouping)

### Skills de Machine Learning
4. **r-tidymodels** - Framework completo de ML (recipes, parsnip, tune, workflows)
5. **r-bayes** - Inferência Bayesiana (brms, Stan, multilevel models)
6. **r-timeseries** - Forecasting (fable, tsibble, ARIMA, ETS)
7. **r-text-mining** - NLP e text mining (tidytext, textrecipes)

### Skills de Visualização
8. **ggplot2** - Visualização especializada (gramática de gráficos)

### Skills de Desenvolvimento
9. **r-package-development** - Criação de pacotes (devtools, usethis, roxygen2)
10. **r-oop** - OOP em R (S3, S4, S7, vctrs)
11. **r-performance** - Otimização (profiling, benchmarking, vectorization)
12. **r-style-guide** - Convenções de código (tidyverse style)
13. **tdd-workflow** - TDD com testthat

### Skills de Aplicações
14. **r-shiny** - Apps web interativos (reactive programming, modules)
15. **dm-relational** - Modelagem relacional ({dm} package)
16. **rlang-patterns** - Metaprogramação (tidy evaluation, data-masking)

---

## Dimensões de Avaliação

### 1. Cobertura de Conhecimento (Abrangência)

Avaliar se cada skill cobre **todos os cenários principais** de sua área:

#### Checklist por Skill

**r-datascience** (skill orquestrador):
- [ ] Referencia os outros skills especializados adequadamente
- [ ] Cobre workflow end-to-end: import → wrangle → visualize → model → communicate
- [ ] Inclui data splitting, feature engineering, model evaluation
- [ ] Contempla tanto statistical learning quanto machine learning

**tidyverse-expert**:
- [ ] Cobre todas as operações dplyr (filter, select, mutate, summarize, arrange, joins)
- [ ] Inclui tidyr completo (pivot, nest, unnest, separate, complete)
- [ ] Abrange purrr (map family, safely, possibly, walk)
- [ ] Contempla stringr, forcats, lubridate com exemplos práticos
- [ ] Documenta across(), rowwise(), window functions

**r-tidymodels**:
- [ ] Cobre workflow completo: split → recipe → model → workflow → tune → evaluate
- [ ] Inclui ~100 recipe steps mais comuns
- [ ] Documenta ~50 modelos principais (parsnip)
- [ ] Contempla resampling (cross-validation, bootstrap)
- [ ] Abrange hyperparameter tuning
- [ ] Inclui model stacking e ensembles
- [ ] Documenta class imbalance (themis)

**ggplot2**:
- [ ] Cobre todos os geoms principais (20+ geoms)
- [ ] Inclui scales (continuous, discrete, date, color)
- [ ] Documenta themes e customização
- [ ] Contempla faceting (facet_wrap, facet_grid)
- [ ] Abrange position adjustments
- [ ] Inclui statistical transformations

**r-shiny**:
- [ ] Cobre reactive programming (reactive, observe, eventReactive)
- [ ] Inclui UI design patterns
- [ ] Documenta modules para reutilização
- [ ] Contempla performance (caching, async)
- [ ] Abrange security best practices

**r-bayes**:
- [ ] Cobre priors specification
- [ ] Inclui multilevel/hierarchical models
- [ ] Documenta posterior distribution analysis
- [ ] Contempla model comparison (LOO, WAIC)
- [ ] Abrange marginal effects

**r-timeseries**:
- [ ] Cobre tsibble data structure
- [ ] Inclui ARIMA, ETS, Prophet
- [ ] Documenta seasonality handling
- [ ] Contempla forecast evaluation
- [ ] Abrange feature engineering temporal

**r-text-mining**:
- [ ] Cobre tokenization (word, sentence, ngram)
- [ ] Inclui TF-IDF
- [ ] Documenta sentiment analysis
- [ ] Contempla topic modeling
- [ ] Abrange text classification com tidymodels

**r-performance**:
- [ ] Cobre profiling (profvis)
- [ ] Inclui benchmarking (bench::mark)
- [ ] Documenta vectorization
- [ ] Contempla memory optimization
- [ ] Abrange parallel processing

**r-package-development**:
- [ ] Cobre package structure (DESCRIPTION, NAMESPACE)
- [ ] Inclui roxygen2 documentation
- [ ] Documenta testing com testthat
- [ ] Contempla vignettes
- [ ] Abrange CRAN submission

### 2. Precisão de Ativação (Triggers)

Avaliar se os skills são **invocados automaticamente** nos contextos corretos:

#### Testes de Trigger por Categoria

##### A. Testes de Trigger Direto (Positivos)
Frases que **devem** ativar cada skill:

**r-datascience**:
- "Preciso fazer uma análise de dados em R"
- "Como faço machine learning com tidymodels?"
- "Quero wrangle este dataset"
- "Me ajude com data wrangling em R"

**tidyverse-expert**:
- "Como uso dplyr para filtrar dados?"
- "Preciso pivotar uma tabela com tidyr"
- "Como mapear uma função com purrr?"
- "Manipule strings com stringr"

**r-tidymodels**:
- "Quero treinar um modelo de classificação"
- "Como faço feature engineering com recipes?"
- "Preciso fazer cross-validation"
- "Como tunear hyperparâmetros?"

**ggplot2**:
- "Crie um gráfico com ggplot2"
- "Como customizar o theme deste plot?"
- "Preciso fazer um geom_boxplot"
- "Faça um facet_wrap por categoria"

**r-shiny**:
- "Crie um Shiny app"
- "Como faço reactive programming?"
- "Preciso usar shinymodules"
- "Construa um dashboard interativo"

**r-bayes**:
- "Quero fazer inferência Bayesiana"
- "Como uso brms para multilevel model?"
- "Especifique priors para este modelo"
- "Preciso de análise Bayesiana com Stan"

**r-timeseries**:
- "Como faço forecasting em R?"
- "Preciso modelar séries temporais com ARIMA"
- "Use fable para prever vendas"
- "Análise de sazonalidade"

**r-text-mining**:
- "Preciso fazer sentiment analysis"
- "Como tokenizar texto em R?"
- "Quero TF-IDF destes documentos"
- "Faça topic modeling"

**r-performance**:
- "Este código está lento, como otimizar?"
- "Preciso fazer profiling em R"
- "Como vectorizar este loop?"
- "Benchmarque estas funções"

**r-package-development**:
- "Quero criar um pacote R"
- "Como documento funções com roxygen2?"
- "Configure testthat para este package"
- "Prepare para submissão no CRAN"

##### B. Testes de Contexto Implícito (Positivos)
Situações onde o skill **deve** ativar sem menção explícita:

1. **Detecção de código R**:
   - Ver `library(tidyverse)` → ativar tidyverse-expert
   - Ver `library(tidymodels)` → ativar r-tidymodels
   - Ver `library(shiny)` → ativar r-shiny
   - Ver `brm()` ou `library(brms)` → ativar r-bayes

2. **Detecção de padrões de código**:
   - Ver `%>%` ou `|>` com dplyr verbs → ativar tidyverse-expert
   - Ver `recipe() |> step_*()` → ativar r-tidymodels
   - Ver `ggplot() + geom_*()` → ativar ggplot2
   - Ver `ui <- fluidPage()` → ativar r-shiny

3. **Detecção por estrutura de projeto**:
   - Ver arquivos .R com roxygen comments → ativar r-package-development
   - Ver `tests/testthat/` directory → ativar tdd-workflow
   - Ver `.Rproj` + múltiplos scripts → ativar r-style-guide

##### C. Testes de Não-Ativação (Negativos)
Situações onde o skill **não deve** ativar:

1. **Outras linguagens**:
   - "Crie um modelo de ML em Python" → NÃO ativar r-tidymodels
   - "Análise de dados com pandas" → NÃO ativar tidyverse-expert

2. **Contextos ambíguos**:
   - "Como fazer gráficos?" (sem mencionar R) → NÃO ativar ggplot2 ainda
   - "Preciso de um dashboard" (sem contexto) → NÃO ativar r-shiny

3. **Overlaps controlados**:
   - Quando múltiplos skills se aplicam, verificar hierarquia:
     - "ML em R" → r-datascience (orquestrador) + r-tidymodels (específico)
     - "Plot com tidyverse" → tidyverse-expert + ggplot2

##### D. Testes de Coordenação entre Skills
Cenários que **exigem múltiplos skills**:

1. **Pipeline completo**:
   - "Construa um modelo preditivo do zero" → r-datascience + tidyverse-expert + r-tidymodels + ggplot2

2. **App com ML**:
   - "Shiny app com modelo de previsão" → r-shiny + r-tidymodels + ggplot2

3. **Package com modelo**:
   - "Pacote R com funções de forecasting" → r-package-development + r-timeseries + tdd-workflow + r-style-guide

4. **Análise Bayesiana visual**:
   - "Modelo Bayesiano com diagnósticos visuais" → r-bayes + ggplot2

### 3. Qualidade das Orientações (Agregação de Valor)

Avaliar se as orientações geram **código production-ready**:

#### Critérios de Qualidade

##### A. Correção Técnica
- [ ] Código sintaticamente correto (sem erros)
- [ ] Usa APIs atualizadas (não deprecated)
- [ ] Segue padrões modernos (native pipe `|>` em vez de `%>%` quando apropriado)
- [ ] Implementa best practices do pacote

**Exemplo de teste**:
```
Prompt: "Crie um modelo de random forest com tidymodels"

Verificar que usa:
✓ rand_forest() com engine = "ranger" (não randomForest deprecated)
✓ mode = "classification" ou "regression" explícito
✓ set_mode() e set_engine() corretos
✓ workflow() wrapping recipe + model
✓ Não usa model %>% fit() diretamente sem recipe
```

##### B. Completude
- [ ] Inclui todos os passos necessários (não pula etapas)
- [ ] Adiciona tratamento de erros quando apropriado
- [ ] Documenta assumptions e limitações
- [ ] Fornece código executável end-to-end

**Exemplo de teste**:
```
Prompt: "Pipeline de ML para classificação binária"

Verificar que inclui:
✓ Data splitting (initial_split)
✓ Recipe com feature engineering
✓ Model specification
✓ Workflow bundling
✓ Resampling strategy (vfold_cv)
✓ Fit e avaliação
✓ Final fit no full training set
✓ Predict em test set
✗ Não pula diretamente para fit() sem recipe
```

##### C. Eficiência
- [ ] Usa operações vectorizadas (não loops desnecessários)
- [ ] Aproveita lazy evaluation
- [ ] Evita cópias desnecessárias de dados
- [ ] Sugere parallel processing quando apropriado

**Exemplo de teste**:
```
Prompt: "Calcule média por grupo para 100 colunas"

Verificar que usa:
✓ across(where(is.numeric), mean, .names = "{col}_mean")
✗ Não cria 100 mutate() calls separados
✗ Não usa loops for()
```

##### D. Legibilidade
- [ ] Nomes descritivos (não `df`, `x`, `temp`)
- [ ] Pipes bem formatados
- [ ] Comentários explicativos em código complexo
- [ ] Estrutura lógica clara

##### E. Reprodutibilidade
- [ ] Usa `set.seed()` quando há aleatoriedade
- [ ] Documenta versões de pacotes quando relevante
- [ ] Código independente (não assume estado global)

##### F. Segurança
- [ ] Valida inputs quando necessário
- [ ] Não expõe dados sensíveis em Shiny apps
- [ ] Sanitiza SQL queries (quando aplicável)
- [ ] Trata edge cases (missing values, empty datasets)

---

## Metodologia de Teste

### Fase 1: Testes de Cobertura (Manual Review)

**Objetivo**: Verificar se cada skill documenta completamente seu domínio

**Método**:
1. Para cada skill, abrir SKILL.md completo
2. Listar todas as funções/conceitos principais do domínio (referência: documentação oficial)
3. Verificar se cada conceito está documentado
4. Identificar gaps de conhecimento

**Output**: Matriz de cobertura
```
Skill              | Conceitos Total | Conceitos Cobertos | % Cobertura | Gaps Identificados
-------------------|-----------------|-----------------------|-------------|-------------------
r-tidymodels       | 150             | 140                   | 93%         | model stacking, calibration
tidyverse-expert   | 80              | 75                    | 94%         | across() edge cases
ggplot2            | 60              | 58                    | 97%         | annotation_raster()
...
```

### Fase 2: Testes de Ativação (Automatizado + Manual)

**Objetivo**: Verificar se triggers funcionam corretamente

**Método Automatizado**:
```python
# Pseudocódigo para teste automatizado
test_triggers = {
    "r-tidymodels": [
        "Crie um modelo de random forest",
        "Como fazer cross-validation?",
        "Feature engineering com recipes"
    ],
    "ggplot2": [
        "Faça um gráfico de dispersão",
        "Como customizar ggplot theme?",
        "Crie um facet_wrap"
    ],
    # ... todos os skills
}

for skill, prompts in test_triggers.items():
    for prompt in prompts:
        invoked_skills = claude.chat(prompt).skills_invoked
        assert skill in invoked_skills, f"{skill} não ativou para: {prompt}"
```

**Método Manual**:
1. Para cada skill, criar 10 prompts de teste (5 positivos, 5 de contexto)
2. Executar cada prompt em sessão limpa do Claude Code
3. Verificar quais skills foram invocados (via logs ou observação)
4. Documentar falsos negativos (skill deveria ativar mas não ativou)
5. Documentar falsos positivos (skill ativou incorretamente)

**Output**: Taxa de ativação
```
Skill              | True Positives | False Negatives | False Positives | Precision | Recall
-------------------|----------------|-----------------|-----------------|-----------|--------
r-tidymodels       | 9/10           | 1/10            | 0/10            | 100%      | 90%
ggplot2            | 10/10          | 0/10            | 1/10            | 91%       | 100%
...
```

### Fase 3: Testes de Qualidade (Code Review)

**Objetivo**: Verificar se o código gerado é production-ready

**Método**:
1. Para cada skill, criar 5 cenários realistas
2. Gerar código completo com Claude usando o skill
3. Code review com checklist de qualidade (seção 3)
4. Executar código em ambiente R limpo
5. Rodar linters (lintr, styler) no código gerado
6. Verificar performance com profvis/bench se relevante

**Cenários de Teste por Skill**:

**r-tidymodels**:
- [ ] Classificação binária end-to-end (data split → recipe → model → tuning → evaluation)
- [ ] Regressão com ensemble de modelos
- [ ] Text classification com textrecipes
- [ ] Time series forecast com modeltime (extensão tidymodels)
- [ ] Class imbalance handling com themis

**tidyverse-expert**:
- [ ] Wrangling dataset com joins complexos
- [ ] Pivoting wide ↔ long com múltiplas colunas
- [ ] Nested data frames com purrr map
- [ ] String manipulation com regex
- [ ] Date-time parsing e arithmetic

**ggplot2**:
- [ ] Multi-panel plot com facets
- [ ] Custom theme completo
- [ ] Annotation layers
- [ ] Secondary axis
- [ ] Export high-res para publicação

**r-shiny**:
- [ ] App com reactive data processing
- [ ] Modularized app (modules)
- [ ] Performance optimization (caching)
- [ ] User authentication
- [ ] File upload e processing

**r-bayes**:
- [ ] Multilevel model com brms
- [ ] Prior sensitivity analysis
- [ ] Posterior predictive checks
- [ ] Model comparison (LOO)
- [ ] Marginal effects visualization

**Output**: Scorecard de qualidade
```
Skill              | Correção | Completude | Eficiência | Legibilidade | Reprodutibilidade | Score Total
-------------------|----------|------------|------------|--------------|-------------------|------------
r-tidymodels       | 5/5      | 5/5        | 4/5        | 5/5          | 5/5               | 24/25 (96%)
tidyverse-expert   | 5/5      | 5/5        | 5/5        | 4/5          | 5/5               | 24/25 (96%)
...
```

### Fase 4: Testes de Integração (Holístico)

**Objetivo**: Verificar se múltiplos skills funcionam juntos harmoniosamente

**Método**:
1. Criar 3 projetos realistas que exigem múltiplos skills
2. Desenvolver projeto completo do zero com Claude
3. Verificar coordenação entre skills
4. Avaliar consistência de estilo/abordagem

**Projetos de Teste**:

**Projeto 1: Dashboard de Previsão**
- Requisitos: Shiny app com modelo de forecasting e visualizações interativas
- Skills esperados: r-shiny + r-tidymodels + r-timeseries + ggplot2 + tidyverse-expert
- Avaliação:
  - [ ] Skills ativaram nos momentos corretos?
  - [ ] Houve contradições entre skills?
  - [ ] Código final é coeso?
  - [ ] Performance é adequada?

**Projeto 2: Pacote R de ML**
- Requisitos: Pacote R com funções de feature engineering, testes, documentação
- Skills esperados: r-package-development + r-tidymodels + tdd-workflow + r-style-guide + roxygen2
- Avaliação:
  - [ ] Estrutura do pacote correta?
  - [ ] Testes com coverage >80%?
  - [ ] Documentação completa?
  - [ ] Passa R CMD check?

**Projeto 3: Análise Bayesiana com Report**
- Requisitos: Análise Bayesiana completa com visualizações e relatório reprodutível
- Skills esperados: r-bayes + ggplot2 + tidyverse-expert + r-style-guide
- Avaliação:
  - [ ] Modelo especificado corretamente?
  - [ ] Diagnósticos completos?
  - [ ] Visualizações publication-ready?
  - [ ] Código reprodutível?

**Output**: Score de integração
```
Projeto                        | Skills Coordenados | Consistência | Completude | Score
-------------------------------|---------------------|--------------|------------|------
Dashboard de Previsão          | 5/5                 | 4/5          | 5/5        | 14/15
Pacote R de ML                 | 5/5                 | 5/5          | 4/5        | 14/15
Análise Bayesiana com Report   | 4/5                 | 5/5          | 5/5        | 14/15
```

---

## Fase 5: Benchmarking Comparativo

**Objetivo**: Comparar skills com Claude base (sem skills) e com especialistas humanos

### Teste A: Claude com Skills vs Claude sem Skills

**Método**:
1. Mesmo conjunto de 20 tarefas executadas por:
   - Claude Code com skills R/DS carregados
   - Claude Code sem skills (modo base)
2. Avaliar diferenças em:
   - Tempo para solução
   - Qualidade do código
   - Uso de best practices
   - Documentação gerada

**Métricas**:
```
Tarefa                    | Com Skills | Sem Skills | Melhoria
--------------------------|------------|------------|----------
Tempo médio (min)         | 3.2        | 5.8        | +81%
Best practices (score)    | 9.2/10     | 6.5/10     | +42%
Código executável (%)     | 95%        | 75%        | +27%
Documentação (score)      | 8.5/10     | 5.0/10     | +70%
```

### Teste B: Claude com Skills vs Especialista Humano

**Método**:
1. Recrutamento de 3 especialistas R (>5 anos experiência)
2. Mesmas 10 tarefas complexas para:
   - Claude com skills
   - Especialistas humanos
3. Code review cego (avaliadores não sabem origem)
4. Avaliar:
   - Correção
   - Idiomaticidade (uso correto de idioms R/tidyverse)
   - Performance
   - Maintainability

**Métricas**:
```
Critério              | Claude Skills | Especialista | Delta
----------------------|---------------|--------------|-------
Correção              | 92%           | 95%          | -3%
Idiomaticidade        | 88%           | 93%          | -5%
Performance           | 85%           | 90%          | -5%
Maintainability       | 90%           | 92%          | -2%
Tempo (min)           | 5.2           | 12.5         | +140% (mais rápido)
```

---

## Instrumentação e Ferramentas

### Ferramentas Necessárias

1. **Logging de Skills Invocados**:
   - Modificar Claude Code para logar quais skills são invocados
   - Format: `timestamp | prompt | skills_invoked | user_invoked | auto_invoked`

2. **Test Suite Automatizado**:
   - Script Python/R para executar bateria de prompts
   - Capturar outputs e avaliar contra expected results
   - CI/CD integration para regressão

3. **Code Quality Analyzer**:
   - Linters: `lintr`, `styler`
   - Static analysis: verificar APIs deprecated
   - Execution: rodar código e capturar erros/warnings

4. **Coverage Tool**:
   - Mapear cada conceito de cada domínio
   - Track quais foram mencionados nos skills
   - Gerar coverage report

### Scripts de Teste

#### Script 1: Teste de Triggers (Python)
```python
# test_triggers.py
import subprocess
import json

triggers_tests = {
    "r-tidymodels": [
        "Crie um modelo de classificação com tidymodels",
        "Como fazer feature engineering com recipes?",
        # ... mais prompts
    ],
    # ... outros skills
}

results = []
for skill, prompts in triggers_tests.items():
    for prompt in prompts:
        # Executar Claude Code com prompt
        result = subprocess.run(
            ["claude-code", "--non-interactive", prompt],
            capture_output=True,
            text=True
        )

        # Parsear quais skills foram invocados (requer logging)
        invoked = parse_invoked_skills(result.stdout)

        results.append({
            "skill": skill,
            "prompt": prompt,
            "expected": skill,
            "invoked": invoked,
            "success": skill in invoked
        })

# Gerar relatório
generate_report(results)
```

#### Script 2: Code Quality Check (R)
```r
# test_quality.R
library(lintr)
library(testthat)

evaluate_generated_code <- function(code_file) {
  # Lint check
  lint_results <- lint(code_file)

  # Execução
  tryCatch({
    source(code_file)
    execution_success <- TRUE
    execution_error <- NULL
  }, error = function(e) {
    execution_success <- FALSE
    execution_error <- e$message
  })

  # Verificar APIs deprecated (requer custom check)
  deprecated_check <- check_deprecated_functions(code_file)

  list(
    lint_count = length(lint_results),
    execution_success = execution_success,
    execution_error = execution_error,
    deprecated_count = length(deprecated_check)
  )
}

# Rodar para todos os outputs gerados
test_files <- list.files("test_outputs/", pattern = "\\.R$", full.names = TRUE)
results <- lapply(test_files, evaluate_generated_code)
```

#### Script 3: Coverage Analysis (R)
```r
# coverage_analysis.R

# Domínios e conceitos esperados
domains <- list(
  tidymodels = c(
    "initial_split", "recipe", "step_normalize", "step_dummy",
    "rand_forest", "logistic_reg", "workflow", "tune_grid",
    "vfold_cv", "collect_metrics", "finalize_workflow",
    # ... ~150 conceitos
  ),
  tidyverse = c(
    "filter", "select", "mutate", "summarize", "group_by",
    "pivot_longer", "pivot_wider", "nest", "unnest",
    "map", "map_dbl", "walk", "reduce",
    # ... ~80 conceitos
  )
  # ... outros domínios
)

# Extrair conceitos mencionados no skill
extract_concepts <- function(skill_file) {
  content <- readLines(skill_file)
  content_text <- paste(content, collapse = " ")

  # Buscar por backtick-wrapped functions
  functions <- str_extract_all(content_text, "`[a-z_]+\\(\\)`")[[1]]
  functions <- str_remove_all(functions, "`|\\(\\)")

  unique(functions)
}

# Calcular coverage
calculate_coverage <- function(domain_name) {
  expected <- domains[[domain_name]]
  skill_file <- paste0(".claude/skills/", domain_name, "/SKILL.md")
  documented <- extract_concepts(skill_file)

  coverage <- length(intersect(expected, documented)) / length(expected)
  missing <- setdiff(expected, documented)

  list(
    domain = domain_name,
    coverage = coverage,
    documented_count = length(documented),
    expected_count = length(expected),
    missing = missing
  )
}

# Rodar para todos os domínios
coverage_results <- lapply(names(domains), calculate_coverage)
```

---

## Cronograma de Testes

### Sprint 1 (Semana 1): Cobertura
- [ ] Mapear todos os conceitos esperados por domínio
- [ ] Auditar cada SKILL.md para coverage
- [ ] Gerar matriz de cobertura
- [ ] Identificar top 10 gaps mais críticos

### Sprint 2 (Semana 2): Triggers
- [ ] Criar bateria de 200+ prompts de teste
- [ ] Desenvolver script automatizado de trigger testing
- [ ] Executar testes e coletar dados
- [ ] Analisar falsos positivos/negativos
- [ ] Iterar em descriptions para melhorar precision/recall

### Sprint 3 (Semana 3): Qualidade de Código
- [ ] Criar 5 cenários por skill (85 cenários total)
- [ ] Gerar código com Claude para cada cenário
- [ ] Code review manual com checklist
- [ ] Rodar linters e static analysis
- [ ] Executar código e verificar outputs
- [ ] Compilar scorecard de qualidade

### Sprint 4 (Semana 4): Integração
- [ ] Desenvolver 3 projetos holísticos
- [ ] Avaliar coordenação entre skills
- [ ] Testar edge cases de sobreposição
- [ ] Verificar consistência de estilo

### Sprint 5 (Semana 5): Benchmarking
- [ ] Executar comparação Claude com/sem skills
- [ ] Recrutar especialistas para comparação
- [ ] Code review cego
- [ ] Compilar relatórios finais

---

## Métricas de Sucesso

### Targets Mínimos (Produção-Ready)

**Cobertura**:
- ✓ Cada skill cobre ≥90% dos conceitos principais do domínio
- ✓ Gaps identificados são edge cases (não funcionalidades core)

**Ativação**:
- ✓ Precision ≥95% (raros falsos positivos)
- ✓ Recall ≥90% (skill ativa quando deveria)
- ✓ Zero conflitos entre skills (coordenação harmoniosa)

**Qualidade**:
- ✓ Correção: 100% código sintaticamente correto
- ✓ Completude: ≥95% cenários incluem todos os passos necessários
- ✓ Eficiência: ≥90% código usa best practices de performance
- ✓ Legibilidade: ≥95% código passa linter com zero warnings
- ✓ Reprodutibilidade: 100% código com set.seed() quando necessário

**Integração**:
- ✓ ≥90% projetos holísticos completados sem intervenção manual
- ✓ Zero contradições entre orientações de diferentes skills

**Benchmarking**:
- ✓ Claude com skills ≥50% mais rápido que sem skills
- ✓ Qualidade de código Claude com skills ≥90% da qualidade de especialista humano

---

## Plano de Ação Pós-Testes

### Fase de Correção

1. **Gaps de Cobertura Críticos**:
   - Priorizar top 10 gaps identificados
   - Expandir SKILL.md ou adicionar supporting files
   - Re-testar cobertura

2. **Triggers com Baixo Recall**:
   - Expandir descriptions com mais trigger phrases
   - Adicionar exemplos de contextos
   - Re-testar ativação

3. **Problemas de Qualidade**:
   - Atualizar orientações para APIs deprecadas
   - Adicionar exemplos de best practices
   - Expandir seção de anti-patterns
   - Re-testar geração de código

4. **Conflitos de Integração**:
   - Clarificar hierarquia de skills (qual tem prioridade)
   - Adicionar cross-references entre skills
   - Documentar hand-offs entre skills

### Fase de Monitoramento Contínuo

1. **Feedback Loop**:
   - Coletar logs de invocação em produção
   - Identificar padrões de falha
   - Iterar em skills baseado em uso real

2. **Regressão**:
   - Rodar test suite completo a cada mudança em skills
   - CI/CD com testes automatizados
   - Block merges que quebram testes

3. **Evolução**:
   - Monitorar updates de pacotes R (tidyverse, tidymodels, etc.)
   - Atualizar skills quando APIs mudam
   - Adicionar novos conceitos quando lançados

---

## Conclusão

Esta estratégia fornece um framework sistemático para avaliar se os skills transformam Claude em um especialista R/Data Science completo. As três dimensões (Abrangência, Ativação, Qualidade) cobrem todos os aspectos necessários:

✅ **Abrangência**: Garante conhecimento completo dos domínios
✅ **Ativação**: Garante skills são usados quando necessário
✅ **Qualidade**: Garante código production-ready

O cronograma de 5 sprints (~5 semanas) e métricas quantitativas permitem avaliar objetivamente o sucesso e identificar áreas de melhoria.
