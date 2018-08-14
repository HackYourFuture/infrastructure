variable "depends_on" { default = [], type = "list" }

variable "role_name" {
  type = "string"
  description = "The role where apply the policy attachment document for cloud watch"
}

resource "aws_iam_policy" "allow_cloudwatch" {
  name = "allow_cloudwatch"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*",
                "cloudwatch:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role = "${var.role_name}"
  policy_arn = "${aws_iam_policy.allow_cloudwatch.arn}"
}
