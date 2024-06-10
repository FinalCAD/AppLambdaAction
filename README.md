# AppLambdaAction

Github Action to deploy a lambda from the app repository.
See readme of [terraform repository](https://github.com/FinalCAD/terraform-app-lambda) for detail on configuration file.
You must call this action for each lambda and each datacenter. Use app-name in combination with suffix to handle multiple lambda from the same application.

## Inputs
### `app-name`
[**Required**] Application ID to identify the apps in eks-apps. Should be identical for all resources in the same project.

### `suffix`
Suffix for multi lambda in same repository, Default : ''

### `aws-role`
[**Required**] AWS role allowing Secret manager usage

### `terraform-version`
Terraform version to use, Default: latest

### `terragrunt-version`
Terragrunt version to use, Default: latest

### `terraform-app-lambda`
Repository containing terraform code for secret creation, Default: FinalCAD/terraform-app-lambda

### `terraform-app-lambda-ref`
Reference to use for `terraform-app-lambda` repository, Default: master

### `github-token`
Github token to avoid limit rate when pulling package

### `github-ssh`
[**Required**] Github ssh key to pull `terraform-app-lambda` repository

### `environment`
[**Required**] Finalcad envrionment: production, staging, sandbox

### `region-friendly`
Finalcad region: frankfurt or tokyo, Default: frankfurt

### `sub-path`
Subpath in current lambda repository to call `repare_archive.sh`. Only use for monorepo with multiple subdirectory and in case of Package lambda

### `configuration-file`
Path to lambda configuration file, Default: `.finalcad/lambda.yaml`

### `policies-file`
Path to lambda policies file, Default: `.finalcad/lambda-policies.json`

### `pr-number`
Pull rerquest number, empty for push, will only output result in pull request without applying.

### `python-version`
Python version to construct python zip, only for Package lambda

### `dry-run`
Dry run, will not trigger apply, Default: `false`

### `override-output-file`
(Optional) Path where to store override content from Terraform output.

## Usage

```yaml
- name: Deploy lambda
  uses: FinalCAD/AppLambdaAction@v1.0
  with:
    app-name: api1-service-api
    aws-role: ${{ secrets.DEPLOY_ROLE_MASTER }}
    github-ssh: ${{ secrets.GH_DEPLOY_SSH }}
    environment: sandbox
    region-friendly: frankfurt
```
