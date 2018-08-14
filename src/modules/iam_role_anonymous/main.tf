
variable "role_name" {
  type = "string"
  description = "The role name"
}

resource "aws_iam_role" "anonymous" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {"AWS":"*"},
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

output "role_arn" {
  value = "${aws_iam_role.anonymous.arn}"
}
