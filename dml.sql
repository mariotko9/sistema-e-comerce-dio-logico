
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Clientes */
INSERT INTO Cliente (email, telefone, tipo) VALUES
('ana.pf@exemplo.com', '67999990001', 'PF'),
('loja.alpha@exemplo.com', '67999990002', 'PJ'),
('carlos.pf@exemplo.com', '67999990003', 'PF'),
('comercial.beta@exemplo.com', '67999990004', 'PJ');

/* Subtipos */
INSERT INTO PessoaFisica (id_cliente, nome, cpf, data_nascimento)
VALUES
(1, 'Ana Souza', '11122233344', '1990-05-10'),
(3, 'Carlos Lima', '55566677788', '1985-08-22');

INSERT INTO PessoaJuridica (id_cliente, razao_social, cnpj, inscricao_estadual)
VALUES
(2, 'Loja Alpha LTDA', '00987654000199', 'ISENTO'),
(4, 'Comercial Beta SA', '11223344000155', '123456789');

/* Formas de pagamento */
INSERT INTO FormaPagamento (id_cliente, tipo, apelido, detalhes_masked)
VALUES
(1, 'Cartao', 'Visa Ana', '**** **** **** 1234'),
(1, 'Pix', 'PIX Ana', 'chave: ana@pix'),
(2, 'Boleto', 'Boleto Alpha', NULL),
(3, 'Cartao', 'Master Carlos', '**** **** **** 9876');

/* Produtos */
INSERT INTO Produto (nome, descricao, preco) VALUES
('Notebook X', 'Notebook 16GB RAM, 512GB SSD', 4500.00),
('Mouse Pro', 'Mouse óptico', 80.00),
('Teclado Mecanico', 'Switch blue', 320.00),
('Monitor 27', '144Hz IPS', 1800.00);

/* Fornecedores */
INSERT INTO Fornecedor (nome, cnpj) VALUES
('Tech Import LTDA', '20112233000190'),
('Alpha Distribuidora', '00987654000199'); -- mesmo CNPJ da Loja Alpha (vendedor PJ)

/* ProdutoFornecedor */
INSERT INTO ProdutoFornecedor (id_produto, id_fornecedor, preco_custo, lead_time_dias) VALUES
(1, 1, 3800.00, 7),
(2, 1, 50.00, 5),
(2, 2, 45.00, 3),
(3, 2, 250.00, 6),
(4, 1, 1500.00, 10);

/* Estoque */
INSERT INTO Estoque (id_produto, quantidade, localizacao) VALUES
(1, 15, 'CD Campo Grande'),
(2, 200, 'CD Campo Grande'),
(3, 50, 'CD Dourados'),
(4, 30, 'CD Campo Grande');

/* Vendedores (marketplace) */
INSERT INTO Vendedor (id_cliente, nome_fantasia, cnpj)
VALUES
(2, 'Loja Alpha', '00987654000199'),  -- PJ com CNPJ que também é fornecedor
(4, 'Comercial Beta', '11223344000155');

/* Pedidos */
INSERT INTO Pedido (id_cliente, status) VALUES
(1, 'Criado'),
(1, 'Criado'),
(3, 'Criado');

/* Itens dos pedidos */
-- Pedido 1 (Ana)
INSERT INTO ItemPedido (id_pedido, id_produto, quantidade, preco_unitario, desconto_percent)
VALUES
(1, 1, 1, 4500.00, 10), -- Notebook com 10% off
(1, 2, 2, 80.00, 0);

-- Pedido 2 (Ana)
INSERT INTO ItemPedido (id_pedido, id_produto, quantidade, preco_unitario, desconto_percent)
VALUES
(2, 3, 1, 320.00, 0);

-- Pedido 3 (Carlos)
INSERT INTO ItemPedido (id_pedido, id_produto, quantidade, preco_unitario, desconto_percent)
VALUES
(3, 4, 1, 1800.00, 5);

/* Entregas */
INSERT INTO Entrega (id_pedido, status_entrega, codigo_rastreamento, data_envio)
VALUES
(1, 'Em andamento', 'BR123-0001', '2025-08-20'),
(2, 'Em andamento', NULL, '2025-08-21'),
(3, 'Cancelada', 'BR123-0003', NULL);

/* Pagamentos (múltiplas formas) */
-- Pedido 1 pago em 2 formas (cartão + pix) da Ana
INSERT INTO Pagamento (id_pedido, id_forma_pagamento, valor_pago, status, codigo_autorizacao)
VALUES
(1, 1, 3000.00, 'Capturado', 'AUTH-A1'),
(1, 2, 170.00, 'Capturado', 'AUTH-PX1');

-- Pedido 2 não pago ainda
-- Pedido 3 pago integralmente no cartão do Carlos
INSERT INTO Pagamento (id_pedido, id_forma_pagamento, valor_pago, status, codigo_autorizacao)
VALUES
(3, 4, 1710.00, 'Capturado', 'AUTH-C3'); -- 1800 com 5% off = 1710
