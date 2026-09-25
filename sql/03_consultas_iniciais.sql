-- Despesa Total por ano
SELECT
    p.ano,
    ROUND(SUM(df.despesa_total), 2) AS despesa_total
FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
GROUP BY p.ano
ORDER BY p.ano;

-- Resultado Primário por ano
SELECT
    p.ano,
    ROUND(SUM(df.resultado_primario), 2) AS resultado_primario
FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
GROUP BY p.ano
ORDER BY p.ano;

-- IPCA acumulado de cada ano
SELECT
    p.ano,
    i.ipca_acumulado_ano
FROM periodo p
JOIN ipca i
    ON p.id_periodo = i.id_periodo
WHERE p.mes = 12
ORDER BY p.ano;

-- Visão anual consolidada dos principais indicadores
SELECT
    p.ano,
    ROUND(SUM(df.receita_total), 2) AS receita_total_rs_milhoes,
    ROUND(SUM(df.despesa_total), 2) AS despesa_total_rs_milhoes,
    ROUND(SUM(df.resultado_primario), 2) AS resultado_primario_rs_milhoes,
    MAX(CASE
        WHEN p.mes = 12 THEN i.ipca_acumulado_ano
    END) AS ipca_acumulado_ano

FROM periodo p

JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo

JOIN ipca i
    ON p.id_periodo = i.id_periodo

GROUP BY p.ano
ORDER BY p.ano;