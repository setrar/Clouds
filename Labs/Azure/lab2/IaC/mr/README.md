# AZ Cli Management

```
export AzureWebJobsStorage=$(tofu output -raw storage_account_connection_string)
```

```
tofu output -raw storage_account_connection_string
```
> DefaultEndpointsProtocol=https;AccountName=clouds25brlab2mrstrg;AccountKey=O9nlMI0+uG+H7WD+FFFdtNjL0hylf1lhFFFFFFFFFFFF7wFT+AStlo2Xww==;EndpointSuffix=core.windows.net

```
export ACCOUNT_KEY=$(tofu output -raw storage_account_connection_string | sed -n 's/.*AccountKey=\([^;]*\).*/\1/p')
```

```
az storage blob list \
          --container-name function-releases \
          --account-name clouds25brlab2mrstrg --account-key ${ACCOUNT_KEY} \
          --output table                                                     
```
> Returns
```powershell
Name                                                     Blob Type    Blob Tier    Length    Content Type              Last Modified              Snapshot
-------------------------------------------------------  -----------  -----------  --------  ------------------------  -------------------------  ----------
20250126183415-51c6b113-3d3c-4954-862c-9698b53bf0e6.zip  BlockBlob    Hot          8394      application/octet-stream  2025-01-26T17:34:16+00:00
```

```
az storage blob download \
          --container-name function-releases \
          --account-name clouds25brlab2mrstrg --account-key ${ACCOUNT_KEY} \
          --name 20250126183415-51c6b113-3d3c-4954-862c-9698b53bf0e6.zip --file function_code.zip                                                  
```

```
az storage container list  \
          --account-name clouds25brlab2mrstrg --account-key ${ACCOUNT_KEY} \
          --output table                                                     
```
> Returns
```powershell
Name                          Lease Status    Last Modified
----------------------------  --------------  -------------------------
azure-webjobs-hosts                           2025-01-26T17:34:00+00:00
azure-webjobs-secrets                         2025-01-26T17:34:23+00:00
clouds25brlab2mrfnc-applease                  2025-01-26T17:34:59+00:00
clouds25brlab2mrfnc-leases                    2025-01-26T17:34:59+00:00
function-releases                             2025-01-26T17:34:16+00:00
input-container                               2025-01-26T17:31:59+00:00
scm-releases                                  2025-01-26T17:32:06+00:00
```

```
curl -X POST https://clouds25brlab2mrfnc.azurewebsites.net/api/orchestrators/masterorchestrator -d '{}' -H "Content-Type: application/json"
```

---

The error indicates that the Azure Function app cannot resolve the Azure Storage connection string named Storage. This issue arises when the expected connection string for `AzureWebJobsStorage` or a similar setting is either missing or invalid.

Here’s how to troubleshoot and resolve it:

Steps to Fix the Issue
1.	Verify local.settings.json File:
Ensure your `local.settings.json` file includes the correct `AzureWebJobsStorage` setting. It should look something like this:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<storage_account_name>;AccountKey=<storage_account_key>;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME": "python"
  }
}
```

Replace `<storage_account_name>` and `<storage_account_key>` with your Azure Storage account’s name and key.

2.	Check Connection String:

If you’re running locally, ensure that the storage account connection string is accurate. Test it by attempting to connect to the storage account:

```
az storage container list --account-name <storage_account_name> --account-key <storage_account_key> --output table
```


3.	Set the Environment Variable:

If you don’t want to use local.settings.json, you can set the connection string as an environment variable:

```
export AzureWebJobsStorage="DefaultEndpointsProtocol=https;AccountName=<storage_account_name>;AccountKey <storage_account_key>;EndpointSuffix=core.windows.net"
```


4.	Check the DurableTask Configuration:

In your app, verify the host.json file for any DurableTask configuration referencing a connection string named Storage. Ensure it matches the name of the connection string in your local.settings.json. Example:

```json
{
  "version": "2.0",
  "extensions": {
    "durableTask": {
      "hubName": "TestHubName",
      "storageProvider": {
        "connectionStringName": "AzureWebJobsStorage"
      }
    }
  }
}
```

Make sure connectionStringName matches the AzureWebJobsStorage or another valid key in your settings.

5.	Restart the Function:

After making these changes, restart your function app locally:

```
func start
```

Common Debugging Commands

 •	Check the local storage connection:

```
az storage blob list --account-name <storage_account_name> --account-key <storage_account_key> --container-name <container_name>
```

•	Validate your local environment variables:

```
env | grep AzureWebJobsStorage
```

