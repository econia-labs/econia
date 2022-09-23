module econia::registry {
    use econia::incentives;
    fun use_friend() {incentives::calculate_max_quote_match(false, 0, 0);}
}