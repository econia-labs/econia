use once_cell::sync::Lazy;
use regex::Regex;

pub static ADDR_REGEX: Lazy<Regex> = Lazy::new(|| Regex::new(r"^0x[0-9a-fA-F]+$").unwrap());

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_regex_match_1() {
        let addr = "0x123456";
        assert!(ADDR_REGEX.is_match(addr));
    }

    #[test]
    fn test_regex_match_2() {
        let addr = "0xabcdef";
        assert!(ADDR_REGEX.is_match(addr));
    }

    #[test]
    fn test_regex_not_match_1() {
        let addr = "0xeconia";
        assert!(!ADDR_REGEX.is_match(addr));
    }

    #[test]
    fn test_regex_not_match_2() {
        let addr = "abc012";
        assert!(!ADDR_REGEX.is_match(addr));
    }
}
