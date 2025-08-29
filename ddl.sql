-- Habilita opções exigidas
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Conecta-se ao contexto do banco master
USE master;
GO

-- Remove o banco, se existir
IF DB_ID('EcommerceDIO') IS NOT NULL
BEGIN
    ALTER DATABASE EcommerceDIO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EcommerceDIO;
END;
GO

-- Cria o banco
CREATE DATABASE EcommerceDIO;
GO

-- Muda o contexto para o novo banco
USE EcommerceDIO;
GO

-- CLIENTE
CREATE TABLE Cliente (
    id INT IDENTITY(1,1) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NULL,
    tipo CHAR(2) NOT NULL CHECK (tipo IN ('PF','PJ')),
    CONSTRAINT PK_Cliente PRIMARY KEY (id),
    CONSTRAINT UQ_Cliente_email UNIQUE (email)
);
CREATE UNIQUE INDEX UX_Cliente_id_tipo ON Cliente(id, tipo);

-- PESSOA FÍSICA
CREATE TABLE PessoaFisica (
    id_cliente INT NOT NULL,
    tipo CHAR(2) NOT NULL CONSTRAINT DF_PF_tipo DEFAULT 'PF' CHECK (tipo = 'PF'),
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    data_nascimento DATE NULL,
    CONSTRAINT PK_PessoaFisica PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_PessoaFisica_cpf UNIQUE (cpf),
    CONSTRAINT FK_PessoaFisica_Cliente FOREIGN KEY (id_cliente, tipo)
        REFERENCES Cliente(id, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- PESSOA JURÍDICA
CREATE TABLE PessoaJuridica (
    id_cliente INT NOT NULL,
    tipo CHAR(2) NOT NULL CONSTRAINT DF_PJ_tipo DEFAULT 'PJ' CHECK (tipo = 'PJ'),
    razao_social VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    inscricao_estadual VARCHAR(20) NULL,
    CONSTRAINT PK_PessoaJuridica PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_PessoaJuridica_cnpj UNIQUE (cnpj),
    CONSTRAINT FK_PessoaJuridica_Cliente FOREIGN KEY (id_cliente, tipo)
        REFERENCES Cliente(id, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- FORMA DE PAGAMENTO
CREATE TABLE FormaPagamento (
    id INT IDENTITY(1,1) NOT NULL,
    id_cliente INT NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Cartao','Boleto','Pix')),
    apelido VARCHAR(50) NULL,
    detalhes_masked VARCHAR(100) NULL,
    ativo BIT NOT NULL CONSTRAINT DF_FormaPagamento_ativo DEFAULT (1),
    CONSTRAINT PK_FormaPagamento PRIMARY KEY (id),
    CONSTRAINT FK_FormaPagamento_Cliente FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- PRODUTO
CREATE TABLE Produto (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(MAX) NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    ativo BIT NOT NULL CONSTRAINT DF_Produto_ativo DEFAULT (1),
    CONSTRAINT PK_Produto PRIMARY KEY (id)
);

-- FORNECEDOR
CREATE TABLE Fornecedor (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    CONSTRAINT PK_Fornecedor PRIMARY KEY (id),
    CONSTRAINT UQ_Fornecedor_cnpj UNIQUE (cnpj)
);

-- PRODUTO x FORNECEDOR
CREATE TABLE ProdutoFornecedor (
    id_produto INT NOT NULL,
    id_fornecedor INT NOT NULL,
    preco_custo DECIMAL(10,2) NULL CHECK (preco_custo IS NULL OR preco_custo >= 0),
    lead_time_dias INT NULL CHECK (lead_time_dias IS NULL OR lead_time_dias >= 0),
    CONSTRAINT PK_ProdutoFornecedor PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT FK_ProdForn_Produto FOREIGN KEY (id_produto) REFERENCES Produto(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_ProdForn_Fornecedor FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ESTOQUE
CREATE TABLE Estoque (
    id INT IDENTITY(1,1) NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade >= 0),
    localizacao VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Estoque PRIMARY KEY (id),
    CONSTRAINT FK_Estoque_Produto FOREIGN KEY (id_produto)
        REFERENCES Produto(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX IX_Estoque_produto ON Estoque(id_produto);

-- VENDEDOR
CREATE TABLE Vendedor (
    id INT IDENTITY(1,1) NOT NULL,
    id_cliente INT NOT NULL,
    nome_fantasia VARCHAR(120) NOT NULL,
    cnpj CHAR(14) NULL,
    ativo BIT NOT NULL CONSTRAINT DF_Vendedor_ativo DEFAULT (1),
    CONSTRAINT PK_Vendedor PRIMARY KEY (id),
    CONSTRAINT UQ_Vendedor_cnpj UNIQUE (cnpj),
    CONSTRAINT UQ_Vendedor_cliente UNIQUE (id_cliente),
    CONSTRAINT FK_Vendedor_Cliente FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- PEDIDO
CREATE TABLE Pedido (
    id INT IDENTITY(1,1) NOT NULL,
    id_cliente INT NOT NULL,
    data_pedido DATETIME2 NOT NULL CONSTRAINT DF_Pedido_data DEFAULT (SYSUTCDATETIME()),
    valor_total DECIMAL(12,2) NOT NULL CONSTRAINT DF_Pedido_valor DEFAULT (0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Criado','Pago','Em separacao','Enviado','Entregue','Cancelado')),
    CONSTRAINT PK_Pedido PRIMARY KEY (id),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- ITEM DO PEDIDO
CREATE TABLE ItemPedido (
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    desconto_percent DECIMAL(5,2) NOT NULL CONSTRAINT DF_Item_desconto DEFAULT (0)
        CHECK (desconto_percent BETWEEN 0 AND 100),
    CONSTRAINT PK_ItemPedido PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT FK_ItemPedido_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_ItemPedido_Produto FOREIGN KEY (id_produto) REFERENCES Produto(id)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- ENTREGA
CREATE TABLE Entrega (
    id INT IDENTITY(1,1) NOT NULL,
    id_pedido INT NOT NULL,
    status_entrega VARCHAR(20) NOT NULL CHECK (status_entrega IN ('Em andamento','Entregue','Cancelada')),
    codigo_rastreamento VARCHAR(50) NULL,
    data_envio DATE NULL,
    data_entrega DATE NULL,
    CONSTRAINT PK_Entrega PRIMARY KEY (id),
    CONSTRAINT FK_Entrega_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE UNIQUE INDEX UX_Entrega_codigo_rastreamento ON Entrega(codigo_rastreamento)
    WHERE codigo_rastreamento IS NOT NULL;

-- PAGAMENTO
CREATE TABLE Pagamento (
    id INT IDENTITY(1,1) NOT NULL,
    id_pedido INT NOT NULL,
    id_forma_pagamento INT NOT NULL,
    valor_pago DECIMAL(12,2) NOT NULL CHECK (valor_pago > 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Autorizado','Capturado','Negado','Estornado')),
    codigo_autorizacao VARCHAR(50) NULL,
    data_pagamento DATETIME2 NOT NULL CONSTRAINT DF_Pagamento_data DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Pagamento PRIMARY KEY (id),
    CONSTRAINT FK_Pagamento_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Pagamento_Forma FOREIGN KEY (id_forma_pagamento)
    	REFERENCES FormaPagamento(id)
);
CREATE INDEX IX_Pagamento_pedido ON Pagamento(id_pedido);


