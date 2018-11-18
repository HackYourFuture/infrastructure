terraform {
  backend "s3" {
    bucket = "hyf-api-deploy"
    key    = "infra/state"
    region = "eu-central-1"
  }
}

provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.AWS_DEFAULT_REGION}"
}

// Generic HYF Bucket for deploy, state and credentials
resource "aws_s3_bucket" "source_deploy"{
  bucket = "hyf-api-deploy"
  acl    = "private"

  versioning {
    enabled = true
  }
}

// PROJECTS

// INFRA-API
// allows student to get authenticantion to the AWS resources,
// contains functions for SSO and resources for creating EC2 Instances.
// The source code is in this repository under the folder api/
module "infra" {
  source = "./projects/infra"

  stage = "prod"
  lambda_role_name = "infra_api"
  s3_bucket = "${aws_s3_bucket.source_deploy.id}"
  s3_object = "infra-api-${var.infra_api_deploy_tag}.zip"

  github_app_token = "${var.GITHUB_APP_TOKEN}"
  github_app_secret = "${var.GITHUB_APP_SECRET}"
  github_app_url = "${var.GITHUB_APP_URL}"
}

// WEBSITE
// The source code can be found https://github.com/HackYourFuture/hackyourfuture.github.io
module "website" {
  source = "./projects/website"

  stage = "prod"

  lambda_role_name = "lambda_proxy_with_ses"

  lambda_s3_bucket_deploy = "${aws_s3_bucket.source_deploy.id}"
  lambda_s3_key_deploy = "api-${var.website_api_deploy_tag}.zip"

  private_uploads_bucket = "${var.s3_bucket_name_web_private_upload}"
  google_app_jwt = "${var.GOOGLE_APP_JWT}"
  mollie_api_key = "${var.MOLLIE_API_KEY}"
}

// SSO ROLES
// This are a set of preset role needed for the SSO
// for make sure that the organization gets right resources assigned
module "sso_role_student" {
  source = "./projects/sso_roles/student"
  website_upload_bucket = "${var.s3_bucket_name_web_private_upload}"
}

module "sso_role_dev_ops" {
  source = "./projects/sso_roles/dev_ops"
}

// https://github.com/HackYourForecast/hackyourforecast
module "hackyourforecast" {
  source = "./projects/hackyourforecast"
}