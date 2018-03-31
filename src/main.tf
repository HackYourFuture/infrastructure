
module "role" {
  source = "./modules/iam_role_lambda"
}

module "lambda" {
  source = "./modules/lambda"

  function_name = "gateway_proxy"
  handler       = "main.handler"
  s3_bucket = "hyf-api-deploy"
  s3_key = "lambda.zip"
  iam_role_arn = "${module.role.role_arn}"
}

module "gateway" {
  source = "./modules/api_gateway_lambda_proxy"

  name = "API Lambda"
  description   = "The entry point for the API gateway function"
  lambda_invoke_arn = "${module.lambda.invoke_arn}"
  lambda_arn = "${module.lambda.arn}"
}
