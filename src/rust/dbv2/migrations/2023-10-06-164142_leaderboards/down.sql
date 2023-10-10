-- This file should undo anything in `up.sql`
DROP FUNCTION api.volume;

DROP VIEW api.competition_exclusion_list;

DROP TABLE competition_exclusion_list;

DROP VIEW api.competition_leaderboard_users;

DROP TABLE competition_leaderboard_users;

DROP TABLE competition_indexed_events;

DROP VIEW api.competition_metadata;

DROP TABLE competition_metadata;
