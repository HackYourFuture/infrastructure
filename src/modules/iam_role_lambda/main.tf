
variable "role_name" {
  type = "string"
  description = "The role where apply the policy attachment document for send emails"
}

resource "aws_iam_role" "lambda" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

output "role_arn" {
  value = "${aws_iam_role.lambda.arn}"
}
