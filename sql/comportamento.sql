WITH metricas AS (
  SELECT 
    o.user_id,
    SUM(oi.sale_price) AS total_vendas,
    COUNT(DISTINCT o.order_id) AS total_pedidos
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` o ON oi.order_id = o.order_id
  WHERE oi.status = 'Complete'
  GROUP BY o.user_id
)
SELECT 
  u.id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  ROUND(m.total_vendas / m.total_pedidos, 2) AS ticket_medio
FROM metricas m
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` u ON u.id = m.user_id
WHERE u.id IS NOT NULL;

WITH metricas AS (
  SELECT
    oi.user_id,
    ROUND(SUM(oi.sale_price), 2) AS receita,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ARRAY_AGG(o.order_id ORDER BY o.created_at ASC LIMIT 1)[OFFSET(0)] AS id_primeira_compra,
    MIN(o.created_at) AS data_primeira_compra,
    ARRAY_AGG(o.order_id ORDER BY o.created_at DESC LIMIT 1)[OFFSET(0)] AS id_ultima_compra,
    MAX(o.created_at) AS data_ultima_compra,
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` o ON oi.order_id = o.order_id
  WHERE oi.status = 'Complete'
  GROUP BY oi.user_id
)
SELECT
  u.id,
  CONCAT(u.first_name,' ',u.last_name),
  m.receita,
  m.total_pedidos,
  ROUND((m.receita / m.total_pedidos),2) AS ticket_medio,
  m.id_primeira_compra,
  m.data_primeira_compra,
  m.id_ultima_compra,
  m.data_ultima_compra,
  CASE WHEN m.total_pedidos = 1 THEN NULL 
        ELSE DATE_DIFF(m.data_ultima_compra,m.data_primeira_compra,HOUR) / (m.total_pedidos - 1)
        END AS tempo_medio_entre_pedidos_horas  
FROM
  metricas m 
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` u ON u.id = m.user_id
WHERE u.id IS NOT NULL;