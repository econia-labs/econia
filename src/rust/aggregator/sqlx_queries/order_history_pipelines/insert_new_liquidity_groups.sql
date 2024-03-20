INSERT INTO aggregator.liquidity_groups (name, market_id)
SELECT 'all', market_id FROM market_registration_events m WHERE NOT EXISTS (
    SELECT *
    FROM aggregator.liquidity_groups lg
    WHERE lg.market_id = m.market_id
    AND lg.name = 'all'
);
