variable "depends_on" { default = [], type = "list" }

variable "bucket_name" {
  type = "string"
  description = "The bucket name to assign the policy for read and write"
}

variable "role_name" {
  type = "string"
  description = "The role where apply the policy attachment document for allowing s3 bucket read and write"
}

resource "aws_iam_policy" "allow_s3_bucket_read_write" {
  name = "s3_bucket_read_write_${var.bucket_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetBucketLocation",
            "s3:ListAllMyBuckets"
          ],
          "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::${var.bucket_name}"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role = "${var.role_name}"
  policy_arn = "${aws_iam_policy.allow_s3_bucket_read_write.arn}"
}
