// hackyourfuture.github.io
variable "lambda_role_name" {
  type = "string"
  description = "The role name for the lambda function"
  default = "lambda_proxy_with_ses"
}

variable "stage" {
  type = "string"
  description = "The stage for the api gateway"
  default = "prod"
}

variable "lambda_s3_bucket_deploy" {
  type = "string"
  description = "The bucket where the api would be deployed"
}

variable "lambda_s3_key_deploy" {
  type = "string"
  description = "The file where the api would be deployed"
}

variable "private_uploads_bucket" {
  type = "string"
  description = "The bucket where you can run uploads"
}

module "role" {
  source = "./../../modules/iam_role_lambda"
  role_name = "${var.lambda_role_name}"
}

module "add_ses_to_role" {
  source = "./../../modules/iam_policy_attachment_ses"
  role_name = "${var.lambda_role_name}"
  depends_on = ["module.role"]
}

module "lambda" {
  source = "./../../modules/lambda"

  function_name = "gateway_proxy"
  handler       = "main.handler"
  s3_bucket = "${var.lambda_s3_bucket_deploy}"
  s3_key = "${var.lambda_s3_key_deploy}"
  iam_role_arn = "${module.role.role_arn}"
}

module "gateway" {
  source = "./../../modules/api_gateway_lambda_proxy"

  name = "API Lambda"
  stage = "${var.stage}"
  description   = "The entry point for the API gateway function"
  lambda_invoke_arn = "${module.lambda.invoke_arn}"
  lambda_arn = "${module.lambda.arn}"
}

module "bucket_website" {
  source ="./../../modules/s3_bucket"
  bucket_site = "hyf-website"
}

resource "aws_s3_bucket" "web_private_upload"{
  bucket = "${var.private_uploads_bucket}"
  acl = "public-read"
}

output "url" {
  value = "${module.bucket_website.url}"
}

output "api" {
  value = "${module.gateway.url}"
}

