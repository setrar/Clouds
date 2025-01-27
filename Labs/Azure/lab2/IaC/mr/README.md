# AZ Cli Management

```
tofu output -raw storage_account_connection_string
```
> DefaultEndpointsProtocol=https;AccountName=clouds25brlab2mrstrg;AccountKey=O9nlMI0+uG+H7WD+FFFdtNjL0hylf1lhFFFFFFFFFFFF7wFT+AStlo2Xww==;EndpointSuffix=core.windows.net

```
export ACCOUNT_KEY=$(tofu output -raw storage_account_connection_string | sed -n 's/.*AccountKey=\([^;]*\).*/\1/p')
```

```
az storage blob list --account-name clouds25brlab2mrstrg --account-key ${ACCOUNT_KEY} \
                                                     --container-name function-releases --output table
```
> Returns
```powershell
Name                                                     Blob Type    Blob Tier    Length    Content Type              Last Modified              Snapshot
-------------------------------------------------------  -----------  -----------  --------  ------------------------  -------------------------  ----------
20250126183415-51c6b113-3d3c-4954-862c-9698b53bf0e6.zip  BlockBlob    Hot          8394      application/octet-stream  2025-01-26T17:34:16+00:00
```

```
az storage blob download --account-name clouds25brlab2mrstrg --account-key ${ACCOUNT_KEY} \
                         --container-name function-releases \
                         --name 20250126183415-51c6b113-3d3c-4954-862c-9698b53bf0e6.zip --file function_code.zip
```


```
curl -X POST https://clouds25brlab2mrfnc.azurewebsites.net/api/orchestrators/masterorchestrator -d '{}' -H "Content-Type: application/json"
```
