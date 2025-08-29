-- Quantos pedidos foram feitos por cada cliente? OK 4reg
SELECT
    c.id AS id_cliente,
    COALESCE(pf.nome, pj.razao_social, c.email) AS cliente,
    COUNT(*) AS qtde_pedidos
FROM Cliente c
LEFT JOIN PessoaFisica pf ON pf.id_cliente = c.id
LEFT JOIN PessoaJuridica pj ON pj.id_cliente = c.id
LEFT JOIN Pedido p ON p.id_cliente = c.id
GROUP BY c.id, COALESCE(pf.nome, pj.razao_social, c.email)
ORDER BY qtde_pedidos DESC, cliente;

--Algum vendedor também é fornecedor? (match por CNPJ) OK 1reg
SELECT
    v.id AS id_vendedor,
    v.nome_fantasia,
    v.cnpj,
    f.id AS id_fornecedor,
    f.nome AS fornecedor
FROM Vendedor v
INNER JOIN Fornecedor f
    ON v.cnpj IS NOT NULL
   AND v.cnpj = f.cnpj;

--Relação de produtos, fornecedores e estoques OK 5reg
SELECT
    pr.id AS id_produto,
    pr.nome AS produto,
    f.nome AS fornecedor,
    pf.preco_custo,
    e.quantidade AS estoque,
    e.localizacao
FROM Produto pr
LEFT JOIN ProdutoFornecedor pf ON pf.id_produto = pr.id
LEFT JOIN Fornecedor f ON f.id = pf.id_fornecedor
LEFT JOIN Estoque e ON e.id_produto = pr.id
ORDER BY pr.nome, fornecedor, e.localizacao;

-- Relação de nomes dos fornecedores e nomes dos produtos OK 5reg
SELECT DISTINCT
    f.nome AS fornecedor,
    p.nome AS produto
FROM Fornecedor f
INNER JOIN ProdutoFornecedor pf ON pf.id_fornecedor = f.id
INNER JOIN Produto p ON p.id = pf.id_produto
ORDER BY fornecedor, produto;

-- Clientes PF com ticket médio acima de R$ 1.000,00 OK 0reg(rever)
SELECT
    pf.nome,
    AVG(p.valor_total) AS ticket_medio
FROM PessoaFisica pf
INNER JOIN Cliente c ON c.id = pf.id_cliente
INNER JOIN Pedido p ON p.id_cliente = c.id
GROUP BY pf.nome
HAVING AVG(p.valor_total) > 1000
ORDER BY ticket_medio DESC;

--Top 3 produtos por receita bruta (sem considerar descontos) OK 3reg
SELECT TOP 3
    pr.nome AS produto,
    SUM(ip.preco_unitario * ip.quantidade) AS receita_bruta
FROM ItemPedido ip
INNER JOIN Produto pr ON pr.id = ip.id_produto
GROUP BY pr.nome
ORDER BY receita_bruta DESC;

--Receita líquida por pedido, incluindo atributo derivado valor_desconto_total OK 3reg
SELECT
    p.id AS id_pedido,
    p.valor_total AS receita_liquida,
    SUM( (ip.preco_unitario * ip.quantidade) * (ip.desconto_percent/100.0) ) AS valor_desconto_total
FROM Pedido p
INNER JOIN ItemPedido ip ON ip.id_pedido = p.id
GROUP BY p.id, p.valor_total
ORDER BY receita_liquida DESC;

-- Pedidos com pagamento insuficiente (somatório de pagamentos capturados < valor_total) OK 0reg (ver)
SELECT
    p.id AS id_pedido,
    p.valor_total,
    SUM(CASE WHEN g.status = 'Capturado' THEN g.valor_pago ELSE 0 END) AS total_pago
FROM Pedido p
LEFT JOIN Pagamento g ON g.id_pedido = p.id
GROUP BY p.id, p.valor_total
HAVING SUM(CASE WHEN g.status = 'Capturado' THEN g.valor_pago ELSE 0 END) < p.valor_total;

--Entregas “Em andamento” com mais de 5 dias desde o envio OK 2reg
SELECT
    e.id AS id_entrega,
    e.id_pedido,
    e.codigo_rastreamento,
    e.data_envio,
    DATEDIFF(DAY, e.data_envio, CAST(SYSUTCDATETIME() AS DATE)) AS dias_em_transito
FROM Entrega e
WHERE e.status_entrega = 'Em andamento'
  AND e.data_envio IS NOT NULL
  AND DATEDIFF(DAY, e.data_envio, CAST(SYSUTCDATETIME() AS DATE)) > 5
ORDER BY dias_em_transito DESC;

-- Estoque abaixo de nível mínimo derivado por produto (ex.: 10 unidades) Ok 0reg (ver)
SELECT
    pr.nome AS produto,
    SUM(e.quantidade) AS estoque_total,
    10 AS nivel_minimo
FROM Produto pr
LEFT JOIN Estoque e ON e.id_produto = pr.id
GROUP BY pr.nome
HAVING SUM(e.quantidade) < 10;


