variable "website_upload_bucket" {
  type = "string"
  description = "Student wants to be capable to debug the webstie"
}

module "sso_role" {
  source = "./../../../modules/iam_role_anonymous"
  role_name = "sso_student_role"
}

module "add_cloudwatch_to_student" {
  source = "./../../../modules/iam_policy_attachment_cloudwatch_dashboard"
  role_name = "sso_student_role"
  depends_on = ["module.sso_student_role"]
}

module "add_s3_hyf_uploads_to_student" {
  source = "./../../../modules/iam_policy_attachment_s3_bucket_read_write"
  bucket_name = "${var.website_upload_bucket}"
  role_name = "sso_student_role"
  depends_on = ["module.sso_student_role"]
}

output "role_arn" {
  value = "${module.sso_role.role_arn}"
}
