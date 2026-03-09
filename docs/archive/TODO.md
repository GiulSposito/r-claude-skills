# TODO - Melhorias Pendentes dos Skills R/Data Science

**Última atualização:** 2026-03-09
**Baseado em:** SKILL_ANALYSIS_REPORT.md e CHANGES.md

---

## ✅ Concluído (2026-03-09)

- [x] ~~Melhorar descriptions fracas (r-bayes, r-oop, r-performance, r-style-guide)~~
- [x] ~~Adicionar allowed-tools nesses 4 skills~~
- [x] ~~Padronizar version e user-invocable nesses 4 skills~~
- [x] ~~Criar análise crítica completa (SKILL_ANALYSIS_REPORT.md)~~

**Resultado:** +1200% melhoria média em trigger phrases (4 skills)

---

## 🔴 Prioridade Alta (Esta Semana)

### 1. Completar Padronização de Frontmatter

**Status:** Parcialmente concluído (4 de 17 skills)

**Ações restantes:**
```markdown
Skills que ainda precisam de frontmatter completo:
[ ] tidyverse-expert - adicionar version, verificar allowed-tools
[ ] tidyverse-patterns - adicionar version, allowed-tools, mais triggers
[ ] rlang-patterns - adicionar version, allowed-tools, triggers
[ ] dm-relational - adicionar version, allowed-tools, triggers
[ ] r-package-development - adicionar version, allowed-tools, triggers
[ ] r-datascience - revisar configuração (user-invocable: true?)
[ ] r-text-mining - verificar configuração
[ ] r-timeseries - verificar configuração
[ ] r-shiny - verificar configuração
[ ] ggplot2 - verificar se falta algo
[ ] r-tidymodels - verificar se falta algo
[ ] tdd-workflow - adicionar version, allowed-tools, triggers
```

**Template a seguir:**
```yaml
---
name: skill-name
description: [Detailed description with 8+ trigger phrases]
version: 1.0.0
user-invocable: false  # ou true se for workflow skill
allowed-tools: Read, Grep, Glob  # adjust per skill needs
---
```

**Estimativa:** 2-3 horas

---

### 2. Criar Script de Validação

**Status:** Não iniciado

**Ações:**
```markdown
[ ] Criar tests/validate-skills.sh
[ ] Validar YAML frontmatter (syntax check)
[ ] Verificar referências de arquivos existem
[ ] Testar examples/ como scripts executáveis
[ ] Validar shell commands em !`...`
[ ] Adicionar GitHub Actions CI/CD workflow
```

**Script base sugerido:**
```bash
#!/bin/bash
# tests/validate-skills.sh

echo "🔍 Validating skills..."

# 1. Check YAML frontmatter
for skill in .claude/skills/*/SKILL.md; do
  echo "Checking $skill..."
  head -20 "$skill" | yq eval - > /dev/null 2>&1 || echo "❌ Invalid YAML: $skill"
done

# 2. Check file references
# 3. Validate R syntax in examples/
# 4. Test shell commands
```

**Estimativa:** 3-4 horas

---

### 3. Documentar Estratégia de Consolidação

**Status:** Não iniciado

**Ações:**
```markdown
[ ] Criar CONSOLIDATION_PLAN.md
[ ] Documentar decisões de merge/rename
[ ] Definir timeline de implementação
[ ] Identificar breaking changes
[ ] Planejar comunicação com usuários
```

**Decisões a documentar:**
- tidyverse-patterns → tidyverse-expert (merge)
- tidyverse-expert → tidyverse (rename)
- r-datascience → r-quickstart (transform)
- r-oop + r-performance + r-package-dev → r-advanced (merge)

**Estimativa:** 2 horas

---

## 🟡 Prioridade Média (Este Mês)

### 4. Consolidar Skills Redundantes

**Status:** Não iniciado

**Impacto:** Reduz de 17 para ~12 skills core, elimina 70% de overlap

