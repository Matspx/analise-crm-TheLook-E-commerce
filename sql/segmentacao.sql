WITH metricas AS (
  SELECT
    o.user_id,
    DATE_DIFF((SELECT MAX(created_at) AS data_maxima_dataset FROM `bigquery-public-data.thelook_ecommerce.orders` WHERE status = 'Complete'), MAX(o.created_at),DAY) AS recencia,
    COUNT(DISTINCT o.order_id) AS qtd_pedidos,
    ROUND(SUM(o.sale_price),2) AS receita
  FROM `bigquery-public-data.thelook_ecommerce.order_items` o
  WHERE status = 'Complete'
  GROUP BY o.user_id
)
SELECT 
  user_id,
  recencia,
  CASE 
    WHEN recencia >= 0 AND recencia < 31 THEN 'Recente'
    WHEN recencia >= 31 AND recencia < 91 THEN 'Atenção'
    WHEN recencia >= 91 AND recencia < 181 THEN 'Inativo'
    WHEN recencia >= 181 THEN ' Muito Inativo'
    END AS classificacao,
  qtd_pedidos,
  CASE 
    WHEN qtd_pedidos = 1 THEN 'Compra única'
    WHEN qtd_pedidos > 1 AND qtd_pedidos < 4 THEN 'Recorrente'
    WHEN qtd_pedidos >= 4 THEN ' Frequente'
    END AS frenquencia,
  receita
FROM metricas;

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
    ROUND(receita/qtd_pedidos,2) AS ticket_medio,
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
  classificacao,
  frequencia,
  COUNT(user_id) as qtd_usuarios,
  ROUND(SUM(receita),2) AS receita_total,
  ROUND(AVG(ticket_medio),2) AS ticket_medio_grupo
FROM usuario_classificados
WHERE (frequencia = 'Recorrente' OR frequencia = 'Frequente') AND (classificacao = 'Inativo' OR classificacao = 'Muito Inativo')
GROUP BY 1,2
ORDER BY qtd_usuarios DESC,1,2
;