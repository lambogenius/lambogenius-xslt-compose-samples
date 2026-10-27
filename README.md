# Compose using XSLT: samples

Runnable Azure Logic Apps Standard projects for **Compose using XSLT**, the Lambogenius built-in action that runs
XSLT 1.0 maps in a workflow. It supports deployed and inline maps, `xsl:include`/`xsl:import`, parameters,
`msxsl:script` C# helpers, and calls to Azure Functions from maps. Every transformation runs in a supervised worker
process with a hard deadline.

Each folder is a complete Logic App. `run.ps1` builds and starts it locally, and `demo.ps1` calls every workflow and
checks the results.

| Sample | Port | Workflows | Shows |
| --- | --- | --- | --- |
| [01-basics](01-basics) | 7181 | `order-to-sales-order`, `inline-map`, `order-report-html`, `order-lines-csv`, `order-to-json`, `error-handling` | Deployed and inline maps, `xsl:import`, parameters from the query string, XML/HTML/text output, CSV and JSON from XSLT 1.0, reading the result with `xpath()`, catching failures in a Scope |
| [02-workflow-variables](02-workflow-variables) | 7182 | `variables-as-parameters`, `batch-loop`, `dynamic-map`, `approval-routing` | String, float, boolean and integer **workflow variables as XSLT parameters**; a `For each` loop that transforms each order and collects results in array/integer/float variables; a variable that picks the map; a `Switch` on a variable set from the map's output |
| [03-csharp-scripts](03-csharp-scripts) | 7183 | `invoice-with-csharp`, `inline-script`, `timeout-protection` | `msxsl:script` C# helpers (money, dates, regular expressions, a check digit), several script namespaces, compile caching, and a runaway script stopped at the action's deadline |
| [04-azure-functions](04-azure-functions) | 7184 | `order-to-sales-order`, `enrich-orders`, `function-not-allowed` | `az:InvokeText` calls to an Azure Function from a map, the function registry, per-transformation caching, a Function error caught by the workflow, and an alias the action does not allow |

[shared/functions/GetCustomerName](shared/functions/GetCustomerName) is the sample Function that the maps in
04-azure-functions call. `run.ps1` starts it on port 7180.

## Prerequisites

- **.NET SDK 8** or later, with the **.NET 8 runtime**
- **Azure Functions Core Tools 4**: `npm install -g azure-functions-core-tools@4`
- **Azurite**: `npm install -g azurite`. The scripts start it, or reuse one that is already running.
- **PowerShell 7** (`pwsh`)
- **The connector package**: sign in at <https://lambogenius.com/app/downloads/xslt-compose>, download
  `Lambogenius.XsltCompose.LogicApps.1.1.1.nupkg`, and save it in [packages/](packages)

## Licensing

The samples run without a license: under Azure Functions Core Tools (`func start`) on a developer machine the action
runs unlicensed and logs a reminder. Anywhere else (Azure, containers, `dotnet run`) it needs a license token in the
app setting `LAMBOGENIUS_LICENSE`, or it fails with `LicenseRequired` (HTTP 403). Get a token at
<https://lambogenius.com/app/licensing>: a free developer license for development and testing (Azure included), a
free 30-day trial, or a production license from sales.

## Run a sample

```powershell
cd 01-basics
./run.ps1                       # builds, starts Azurite and the Logic App on http://localhost:7181; Ctrl+C stops it
```

In a second window:

```powershell
cd 01-basics
./demo.ps1                      # calls every workflow and checks the results
./send.ps1 order-to-sales-order requests/order.xml -Query currency=USD
```

To run every sample, one after another, with checks:

```powershell
./test-all.ps1
```

## How a sample is put together

```text
01-basics/
  LogicApp.csproj            NuGet-based Standard project; references Lambogenius.XsltCompose.LogicApps
  host.json                  the build removes "extensionBundle" from the copy the runtime uses
  connections.json           the lamboXsltCompose service provider connection
  Artifacts/Maps/            deployed maps (mapName is relative to this folder)
  <workflow>/workflow.json   one folder per workflow
  requests/                  messages to send
  run.ps1, send.ps1, demo.ps1
```

The action in a workflow:

```json
"Compose_using_XSLT": {
  "type": "ServiceProvider",
  "inputs": {
    "parameters": {
      "content": "@{triggerBody()}",
      "mapSource": "deployed",
      "mapName": "orders/order-to-sales-order.xslt",
      "parameters": { "currency": "@variables('currency')" },
      "enableScripts": false,
      "allowedFunctionAliases": [],
      "timeoutSeconds": 30
    },
    "serviceProviderConfiguration": {
      "connectionName": "lamboXsltCompose",
      "operationId": "ComposeXslt",
      "serviceProviderId": "/serviceProviders/lamboXsltCompose"
    }
  }
}
```

The action returns `result` (the transformed text), `contentType`, `outputMethod`, `mapHash` and `diagnostics`
(timings, cache hits, Function call counts).

## Use the connector in your own project

1. The project must be NuGet-based (`Microsoft.Azure.Workflows.WebJobs.Extension` and
   `Microsoft.NET.Sdk.Functions`), like `LogicApp.csproj` here.
2. Add the folder or feed that holds the package to your `nuget.config`, then
   `dotnet add package Lambogenius.XsltCompose.LogicApps --version 1.1.1`.
3. Copy the `RemoveExtensionBundleFrom...` targets from a sample's `LogicApp.csproj`, so the runtime loads your
   project's packages instead of the extension bundle.
4. Set `FUNCTIONS_INPROC_NET8_ENABLED=1` and add the `lamboXsltCompose` connection.

The full documentation, including configuration, limits, error codes and Azure deployment, is at
<https://lambogenius.com/docs/xslt-compose>.

## Notes

- These samples use synthetic data only.
- Function keys never go in maps, workflows or the registry. The registry (`xslt-functions.json`) names the app
  setting that holds the key; locally, Core Tools does not check keys.
- `XsltCompose__Development__AllowLocalhostHttp` lets the registry use `http://localhost` and is for local
  development only.
