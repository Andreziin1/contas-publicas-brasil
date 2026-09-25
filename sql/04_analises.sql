-- Pergunta 1:
-- Como a Receita Total e a Despesa Total evoluíram entre 2000 e 2025,
-- e qual foi a porcentagem de crescimento ou queda em relação ao ano anterior?

WITH valores_anuais AS (
    SELECT
        p.ano,
        SUM(df.receita_total) AS receita_total,
        SUM(df.despesa_total) AS despesa_total
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
    GROUP BY p.ano
)

SELECT
    ano,

    ROUND(receita_total, 2) AS receita_total_rs_milhoes,

    ROUND(
        ((receita_total - LAG(receita_total) OVER (ORDER BY ano))
        / LAG(receita_total) OVER (ORDER BY ano)) * 100,
        2
    ) AS variacao_receita_percentual,

    ROUND(despesa_total, 2) AS despesa_total_rs_milhoes,

    ROUND(
        ((despesa_total - LAG(despesa_total) OVER (ORDER BY ano))
        / LAG(despesa_total) OVER (ORDER BY ano)) * 100,
        2
    ) AS variacao_despesa_percentual

FROM valores_anuais
ORDER BY ano;

-- Pergunta 2:
-- Como o Resultado Primário evoluiu entre 2000 e 2025 e quais anos apresentaram Superávit ou Déficit?

SELECT
    p.ano,
    ROUND(SUM(df.resultado_primario), 2) AS resultado_primario_rs_milhoes,
    CASE
        WHEN SUM(df.resultado_primario) > 0 THEN 'Superávit'
        WHEN SUM(df.resultado_primario) < 0 THEN 'Déficit'
        ELSE 'Equilíbrio'
    END AS situacao
FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
GROUP BY p.ano
ORDER BY p.ano;

-- Pergunta 3:
-- Como o Resultado Primário mudou em relação ao ano anterior e quando ocorreram transições entre Superávit e Déficit?

WITH resultado_anual AS (
    SELECT
        p.ano,
        SUM(df.resultado_primario) AS resultado_primario
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
    GROUP BY p.ano
),

comparacao AS (
    SELECT
        ano,
        resultado_primario,
        LAG(resultado_primario) OVER (ORDER BY ano) AS resultado_ano_anterior
    FROM resultado_anual
)

SELECT
    ano,
    ROUND(resultado_primario, 2) AS resultado_primario_rs_milhoes,
    ROUND(resultado_primario - resultado_ano_anterior, 2) AS diferenca_ano_anterior_rs_milhoes,

    CASE
        WHEN resultado_ano_anterior IS NULL THEN 'Sem comparação'
        WHEN resultado_primario > resultado_ano_anterior THEN 'Melhora'
        WHEN resultado_primario < resultado_ano_anterior THEN 'Piora'
        ELSE 'Sem alteração'
    END AS evolucao,

    CASE
        WHEN resultado_ano_anterior > 0 AND resultado_primario < 0
            THEN 'Superávit → Déficit'
        WHEN resultado_ano_anterior < 0 AND resultado_primario > 0
            THEN 'Déficit → Superávit'
        ELSE 'Sem mudança de situação'
    END AS transicao

FROM comparacao
ORDER BY ano;

-- Pergunta 4:
-- Quantos meses de Superávit e Déficit ocorreram em cada ano?

SELECT
    p.ano,

    COUNT(*) FILTER (
        WHERE df.resultado_primario > 0
    ) AS meses_superavit,

    COUNT(*) FILTER (
        WHERE df.resultado_primario < 0
    ) AS meses_deficit,

    COUNT(*) FILTER (
        WHERE df.resultado_primario = 0
    ) AS meses_equilibrio,

    ROUND(SUM(df.resultado_primario), 2) AS resultado_primario_rs_milhoes

FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo

GROUP BY p.ano
ORDER BY p.ano;

-- Pergunta 5:
-- Existe um padrão de sazonalidade nas Receitas, Despesas e no Resultado Primário ao longo dos meses?

WITH totais_anuais AS (
    SELECT
        p.ano,
        SUM(df.receita_total) AS receita_anual,
        SUM(df.despesa_total) AS despesa_anual
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
    GROUP BY p.ano
)

SELECT
    p.mes,

    ROUND(
        AVG((df.receita_total / NULLIF(t.receita_anual, 0)) * 100),
        2
    ) AS participacao_media_receita_percentual,

    ROUND(
        AVG((df.despesa_total / NULLIF(t.despesa_anual, 0)) * 100),
        2
    ) AS participacao_media_despesa_percentual,

    COUNT(*) FILTER (
        WHERE df.resultado_primario > 0
    ) AS anos_com_superavit_no_mes,

    COUNT(*) FILTER (
        WHERE df.resultado_primario < 0
    ) AS anos_com_deficit_no_mes

FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
JOIN totais_anuais t
    ON p.ano = t.ano

GROUP BY p.mes
ORDER BY p.mes;

-- Pergunta 6:
-- O que o acumulado móvel de 12 meses revela sobre a tendência das Receitas, Despesas e do Resultado Primário?

