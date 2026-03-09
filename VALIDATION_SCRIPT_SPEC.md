# Validation Script - Especificação Detalhada

**O que é:** Script automatizado para validar qualidade e integridade dos skills

**Onde:** `tests/validate-skills.sh`

**Quando rodar:**
- Antes de cada commit
- Em CI/CD (GitHub Actions)
- Manualmente quando desenvolver/modificar skills

---

## 🎯 O Que o Script Faz/Entrega

### 1. **Valida YAML Frontmatter** ✅

**Problema que resolve:**
- YAML inválido quebra o skill silenciosamente
- Erro de syntax não é detectado até skill ser invocado
- Difícil debugar quando skill não aparece

**O que verifica:**
```bash
✓ Frontmatter tem delimitadores --- corretos
✓ YAML syntax é válido (pode ser parseado)
✓ Campos obrigatórios estão presentes (name, description)
✓ Valores de campos estão corretos (user-invocable: true/false, não "yes")
✓ version segue semver (1.0.0, não "v1" ou "1.0")
✓ allowed-tools lista apenas ferramentas válidas
```

**Output esperado:**
```
✅ r-bayes/SKILL.md - YAML válido
✅ r-oop/SKILL.md - YAML válido
❌ r-example/SKILL.md - YAML inválido: missing closing ---
❌ r-test/SKILL.md - Campo obrigatório ausente: description
```

---

### 2. **Verifica Referências de Arquivos** 📁

**Problema que resolve:**
- Skills referenciam arquivos que não existem
- Links quebrados em documentação
- References/templates/examples referenciados mas ausentes

**O que verifica:**
```bash
✓ Todos [arquivo.md](path/to/file.md) existem
✓ Todos references/ citados existem
✓ Todos examples/ citados existem
✓ Todos templates/ citados existem
✓ Paths em ${CLAUDE_SKILL_DIR}/script.sh existem
```

**Exemplo de verificação:**
```markdown
# No SKILL.md
See [references/dplyr-reference.md](references/dplyr-reference.md)
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                    Script verifica se este arquivo existe
```

**Output esperado:**
```
✅ tidyverse-expert: Todas 6 referências existem
❌ r-example: Arquivo não encontrado: references/missing.md
   Referenciado em linha 42: [missing.md](references/missing.md)
```

---

### 3. **Valida Sintaxe R nos Examples** 💻

**Problema que resolve:**
- Examples com código R inválido
- Código que não roda quebra confiança
- Usuários copiam código quebrado

**O que verifica:**
```bash
✓ Todos arquivos em examples/*.R têm sintaxe R válida
✓ Blocos ```r nos SKILL.md são sintaxe válida
✓ Code snippets podem ser parseados (não necessariamente executados)
```

**Como testa:**
```bash
# Para cada arquivo .R
Rscript --vanilla -e "parse('examples/workflow.R')"

# Para blocos ```r em markdown
# Extrai blocos, salva temp file, testa syntax
```

**Output esperado:**
```
✅ tidyverse-expert/examples/data-wrangling.R - Sintaxe válida
❌ r-example/examples/broken.R - Erro de sintaxe linha 15:
   Error: unexpected symbol in "x <-"
✅ ggplot2/SKILL.md - 12 blocos R, todos válidos
```

---

### 4. **Testa Shell Commands** 🐚

**Problema que resolve:**
- Commands em !`command` que falham
- Dependencies não instaladas
- Commands com syntax errado

**O que verifica:**
```bash
✓ Todos !`command` têm error handling (|| echo "fallback")
✓ Commands básicos estão disponíveis (git, R, Rscript)
✓ Syntax de command substitution está correta
```

**Exemplo:**
```markdown
# ❌ Sem error handling
!`git branch --show-current`

# ✅ Com error handling
!`git branch --show-current 2>/dev/null || echo "Not a git repo"`
```

**Output esperado:**
```
✅ r-datascience: Todos commands têm error handling
❌ r-example: Command sem error handling linha 25:
   !`git status`
   Deveria ser: !`git status 2>/dev/null || echo "fallback"`
