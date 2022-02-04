[![APIsec](https://cloud.fxlabs.io/assets/images/logo.png)](https://www.apisec.ai/product)

APIsec addresses the critical need to secure APIs before they reach production. APIsec provides the industry’s only automated and continuous API testing platform that uncovers security vulnerabilities and logic flaws in APIs. Clients rely on APIsec to evaluate every update and release, ensuring that no APIs go to production with vulnerabilities.

You develop the application and API, we bring complete and continuous security testing to you, accelerating development. 

Know your API and Applications are secure with Apisec – our automated and continuous API security testing platform. 

## How Apisec works:
Apisec functions in the following simple steps.

### Register API
Connect your API gateways, including Apigee, Kong, Mulesoft, AWS API Gateway, Azure API Gateway, etc. Or point us towards your API. Apisec instantly learns your live API composition, including the list of endpoints and operations, and creates an API functionality map. Apisec supports various API specifications, including OpenAPI specification, Swagger, Postman collection, RAML, etc.

### Automatic Coverage
Apisec automatically creates thousands of attack playbooks to comprehensively and completely test every function of your API. The playbooks address the entire OWASP API Security Top 10 and more, giving you complete coverage.

### Continuous Testing
Apisec runs playbooks against your APIs to ensure the code check-in introduces no vulnerabilities. These playbooks are non-intrusive, save, and run against test/staging or production environments.

### Vulnerabilities Reporting
The Apisec playbooks are designed to find the trickiest vulnerabilities - business logic flaws, OWASP API top 10, and not just standard security issues. 

You can view the scan results from the project home page in APIsec Platform. The link to view the scan results is also displayed on the console on successful completion of action.

![ScreenShot-APISec-resized](https://user-images.githubusercontent.com/83706991/133243533-5a8cd3b6-9537-4427-af3b-58736fdfe010.jpg)

APIsec also provides Summary Report with OWASP Coverage, Category wise Test Cases and Vulnerabilities count.
This can be used to share summary information about the security quality of your application without exposing the details of potentially-exploitable findings. 

![APISec-Report-Image](https://user-images.githubusercontent.com/83706991/133770517-a4c7c4ed-fd69-4daa-a183-8a5a44a4e904.jpg)

If you configure the Issue Tracker to GitHub Issues (see [Auto Bug Management](https://www.apisec.ai/documentation#section6)), the list of open vulnerabilities across all security scans executed within this project can be viewed and closed from the GitHub issues.

Identified vulnerabilities are formatted into SARIF and then reported into the security tab in your GitHub repository if code scanning is enabled.

## Getting Started:

### Step #1: 
Sign up for a free account with Apisec
https://cloud.fxlabs.io/#/signup

### Step #2
Login into Apisec and `Register API` on the Apisec dashboard. 
For example, you can use this sample NetBank OpenAPI Specification URL: http://application.apisec.ai:8080/v2/api-docs” and name your project `NetBank`

### Step #3
Go to your GitHub Repository on which you like to activate Apisec scanning. Make sure the GitHub Advanced Security is activated. Select the Security tab, then click on `Set up code scanning`, then search and select **APIsec Scan** action. 

If you do not have GitHub Advanced Security enabled you can still add the `apisec-run-scan` action to existing GitHub workflow or create one. To create a new workflow select the `Actions` tab and click `Configure` Simple Workflow, then search and select **APIsec Scan** action from marketplace.

This will open the APIsec Scan action in the edit mode, now change the `apisec-project` property to your registered API name i.e. `NetBank`.

Now you need to add `apisec_username` and `apisec_password` as repository secrets. Go to `Repository/Settings/Secrets/New repository secrets` and use your free account credentials.

### Step #4
Go to the Actions tab, select APIsec action and click `Run workflow`. Once the action completes successfully, it will report vulnerabilities in the `Security/Code scanning alerts`. Click on one of the reported alerts to learn more about the vulnerability and remediation best practices.

Here is the video:
https://drive.google.com/drive/folders/1x0fi8Cg2lUMM-TIlfxbS-xSSbF57zc4_?usp=sharing


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
### `sarif-result-file`
**Optional** The name of the sarif format result file. The file is written only if this property is provided.
|Default value|`""`|
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
### Upload results to GitHub - Code scanning alerts:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.3
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    sarif-result-file: "apisec-results.sarif"
    
- name: upload sarif file to repository
  uses: github/codeql-action/upload-sarif@v1
  with:
    sarif_file: ./apisec-results.sarif
```
