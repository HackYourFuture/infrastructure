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

provider "aws" {
  alias = "west"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "eu-west-1"
}

// Generic HYF Bucket for deploy, state and credentials
resource "aws_s3_bucket" "source_deploy"{
  bucket = "hyf-api-deploy"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "infra"{
  bucket = "hyf-infra"
  acl    = "private"

  versioning {
    enabled = true
  }
}

// PROJECTS
resource "aws_default_vpc" "default" {}

module "network" {
  source = "./projects/network"
  vpc_id = "${aws_default_vpc.default.id}"
}

// General shared DB
module "bastion" {
  source = "./projects/bastion"
  security_group_ids = ["${module.network.bastion_sg_id}"]
}

module "db" {
  source = "./projects/database"
  security_group_ids = ["${module.network.db_sg_id}"]
}

// HackYourForecast
module "hackyourforecast" {
  source = "./projects/hackyourforecast"
  vpc_id = "${aws_default_vpc.default.id}"
}

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
