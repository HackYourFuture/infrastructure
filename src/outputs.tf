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

output "rds_endpoint" {
  value = "${module.db.endpoint}"
}

output "bastion_ip" {
  value = "${module.bastion.ip}"
}

output "bastion_dns" {
  value = "${module.bastion.dns}"
}

output "hackyourforecast_ip" {
  value = "${module.hackyourforecast.ip}"
}

output "hackyourforecast_dns" {
  value = "${module.hackyourforecast.dns}"
}
