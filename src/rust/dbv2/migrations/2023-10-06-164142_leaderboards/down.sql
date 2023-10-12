-- This file should undo anything in `up.sql`
DROP FUNCTION api.volume;


DROP FUNCTION api.is_eligible;


DROP FUNCTION aggregator.current_places;


DROP FUNCTION aggregator.current_fills;


DROP VIEW aggregator.homogenous_places;


DROP VIEW aggregator.homogenous_fills;


DROP VIEW api.competition_exclusion_list;


DROP TABLE aggregator.competition_exclusion_metadata;


DROP VIEW api.competition_leaderboard_users;


DROP TABLE aggregator.competition_leaderboard_users;


DROP TABLE aggregator.competition_indexed_events;


DROP VIEW api.competition_metadata;


DROP TABLE aggregator.competition_metadata;