**Ações:**
```markdown
Fase 1 - Preparação:
[ ] Criar branch feature/consolidation
[ ] Backup dos skills originais
[ ] Atualizar testes para novos nomes

Fase 2 - Tidyverse consolidation:
[ ] Merge tidyverse-patterns content → tidyverse-expert
[ ] Rename tidyverse-expert → tidyverse
[ ] Update all references em outros skills
[ ] Update trigger phrases para evitar colisão
[ ] Testar auto-invocation

Fase 3 - r-datascience transformation:
[ ] Criar novo r-quickstart skill (onboarding)
[ ] Migrar conteúdo útil de r-datascience
[ ] Adicionar skill navigator/discovery
[ ] Documentar quando usar cada skill
[ ] Deprecate r-datascience (ou transformar)

Fase 4 - Advanced R consolidation:
[ ] Merge r-oop content → new r-advanced
[ ] Merge r-performance content → r-advanced
[ ] Merge r-package-development → r-advanced
[ ] Organizar em seções claras
[ ] Manter como bundled skill
```

**Estimativa:** 1-2 semanas

---

### 5. Expandir Skills Existentes

**Status:** Não iniciado

**r-performance (transformar em bundled):**
```markdown
[ ] Criar structure: references/, examples/, templates/
[ ] Adicionar references/profvis-guide.md
[ ] Adicionar references/benchmarking.md
[ ] Adicionar references/rcpp-integration.md
[ ] Adicionar references/parallelization.md
[ ] Adicionar examples/optimization-workflow.md
[ ] Adicionar templates/performance-analysis.R
```

**r-package-development (transformar em bundled):**
```markdown
[ ] Criar structure: references/, examples/, templates/
[ ] Adicionar references/roxygen2-reference.md
[ ] Adicionar references/pkgdown-guide.md
[ ] Adicionar references/testing-strategies.md
[ ] Adicionar templates/github-actions-r-cmd-check.yml
[ ] Adicionar templates/cran-submission-checklist.md
[ ] Adicionar examples/complete-package-structure.md
```

**r-bayes (transformar em bundled):**
```markdown
[ ] Criar structure: references/, examples/, templates/
[ ] Adicionar references/prior-specification.md
[ ] Adicionar references/model-checking.md
[ ] Adicionar references/marginal-effects.md
[ ] Adicionar examples/multilevel-model-workflow.md
[ ] Adicionar templates/bayesian-analysis-template.R
```

**Estimativa:** 2-3 semanas

---

### 6. Criar Novos Skills Core

**Status:** Não iniciado

**Skills prioritários por demanda:**

**r-databases (Alta prioridade):**
```markdown
[ ] Criar structure bundled
[ ] Cobertura: DBI, dbplyr, odbc, RPostgres
[ ] Patterns: connection management, queries, transactions
[ ] Examples: database workflows
[ ] Triggers: "database", "SQL", "DBI", "dbplyr"
```

**r-reporting (Alta prioridade):**
```markdown
[ ] Criar structure bundled
[ ] Cobertura: Quarto, Rmarkdown, knitr
[ ] Patterns: parameterized reports, output formats
[ ] Examples: report templates
[ ] Triggers: "Quarto", "Rmarkdown", "report", "knit"
```

**r-quickstart (Essencial para UX):**
```markdown
[ ] Criar skill de onboarding
[ ] Skill navigator/discovery
[ ] Quick reference de todos skills disponíveis
[ ] Decision tree: qual skill usar?
[ ] Triggers: "getting started", "what R skills", "help"
[ ] user-invocable: true
```

**Estimativa:** 3-4 semanas

---

### 7. Adicionar Dynamic Integration

**Status:** Não iniciado

**r-tidymodels já tem, expandir para outros:**

```markdown
[ ] tidyverse - WebFetch para tidyverse.org/packages
[ ] ggplot2 - WebFetch para ggplot2.tidyverse.org
[ ] r-shiny - WebFetch para shiny.posit.co
[ ] r-text-mining - WebFetch para tidytextmining.com
[ ] r-timeseries - WebFetch para otexts.com/fpp3

[ ] Implementar fallback para docs locais
[ ] Implementar caching de lookups (15 min cache)
[ ] Adicionar projeto context (!`Rscript -e "installed.packages()"`)
```

**Pattern a seguir:**
```yaml
allowed-tools: Read, Write, Edit, WebFetch
```

