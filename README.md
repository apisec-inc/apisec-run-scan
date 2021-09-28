[![APIsec](https://cloud.fxlabs.io/assets/images/logo.png)](https://www.apisec.ai/product)

APIsec addresses the critical need to secure APIs before they reach production. APIsec provides the industry’s only automated and continuous API testing platform that uncovers security vulnerabilities and logic flaws in APIs. Clients rely on APIsec to evaluate every update and release, ensuring that no APIs go to production with vulnerabilities.

## How to Get Started with APIsec.ai
1. <a href="https://www.apisec.ai/request-a-demo" target="_blank" rel="noopener noreferrer">Schedule a demo</a>
2. <a href="https://cloud.fxlabs.io/#/signup" target="_blank" rel="noopener noreferrer">Register your account</a>
3. <a href="https://www.youtube.com/watch?v=MK3Xo9Dbvac" target="_blank" rel="noopener noreferrer">Register your API</a>
4. Get GitHub Actions scan attributes from **APIsec Project -> Configurations -> Integrations -> CI-CD -> GitHub Actions**

![image](https://user-images.githubusercontent.com/83706991/134920640-95a0a6cd-ca03-44da-a86d-09a7b5810b47.png)




# apisec-run-scan 
#### _Triggers on-demand scans for projects registered in APIsec._
This action triggers the on-demand scans for projects registered in APIsec. Once the scan is completed successfully, You can view the scan results from the project home page in APIsec Platform. The link to view the scan results is also displayed on the console on successful completion of action.

![ScreenShot-APISec-resized](https://user-images.githubusercontent.com/83706991/133243533-5a8cd3b6-9537-4427-af3b-58736fdfe010.jpg)

APIsec also provides Summary Report with OWASP Coverage, Category wise Test Cases and Vulnerabilities count.
This can be used to share summary information about the security quality of your application without exposing the details of potentially-exploitable findings. 

![APISec-Report-Image](https://user-images.githubusercontent.com/83706991/133770517-a4c7c4ed-fd69-4daa-a183-8a5a44a4e904.jpg)

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
### `apisec-project`
**Required** The Name of the project for security scan.
|Default value|`""`|
--- | ---
### `apisec-profile`
**Optional** The Name of the scan profile to be executed.
|Default value|`"Master"`|
--- | ---
### `apisec-region`
**Optional**  The location the scan will be executed in
|Default value|`"The location configured in Profile"`|
--- | ---


## Example usage

The APIsec credentials are read from github secrets.

**Warning:** Never store your secrets in the repository.

### Basic:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.3
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
```
### Advanced:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.3
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    apisec-profile: "Staging"
    apisec-region: "Super_1"
```
