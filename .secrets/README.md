# Secrets

With the exception of this file, the `.secrets` directory is ignored by Git.

The `.secrets` directory contains hot wallet account secret files, which should be stored in files of the form `<account_authentication_key>.secret`, with the secret file containing the account's private key (secret) in plain text.

Both the authentication key in the filename and the hex secret in the file should be stored without a `0x` prefix.

A persistent test account may be stored in the `persistent` directory, a temporary account may be stored in the `temporary` directory, old test accounts may be stored in an `old` subdirectory, and other directories can be generated as needed.
