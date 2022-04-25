script {
use 0x2::Test;
fun test_script(account: signer) {
    Test::publish(&account)
}
}