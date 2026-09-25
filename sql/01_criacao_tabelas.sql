CREATE TABLE periodo (
    id_periodo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_referencia DATE NOT NULL UNIQUE,
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL
);
CREATE TABLE fonte_dados (
    id_fonte INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    orgao VARCHAR(150) NOT NULL,
    nome_base VARCHAR(200) NOT NULL,
    arquivo_origem VARCHAR(200),
    url TEXT,
    observacao TEXT
);
CREATE TABLE dados_fiscais (
    id_dado_fiscal INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_periodo INTEGER NOT NULL UNIQUE,
    id_fonte INTEGER NOT NULL,
    receita_total NUMERIC(20,10) NOT NULL,
    despesa_total NUMERIC(20,10) NOT NULL,
    resultado_primario NUMERIC(20,10) NOT NULL,

    FOREIGN KEY (id_periodo) REFERENCES periodo(id_periodo),
    FOREIGN KEY (id_fonte) REFERENCES fonte_dados(id_fonte)
);
CREATE TABLE ipca (
    id_ipca INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_periodo INTEGER NOT NULL UNIQUE,
    id_fonte INTEGER NOT NULL,
    ipca_mensal NUMERIC(5,2) NOT NULL,
    ipca_acumulado_ano NUMERIC(5,2) NOT NULL,

    FOREIGN KEY (id_periodo) REFERENCES periodo(id_periodo),
    FOREIGN KEY (id_fonte) REFERENCES fonte_dados(id_fonte)
);