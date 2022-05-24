module Econia::Match {

    #[test_only]
    use Econia::CritBit::{
        CB,
        borrow as cb_b,
        borrow_mut as cb_b_m,
        insert as cb_i,
        pop as cb_p,
        singleton as cb_s
    };

    #[test]
    fun inspect_and_change():
    CB<u8> {
        let cb = cb_s<u8>(1, 5);
        cb_i(&mut cb, 2, 6); // Changed (attempted)
        cb_i(&mut cb, 3, 7); // Popped
        let _ = cb_p(&mut cb, 3); // Pop
        assert!(*cb_b(&cb, 2) == 6, 0); // Assert {2, 6}
        let n_ref = cb_b_m(&mut cb, 2); // Borrow mut ref to key 2
        *n_ref = 3; // Change value to 3
        assert!(*cb_b(&cb, 2) == 3, 0); // Assert {2, 3}
        cb // Return rather than unpack
    }
}