variable "depends_on" { default = [], type = "list" }

variable "role_name" {
  type = "string"
  description = "The role where apply the policy attachment document for send emails"
}

resource "aws_iam_policy" "allow_send_emails" {
  name = "ses_send_email"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role = "${var.role_name}"
  policy_arn = "${aws_iam_policy.allow_send_emails.arn}"
}
