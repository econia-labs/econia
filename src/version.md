# Version

## Module `0xc0deb00c::Version`

Mock version number functionality for simulating Aptos database version number. Calls to [`get_v_n`](version.md#0xc0deb00c\_Version\_get\_v\_n)`()` can be easily replaced with a Move native function for getting the true database version number (once it is implemented).

* [Resource `MC`](version.md#0xc0deb00c\_Version\_MC)
* [Constants](version.md#@Constants\_0)
* [Function `get_v_n`](version.md#0xc0deb00c\_Version\_get\_v\_n)
* [Function `init_mock_version_number`](version.md#0xc0deb00c\_Version\_init\_mock\_version\_number)
* [Function `get_updated_mock_version_number`](version.md#0xc0deb00c\_Version\_get\_updated\_mock\_version\_number)

```
use 0x1::Signer;
```

### Resource `MC`

Mock version number counter

```
struct MC has key
```

<details>

<summary>Fields</summary>

`i: u64`

</details>

### Constants

When account/address is not Econia

```
const E_NOT_ECONIA: u64 = 0;
```

When mock version number counter already exists

```
const E_MC_EXISTS: u64 = 1;
```

### Function `get_v_n`

Wrapped get-update function for mock version number counter, calls to which can be easily replaced once a true version number getter is implemented as a Move native function

```
public(friend) fun get_v_n(): u64
```

<details>

<summary>Implementation</summary>

```
public(friend) fun get_v_n():
u64
acquires MC {
    get_updated_mock_version_number()
}
```

</details>

### Function `init_mock_version_number`

Initialize mock version number counter under Econia account, aborting if called by another signer or if counter exists

```
public(friend) fun init_mock_version_number(account: &signer)
```

<details>

<summary>Implementation</summary>

```
public(friend) fun init_mock_version_number(
    account: &signer
) {
    let addr = s_a_o(account); // Get account address
    assert!(addr == @Econia, E_NOT_ECONIA); // Assert Econia called
    // Assert mock version number counter doesn't exist already
    assert!(!exists<MC>(addr), E_MC_EXISTS);
    move_to<MC>(account, MC{i: 0}); // Move mock counter to Econia
}
```

</details>

### Function `get_updated_mock_version_number`

Increment mock version number counter by one and return result. To reduce overhead, assume [`MC`](version.md#0xc0deb00c\_Version\_MC) has already been initialized

```
fun get_updated_mock_version_number(): u64
```

<details>

<summary>Implementation</summary>

```
fun get_updated_mock_version_number():
u64
acquires MC {
    // Borrow mutable reference to mock version number counter value
    let v_n = &mut borrow_global_mut<MC>(@Econia).i;
    *v_n = *v_n + 1; // Increment by 1
    *v_n // Return new value
}
```

</details>
