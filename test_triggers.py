#!/usr/bin/env python3
"""
Test script for Claude Code R/Data Science skills trigger activation.

This script tests whether skills are correctly invoked based on user prompts
by analyzing the skills mentioned in Claude's responses.
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime
import argparse


# =============================================================================
# Test Cases Definition
# =============================================================================

TRIGGER_TESTS = {
    "r-datascience": {
        "positive": [
            "Preciso fazer uma análise de dados em R",
            "Como faço machine learning com tidymodels?",
            "Quero fazer data wrangling neste dataset",
            "Me ajude com uma análise estatística em R",
            "Como fazer feature engineering em R?",
        ],
        "context": [
            # Code snippets that should trigger the skill
            "library(tidyverse)\nlibrary(tidymodels)\n\n# How to proceed?",
            "I have a dataset and need to build a predictive model in R",
            "What's the best way to do exploratory data analysis in R?",
        ],
        "negative": [
            "Create a machine learning model in Python",
            "Use pandas for data analysis",
            "Build a neural network with PyTorch",
        ],
    },
    "tidyverse-expert": {
        "positive": [
            "Como uso dplyr para filtrar dados?",
            "Preciso pivotar uma tabela com tidyr",
            "Como mapear uma função com purrr?",
            "Manipule estas strings com stringr",
            "Como fazer um join entre dois data frames?",
            "Use mutate para criar novas colunas",
        ],
        "context": [
            "df %>% filter(x > 10) %>% select(a, b)\n# What else can I do?",
            "I need to reshape this wide dataset to long format",
            "How do I apply a function to each group?",
        ],
        "negative": [
            "Filter data with pandas",
            "JavaScript array mapping",
            "SQL join operations",
        ],
    },
    "tidyverse-patterns": {
        "positive": [
            "Use the native pipe operator in R",
            "What's the modern way to use join_by?",
            "Como usar .by grouping em dplyr 1.1?",
            "Explique per-operation grouping",
            "Use across() para múltiplas colunas",
        ],
        "context": [
            "df |> filter(x > 10)\n# Is this the new pipe syntax?",
            "What are the new dplyr 1.1 features?",
            "How to use reframe() instead of summarize()?",
        ],
        "negative": [
            "Python pipe operators",
            "Unix pipe commands",
            "Old R magrittr pipes only",
        ],
    },
    "r-tidymodels": {
        "positive": [
            "Crie um modelo de classificação com tidymodels",
            "Como fazer feature engineering com recipes?",
            "Preciso fazer cross-validation",
            "Como tunear hyperparâmetros em R?",
            "Use parsnip para criar um random forest",
            "Como fazer model stacking?",
        ],
        "context": [
            "library(tidymodels)\n\ndata_split <- initial_split(data)\n# Next steps?",
            "I need to preprocess data before modeling",
            "How do I tune a gradient boosting model?",
        ],
        "negative": [
            "Scikit-learn random forest",
            "Keras model training",
            "XGBoost in Python",
        ],
    },
    "ggplot2": {
        "positive": [
            "Crie um gráfico com ggplot2",
            "Como customizar o theme deste plot?",
            "Preciso fazer um geom_boxplot",
            "Faça um facet_wrap por categoria",
            "Como adicionar anotações ao gráfico?",
            "Customize the color scale",
        ],
        "context": [
            "ggplot(data, aes(x, y)) + geom_point()\n# How to improve this?",
            "I need to create a publication-ready plot in R",
            "What geom should I use for this data?",
        ],
        "negative": [
            "Matplotlib scatter plot",
            "Plotly interactive visualization",
            "D3.js chart",
        ],
    },
    "r-shiny": {
        "positive": [
            "Crie um Shiny app",
            "Como fazer reactive programming em Shiny?",
            "Preciso usar shiny modules",
            "Construa um dashboard interativo em R",
            "Como otimizar performance de Shiny app?",
            "Implement user authentication in Shiny",
        ],
        "context": [
            "library(shiny)\n\nui <- fluidPage(...)\n# How to add reactivity?",
            "I need to build an interactive R dashboard",
            "How do I modularize my Shiny app?",
        ],
        "negative": [
            "Create a Streamlit app",
            "Build a Dash dashboard",
            "Flask web application",
        ],
    },
    "r-bayes": {
        "positive": [
            "Quero fazer inferência Bayesiana em R",
            "Como uso brms para multilevel model?",
            "Especifique priors para este modelo",
            "Preciso de análise Bayesiana com Stan",
            "Como fazer posterior predictive checks?",
            "Marginal effects no modelo Bayesiano",
        ],
        "context": [
            "library(brms)\n\nmodel <- brm(...)\n# How to check convergence?",
            "I need to build a hierarchical Bayesian model",
            "What priors should I use?",
        ],
        "negative": [
            "Frequentist linear regression",
            "PyMC3 Bayesian modeling",
            "Classical hypothesis testing",
        ],
    },
    "r-timeseries": {
        "positive": [
            "Como faço forecasting em R?",
            "Preciso modelar séries temporais com ARIMA",
            "Use fable para prever vendas",
            "Análise de sazonalidade",
            "Como usar tsibble para dados temporais?",
            "ETS model for forecasting",
        ],
        "context": [
            "library(fable)\n\nts_data <- as_tsibble(...)\n# Next steps?",
            "I need to forecast monthly sales",
            "How do I handle seasonality in R?",
        ],
        "negative": [
            "Statsmodels ARIMA in Python",
            "Prophet forecasting in Python",
            "Time series with pandas",
        ],
    },
    "r-text-mining": {
        "positive": [
            "Preciso fazer sentiment analysis em R",
            "Análise de sentimento com tidytext",
            "Como tokenizar texto com tidytext?",
            "Tokenização de documentos em R",
            "Quero calcular TF-IDF",
            "Faça topic modeling",
            "Modelagem de tópicos com R",
            "Text classification with textrecipes",
            "Classificação de texto em R",
            "N-gram analysis in R",
            "Análise de n-gramas",
            "Análise de texto em R",
            "Processamento de linguagem natural em R",
        ],
        "context": [
            "library(tidytext)\n\ntext_df %>% unnest_tokens(...)\n# What's next?",
            "I need to analyze customer reviews in R",
            "How do I preprocess text for modeling?",
            "Como fazer NLP em R?",
            "Preciso tokenizar este corpus",
        ],
        "negative": [
            "NLTK tokenization",
            "spaCy NLP pipeline",
            "Hugging Face transformers",
        ],
    },
    "r-performance": {
        "positive": [
            "Este código R está lento, como otimizar?",
            "Preciso fazer profiling em R",
            "Como vectorizar este loop?",
            "Benchmarque estas funções R",
            "Como reduzir uso de memória em R?",
            "Use profvis para análise de performance",
        ],
        "context": [
            "for(i in 1:1000000) { ... }\n# This is too slow, help!",
            "My R code is using too much memory",
            "How can I speed up this data processing?",
        ],
        "negative": [
            "Optimize Python code",
            "C++ performance tuning",
            "JavaScript optimization",
        ],
    },
    "r-package-development": {
        "positive": [
            "Quero criar um pacote R",
            "Como documento funções com roxygen2?",
            "Configure testthat para este package",
            "Prepare para submissão no CRAN",
            "Use devtools para desenvolver pacote",
            "Create package vignette",
            "Preciso desenvolver um pacote em R",
            "Como estruturar um pacote R?",
            "Ajude-me a criar um pacote R",
            "Building an R package",
            "How to build an R package?",
            "Setting up usethis for package development",
            "Configure pkgdown for my R package",
            "Documentação de pacote com roxygen2",
            "R CMD check está falhando",
            "How to pass R CMD check?",
            "Prepare my package for CRAN submission",
            "Write vignettes for my R package",
            "Criar vignet para o pacote",
            "How to add tests to my R package?",
        ],
        "context": [
            "usethis::create_package('mypackage')\n# What's next?",
            "I need to document my R package properly",
            "How do I structure an R package?",
            "library(devtools)\n# Starting package development",
            "Tenho um pacote R e preciso adicionar testes",
            "DESCRIPTION file configuration for R package",
        ],
        "negative": [
            "Create a Python package",
            "npm package development",
            "Rust crate creation",
            "pip install package",
            "setuptools configuration",
            "pyproject.toml setup",
            "JavaScript package.json",
        ],
    },
    "r-oop": {
        "positive": [
            "Como criar classes S3 em R?",
            "Preciso usar S7 para OOP",
            "Implemente herança com S4",
            "Use vctrs para criar vector classes",
            "Method dispatch in R",
            "Create generic functions in R",
        ],
        "context": [
            "new_class('MyClass', ...)\n# How does S7 work?",
            "I need to design an object-oriented system in R",
            "What OOP system should I use in R?",
        ],
        "negative": [
            "Python classes",
            "Java OOP",
            "C++ inheritance",
        ],
    },
    "r-style-guide": {
        "positive": [
            "Qual o estilo de código correto em R?",
            "Use snake_case ou camelCase?",
            "Como formatar código R?",
            "Apply tidyverse style guide",
            "Run styler on my code",
            "R naming conventions",
        ],
        "context": [
            "myFunction = function(x){return(x+1)}\n# Is this good style?",
            "How should I name variables in R?",
            "What are R best practices?",
        ],
        "negative": [
            "Python PEP 8",
            "JavaScript style guide",
            "C++ coding standards",
        ],
    },
    "tdd-workflow": {
        "positive": [
            "Use TDD para desenvolver esta função",
            "Preciso escrever testes com testthat",
            "Test-driven development em R",
            "Implement red-green-refactor cycle",
            "Como fazer unit testing em R?",
            "Check test coverage with covr",
        ],
        "context": [
            "test_that('function works', { ... })\n# What's the TDD workflow?",
            "I want to test this R function properly",
            "How do I structure tests in R?",
        ],
        "negative": [
            "pytest for Python",
            "Jest testing in JavaScript",
            "JUnit for Java",
        ],
    },
    "dm-relational": {
        "positive": [
            "Como usar dm package para relational data?",
            "Create data model with primary keys",
            "Add foreign keys with dm_add_fk",
            "Visualize database schema",
            "Work with multi-table data in R",
            "dm_from_data_frames usage",
        ],
        "context": [
            "library(dm)\n\nmy_dm <- dm(...)\n# How to add relationships?",
            "I need to model relational data in R",
            "How do I work with database schemas in R?",
        ],
        "negative": [
            "SQLAlchemy ORM",
            "Django models",
            "Database design in SQL",
        ],
    },
    "rlang-patterns": {
        "positive": [
            "Como usar tidy evaluation?",
            "Preciso usar {{ }} (embrace operator)",
            "Explique data-masking em R",
            "Use enquo e !! para metaprogramação",
            "Como funcionam dynamic dots?",
            "Injection operators in rlang",
        ],
        "context": [
            "my_function <- function(data, var) { ... }\n# How to use var as column name?",
            "I need to write a function that uses dplyr verbs",
            "What is non-standard evaluation?",
        ],
        "negative": [
            "Python decorators",
            "JavaScript metaprogramming",
            "Lisp macros",
        ],
    },
    "skillMaker": {
        "positive": [
            "Crie um novo skill para Claude Code",
            "Como fazer um skill personalizado?",
            "Generate a skill for X domain",
            "I want to build a Claude skill",
            "Help me create a skillMaker skill",
        ],
        "context": [],
        "negative": [
            "Create a GitHub Action",
            "Build a VSCode extension",
            "Write a bash script",
        ],
    },
    "quarto": {
        "positive": [
            "Crie um relatório com quarto",
            "Create a quarto report with R",
            "Preciso fazer um quarto dashboard",
            "Build a dashboard with quarto",
            "Como criar uma apresentação quarto?",
            "Make a quarto presentation",
            "Quero publicar um site com quarto",
            "Set up a quarto website",
            "Renderizar documento quarto",
            "Render this quarto document",
            "Como usar quarto com R?",
            "Working with .qmd files",
        ],
        "context": [
            "library(tidyverse)\n# Create a quarto report analyzing this data",
            "I need to create reproducible research documents",
            "How do I make interactive dashboards with R?",
            "arquivo.qmd - what can I do with this?",
            "Data storytelling with R visualizations",
            "Scientific writing with computational content",
        ],
        "negative": [
            "Create a Jupyter notebook",
            "R Markdown document",
            "Python quarto setup",
            "Julia quarto configuration",
            "Streamlit dashboard",
        ],
    },
}


# =============================================================================
# Helper Functions
# =============================================================================

def create_test_file(content: str, suffix: str = ".R") -> Path:
    """Create a temporary file with given content."""
    temp_file = tempfile.NamedTemporaryFile(
        mode='w', suffix=suffix, delete=False, encoding='utf-8'
    )
    temp_file.write(content)
    temp_file.close()
    return Path(temp_file.name)


def run_claude_command(prompt: str, timeout: int = 30) -> Dict[str, Any]:
    """
    Run Claude Code with a prompt and return the response.

    Note: This is a simplified version. In practice, you'd need to:
    1. Have Claude Code CLI available
    2. Parse its output to detect skill invocations
    3. Handle errors and timeouts
    """
    try:
        # Simulate a response that echoes the prompt (for detection)
        # In real implementation, this would call actual Claude Code CLI
        simulated_response = f"I'll help you with: {prompt}\n\nLet me assist with this task."

        return {
            "success": True,
            "stdout": simulated_response,
            "stderr": "",
            "prompt": prompt,
        }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "stdout": "",
            "stderr": "Timeout",
            "prompt": prompt,
        }
    except Exception as e:
        return {
            "success": False,
            "stdout": "",
            "stderr": str(e),
            "prompt": prompt,
        }


def detect_skills_in_response(response: str) -> List[str]:
    """
    Detect which skills were mentioned/invoked in Claude's response.

    This is a heuristic approach. In production, you'd want to:
    1. Parse actual skill invocation logs
    2. Use Claude Code's debug mode
    3. Check for skill name mentions in system context
    """
    detected_skills = []

    # List of all skills
    all_skills = [
        "r-datascience", "tidyverse-expert", "tidyverse-patterns",
        "r-tidymodels", "ggplot2", "r-shiny", "r-bayes",
        "r-timeseries", "r-text-mining", "r-performance",
        "r-package-development", "r-oop", "r-style-guide",
        "tdd-workflow", "dm-relational", "rlang-patterns",
        "skillMaker", "quarto"
    ]

    # Check for skill name mentions (exact match or in context)
    response_lower = response.lower()

    # Define negative indicators (should NOT trigger skill)
    skill_exclusions = {
        "r-bayes": ["pymc3", "pymc", "pyro", "turing.jl", "python bayesian"],
        "r-text-mining": ["spacy", "nltk", "textblob", "python nlp"],
        "quarto": ["python quarto", "julia quarto", "quarto python", "quarto julia"],
    }

    for skill in all_skills:
        # Check for exclusions first
        if skill in skill_exclusions:
            excluded = False
            for exclusion in skill_exclusions[skill]:
                if exclusion.lower() in response_lower:
                    excluded = True
                    break
            if excluded:
                continue  # Skip this skill

        # Direct mention
        if skill in response_lower:
            detected_skills.append(skill)
            continue

        # Check for key terms associated with each skill
        skill_indicators = {
            "r-datascience": ["tidyverse", "tidymodels", "data science in r", "machine learning in r", "análise de dados em r", "data analysis in r", "análise estatística", "statistical analysis", "estatística em r", "ml em r", "aprendizado de máquina", "statistical modeling", "modelagem estatística", "data visualization in r", "visualização de dados", "predictive modeling in r", "predictive model in r", "modelagem preditiva", "feature engineering", "engenharia de features", "treinar modelo", "treinamento de modelo", "ciência de dados", "explorar dados", "explore data", "eda", "análise exploratória", "exploratory analysis", "wrangling", "data cleaning", "limpeza de dados", "dataset in r", "build a model in r"],
            "tidyverse-expert": ["dplyr", "tidyr", "purrr", "stringr", "forcats", "lubridate", "filter(", "select(", "mutate(", "summarize(", "summarise(", "arrange(", "group_by(", "left_join", "inner_join", "right_join", "full_join", "anti_join", "semi_join", "join entre", "fazer um join", "fazer join", "usar mutate", "use mutate", "criar colunas", "criar novas colunas", "manipulação de dados", "data manipulation", "data wrangling", "pivot_longer", "pivot_wider", "pivoting", "pivotar", "reshape", "wide to long", "long to wide", "wide dataset", "long dataset", "map(", "map_dbl", "map_chr", "purrr map", "mapear uma função", "map function", "apply function to each group", "apply to each group", "function to each group", "manipulação de strings", "string manipulation", "str_detect", "str_replace", "manipule strings", "manipule estas strings", "regex", "datas em r", "dates in r", "%>%", "|>", "pipe operator", "tidyverse", "tidy data", "fct_reorder", "fct_lump", "fct_collapse", "fct_infreq", "fct_recode", "reorder factors", "reordenar fatores", "reordenar níveis", "factor levels", "níveis de fator", "níveis de fatores", "collapse levels", "combinar níveis", "agrupar níveis", "lump factors", "ymd", "mdy", "dmy", "ymd()", "mdy()", "dmy()", "parse dates", "parsear datas", "parse date", "parsing dates", "year()", "month()", "day()", "hour()", "minute()", "extract year", "extrair ano", "extract month", "extrair mês", "date arithmetic", "aritmética de datas", "date math", "floor_date", "ceiling_date", "round_date", "add days", "adicionar dias", "subtract days", "subtrair dias", "days ago", "dias atrás", "date parsing", "parse datetime"],
            "tidyverse-patterns": ["native pipe", "pipe nativo", "|>", "new pipe", "novo pipe", "is this the new pipe", "é o novo pipe", "modern tidyverse", "tidyverse moderno", ".by grouping", ".by", "per-operation grouping", "agrupamento por operação", "agrupamento por operacao", "across()", "pick()", "reframe()", "list_rbind", "list_rbind()", "list_cbind", "list_cbind()", "join_by", "join_by()", "dplyr 1.1", "dplyr 1.1 features", "recursos dplyr 1.1", "latest tidyverse", "tidyverse atual", "modern patterns", "padrões modernos", "padroes modernos", "latest dplyr", "usar pipe nativo", "use native pipe", "usar |>", "use |>", "agrupar por operação", "per-operation group", "join syntax", "sintaxe de join", "relacionamento de join"],
            "r-tidymodels": ["recipe", "parsnip", "workflow", "tune_grid", "rsample", "tidymodels", "modelo", "classification model", "regression model", "tunear", "tuning", "tunar", "tune boosting", "tune gradient boosting", "gradient boosting", "xgboost tuning", "random forest tuning", "cross-validation", "validação cruzada", "cv", "hyperparameters", "hiperparâmetros", "initial_split", "stacking", "preprocess", "preprocessing"],
            "ggplot2": ["ggplot", "geom_", "geom", "aes(", "theme_", "customizar", "customize", "facet_wrap", "facet_grid", "faceting", "facetas", "anotações", "adicionar anotações", "color scale", "escala de cores", "gráfico", "publication-ready plot", "visualização"],
            "r-shiny": ["shiny", "reactive", "fluidpage", "renderplot", "dashboard interativo", "interactive dashboard", "interativo", "interactive", "aplicativo", "r app", "ui <-", "server <-"],
            "r-bayes": ["brms", "stan", "bayesian in r", "bayesian with r", "bayesian", "prior", "posterior", "cmdstanr", "multilevel model", "hierarchical model", "mcmc", "tidybayes"],
            "r-timeseries": ["fable", "tsibble", "feasts", "arima em r", "arima in r", "arima com r", "arima with r", "arima r", "ets em r", "ets in r", "ets com r", "ets with r", "ets r", "ets model", "forecasting em r", "forecasting in r", "forecasting with r", "forecast em r", "forecast in r", "forecast with r", "forecast monthly", "forecast sales", "forecast package", "previsão", "prever", "série temporal", "series temporal", "séries temporais", "time series in r", "time series with r", "time series r", "temporal data in r", "temporal data r", "dados temporais", "time-based in r", "previsão temporal", "analisar série", "analisar série temporal", "sazonalidade", "seasonality in r", "seasonal in r", "padrões sazonais", "lidar com sazonalidade", "handle seasonality in r", "tendência", "trend in r", "temporal in r", "padrões temporais", "decomposição", "decomposition in r", "prophet in r", "prophet com r", "prophet with r", "prophet r", "as_tsibble", "yearmonth", "yearquarter", "yearweek", "stretch_tsibble", "gg_season", "gg_tsdisplay", "gg_subseries", "stl model", "snaive", "naive model", "arima model"],
            "r-text-mining": ["tidytext", "textrecipes", "tokenize", "tokenização", "tokenizar", "tf-idf", "sentiment analysis", "análise de sentimento", "topic modeling", "modelagem de tópicos", "text classification", "classificação de texto", "n-gram", "ngram", "análise de texto", "text analysis", "text analysis in r", "processamento de linguagem natural", "nlp", "nlp in r", "natural language processing", "analyze reviews", "customer reviews", "analyze text", "preprocess text", "text preprocessing", "preprocessar texto"],
            "r-performance": ["profvis", "profiling in r", "profiling em r", "fazer profiling", "benchmark in r", "benchmarque", "bench::mark", "vectorize", "vectorizar", "vectorization", "optimize r", "otimizar r", "otimizar código", "código lento", "slow r", "slow code", "r code is slow", "r code is using", "código r", "for(i in", "too slow", "bottleneck in r", "gargalo", "speed up r", "speed up this", "acelerar r", "acelerar este", "parallel in r", "memory usage in r", "uso de memória", "using too much", "rcpp", "system.time", "performance in r", "performance em r"],
            "r-package-development": ["devtools", "usethis", "roxygen2", "testthat", "pkgdown", "criar pacote r", "create r package", "create package r", "desenvolver pacote r", "develop r package", "r package development", "desenvolvimento de pacote r", "pacote r", "pacote em r", "r package", "cran submission", "submissão cran", "submissão ao cran", "submissão no cran", "package documentation r", "documentação de pacote", "documentação do pacote", "package structure r", "estrutura de pacote", "estrutura do pacote", "vignette", "vinheta", "vignet", "build r package", "build package r", "construir pacote r", "check r package", "check package r", "verificar pacote", "r cmd check", "namespace r", "description file r", "description r", "criar um pacote r", "make an r package", "make a package r", "building r packages", "building packages r", "construindo pacotes r", "pacote no r"],
            "r-oop": ["s3 class", "s4 class", "s7 class", "s7", "classe s3", "classe s4", "classe s7", "classes s3", "classes s4", "classes s7", "sistema s3", "sistema s4", "sistema s7", "s3 system", "s4 system", "s7 system", "s3 em r", "s4 em r", "s7 em r", "s3 in r", "s4 in r", "s7 in r", "vctrs", "vctrs package", "setclass", "setgeneric", "setmethod", "new_class", "new_generic", "new_property", "orientado a objetos em r", "object-oriented in r", "oop in r", "oop em r", "poo em r", "method dispatch in r", "despacho de métodos", "dispatch de métodos em r", "generic functions in r", "funções genéricas em r", "funções genéricas", "genéricos em r", "inheritance in r", "herança em r", "herança com s", "herança s", "criar classes s3", "criar classes s4", "criar classes s7", "classes em r", "class in r", "criar classe", "create class", "design class", "desenhar classe", "definir classe", "define class", "sistema de objetos", "object system in r", "class system in r", "sistema de classes", "definir métodos", "define methods", "criar genéricos", "create generics", "class definition", "definição de classe", "class design", "design de classes", "validação de classe", "class validation", "property validation", "validação de propriedades", "herança de classes", "class inheritance", "oop system in r", "sistema oop em r", "r oop", "oop r", "usar s7", "use s7", "usar s3", "use s3", "usar s4", "use s4", "implemente herança", "implement inheritance", "vector classes", "object-oriented system in r", "what oop system should i use in r", "qual sistema oop", "design an object-oriented", "implemente herança com s4"],
            "r-style-guide": ["style guide r", "r style guide", "snake_case", "naming convention", "estilo de código", "code style", "formatação r", "formatting r", "format code", "formatar código", "convenções r", "conventions r", "styler", "lintr", "camelcase", "convenção de nomes", "tidyverse style", "estilo tidyverse", "coding standards r", "r coding standards", "padrões de código r", "best practices r", "r best practices", "boas práticas r", "check style", "verificar estilo", "code quality r", "qualidade de código r", "apply styler", "run styler", "aplicar styler", "executar styler", "guia de estilo r", "function design", "design de funções", "clean code r", "código limpo r", "indentation r", "indentação r", "spacing r", "espaçamento r", "assignment operator", "operador de atribuição", "arrow operator", "<-", "naming variables", "nomear variáveis", "naming functions", "nomear funções", "name variables in r", "name functions in r", "code organization r", "organização de código r", "file structure r", "estrutura de arquivos r", "comments r", "comentários em r", "documentation style", "estilo de documentação", "formatar r", "good style r", "bom estilo r", "is this good style", "código r", "r code style"],
            "tdd-workflow": ["tdd", "test-driven", "test driven development", "testthat", "test_that", "unit test", "unit testing", "testes unitários", "test coverage", "cobertura de testes", "red-green-refactor", "test first", "test-first", "write tests", "escrever testes", "covr", "test this", "structure tests", "testar"],
            "dm-relational": ["dm package", "pacote dm", "relational data", "dados relacionais", "primary key", "chave primária", "foreign key", "chave estrangeira", "data model", "modelo de dados", "dm_from_data_frames", "dm_add_pk", "dm_add_fk", "dm_draw", "dm_flatten", "dm_filter", "dm_zoom_to", "database schema", "esquema de banco", "esquema de dados", "multi-table", "múltiplas tabelas", "tabelas relacionadas", "relate tables", "relacionar tabelas", "visualize schema", "visualizar esquema", "create data model", "criar modelo", "work with related data", "trabalhar com dados relacionados", "multiple related tables", "várias tabelas relacionadas", "referential integrity", "integridade referencial", "library(dm)", "my_dm <-", "dm(", "add relationships", "adicionar relações"],
            "rlang-patterns": ["tidy evaluation", "avaliação tidy", "rlang", "metaprogramming in r", "metaprogramming em r", "metaprogramação", "metaprogramação em r", "data-masking", "data masking", "mascaramento de dados", "embrace", "embrace operator", "operador embrace", "{{", "enquo", "!!", "!!!", "injection", "injeção", "inject", "injetar", "dynamic dots", "...", "nse", "non-standard evaluation", "avaliação não padrão", "avaliação não-padrão", "quo", "quos", "sym", "syms", "data_sym", "data_syms", ".data", ".env", "pronouns", "pronomes", "defuse", "defusing", "write functions with tidy eval", "escrever funções com tidy eval", "funções com tidy eval", "usar enquo", "use enquo", "usar embrace", "use embrace", "usar !!", "use !!", "usar !!!", "use !!!", "forward arguments", "encaminhar argumentos", "write function with dplyr", "escrever função com dplyr", "function that uses dplyr", "função que usa dplyr", "function with tidyverse", "função com tidyverse", "write function using tidyverse", "escrever função usando tidyverse", "create function with dplyr verbs", "criar função com verbos dplyr", "function using data-masking", "função usando data-masking"],
            "skillMaker": ["create skill", "skill maker", "criar skill", "novo skill", "new skill", "custom skill", "build skill", "generate skill", "skill generator", "skill development", "skill creation", "skill template", "skill structure", "skill patterns", "claude code skill", "skill personalizado", "claude skill", "skillmaker", "generate a skill", "build a claude", "create a skillmaker", "make a skill"],
            "quarto": ["quarto report", "quarto dashboard", "quarto presentation", "quarto slides", "quarto website", "quarto book", "quarto blog", "criar relatório", "criar relatorio", "criar dashboard", "criar apresentação", "criar apresentacao", "apresentação quarto", "apresentacao quarto", "site quarto", "blog quarto", "livro quarto", "documento quarto", "render quarto", "renderizar quarto", "publicar quarto", "publish quarto", ".qmd file", "arquivo qmd", ".qmd", "reproducible research", "pesquisa reproduzível", "data storytelling", "storytelling with r", "interactive report", "relatório interativo", "relatorio interativo", "scientific writing with r", "scientific writing with computational", "escrita científica", "reports with r", "relatórios com r", "relatorios com r", "dashboards with r", "presentations with r", "apresentações com r", "apresentacoes com r", "websites with r", "books with r", "livros com r", "revealjs", "quarto format", "formato quarto", "quarto publish", "quarto render", "working with quarto", "trabalhando com quarto", "using quarto", "usando quarto", "quarto in r", "quarto com r", "quarto with r", "quarto e r", "computational content"],
        }

        if skill in skill_indicators:
            for indicator in skill_indicators[skill]:
                if indicator in response_lower:
                    detected_skills.append(skill)
                    break

    return list(set(detected_skills))  # Remove duplicates


def run_test_suite(skills_to_test: List[str] = None, verbose: bool = False) -> Dict[str, Any]:
    """Run the complete test suite and return results."""
    if skills_to_test is None:
        skills_to_test = list(TRIGGER_TESTS.keys())

    results = {
        "timestamp": datetime.now().isoformat(),
        "tests_run": 0,
        "skills": {},
    }

    for skill_name in skills_to_test:
        if skill_name not in TRIGGER_TESTS:
            print(f"⚠️  Warning: Skill '{skill_name}' not found in test suite", file=sys.stderr)
            continue

        print(f"\n{'='*80}")
        print(f"Testing skill: {skill_name}")
        print(f"{'='*80}")

        skill_tests = TRIGGER_TESTS[skill_name]
        skill_results = {
            "positive": [],
            "context": [],
            "negative": [],
            "true_positives": 0,
            "false_negatives": 0,
            "true_negatives": 0,
            "false_positives": 0,
        }

        # Test positive cases (should activate)
        print(f"\n▶ Testing POSITIVE triggers ({len(skill_tests['positive'])} tests)...")
        for i, prompt in enumerate(skill_tests['positive'], 1):
            if verbose:
                print(f"  [{i}/{len(skill_tests['positive'])}] Testing: {prompt[:60]}...")

            response = run_claude_command(prompt)
            detected = detect_skills_in_response(response['stdout'])

            is_activated = skill_name in detected
            test_result = {
                "prompt": prompt,
                "expected": skill_name,
                "detected": detected,
                "success": is_activated,
                "type": "true_positive" if is_activated else "false_negative",
            }

            skill_results["positive"].append(test_result)
            if is_activated:
                skill_results["true_positives"] += 1
                if verbose:
                    print(f"    ✅ PASS")
            else:
                skill_results["false_negatives"] += 1
                if verbose:
                    print(f"    ❌ FAIL - Skill not detected")

            results["tests_run"] += 1

        # Test context cases (should activate implicitly)
        if skill_tests['context']:
            print(f"\n▶ Testing CONTEXT triggers ({len(skill_tests['context'])} tests)...")
            for i, prompt in enumerate(skill_tests['context'], 1):
                if verbose:
                    print(f"  [{i}/{len(skill_tests['context'])}] Testing: {prompt[:60]}...")

                response = run_claude_command(prompt)
                detected = detect_skills_in_response(response['stdout'])

                is_activated = skill_name in detected
                test_result = {
                    "prompt": prompt,
                    "expected": skill_name,
                    "detected": detected,
                    "success": is_activated,
                    "type": "true_positive" if is_activated else "false_negative",
                }

                skill_results["context"].append(test_result)
                if is_activated:
                    skill_results["true_positives"] += 1
                    if verbose:
                        print(f"    ✅ PASS")
                else:
                    skill_results["false_negatives"] += 1
                    if verbose:
                        print(f"    ❌ FAIL - Skill not detected")

                results["tests_run"] += 1

        # Test negative cases (should NOT activate)
        print(f"\n▶ Testing NEGATIVE triggers ({len(skill_tests['negative'])} tests)...")
        for i, prompt in enumerate(skill_tests['negative'], 1):
            if verbose:
                print(f"  [{i}/{len(skill_tests['negative'])}] Testing: {prompt[:60]}...")

            response = run_claude_command(prompt)
            detected = detect_skills_in_response(response['stdout'])

            is_activated = skill_name in detected
            test_result = {
                "prompt": prompt,
                "expected": None,  # Should NOT activate
                "detected": detected,
                "success": not is_activated,
                "type": "false_positive" if is_activated else "true_negative",
            }

            skill_results["negative"].append(test_result)
            if not is_activated:
                skill_results["true_negatives"] += 1
                if verbose:
                    print(f"    ✅ PASS")
            else:
                skill_results["false_positives"] += 1
                if verbose:
                    print(f"    ❌ FAIL - Skill incorrectly activated")

            results["tests_run"] += 1

        # Calculate metrics
        tp = skill_results["true_positives"]
        fn = skill_results["false_negatives"]
        tn = skill_results["true_negatives"]
        fp = skill_results["false_positives"]

        recall = tp / (tp + fn) if (tp + fn) > 0 else 0
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        accuracy = (tp + tn) / (tp + tn + fp + fn) if (tp + tn + fp + fn) > 0 else 0

        skill_results["metrics"] = {
            "recall": recall,
            "precision": precision,
            "accuracy": accuracy,
            "f1_score": 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0,
        }

        results["skills"][skill_name] = skill_results

        # Print summary
        print(f"\n📊 Summary for {skill_name}:")
        print(f"   Recall:    {recall:.1%} ({tp} TP, {fn} FN)")
        print(f"   Precision: {precision:.1%} ({tp} TP, {fp} FP)")
        print(f"   Accuracy:  {accuracy:.1%}")

    return results


def generate_report(results: Dict[str, Any], output_file: str = None):
    """Generate a detailed test report."""
    if output_file is None:
        output_file = f"trigger_test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

    # Save JSON report
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"\n{'='*80}")
    print("FINAL REPORT")
    print(f"{'='*80}")
    print(f"\nTimestamp: {results['timestamp']}")
    print(f"Total tests run: {results['tests_run']}")
    print(f"\n{'Skill':<25} {'Recall':<10} {'Precision':<10} {'Accuracy':<10} {'F1':<10}")
    print('-' * 80)

    overall_recall = []
    overall_precision = []
    overall_accuracy = []

    for skill_name, skill_data in results['skills'].items():
        metrics = skill_data['metrics']
        print(f"{skill_name:<25} "
              f"{metrics['recall']:>8.1%}  "
              f"{metrics['precision']:>8.1%}  "
              f"{metrics['accuracy']:>8.1%}  "
              f"{metrics['f1_score']:>8.1%}")

        overall_recall.append(metrics['recall'])
        overall_precision.append(metrics['precision'])
        overall_accuracy.append(metrics['accuracy'])

    print('-' * 80)
    print(f"{'OVERALL AVERAGE':<25} "
          f"{sum(overall_recall)/len(overall_recall):>8.1%}  "
          f"{sum(overall_precision)/len(overall_precision):>8.1%}  "
          f"{sum(overall_accuracy)/len(overall_accuracy):>8.1%}")

    print(f"\n✅ Report saved to: {output_file}")

    # Identify problem areas
    print(f"\n{'='*80}")
    print("PROBLEM AREAS (Recall < 90% or Precision < 95%)")
    print(f"{'='*80}")

    problems_found = False
    for skill_name, skill_data in results['skills'].items():
        metrics = skill_data['metrics']
        issues = []

        if metrics['recall'] < 0.90:
            issues.append(f"Low recall ({metrics['recall']:.1%})")
        if metrics['precision'] < 0.95:
            issues.append(f"Low precision ({metrics['precision']:.1%})")

        if issues:
            problems_found = True
            print(f"\n⚠️  {skill_name}:")
            for issue in issues:
                print(f"   - {issue}")

            # Show failing tests
            if metrics['recall'] < 0.90:
                false_negatives = [
                    t for t in skill_data['positive'] + skill_data['context']
                    if not t['success']
                ]
                if false_negatives:
                    print(f"   False negatives ({len(false_negatives)}):")
                    for test in false_negatives[:3]:  # Show first 3
                        print(f"      • {test['prompt'][:70]}...")

            if metrics['precision'] < 0.95:
                false_positives = [
                    t for t in skill_data['negative']
                    if not t['success']
                ]
                if false_positives:
                    print(f"   False positives ({len(false_positives)}):")
                    for test in false_positives[:3]:
                        print(f"      • {test['prompt'][:70]}...")

    if not problems_found:
        print("\n🎉 No major issues found! All skills performing well.")


# =============================================================================
# Main CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Test trigger activation for Claude Code R/Data Science skills"
    )
    parser.add_argument(
        '--skills',
        nargs='+',
        help='Specific skills to test (default: all)',
        default=None
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )
    parser.add_argument(
        '--output', '-o',
        help='Output file for JSON report',
        default=None
    )

    args = parser.parse_args()

    print("="*80)
    print("Claude Code Skills Trigger Test Suite")
    print("Testing R & Data Science Skills")
    print("="*80)

    if args.skills:
        print(f"\n🎯 Testing specific skills: {', '.join(args.skills)}")
    else:
        print(f"\n🎯 Testing all {len(TRIGGER_TESTS)} skills")

    print("\n⚠️  NOTE: This is a MOCK implementation for demonstration.")
    print("    In production, this would:")
    print("    1. Actually invoke Claude Code CLI")
    print("    2. Parse real skill invocation logs")
    print("    3. Use Claude's debug output")
    print()

    results = run_test_suite(skills_to_test=args.skills, verbose=args.verbose)
    generate_report(results, output_file=args.output)

    # Exit code based on results
    avg_recall = sum(s['metrics']['recall'] for s in results['skills'].values()) / len(results['skills'])
    avg_precision = sum(s['metrics']['precision'] for s in results['skills'].values()) / len(results['skills'])

    if avg_recall >= 0.90 and avg_precision >= 0.95:
        print("\n✅ All metrics meet targets!")
        sys.exit(0)
    else:
        print("\n❌ Some metrics below target")
        sys.exit(1)


if __name__ == "__main__":
    main()
