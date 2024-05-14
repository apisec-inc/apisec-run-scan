[![APIsec](https://cloud.apisec.ai/assets/images/logo.png)](https://www.apisec.ai/product)

*NOTE: This GitHub Action is for users of APIsec Standard, Professional, and Enterprise who are integrating scans into their GitHub workflows. If you are looking for the free utility by **APIsec University**- you can find that [here](https://github.com/apisec-university/free-API-security-test-action/tree/main)*

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
https://cloud.apisec.ai/#/signup

### Step #2
Login into Apisec and `Register API` on the Apisec dashboard. 
For example, you can use this sample NetBank OpenAPI Specification URL: [http://netbanking.apisec.ai:8080/v2/api-docs](http://netbanking.apisec.ai:8080/v2/api-docs)” and name your project `NetBank`

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
### `apisec-email-report`
**Optional**  To get notify with scans results.
|Default value|`"false"`|
--- | ---
### `apisec-fail-on-vuln-severity`
**Optional**  Pass the severity string for which pipeline execution breaks upon finding that severity vulnerability. Possible string values are Critical, High and Medium severity. By default its an empty string ""
|Default value|`""`|
--- | ---
### `apisec-oas`
**Optional**  Set this value as "true" to register a project and trigger a scan.
|Default value|`"false"`|
--- | ---
### `apisec-openapi-spec-url`
**Optional**  OpenAPI Spec Url for registering a project.
|Default value|`""`|
--- | ---
### `apisec-refresh-playbooks`
**Optional**  To refresh playbooks of a project and trigger a scan.
|Default value|`"false"`|
--- | ---

## Example usage

Below is a sample of a complete workflow action. It does not have ALL the possible elements.
Further down in the documentation you can see additional options for further configuration.
### Full sample

```yaml

# This is a starter workflow to help you get started with APIsec-Scan Actions

name: APIsec

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  # Customize trigger events based on your DevSecOps processes.
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '21 19 * * 4'

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:


permissions:
  contents: read

jobs:

  Trigger_APIsec_scan:
    permissions:
      security-events: write # for github/codeql-action/upload-sarif to upload SARIF results
      actions: read # only required for a private repository by github/codeql-action/upload-sarif to get the Action run status 
    runs-on: ubuntu-latest

    steps:
       - name: APIsec scan
         uses: apisec-inc/apisec-run-scan@v1.0.6
         with:
          # The APIsec username with which the scans will be executed
          apisec-username: ${{ secrets.apisec_username }}
          # The Password of the APIsec user with which the scans will be executed
          apisec-password: ${{ secrets.apisec_password}}
          # The name of the project for security scan
          apisec-project: "VAmPI"
          # The name of the sarif format result file The file is written only if this property is provided.
          sarif-result-file: "apisec-results.sarif"
       - name: Import results
         uses: github/codeql-action/upload-sarif@v2
         with:
          sarif_file: ./apisec-results.sarif
```


The APIsec credentials are read from github secrets.

**Warning:** Never store your secrets in the repository.

### Basic:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
```
### Advanced:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
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
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    sarif-result-file: "apisec-results.sarif"
    
- name: upload sarif file to repository
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: ./apisec-results.sarif
```


### To get email reports for the triggered scans:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    apisec-email-report: "true"
```

### To break pipeline execution on finding High and Critical severity vulnerabilities: 

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    apisec-fail-on-vuln-severity: "High"
```

### To register new a project and trigger a scan:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    apisec-oas: "true"
    apisec-openapi-spec-url: "http://netbanking.apisec.ai:8080/v2/api-docs"
        
```

### To refresh playbooks of a project and trigger a scan:

```yaml
- name: Trigger APIsec scan
  id: scan
  uses: apisec-inc/apisec-run-scan@v1.0.6
  with:
    apisec-username: ${{ secrets.apisec_username }}
    apisec-password: ${{ secrets.apisec_password }}
    apisec-project: "VAmPI"
    apisec-refresh-playbooks: "true"
        
```

### Description of script flow of execution:

```yaml
   Script Purpose: This script does following things:
   
       1. Will register a project if one with the project name doesn't exist in APIsec product. 
          If it exists then script will either refresh the playbooks provided the user have  
          set the flag --refresh-playbooks as true or script will trigger scan on it.
                     
          User need to set --oas as true and --openApiSpecUrl with swagger/open api spec URL
          like --oas true --openApiSpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs"

       2. Will refresh/regenerate playbooks of a project if --refresh-playbooks flag is set as true.

       3. Will trigger a scan on a project.

       4. Will generate Sarif file after scan trigger gets completed, if --outputfile parameter passed with some string like "sarif".
          We can use it to  file Vulnerabilities in Github CodeScanning/SecurityCenter.

       5. Checks for vulnerability  of a severity and breaks pipeline execution upon finding one for following use-cases.                    

             i) If user set flag   --fail-on-vuln-severity severity as Critical, then only Critical severity will be checked.

            ii) If user set flag  --fail-on-vuln-severity severity as High, then Critical and High severities will be checked.

           iii) If user set flag --fail-on-vuln-severity severity as Medium, then Critical, High and Medium severity will be checked.

       6. To get email reports for trigger scans we need to set --emailReport flag as "true".    
```
