-- This file should undo anything in `up.sql`
DROP VIEW api.markets;


CREATE VIEW api.markets AS
    SELECT
        m.*,
        CASE
            WHEN r.market_id = m.market_id THEN true
            ELSE false
        END AS is_recognized
    FROM
        market_registration_events AS m
    LEFT JOIN
        aggregator.recognized_markets AS r
    ON
        COALESCE(r.base_account_address, '') = COALESCE(m.base_account_address, '')
    AND
        COALESCE(r.base_module_name, '') = COALESCE(m.base_module_name, '')
    AND
        COALESCE(r.base_struct_name, '') = COALESCE(m.base_struct_name, '')
    AND
        COALESCE(r.base_name_generic, '') = COALESCE(m.base_name_generic, '')
    AND
        r.quote_account_address = m.quote_account_address
    AND
        r.quote_module_name = m.quote_module_name
    AND
        r.quote_struct_name = m.quote_struct_name;


GRANT SELECT ON api.markets TO web_anon;
