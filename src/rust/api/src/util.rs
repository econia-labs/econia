use once_cell::sync::Lazy;
use regex::Regex;

use crate::error::ApiError;

static ADDR_REGEX: Lazy<Regex> = Lazy::new(|| Regex::new(r"^0x[0-9a-fA-F]+$").unwrap());

static PG_URI_REGEX: Lazy<Regex> =
    Lazy::new(|| Regex::new(r"(postgres://.*?:)([^@/]+)(@.*)").unwrap());

/// Checks that the provided address is a valid Aptos account address.
pub fn check_addr(addr: &str) -> Result<(), ApiError> {
    if !ADDR_REGEX.is_match(addr) {
        Err(ApiError::InvalidAddress(addr.to_string()))
    } else {
        Ok(())
    }
}

/// Returns a boolean value representing whether or not the provided string
/// slice is a valid Aptos address.
pub fn is_valid_addr(addr: &str) -> bool {
    ADDR_REGEX.is_match(addr)
}

/// Given a Postgres URL, returns the same URL but with the password replaced
/// with a series of asterisks.
pub fn redact_postgres_password(url: &str) -> String {
    let redacted_url = PG_URI_REGEX.replace(url, r"$1********$3");
    redacted_url.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_regex_match_1() {
        let addr = "0x123456";
        assert!(is_valid_addr(addr));
    }

    #[test]
    fn test_regex_match_2() {
        let addr = "0xabcdef";
        assert!(is_valid_addr(addr));
    }

    #[test]
    fn test_regex_not_match_1() {
        let addr = "0xeconia";
        assert!(!is_valid_addr(addr));
    }

    #[test]
    fn test_regex_not_match_2() {
        let addr = "abc012";
        assert!(!is_valid_addr(addr));
    }
}
