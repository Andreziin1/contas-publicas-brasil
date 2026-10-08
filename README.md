
# Contas Públicas do Brasil | 2000–2025

Projeto de análise de dados sobre a evolução das contas públicas brasileiras, utilizando dados oficiais, SQL, PostgreSQL e Power BI.

O estudo reúne informações sobre **receitas, despesas, resultado primário, inflação (IPCA) e dívida bruta**, permitindo acompanhar o comportamento desses indicadores ao longo dos anos.

## Objetivo

Analisar a evolução das receitas, despesas e do resultado primário do Governo Central entre 2000 e 2025, observando também o comportamento da inflação e da dívida pública no período.

O projeto busca transformar séries históricas em informações organizadas e acessíveis, facilitando comparações temporais e a identificação de tendências.

## Fontes dos dados

Foram utilizadas bases de instituições públicas:

| Indicador | Fonte | Período |
|---|---|---|
| Receita Total | Tesouro Nacional (STN) | 2000–2025 |
| Despesa Total | Tesouro Nacional (STN) | 2000–2025 |
| Resultado Primário | Tesouro Nacional (STN) | 2000–2025 |
| Inflação (IPCA) | IBGE / BCB | 2000–2025 |
| Dívida Bruta (% do PIB) | Banco Central (BCB) | Dez/2006–Dez/2025 |

**Fontes oficiais:**
- [Tesouro Transparente](https://www.tesourotransparente.gov.br/)
- [IBGE — SIDRA](https://sidra.ibge.gov.br/)
- [Banco Central do Brasil](https://www.bcb.gov.br/estatisticas/sgs)

A série utilizada para a dívida bruta começa em dezembro de 2006. Os períodos anteriores não foram preenchidos com valores estimados.

## Tecnologias utilizadas

- **PostgreSQL:** armazenamento e organização dos dados.
- **SQL:** criação de tabelas, validações e análises.
- **Power BI:** desenvolvimento do dashboard.
- **Power Query:** preparação e transformação dos dados.
- **DAX:** criação de medidas e filtros interativos.
- **Git/GitHub:** versionamento e documentação.

## Desenvolvimento

O projeto foi organizado em quatro etapas principais.

### 1. Coleta e preparação

Os dados foram obtidos de fontes públicas, organizados por período e preparados para análise.

Foram realizadas verificações de datas, tipos de dados, quantidade de registros e consistência das informações.

### 2. Banco de dados

Foi desenvolvido um banco relacional no PostgreSQL com quatro tabelas:

- `periodo`: identificação dos anos e meses.
- `fonte_dados`: registro das fontes utilizadas.
- `dados_fiscais`: receitas, despesas e resultado primário.
- `ipca`: inflação mensal e acumulada.

A dívida bruta foi incorporada diretamente ao Power BI.

### 3. Análises SQL

Foram desenvolvidas consultas para investigar:

- Evolução anual das receitas e despesas;
- Variações percentuais entre anos;
- Períodos de superávit e déficit primário;
- Comportamento mensal dos indicadores;
- Evolução histórica da inflação.

As análises utilizaram recursos como `JOIN`, `GROUP BY`, `CASE`, CTEs e funções de janela.

### 4. Dashboard no Power BI

Foi desenvolvido um painel com cinco indicadores:

- Receita Total;
- Despesa Total;
- Resultado Primário;
- IPCA acumulado;
- Dívida Bruta (% do PIB).

O dashboard apresenta gráficos históricos dos indicadores e filtros de **Ano** e **Mês**.

Os filtros atualizam os cartões, enquanto os gráficos mantêm a série histórica completa, permitindo comparar a evolução dos indicadores ao longo do tempo.

## Considerações sobre a análise

Os indicadores possuem características diferentes e devem ser interpretados conforme suas definições oficiais.

- Receitas e despesas são apresentadas em valores correntes, sem correção pela inflação.
- O resultado primário utiliza a série oficial do Tesouro Nacional.
- O IPCA representa a variação percentual dos preços.
- A dívida bruta é apresentada como percentual do PIB, não como valor monetário.
- Comparações entre indicadores não representam, necessariamente, relações de causa e efeito.

## Autor

**André**

[GitHub](https://github.com/Andreziin1)

---

Projeto desenvolvido para aplicação prática de conhecimentos em **Análise de Dados, SQL, PostgreSQL e Business Intelligence**.