```

---

### 5. **Verifica Trigger Phrases** 🎯

**Problema que resolve:**
- Descriptions muito vagas (1-2 triggers)
- Skills que não auto-invocam
- Sobreposição de triggers entre skills

**O que verifica:**
```bash
✓ Description tem pelo menos 5 trigger phrases
✓ Não há sobreposição excessiva (>70%) entre skills
✓ Triggers são específicos (não genéricos como "R code")
```

**Output esperado:**
```
✅ r-bayes: 15 trigger phrases detectadas
⚠️  r-example: Apenas 2 trigger phrases (mínimo: 5)
⚠️  tidyverse-expert vs tidyverse-patterns: 60% overlap
```

---

### 6. **Gera Relatório Completo** 📊

**O que entrega:**

```
╔═══════════════════════════════════════════════════════════╗
║          SKILL VALIDATION REPORT                          ║
╠═══════════════════════════════════════════════════════════╣
║ Date: 2026-03-09 15:30:00                                 ║
║ Skills analyzed: 17                                       ║
║ Total issues: 3                                           ║
╠═══════════════════════════════════════════════════════════╣

✅ PASSED (14 skills)
  • r-bayes
  • r-oop
  • r-performance
  • r-style-guide
  • tidyverse-expert
  • tidyverse-patterns
  • rlang-patterns
  • dm-relational
  • r-package-development
  • tdd-workflow
  • r-shiny
  • ggplot2
  • r-tidymodels
  • r-datascience

⚠️  WARNINGS (2 skills)
  • r-text-mining:
    - Trigger phrase count: 8 (recommended: 10+)
  • r-timeseries:
    - Missing example: examples/forecasting-workflow.R

❌ FAILED (1 skill)
  • r-example:
    - YAML syntax error: line 5
    - Missing file: references/guide.md
    - R syntax error in examples/broken.R

╠═══════════════════════════════════════════════════════════╣
║ SUMMARY                                                   ║
╠═══════════════════════════════════════════════════════════╣
║ ✅ YAML validation: 16/17 passed                          ║
║ ✅ File references: 162/165 found                         ║
║ ⚠️  R syntax check: 45/46 valid                           ║
║ ✅ Shell commands: 23/23 have error handling              ║
║ ⚠️  Trigger phrases: 15/17 meet minimum (5+)              ║
╠═══════════════════════════════════════════════════════════╣
║ Overall: PASS WITH WARNINGS                               ║
╚═══════════════════════════════════════════════════════════╝

Exit code: 1 (warnings present, but not blocking)
```

---

## 🔧 Estrutura do Script

### Arquivo: `tests/validate-skills.sh`

```bash
#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_SKILLS=0
PASSED_SKILLS=0
FAILED_SKILLS=0
WARNINGS=0

# Main validation functions
validate_yaml() { ... }
validate_file_references() { ... }
validate_r_syntax() { ... }
validate_shell_commands() { ... }
validate_trigger_phrases() { ... }

# Generate report
generate_report() { ... }

