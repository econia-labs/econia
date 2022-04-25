script {
use 0x2::Test;
fun test_unpublish_script(account: signer) {
    Test::unpublish(&account)
}
}