CREATE VIEW api.fill_events_deduped AS
SELECT
    *
FROM
    fill_events
WHERE
    emit_address = maker_address;

GRANT SELECT ON api.fill_events_deduped TO web_anon;

