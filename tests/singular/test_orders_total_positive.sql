-- this test will fail if any placed order has a total amount <= 0 and we are ablet o find any such orders
SELECT
    order_id,
    customer_id,
    gross_order_revenue
FROM {{ ref('fct_orders') }}
WHERE gross_order_revenue <= 0
AND order_status NOT IN ('CANCELLED')