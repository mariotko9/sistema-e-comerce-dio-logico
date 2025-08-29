🛒 Projeto de Modelagem Lógica de Banco de Dados – E-commerce

Este projeto apresenta a modelagem lógica e implementação de um banco de dados relacional para um sistema de e-commerce. O modelo foi desenvolvido como parte do desafio de projeto da DIO, com foco em boas práticas de modelagem e normalização. 

🎯 Objetivos

•	Aplicar refinamentos ao modelo conceitual com especializações (PF/PJ)
•	Criar o esquema lógico com constraints, PKs, FKs e gatilhos
•	Popular o banco com dados de teste
•	Elaborar queries SQL complexas para responder perguntas de negócio

🧱 Estrutura do Banco de Dados

Entidades Principais
•	Cliente: Superclasse com especialização em PF e PJ
•	PessoaFisica e PessoaJuridica: Subtipos exclusivos de Cliente
•	FormaPagamento: Múltiplas formas por cliente
•	Pedido e ItemPedido
•	Pagamento: Associado a Pedido e FormaPagamento
•	Entrega: Com status e código de rastreio
•	Produto, Estoque
•	Fornecedor e relação N:N com Produto
•	Vendedor: Representa sellers do marketplace

Relacionamentos

Entidade A	Relacionamento	Entidade B	Tipo
Cliente	1:1	PF ou PJ	Exclusivo
Cliente	1:N	FormaPagamento	
Pedido	1:N	ItemPedido	
Pedido	1:N	Pagamento	
Pedido	1:N	Entrega	
Produto	N:N	Fornecedor	
Produto	1:N	Estoque	
Cliente	1:1	Vendedor	Opcional

⚙️ Scripts

Os scripts estão organizados por função:
•	ddl.sql: Criação das tabelas, constraints e índices
•	dml.sql: Inserção de dados de teste
•	trigger.sql: Gatilhos para regras de negócio (exclusividade PF/PJ, atualização de valor total do pedido)
•	consultas.sql: Consultas SQL complexas para análise de dados
•	perguntas.md: Perguntas de negócio respondidas pelas queries

🧪 Exemplos de Consultas SQL

As queries foram elaboradas para explorar diferentes cláusulas SQL:
•	SELECT, WHERE, ORDER BY, HAVING, JOIN
•	Atributos derivados e agregações
•	Filtros por grupos e condições compostas
Perguntas respondidas:
•	Quantos pedidos foram feitos por cada cliente?
•	Algum vendedor também é fornecedor?
•	Relação de produtos, fornecedores e estoques
•	Relação de nomes dos fornecedores e nomes dos produtos
•	Clientes PF com ticket médio acima de R$ 1.000,00
•	Top 3 produtos por receita bruta
•	Receita líquida por pedido e valor total de descontos
•	Pedidos com pagamento insuficiente
•	Entregas “Em andamento” com mais de 5 dias
•	Estoque abaixo do nível mínimo

📌 Observações

•	O projeto foi desenvolvido para SQL Server, mas pode ser adaptado para outros SGBDs com ajustes de sintaxe.

