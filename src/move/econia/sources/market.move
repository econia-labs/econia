/// Stub for dependency planning
module econia::market {
    use econia::registry;
    use econia::user;
    fun invoke_registry() {registry::n_markets();}
    fun invoke_user() {user::return_0();}
}