// Environment variables for deploy
variable "AWS_KEY" {
  type = "string"
  description = "AWS Access key"
}

variable "AWS_SECRET" {
  type = "string"
  description = "AWS Access key"
}

variable "AWS_REGION" {
  type = "string"
  description = "AWS Access key"
}

// Environment variable for Infra App
variable "GITHUB_APP_TOKEN" {
  type = "string"
  description = "AWS Access key"
}

variable "GITHUB_APP_SECRET" {
  type = "string"
  description = "AWS Access key"
}

variable "GITHUB_APP_URL" {
  type = "string"
  description = "AWS Access key"
}

variable "stage" {
  type = "string"
  description = "The stage for the api gateway"
  default = "prod"
}

variable "infra_api_deploy_tag" {
  type = "string"
  description = "The function deploy tag"
}

variable "website_api_deploy_tag" {
  type = "string"
  description = "The function deploy tag"
}

variable "infra_lambda_role_name" {
  type = "string"
  description = "The role name for the lambda function responsible of infra"
  default = "infra_api"
}

variable "lambda_role_name" {
  type = "string"
  description = "The role name for the lambda function"
  default = "lambda_proxy_with_ses"
}

variable "s3_bucket_name_web_private_upload" {
  type = "string"
  description = "The bucket where the website sends the uploads"
  default = "hyf-website-uploads"
}

provider "aws" {
  access_key = "${var.AWS_KEY}"
  secret_key = "${var.AWS_SECRET}"
  region     = "${var.AWS_REGION}"
}

// The authentication provider
// A set of roles that can be assign to access to aws.amazon.com/console

// STUDENT
module "sso_student_role" {
  source = "./modules/iam_role_anonymous"
  role_name = "sso_student_role"
}

module "add_cloudwatch_to_student" {
  source = "./modules/iam_policy_attachment_cloudwatch_dashboard"
  role_name = "sso_student_role"
  depends_on = ["module.sso_student_role"]
}

module "add_s3_hyf_uploads_to_student" {
  source = "./modules/iam_policy_attachment_s3_bucket_read_write"
  bucket_name = "${var.s3_bucket_name_web_private_upload}"
  role_name = "sso_student_role"
  depends_on = ["module.sso_student_role"]
}
// end-STUDENT

// Generic HYF
resource "aws_s3_bucket" "source_deploy"{
  bucket = "hyf-api-deploy"
  acl    = "private"

  versioning {
    enabled = true
  }
}

terraform {
  backend "s3" {
    bucket = "hyf-api-deploy"
    key    = "infra/state"
    region = "eu-central-1"
  }
}

// infra.hackyourfuture.net
module "infra_role" {
  source = "./modules/iam_role_lambda"
  role_name = "${var.infra_lambda_role_name}"
}

module "role_assume_role" {
  source = "./modules/iam_policy_attachment_assume_role"
  role_name = "${var.infra_lambda_role_name}"
  depends_on = ["module.infra_role"]
}

module "infra_lambda" {
  source = "./modules/lambda"

  function_name = "infra_proxy"
  handler       = "main.handler"
  s3_bucket = "${aws_s3_bucket.source_deploy.id}"
  s3_key = "infra-api-${var.infra_api_deploy_tag}.zip"
  iam_role_arn = "${module.infra_role.role_arn}"
  depends_on = ["aws_s3_bucket_object.object"]
  timeout = 5

  environment {

    variables {

      GITHUB_APP_TOKEN = "${var.GITHUB_APP_TOKEN}"
      GITHUB_APP_SECRET = "${var.GITHUB_APP_SECRET}"
      GITHUB_APP_URL = "${var.GITHUB_APP_URL}"

    }

  }
}

module "infra_gateway" {
  source = "./modules/api_gateway_lambda_proxy"

  name = "Infra API Lambda"
  stage = "${var.stage}"
  description   = "The entry point for the API gateway functions for HYF Infra"
  lambda_invoke_arn = "${module.infra_lambda.invoke_arn}"
  lambda_arn = "${module.infra_lambda.arn}"
}

// hackyourfuture.github.io
module "role" {
  source = "./modules/iam_role_lambda"
  role_name = "${var.lambda_role_name}"
}

module "add_ses_to_role" {
  source = "./modules/iam_policy_attachment_ses"
  role_name = "${var.lambda_role_name}"
  depends_on = ["module.role"]
}

module "lambda" {
  source = "./modules/lambda"

  function_name = "gateway_proxy"
  handler       = "main.handler"
  s3_bucket = "${aws_s3_bucket.source_deploy.id}"
  s3_key = "api-${var.website_api_deploy_tag}.zip"
  iam_role_arn = "${module.role.role_arn}"
  depends_on = ["aws_s3_bucket_object.object"]
}

module "gateway" {
  source = "./modules/api_gateway_lambda_proxy"

  name = "API Lambda"
  stage = "${var.stage}"
  description   = "The entry point for the API gateway function"
  lambda_invoke_arn = "${module.lambda.invoke_arn}"
  lambda_arn = "${module.lambda.arn}"
}

module "bucket_website" {
  source ="./modules/s3_bucket"
  bucket_site = "hyf-website"
}

resource "aws_s3_bucket" "web_private_upload"{
  bucket = "${var.s3_bucket_name_web_private_upload}"
  acl = "public-read"
}

// Outputs
output "website_url" {
  value = "${module.bucket_website.url}"
}

output "uploads_url" {
  value = "${aws_s3_bucket.web_private_upload.bucket_regional_domain_name}"
}

output "api_url" {
  value = "${module.gateway.url}"
}

output "infra_api_url" {
  value = "${module.infra_gateway.url}"
}

output "student_role" {
  value = "${module.sso_student_role.role_arn}"
}