# Run all validations
main() {
  for skill_dir in .claude/skills/*/; do
    validate_yaml "$skill_dir/SKILL.md"
    validate_file_references "$skill_dir"
    validate_r_syntax "$skill_dir"
    validate_shell_commands "$skill_dir/SKILL.md"
    validate_trigger_phrases "$skill_dir/SKILL.md"
  done

  generate_report
}

main
```

---

## 📦 Dependências Necessárias

```bash
# Para validação YAML
- yq (YAML processor)
  Install: brew install yq

# Para validação R
- R (já instalado)
- Rscript (vem com R)

# Para extrair markdown
- grep, sed, awk (built-in)

# Para CI/CD
- GitHub Actions runner (automático)
```

---

## 🚀 CI/CD Integration

### Arquivo: `.github/workflows/validate-skills.yml`

```yaml
name: Validate Skills

on:
  push:
    paths:
      - '.claude/skills/**'
  pull_request:
    paths:
      - '.claude/skills/**'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install dependencies
      run: |
        brew install yq

    - name: Setup R
      uses: r-lib/actions/setup-r@v2

    - name: Run validation
      run: |
        chmod +x tests/validate-skills.sh
        ./tests/validate-skills.sh

    - name: Upload report
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: validation-report
        path: validation-report.txt
```

**Resultado no GitHub:**
- ✅ Check verde se passou
- ❌ Check vermelho se falhou
- 📄 Report disponível em Artifacts

---

## 📈 Benefícios

### Imediato
1. **Detecta erros antes de commit** - Evita bugs em produção
2. **Garante qualidade consistente** - Todos skills seguem padrões
3. **Automatiza revisão manual** - Economiza tempo

### Médio Prazo
4. **CI/CD confiável** - PRs validados automaticamente
5. **Documentação sempre atualizada** - Links nunca quebrados
6. **Melhor contributor experience** - Feedback imediato

### Longo Prazo
7. **Menor tech debt** - Problemas detectados cedo
8. **Maior confiança** - Skills sempre funcionam
9. **Escalabilidade** - Adicionar skills sem quebrar existentes

---

## 🎯 Casos de Uso

### Durante Desenvolvimento
```bash
# Antes de commit
$ ./tests/validate-skills.sh

# Se passar
✅ All checks passed
$ git commit -m "Add new skill"

# Se falhar
❌ 3 issues found
$ # Fix issues
$ ./tests/validate-skills.sh
✅ All checks passed
$ git commit -m "Add new skill"
```

### Em Pull Request
```
GitHub Actions runs automatically:
- Validates all changes
- Posts report as comment
- Blocks merge if critical failures
```

### Manutenção Regular
```bash
# Check all skills periodically
$ ./tests/validate-skills.sh --verbose

# Generate detailed report
$ ./tests/validate-skills.sh --report validation-report.html
```

---

## 📝 Deliverables

Criando o validation script, você recebe:

### 1. Script Executável
- ✅ `tests/validate-skills.sh` (funcional, testado)

### 2. CI/CD Configuration
- ✅ `.github/workflows/validate-skills.yml`

### 3. Documentação
- ✅ `tests/README.md` (como rodar, interpretar resultados)

### 4. Report Template
- ✅ Formato de output padronizado

### 5. Pre-commit Hook (opcional)
- ✅ `.git/hooks/pre-commit` (valida antes de cada commit)

---

## ⏱️ Tempo Estimado

**Desenvolvimento completo:** 3-4 horas

Breakdown:
- Script básico (YAML + file refs): 1h
- R syntax validation: 1h
- Shell commands + triggers: 30min
- CI/CD setup: 30min
- Testing + refinement: 1h

**Valor gerado:**
- Previne ~80% dos bugs comuns
- Economiza ~2h/semana em revisão manual
- ROI positivo após ~2 semanas

---

## 🔍 Exemplo Real de Uso

**Antes do validation script:**
```bash
$ git commit -m "Add new skill"
[main abc123] Add new skill
# Deploy to production
# User reports: "skill doesn't work!"
# Investigation: 2 hours
# Fix: broken file reference
```

**Com validation script:**
```bash
$ git commit -m "Add new skill"
Running pre-commit validation...
❌ Validation failed:
  - Missing file: references/guide.md
  - R syntax error in examples/workflow.R

# Fix issues (5 minutes)
$ git commit -m "Add new skill"
✅ Validation passed
[main abc123] Add new skill
# Deploy to production
# No issues reported! 🎉
```

---

**Resumo:** O validation script é um "linter + teste automatizado" para skills que garante qualidade, previne bugs e economiza tempo de manutenção.

**ROI:** Investe 3-4h uma vez, economiza 2h/semana indefinidamente = Break-even em 2 semanas.

Quer que eu implemente isso agora?
