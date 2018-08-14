variable "depends_on" { default = [], type = "list" }

variable "function_name" {
  type = "string"
  description = "The function name of the lambda function"
}

variable "s3_bucket" {
  type = "string"
  description = "The bucket where the functions would be deployed"
}

variable "s3_key" {
  type = "string"
  description = "The key object (file name), where the lambda function is stored"
}

variable "iam_role_arn" {
  description = "The iam role for the execution"
}

variable "handler" {
  type = "string"
  description = "The handler location"
  default = "main.handler"
}

variable "runtime" {
  type = "string"
  description = "The runtime of your lambda function"
  default = "nodejs8.10"
}

variable "environment" {
  description = "Environment configuration for the Lambda function"
  type        = "map"
  default     = {}
}

variable "timeout" {
  description = "The timeout that the function would exit"
  type        = "string"
  default     = 3
}

resource "aws_lambda_function" "function" {
  function_name = "${var.function_name}"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${var.s3_key}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "${var.handler}"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"

  role = "${var.iam_role_arn}"

  # The aws_lambda_function resource has a schema for the environment
  # variable, where the only acceptable values are:
  #   a. Undefined
  #   b. An empty list
  #   c. A list containing 1 element: a map with a specific schema
  # Use slice to get option "b" or "c" depending on whether a non-empty
  # value was passed into this module.

  environment = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}

output "invoke_arn" {
  value = "${aws_lambda_function.function.invoke_arn}"
}

output "arn" {
  value = "${aws_lambda_function.function.arn}"
}
