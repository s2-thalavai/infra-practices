## 1. Subdomain Example (Recommended, CNAME)

- **Scenario:** You want your function to be available at api.example.com.

**DNS Configuration**
| Record Type | Host  | Points To                     |
| ----------- | ----- | ----------------------------- |
| CNAME       | `api` | `myfuncapp.azurewebsites.net` |

- api is the subdomain prefix.

- Use CNAME because it maps a subdomain to another domain.

- Works well with App Service Managed Certificates for HTTPS.

**Access Example:**

    https://api.example.com

# Azure Functions Custom Domain Flow

## Subdomain Example (`api.example.com`)

```text
+------------------+       +-------------------------+
|  api.example.com | ----> | DNS CNAME: points to    |
+------------------+       | myfuncapp.azurewebsites.net |
                           +-------------------------+
                                      |
                                      v
                           +------------------+
                           |  Azure Function  |
                           +------------------+
                                      |
                                      v
                           +------------------+
                           |  HTTPS / TLS     |
                           +------------------+
```
## 2. Root / Apex Domain Example (Requires A Record + TXT)

- **Scenario:** You want your function to be available at example.com (no subdomain).

**DNS Configuration**

| Record Type | Name                | Value / Points To                   |
| ----------- | ------------------- | ----------------------------------- |
| A           | `@`                 | Function App IP (e.g., 20.50.30.40) |
| TXT         | `asuid.example.com` | Provided by Azure for verification  |


- @ denotes the root domain.

- Azure requires a TXT record to prove ownership before mapping the apex domain.

- HTTPS with Managed Certificates also works, but needs validation.

**Access Example:**

    https://example.com

```text
+------------------+       +------------------+
|  example.com     | ----> | DNS A Record:    |
+------------------+       | points to IP     |
                           +------------------+
                           | TXT Verification |
                           +------------------+
                                      |
                                      v
                           +------------------+
                           |  Azure Function  |
                           +------------------+
                                      |
                                      v
                           +------------------+
                           |  HTTPS / TLS     |
                           +------------------+
```
## Quick Summary Table

| Domain Type | DNS Record Type | Example                                       | Notes                                      |
| ----------- | --------------- | --------------------------------------------- | ------------------------------------------ |
| Subdomain   | CNAME           | api.example.com → myfuncapp.azurewebsites.net | Easier, recommended, supports HTTPS        |
| Root/Apex   | A + TXT         | example.com → Function App IP                 | Slightly more complex, also supports HTTPS |
