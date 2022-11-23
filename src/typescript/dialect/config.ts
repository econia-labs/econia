    // Dialect imports.
    import {
        Dialect,
        DialectCloudEnvironment,
        DialectSdk,
    } from '@dialectlabs/sdk';

    // Aptos-specific imports.
    import {
        Aptos,
        AptosSdkFactory,
        NodeDialectAptosWalletAdapter
    } from '@dialectlabs/blockchain-sdk-aptos';

    // File import.
    import {readFileSync} from 'fs';

    // Read in hex seed from disk (file is in gitignore).
    const hexSeed = readFileSync('./secret.key', 'utf-8');

    // Get private key bytes from string.
    const privateKey = Uint8Array.from(Buffer.from(hexSeed, 'hex'));

    // Declare environment.
    const environment: DialectCloudEnvironment = 'development';

    // Initialize SDK.
    const sdk: DialectSdk<Aptos> = Dialect.sdk(
        {environment},
        AptosSdkFactory.create({
            wallet: NodeDialectAptosWalletAdapter.create(privateKey)}));

    (async () => {
        // Register dapp.
        const dapp = await sdk.dapps.create({
            name: 'Econia',
            description: `Hyper-parallelized on-chain order book for the Aptos blockchain.`
        });
        console.log('dApp registration complete.')
    })();
