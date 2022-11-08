```mermaid

flowchart LR

swap_between_coinstores_entry --> swap_between_coinstores

swap_between_coinstores --> range_check_trade
swap_between_coinstores --> swap

swap_coins --> range_check_trade
swap_coins --> swap

swap_generic --> range_check_trade
swap_generic --> swap

place_limit_order --> match
place_limit_order --> range_check_trade

place_market_order --> match
place_market_order --> range_check_trade

swap --> match

```