variable "deploy_tag" {
  type = "string"
  description = "The function deploy tag"
}


resource "aws_s3_bucket" "source_deploy"{
  bucket = "hyf-api-deploy"
  acl    = "private"
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.source_deploy.id}"
  key    = "lambda-${var.deploy_tag}.zip"
  source = "./../web/lambda.zip"
  etag   = "${md5(file("./../web/lambda.zip"))}"
}

module "role" {
  source = "./modules/iam_role_lambda"
}

module "lambda" {
  source = "./modules/lambda"

  function_name = "gateway_proxy"
  handler       = "main.handler"
  s3_bucket = "${aws_s3_bucket.source_deploy.id}"
  s3_key = "lambda-${var.deploy_tag}.zip"
  iam_role_arn = "${module.role.role_arn}"
  depends_on = ["aws_s3_bucket_object.object"]
}

module "gateway" {
  source = "./modules/api_gateway_lambda_proxy"

  name = "API Lambda"
  description   = "The entry point for the API gateway function"
  lambda_invoke_arn = "${module.lambda.invoke_arn}"
  lambda_arn = "${module.lambda.arn}"
}
