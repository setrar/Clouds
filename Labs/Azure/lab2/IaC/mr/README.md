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
