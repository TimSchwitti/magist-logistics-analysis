USE magist;

-- ----------------------------------------------
-- Map: Logistics and Tech revenue performance by state
-- ----------------------------------------------

SELECT 
    g.state,
    COUNT(DISTINCT o.order_id) AS total_relevant_orders,
    ROUND(SUM(CASE
                WHEN o.order_status = 'delivered' THEN oi.price
                ELSE 0
            END),
            2) AS total_revenue,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date,
                    o.order_purchase_timestamp)),
            1) AS avg_delivery_time_days,
    SUM(CASE
        WHEN o.order_status = 'unavailable' THEN 1
        ELSE 0
    END) AS total_unavailable_orders,
    ROUND(100.0 * SUM(CASE
                WHEN
                    (o.order_status = 'unavailable'
                        OR (o.order_delivered_customer_date IS NOT NULL
                        AND o.order_delivered_customer_date > o.order_estimated_delivery_date))
                        AND r.review_score IN (1 , 2)
                THEN
                    1
                ELSE 0
            END) / NULLIF(SUM(CASE
                        WHEN
                            o.order_status = 'unavailable'
                                OR (o.order_delivered_customer_date IS NOT NULL
                                AND o.order_delivered_customer_date > o.order_estimated_delivery_date)
                        THEN
                            1
                        ELSE 0
                    END),
                    0),
            1) AS dissatisfaction_rate_percent,
    ROUND(100.0 * SUM(CASE
                WHEN
                    o.order_status = 'delivered'
                        AND o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN
                    1
                WHEN o.order_status = 'unavailable' THEN 1
                ELSE 0
            END) / NULLIF(COUNT(DISTINCT o.order_id), 0),
            1) AS unreliability_rate_percent,
    ROUND(SUM(CASE
                WHEN o.order_status = 'delivered' THEN oi.price
                ELSE 0
            END),
            2) AS total_tech_revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
        JOIN
    products p ON oi.product_id = p.product_id
        JOIN
    product_category_name_translation t ON p.product_category_name = t.product_category_name
        LEFT JOIN
    (SELECT 
        order_id, MIN(review_score) AS review_score
    FROM
        order_reviews
    GROUP BY order_id) r ON o.order_id = r.order_id
        JOIN
    customers c ON o.customer_id = c.customer_id
        JOIN
    (SELECT DISTINCT
        zip_code_prefix, state
    FROM
        geo) g ON c.customer_zip_code_prefix = g.zip_code_prefix
WHERE
    o.order_status <> 'canceled'
        AND t.product_category_name_english IN ('computers_accessories' , 'telephony',
        'electronics',
        'consoles_games',
        'fixed_telephony',
        'audio',
        'computers',
        'cine_photo',
        'pc_gamer',
        'signaling_and_security',
        'tablets_printing_image')
GROUP BY g.state
ORDER BY unreliability_rate_percent DESC;

-- ----------------------------------------------
-- Line chart: Risk (Delivery delay vs. Customer satisfaction)
-- ----------------------------------------------

SELECT 
    TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delay_days,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(
        100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END)
        / COUNT(*),
        1
    ) AS logistics_frustration_rate
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND t.product_category_name_english IN (
        'computers_accessories', 'telephony', 'electronics', 'consoles_games', 
        'fixed_telephony', 'audio', 'computers', 'cine_photo', 'pc_gamer', 
        'signaling_and_security', 'tablets_printing_image')
  AND TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 0
GROUP BY 
    TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)
ORDER BY 
    delay_days ASC;
    
-- ----------------------------------------------
-- Analysis: Magist customers (Order value > 500 €)
-- Split: Single payment vs. Installment payment
-- ----------------------------------------------

WITH tech_orders AS (
    SELECT
        o.order_id,
        SUM(oi.price) AS total_order_value,
        CASE
            WHEN MAX(op.payment_installments) = 1 THEN 'Single_Payment'
            ELSE 'Installment_Payment'
        END AS payment_method
    FROM orders o
    JOIN order_items oi USING(order_id)
    JOIN order_payments op USING(order_id)
    JOIN products p USING(product_id)
    GROUP BY o.order_id
    HAVING SUM(oi.price) > 500)
SELECT
    payment_method,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS percentage_share
FROM tech_orders
GROUP BY payment_method;

-- ----------------------------------------------
-- Annual revenue and sales development
-- ----------------------------------------------

SELECT
    YEAR(o.order_purchase_timestamp) AS year,
    COUNT(oi.order_id) AS total_sales,
    ROUND(SUM(oi.price), 2) AS total_revenue_eur
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY year
ORDER BY year;