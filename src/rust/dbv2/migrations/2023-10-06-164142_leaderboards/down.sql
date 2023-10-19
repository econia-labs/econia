-- This file should undo anything in `up.sql`
DROP INDEX aggregator.ranking_idx;


DROP INDEX aggregator.competition_indexed_events_comp_id;


DROP INDEX aggregator.competition_indexed_events_tx_ev;


DROP INDEX fills_market_id;


DROP FUNCTION api.volume;


DROP FUNCTION api.is_eligible;


DROP FUNCTION aggregator.user_volume;


DROP FUNCTION aggregator.user_trades;


DROP FUNCTION aggregator.user_integrators;


DROP FUNCTION aggregator.places;


DROP FUNCTION aggregator.fills;


DROP VIEW api.competition_leaderboard_users;


DROP TABLE aggregator.competition_leaderboard_users;


DROP TABLE aggregator.competition_indexed_events;


DROP VIEW api.competition_exclusion_list;


DROP TABLE aggregator.competition_exclusion_list;


DROP VIEW api.competition_metadata;


DROP TABLE aggregator.competition_metadata;
