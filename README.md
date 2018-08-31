# HYF Infrastructure
Infrastructure code for manage cloud resources of HackYourFuture.

For the time being this code is used mainly to create API resources for the website.

## Prerequisites
Before you can use run this project you would need `make` and [`docker`](https://www.docker.com/community-edition) installed.

For install `make` in a MacOS:
```
brew install make
```

## Authorizations
In order to access the authorizations for deploy new resources to the infrastructure you need to make sure you own the rights to run the operations.
You can get your tokens here: [Get your AWS Tokens](https://5ojpo55fl5.execute-api.eu-central-1.amazonaws.com/prod/auth_token)

## Init
Once you get your tokens you can finally get auth by fetching the environment file needed to perform additional operations:
```
AWS_ACCESS_KEY_ID=<FILL_YOUR_KEY> AWS_SECRET_ACCESS_KEY=<FILL_YOUR_SECRET> AWS_SESSION_TOKEN=<FILL_YOUR_TOKEN> AWS_DEFAULT_REGION=eu-central-1 make .env
```

A password is gonna been ask to perform additional operations.

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
