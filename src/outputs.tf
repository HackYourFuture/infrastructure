output "website_url" {
  value = "${module.website.url}"
}

output "website_api_url" {
  value = "${module.website.api}"
}

output "infra_api_url" {
  value = "${module.infra.url}"
}

output "student_role" {
  value = "${module.sso_role_student.role_arn}"
}

output "dev_ops_role" {
  value = "${module.sso_role_dev_ops.role_arn}"
}
