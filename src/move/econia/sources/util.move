/// Low-level utility functions
module econia::util {


    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::type_info::{
        account_address,
        module_name,
        struct_name,
        TypeInfo
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use aptos_framework::type_info::type_of;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return `true` if `type_info_1` and `type_info_2` are the same
    public fun are_same_type_info(
        type_info_1: &TypeInfo,
        type_info_2: &TypeInfo
    ): bool {
        (account_address(type_info_1) == account_address(type_info_2)) &&
        (module_name(type_info_1) == module_name(type_info_2)) &&
        (struct_name(type_info_1) == struct_name(type_info_2))
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    struct TestStruct{}

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Assert returns
    fun test_are_same_type_info() {
        // Get type info for test struct
        let test_struct_info = type_of<TestStruct>();
        // Get type info for TypeInfo
        let type_info_info = type_of<TypeInfo>();
        // Assert true return when same type
        assert!(are_same_type_info(&test_struct_info, &test_struct_info), 0);
        // Assert false return when different type
        assert!(!are_same_type_info(&test_struct_info, &type_info_info), 0);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}