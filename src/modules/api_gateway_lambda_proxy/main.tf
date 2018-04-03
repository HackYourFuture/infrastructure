
variable "name" {
  type = "string"
  description = "The name of the gateway"
}

variable "stage" {
  type = "string"
  description = "The publishing stage of the gateway"
  default = "prod"
}

variable "description" {
  type = "string"
  description = "The description of the gateway"
  default = "Proxy to lambda function"
}

variable "lambda_arn" {
  description = "The arn of the lambda function"
}

variable "lambda_invoke_arn" {
  description = "The invoke_arn of the lambda function"
}

resource "aws_api_gateway_rest_api" "rest" {
  name        = "${var.name}"
  description = "${var.description}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.rest.id}"
  parent_id   = "${aws_api_gateway_rest_api.rest.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.rest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.rest.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.rest.id}"
  resource_id   = "${aws_api_gateway_rest_api.rest.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.rest.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_invoke_arn}"
  request_templates {
    "application/xml" = "${file("${path.module}/request_template.json")}"
    "application/json" = "${file("${path.module}/request_template.json")}"
    "text/html" = "${file("${path.module}/request_template.json")}"
  }
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.rest.id}"
  stage_name  = "${var.stage}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.gateway_deployment.execution_arn}/*/*"
}

output "url" {
  value = "${aws_api_gateway_deployment.gateway_deployment.invoke_url}"
}
