variable "depends_on" { default = [], type = "list" }

variable "role_name" {
  type = "string"
  description = "The role where apply the policy attachment document for send emails"
}

resource "aws_iam_policy" "allow_to_assume_role" {
  name = "sts_assume_role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*",
                "sts:AssumeRole",
                "sts:GetFederationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role = "${var.role_name}"
  policy_arn = "${aws_iam_policy.allow_to_assume_role.arn}"
}
