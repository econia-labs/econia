-- This file should undo anything in `up.sql`
UPDATE balance_updates_by_handle SET handle = regexp_replace(handle, '0x', '0x0000000000000000000000000000000000000000000000000000000000000000');
UPDATE balance_updates_by_handle SET handle = regexp_replace(handle, '^0x0*(.{64})$', '0x\1');
UPDATE market_account_handles SET handle = regexp_replace(handle, '0x', '0x0000000000000000000000000000000000000000000000000000000000000000');
UPDATE market_account_handles SET handle = regexp_replace(handle, '^0x0*(.{64})$', '0x\1');
