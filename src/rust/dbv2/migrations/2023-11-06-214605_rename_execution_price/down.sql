-- This file should undo anything in `up.sql`
ALTER FUNCTION
    api.average_execution_price
RENAME TO
    execution_price;