```markdown
### Dynamic Reference Lookup

Use WebFetch to search online when:
- User asks about specific function not in local knowledge
- Searching for recently added functionality
- Need comprehensive reference
```

**Estimativa:** 1-2 semanas

---

## 🟢 Prioridade Baixa (Este Trimestre)

### 8. Novos Skills Especializados

**Status:** Não iniciado

**Pipeline sugerido:**

```markdown
Q2 2026:
[ ] r-spatial (sf, terra, stars) - crescente demanda
[ ] r-web (APIs httr2, scraping rvest) - produtização

Q3 2026:
[ ] r-big-data (arrow, duckdb, spark)
[ ] r-interactive-viz (plotly, htmlwidgets)

Q4 2026:
[ ] r-causal-inference (tidycausal, DAGs)
[ ] r-survival-analysis (survival, survminer)
[ ] r-meta-analysis (metafor, meta)
```

**Critério de priorização:**
1. Community demand (issues, discussions)
2. Completeness of ecosystem (packages mature?)
3. Effort vs impact ratio
4. Alignment with project goals

---

### 9. Advanced Features

**Status:** Planejamento

```markdown
[ ] LSP integration (se Claude Code suportar)
[ ] Project-specific context loading
[ ] Auto-detection de installed packages
[ ] Dependency suggestion system
[ ] Code snippet system em templates/
[ ] Interactive examples (executáveis)
```

**Requer:** Research de feasibility

---

### 10. Community Features

**Status:** Não iniciado

```markdown
[ ] CONTRIBUTING.md detalhado
[ ] Skill review process (template + checklist)
[ ] GitHub Discussions para feature requests
[ ] Community-voted priorities (polls)
[ ] Skill versioning strategy (semver)
[ ] Deprecation policy
[ ] Release notes automation
```

---

## 📊 Métricas de Progresso

### Completed (Item #2 da Prioridade Alta)

- ✅ 4/17 skills com frontmatter padronizado (23%)
- ✅ 4/17 skills com triggers otimizados (23%)
- ✅ 1/1 análise crítica completa (100%)

### Remaining

**Prioridade Alta:**
- 🔴 13/17 skills precisam padronização (77%)
- 🔴 0/1 validation script (0%)
- 🔴 0/1 consolidation plan (0%)

**Prioridade Média:**
- 🟡 0/4 consolidações planejadas (0%)
- 🟡 0/3 expansões de skills (0%)
- 🟡 0/3 novos skills core (0%)
- 🟡 0/6 skills com dynamic integration (0%)

**Prioridade Baixa:**
- 🟢 0/7 novos skills especializados (0%)
- 🟢 0/6 advanced features (0%)
- 🟢 0/7 community features (0%)

---

## 🎯 Roadmap Visual

```
✅ Week 1 (Done): Fix critical frontmatter (4 skills)
📍 Week 2 (Current): Complete standardization (13 skills) + validation
   Week 3-4: Consolidation (merge redundant skills)
   Month 2: Expansion (databases, reporting, quickstart)
   Month 3: Advanced features (dynamic lookup, testing, CI/CD)
   Q2 2026: New specialized skills (spatial, web, big data)
```

---

## 🚀 Next Action Items

**Immediate (próximos 3-5 dias):**

1. [ ] Completar padronização de frontmatter (13 skills restantes)
2. [ ] Criar validation script básico
3. [ ] Testar triggers dos 4 skills atualizados

**Short-term (próximas 2 semanas):**

4. [ ] Criar CONSOLIDATION_PLAN.md
5. [ ] Implementar CI/CD básico
6. [ ] Iniciar merge tidyverse-patterns → tidyverse

**Medium-term (próximo mês):**

7. [ ] Completar consolidação de skills
8. [ ] Criar r-databases skill
9. [ ] Criar r-quickstart skill

---

## 📝 Notas

- **Breaking changes:** Consolidação pode quebrar workflows existentes
- **Communication:** Documentar mudanças em CHANGELOG.md
- **Testing:** Testar cada mudança antes de commit
- **Versioning:** Bump version em skills modificados
- **Backup:** Manter skills originais em branch legacy se necessário

---

**Última revisão:** 2026-03-09
**Próxima revisão:** Após completar prioridade alta
**Owner:** Maintainer do projeto
