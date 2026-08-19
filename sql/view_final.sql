WITH metricas AS (
  SELECT
    o.user_id,
    DATE_DIFF((SELECT MAX(created_at) AS data_maxima_dataset FROM `bigquery-public-data.thelook_ecommerce.order_items` WHERE status = 'Complete'), MAX(o.created_at),DAY) AS recencia,
    COUNT(DISTINCT o.order_id) AS qtd_pedidos,
    ROUND(SUM(o.sale_price),2) AS receita
  FROM `bigquery-public-data.thelook_ecommerce.order_items` o
  WHERE status = 'Complete'
  GROUP BY o.user_id
),
usuario_classificados AS (
  SELECT 
    user_id,
    receita,
    qtd_pedidos,
    ROUND(receita/qtd_pedidos,2) AS ticket_medio,
    recencia,
    CASE 
    WHEN recencia >= 0 AND recencia < 31 THEN 'Recente'
    WHEN recencia >= 31 AND recencia < 91 THEN 'Atenção'
    WHEN recencia >= 91 AND recencia < 181 THEN 'Inativo'
    WHEN recencia >= 181 THEN 'Muito Inativo'
    END AS classificacao,
    CASE 
    WHEN qtd_pedidos = 1 THEN 'Compra única'
    WHEN qtd_pedidos > 1 AND qtd_pedidos < 4 THEN 'Recorrente'
    WHEN qtd_pedidos >= 4 THEN 'Frequente'
    END AS frequencia
  FROM metricas
)
SELECT
  uc.user_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  u.country,
  u.gender,
  u.age,
  uc.recencia,
  uc.classificacao,
  uc.qtd_pedidos,
  uc.frequencia,
  uc.receita,
  uc.ticket_medio,
FROM usuario_classificados uc
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u ON u.id = uc.user_id

;