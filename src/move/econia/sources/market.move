/// Stub for dependency planning
module econia::market {
    use econia::registry;
    use econia::user;
    fun invoke_registry() {registry::is_registered_custodian_id(0);}
    fun invoke_user() {user::return_0();}
}