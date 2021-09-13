[![APIsec](https://cloud.fxlabs.io/assets/images/logo.png)](https://www.apisec.ai/product)

# apisec-run-scan 
#### _Triggers on-demand scans for projects registered in APIsec._
This action triggers the on-demand scans for projects registered in APIsec. Once the scan is completed successfully, You can view the scan results from the project home page in APIsec Platform. The link to view the scan results is also displayed on the console on successful completion of action.

If you configure the Issue Tracker to GitHub Issues (see [Auto Bug Management](https://www.apisec.ai/documentation#section6)), the list of open vulnerabilities across all security scans executed within this project can be viewed and closed from the GitHub issues.
___
## Inputs

### `apisec-username`
**Required** The APIsec username with which the scans will be executed.

**Note**: You can create a new user on APIsec with 'ROLE_USER' privilege.
|Default value|`""`|
--- | ---
### `apisec-password`
**Required** The Password of the APIsec user with which the scans will be executed.
|Default value|`""`|
--- | ---
### `apisec-scan-job`
**Required** The id of the scan job to run.
|Default value|`""`|
--- | ---
### `apisec-region`
**Required**  The location the scan will be executed in
|Default value|`"SUPER_1"`|
--- | ---

### `apisec-environment`
**Required** The id of the environment to run.
|Default value|`""`|
--- | ---

### `apisec-project`
**Required** The id of the project for security scan.
|Default value|`""`|
--- | ---


## Example usage

The APIsec credentials are read from github secrets.

**Warning:** Never store your secrets in the repository.

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@latest
  with:
    apisec-username: '${{ secrets.apisec_username }}'
    apisec-password: '${{ secrets.apisec_password }}'
    apisec-scan-job: "8a8094b67b9ac59e017ba54183153cf8"
    apisec-region: "Super_1"
    apisec-environment: "8a8094b67b9ac59e017ba5416f083b2e"
    apisec-project: "8a8094b67b9ac59e017ba5416f043b2c"
```
