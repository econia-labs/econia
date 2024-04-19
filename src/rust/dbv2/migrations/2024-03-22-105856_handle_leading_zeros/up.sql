-- Your SQL goes here
UPDATE balance_updates_by_handle SET handle = regexp_replace(handle, '0x0*', '0x');
UPDATE market_account_handles SET handle = regexp_replace(handle, '0x0*', '0x');
