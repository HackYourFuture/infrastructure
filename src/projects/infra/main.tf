// infra.hackyourfuture.net
variable "lambda_role_name" {
  type = "string"
  description = "The role name for the lambda function"
  default = "lambda_proxy_with_ses"
}

variable "s3_bucket" {
  type = "string"
  description = "The bucket where to upload the lambda code"
}

variable "s3_object" {
  type = "string"
  description = "The file that contains lambda code"
}

variable "stage" {
  type = "string"
  description = "The stage where we want deploy"
}

variable "github_app_token" {
  type = "string"
  description = "The app token for the SSO application"
}

variable "github_app_secret" {
  type = "string"
  description = "The app secret for the SSO application"
}

variable "github_app_url" {
  type = "string"
  description = "The app url for the SSO application"
}

module "role" {
  source = "./../../modules/iam_role_lambda"
  role_name = "${var.lambda_role_name}"
}

module "role_assume_role" {
  source = "./../../modules/iam_policy_attachment_assume_role"
  role_name = "${var.lambda_role_name}"
  depends_on = ["module.role"]
}

module "lambda" {
  source = "./../../modules/lambda"

  function_name = "infra_proxy"
  handler       = "main.handler"
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_object}"
  iam_role_arn = "${module.role.role_arn}"
  depends_on = ["aws_s3_bucket_object.object"]
  timeout = 5

  environment {

    variables {

      GITHUB_APP_TOKEN = "${var.github_app_token}"
      GITHUB_APP_SECRET = "${var.github_app_secret}"
      GITHUB_APP_URL = "${var.github_app_url}"

    }

  }
}

module "gateway" {
  source = "./../../modules/api_gateway_lambda_proxy"

  name = "Infra API Lambda"
  stage = "${var.stage}"
  description   = "The entry point for the API gateway functions for HYF Infra"
  lambda_invoke_arn = "${module.lambda.invoke_arn}"
  lambda_arn = "${module.lambda.arn}"
}

output "url" {
  value = "${module.gateway.url}"
}
