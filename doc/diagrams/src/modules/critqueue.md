# critqueue.move

- [critqueue.move](#critqueuemove)
  - [Bitwise functions](#bitwise-functions)
  - [Initialization](#initialization)
  - [Insertion](#insertion)
  - [Borrowers](#borrowers)
  - [Lookup](#lookup)

## Bitwise functions

```mermaid

flowchart LR

get_critical_bitmask
is_inner_key
is_leaf_key
is_set

```

## Initialization

```mermaid

flowchart LR

new

```

## Insertion

```mermaid

flowchart LR

insert --> insert_update_subqueue
insert --> insert_allocate_leaf
insert --> insert_check_head
insert --> insert_leaf

```

## Borrowers

```mermaid

flowchart LR

borrow
borrow_mut

```

## Lookup

```mermaid

flowchart LR

get_head_access_key
has_access_key
is_empty
would_become_new_head
would_trail_head

```