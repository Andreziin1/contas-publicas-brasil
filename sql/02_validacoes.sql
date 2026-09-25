-- Confere se todos os meses foram importados corretamente
SELECT
    COUNT(*) AS total_registros,
    MIN(data_referencia) AS primeira_data,
    MAX(data_referencia) AS ultima_data
FROM periodo;

-- Confere os IDs que o PostgreSQL gerou para cada fonte
SELECT
    id_fonte,
    orgao,
    nome_base
FROM fonte_dados
ORDER BY id_fonte;

-- Confere se todos os dados fiscais foram importados
SELECT
    COUNT(*) AS total_registros,
    MIN(id_periodo) AS primeiro_periodo,
    MAX(id_periodo) AS ultimo_periodo,
    COUNT(DISTINCT id_periodo) AS periodos_unicos
FROM dados_fiscais;

-- Confere se cada período possui dados fiscais e IPCA relacionados
SELECT
    COUNT(*) AS total_periodos,
    COUNT(df.id_dado_fiscal) AS periodos_com_dados_fiscais,
    COUNT(i.id_ipca) AS periodos_com_ipca,
    COUNT(*) - COUNT(df.id_dado_fiscal) AS fiscais_faltantes,
    COUNT(*) - COUNT(i.id_ipca) AS ipca_faltantes
FROM periodo p
LEFT JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
LEFT JOIN ipca i
    ON p.id_periodo = i.id_periodo;

-- Consolida os dados mensais por ano para validação
SELECT
    p.ano,
    SUM(df.receita_total) AS receita_anual,
    SUM(df.despesa_total) AS despesa_anual,
    SUM(df.resultado_primario) AS resultado_primario_anual,
    MAX(CASE
        WHEN p.mes = 12 THEN i.ipca_acumulado_ano
    END) AS ipca_anual
FROM periodo p
JOIN dados_fiscais df
    ON p.id_periodo = df.id_periodo
JOIN ipca i
    ON p.id_periodo = i.id_periodo
GROUP BY p.ano
ORDER BY p.ano;
