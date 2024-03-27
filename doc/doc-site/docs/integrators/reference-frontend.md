# Reference frontend

## Background

The objective of The Econia [reference frontend](https://reference.econia.exchange/) is to streamline the challenges encountered in product development during the initial phases of creating DeFi products. This tutorial is designed to guide developers, whether experienced or novice, through the process from forking on GitHub to project completion.

![](/img/referencefrontend.png)

## In this tutorial, you will learn how to:

1. Fork Econia reference frontend
1. Run the frontend locally
1. Deploy the frontend on Vercel

# Prerequisites:

1. VSCode, terminal, or your favorite code editor
1. `pnpm` installed

## Step 1: Clone The Econia frontend [Github](https://github.com/econia-labs/econia-frontend) repo

You can either clone the repo using git commands, fork to your own github, or download the zip.

*Don't know how to clone a repository? Check out **[this guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)** from Github.*

![](/img/frontendrepo.png)


## Step 2 (Optional): TradingView repo setup

By default the candlestick chart functionality in the Econia reference frontend relies on the closed source [TradingView Advanced Charts] repository.
If you do not have access to the private repository, the candlestick functionality falls back on the open source [Lightweight Charts](https://github.com/tradingview/lightweight-charts) repository.

> NOTE: Skip this part if you want to use the open source version

The [TradingView Advanced Charts] repository is the submodule of this repository which is used for displaying the trading chart of a specific market and initialized at `src/frontend/public/static`.

In essence, adding the `TradingView` as a submodule clones the `TradingView` repository and build it into static files.
Therefore, you need to have the access rights to the `TradingView` repository.

> To get the access rights, you have to contact the TradingView team and wait for approval.

## Step 3: Open your fork of `econia-frontend`

Before we start, it's important to check out the architecture of the code. You can see a diagram of components and files for each page and view here:

```mermaid
   graph TD;
      src-->sdk;
      src-->frontend;
      frontend-->charting_library_submodule;
      frontend-->pages;
      pages-->trade;
      pages-->swap;
      pages-->faucet;
      trade-->Header;
      trade-->StatsBar;
      trade-->TradingViewChart;
      trade-->DeepChart;
      trade-->OrdersTable;
      trade-->OrderBook;
      trade-->OrderEntry;
      trade-->TradeHistories;
      TradingViewChart-->TVChartContainer;
      TVChartContainer--"*if the charting_library submodule isn't available*"-->LightweightChartsContainer;
``````

*We will work inside the "src/frontend" folder*

## Step 4: Run project locally

- Navigate to the Frontend Folder

```bash
cd src/frontend
```

`cd` means “change directory” to the src/frontend directory

- Install dependencies

```bash
pnpm i # pnpm is required
```

`pnpm` is a package manager

- Copy .env.example file

```bash
cp -R .env.example .env.local
```

The command is copying the contents of the **`.env.example`** file to a file named **`.env.local`**. The **`-R`** flag indicates a recursive copy, which is typically used when dealing with directories.

If you take a look at the `.env` files you may note that the environment variable for the REST URL is set to https://aptos-testnet-econia.nodeinfra.com/, since Nodeinfra runs a community deployment of the [Econia DSS](../off-chain/dss/data-service-stack.md), which provides data feeds for the Econia reference frontend data.

| Variable | Meaning |
| --- | --- |
| `NEXT_PUBLIC_ECONIA_ADDR` | The Econia address |
| `NEXT_PUBLIC_FAUCET_ADDR` | The Econia faucet address |
| `NEXT_PUBLIC_NETWORK_NAME` | The network name (for example, testnet) |
| `NEXT_PUBLIC_API_URL` | The Econia REST API URL |
| `NEXT_PUBLIC_RPC_NODE_URL` | Aptos RPC URL |
| `NEXT_PUBLIC_UNCONNECTED_NOTICE_MESSAGE` | Message that shows in modal when user has not connected wallet yet |
| `NEXT_PUBLIC_READ_ONLY` | Config read only mode, 1 OR 0 |
| `NEXT_PUBLIC_READ_ONLY_MESSAGE` | Error message when user attempt do a require sign operator |
| `NEXT_PUBLIC_DEFAULT_MARKET_ID` | Default market id |
| `TRY_CLONING_TRADINGVIEW` | Set to any value other than "1" to skip private submodule cloning |

- Run the development server

```
pnpm run dev
```

Doing so should open http://localhost:3000/ in your browser, where you'll see the local version of the frontend.

*Note: change the coloring and branding of the frontend before publishing.*

## Steps to deploy on Vercel

Vercel is a user-friendly cloud platform for frontend development and deployment. It streamlines the deployment process by automating Git-based deployments and serverless functions.

Prerequisites:

1. Github Account
1. Github Access Token

To generate a `GITHUB_ACCESS_TOKEN`:

1. Go to https://github.com/settings/tokens/new
2. Provide a descriptive `note`
3. In `Expiration` selection box, choose `No expiration`
4. In the `Select scopes` section, click on `repo - Full control of private repositories` to select all repository-related options
5. Click `Generate token`
6. Copy the generated token to your Vercel environment variables and name it `GITHUB_ACCESS_TOKEN`

## Step 1: Log into Vercel

![](/img/Vercel.png)

## Step 2: Create a Vercel project

 Import project - on your screen, click `Add New` button and select `Project` to create a new project or shortly clicks `Import project` to import the Github repository.

The Vercel webiste displays a list of repositories existing in your Github account.

Now click the `Import` button on the `econia-frontend` repository.

![](/img/Vercel2.png)

## Step 3: Configure Project

**Project Name**: The project name is automatically generated, you can change it as you want.

**Framework Preset**: As the directory at the above path is a NextJS project then Vercel automatically detects that its `Framework Preset` is NextJS.

**Root Directory**: At the `Root Directory` field, click the `Edit` button next to it. A modal pops up and tells you to select the directory where your source code is located. Then, you must select the path `econia-frontend/src/frontend` and click `Continue`.

![](/img/Vercelconfig.png)

**Build and Output Settings**: Override the `Install Command` with the following:

![](/img/VercelBuild.png)

**Environment Preparation**

To deploy on Vercel, you'll need to set up the following environment variables:

| Variable | Meaning |
| --- | --- |
| `NEXT_PUBLIC_ECONIA_ADDR` | The Econia address |
| `NEXT_PUBLIC_FAUCET_ADDR` | The Econia faucet address |
| `NEXT_PUBLIC_NETWORK_NAME` | The network name (for example, testnet) |
| `NEXT_PUBLIC_API_URL` | The Econia REST API URL |
| `NEXT_PUBLIC_RPC_NODE_URL` | Aptos RPC URL |
| `GITHUB_ACCESS_TOKEN` | Access token for GitHub account with private `TradingView` repo access (only required in Vercel) |
| `NEXT_PUBLIC_UNCONNECTED_NOTICE_MESSAGE` | Message that shows in modal when user has not connected wallet yet |
| `NEXT_PUBLIC_READ_ONLY` | Config read only mode, 1 OR 0 |
| `NEXT_PUBLIC_READ_ONLY_MESSAGE` | Error message when user attempt do a require sign operator |
| `NEXT_PUBLIC_DEFAULT_MARKET_ID` | Default market id |
| `TRY_CLONING_TRADINGVIEW` | Set to any value other than "1" to skip private submodule cloning |

Note: If you do not have access to the private `TradingView` submodule then set `TRY_CLONING_TRADINGVIEW` to any value other than “1”.

**Environment Variables**: Paste all the environment variables in `.env.local`  or  `.env.example`  file to the table.

:::tip
There's a trick that you don't need to copy and paste each variable at a time, just copy your file and paste into the input field.
:::

![](/img/VercelEnvironment.png)

## Step 4: Deploy your project

Click the `Deploy` button, wait for several minutes and see the results.

![](/img/VercelDeploy.png)

*Note: You may see the errors below if you do not have access to the private `TradingView` submodule, but the website will still deploy with the open source fallback!

![](/img/VercelErrors.png)

Congrats! You will then be taken to the page hosted on Vercel!

![](/img/VercelCongrats.png)

*Note: Change all design, logos, and branding before publishing.*

[tradingview advanced charts]: https://github.com/tradingview/charting_library