WITH acumulado_12_meses AS (
    SELECT
        p.data_referencia,

        SUM(df.receita_total) OVER (
            ORDER BY p.data_referencia
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS receita_12_meses,

        SUM(df.despesa_total) OVER (
            ORDER BY p.data_referencia
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS despesa_12_meses,

        SUM(df.resultado_primario) OVER (
            ORDER BY p.data_referencia
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS resultado_primario_12_meses,

        COUNT(*) OVER (
            ORDER BY p.data_referencia
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS meses_janela

    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
)

SELECT
    data_referencia,
    ROUND(receita_12_meses, 2) AS receita_12_meses_rs_milhoes,
    ROUND(despesa_12_meses, 2) AS despesa_12_meses_rs_milhoes,
    ROUND(resultado_primario_12_meses, 2) AS resultado_primario_12_meses_rs_milhoes

FROM acumulado_12_meses

WHERE meses_janela = 12

ORDER BY data_referencia;

-- Pergunta 7:
-- Quais meses apresentaram as maiores mudanças em relação ao mesmo mês do ano anterior?

WITH comparacao_anual AS (
    SELECT
        p.data_referencia,
        df.receita_total,
        df.despesa_total,
        df.resultado_primario,
        LAG(df.receita_total, 12) OVER (ORDER BY p.data_referencia) AS receita_ano_anterior,
        LAG(df.despesa_total, 12) OVER (ORDER BY p.data_referencia) AS despesa_ano_anterior,
        LAG(df.resultado_primario, 12) OVER (ORDER BY p.data_referencia) AS resultado_ano_anterior
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
)

SELECT
    data_referencia,

    ROUND(
        ((receita_total - receita_ano_anterior)
        / NULLIF(receita_ano_anterior, 0)) * 100,
        2
    ) AS variacao_receita_percentual,

    ROUND(
        ((despesa_total - despesa_ano_anterior)
        / NULLIF(despesa_ano_anterior, 0)) * 100,
        2
    ) AS variacao_despesa_percentual,

    ROUND(
        resultado_primario - resultado_ano_anterior,
        2
    ) AS diferenca_resultado_primario_rs_milhoes

FROM comparacao_anual

WHERE receita_ano_anterior IS NOT NULL

ORDER BY data_referencia;

-- Pergunta 8:
-- Como o crescimento anual da Receita e da Despesa se compara ao IPCA de cada ano?

WITH valores_anuais AS (
    SELECT
        p.ano,
        SUM(df.receita_total) AS receita_total,
        SUM(df.despesa_total) AS despesa_total,
        MAX(CASE
            WHEN p.mes = 12 THEN i.ipca_acumulado_ano
        END) AS ipca_acumulado_ano
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
    JOIN ipca i
        ON p.id_periodo = i.id_periodo
    GROUP BY p.ano
),

variacoes AS (
    SELECT
        ano,
        receita_total,
        despesa_total,
        ipca_acumulado_ano,
        LAG(receita_total) OVER (ORDER BY ano) AS receita_ano_anterior,
        LAG(despesa_total) OVER (ORDER BY ano) AS despesa_ano_anterior
    FROM valores_anuais
)

SELECT
    ano,

    ROUND(
        ((receita_total - receita_ano_anterior)
        / NULLIF(receita_ano_anterior, 0)) * 100,
        2
    ) AS crescimento_receita_percentual,

    ROUND(
        ((despesa_total - despesa_ano_anterior)
        / NULLIF(despesa_ano_anterior, 0)) * 100,
        2
    ) AS crescimento_despesa_percentual,

    ipca_acumulado_ano

FROM variacoes
ORDER BY ano;

-- Pergunta 9:
-- Quais foram os períodos com as maiores mudanças no Resultado Primário em relação ao mesmo mês do ano anterior?

WITH comparacao AS (
    SELECT
        p.data_referencia,
        df.resultado_primario,
        LAG(df.resultado_primario, 12) OVER (
            ORDER BY p.data_referencia
        ) AS resultado_ano_anterior
    FROM periodo p
    JOIN dados_fiscais df
        ON p.id_periodo = df.id_periodo
),

variacoes AS (
    SELECT
        data_referencia,
        resultado_primario,
        resultado_ano_anterior,
        resultado_primario - resultado_ano_anterior AS diferenca
    FROM comparacao
    WHERE resultado_ano_anterior IS NOT NULL
)

SELECT
    data_referencia,
    ROUND(resultado_primario, 2) AS resultado_primario_rs_milhoes,
    ROUND(resultado_ano_anterior, 2) AS resultado_ano_anterior_rs_milhoes,
    ROUND(diferenca, 2) AS diferenca_rs_milhoes
FROM variacoes
ORDER BY ABS(diferenca) DESC
LIMIT 10;

-- Pergunta 10:
-- Qual foi a magnitude do Resultado Primário em relação à Receita Total em cada ano?

SELECT
    p.ano,

    ROUND(SUM(df.receita_total), 2) AS receita_total_rs_milhoes,

    ROUND(SUM(df.resultado_primario), 2) AS resultado_primario_rs_milhoes,

    ROUND(
        (SUM(df.resultado_primario) / NULLIF(SUM(df.receita_total), 0)) * 100,
        2
    ) AS resultado_sobre_receita_percentual,

    CASE
        WHEN SUM(df.resultado_primario) > 0 THEN 'Superávit'
        WHEN SUM(df.resultado_primario) < 0 THEN 'Déficit'
        ELSE 'Equilíbrio'
    END AS situacao

FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo

GROUP BY p.ano
ORDER BY p.ano;