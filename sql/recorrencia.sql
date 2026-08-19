WITH metricas AS (
  SELECT
    o.user_id,
    o.order_id,
    o.created_at,
    ROW_NUMBER() OVER (
        PARTITION BY o.user_id ORDER BY o.created_at
      ) AS num_pedido,
    LAG(o.created_at, 1) OVER(
        PARTITION BY o.user_id ORDER BY o.created_at
      ) AS dia_anterior,
    DATE_DIFF(o.created_at,LAG(o.created_at, 1) OVER(
        PARTITION BY o.user_id ORDER BY o.created_at), 
      DAY) AS dias_desde_pedido_anterior,
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  WHERE o.status = 'Complete'
)
SELECT 
    user_id,
    order_id,
    created_at,
    num_pedido,
    dia_anterior,
    dias_desde_pedido_anterior
FROM metricas 
ORDER BY user_id
;

WITH metricas AS (
  SELECT
    o.user_id,
    o.order_id,
    o.created_at,
    ROW_NUMBER() OVER (
        PARTITION BY o.user_id ORDER BY o.created_at
      ) AS num_pedido,
    LAG(o.created_at, 1) OVER(
        PARTITION BY o.user_id ORDER BY o.created_at
      ) AS dia_anterior,
    DATE_DIFF(o.created_at,LAG(o.created_at, 1) OVER(
        PARTITION BY o.user_id ORDER BY o.created_at), 
      DAY) AS dias_desde_pedido_anterior,
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  WHERE o.status = 'Complete'
)
SELECT 
    user_id,
    COUNT(dias_desde_pedido_anterior) AS qtd_intervalos_pedidos,
    AVG(dias_desde_pedido_anterior) AS medias_intervalos
FROM metricas
WHERE num_pedido > 1
GROUP BY user_id
;