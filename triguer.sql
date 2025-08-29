GO
CREATE OR ALTER TRIGGER trg_ItemPedido_AfterInsUpdDel
ON ItemPedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PedidosAfetados AS (
        SELECT id_pedido FROM inserted
        UNION
        SELECT id_pedido FROM deleted
    )
    UPDATE p
    SET valor_total = ISNULL(t.total, 0)
    FROM Pedido p
    INNER JOIN (
        SELECT ip.id_pedido,
               SUM((ip.preco_unitario * ip.quantidade) * (1 - ip.desconto_percent / 100.0)) AS total
        FROM ItemPedido ip
        GROUP BY ip.id_pedido
    ) t ON p.id = t.id_pedido
    WHERE p.id IN (SELECT id_pedido FROM PedidosAfetados);

    UPDATE p
    SET valor_total = 0
    FROM Pedido p
    WHERE p.id IN (SELECT id_pedido FROM deleted)
      AND NOT EXISTS (
          SELECT 1 FROM ItemPedido ip WHERE ip.id_pedido = p.id
      );
END;
GO