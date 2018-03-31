# HYF Infrastructure
Infrastructure code for manage cloud resources of HackYourFuture.

For the time being this code is used mainly to create API resources for the website.

## Prerequisites
Before you can use this code you need `make` and `docker`.
Make sure you install them:
```
brew install make
```

[Get docker](https://www.docker.com/community-edition)

## Authorizations
In order to access the authorizations for deploy new resources to the infrastructure you need to make sure you own the file under `src/configurations.tf` location.

### For Admins
The file can be created automatically if you own the password to decrypt the secret.
```
make src/configurations.tf
```
Would prompt for the password and would create the file.

### For Developers
If you want to try this infra code you can use your own credentials.


The `src/configurations.tf` should look like:
```
provider "aws" {
  access_key = "<AWS_KEY>"
  secret_key = "<AWS_SECRET>"
  region     = "<AWS_REGION>" # Our default region is eu-central-1
}
```

If you need credentials ask in #mentor_secrets in slack. Someone would help you out.

## Terraform
We use [terraform](https://www.terraform.io) for describe our infrastructure and we deploy against [AWS](http://aws.amazon.com/).
We highly recommend have study them before play with it `^_^`.

For run terraform you can run:

## Terraform - Init
Dowload the dependencies.
```
./bin/terraform init
```

### Terraform - Check changes
Check changes on infra.
```
`./bin/terraform plan`
```

### Terraform - Apply changes
Deploy the infrastructure.
```
`./bin/terraform apply`
```

## Important
If you change the files and you run `apply` make sure you commit all the files include `.tfstate*` once.

### Secrets
If you change the secrets and you want update the secrets: you can run `make encrypt`.
