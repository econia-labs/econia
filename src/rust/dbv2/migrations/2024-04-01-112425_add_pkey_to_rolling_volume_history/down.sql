-- This file should undo anything in `up.sql`
ALTER TABLE aggregator.daily_rolling_volume_history DROP CONSTRAINT daily_rolling_volume_history_pkey;
ALTER TABLE aggregator.spreads DROP CONSTRAINT spreads_pkey;
