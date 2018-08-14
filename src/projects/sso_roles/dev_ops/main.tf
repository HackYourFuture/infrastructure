module "sso_role" {
  source = "./../../../modules/iam_role_anonymous"
  role_name = "sso_dev_ops"
}

module "add_policy" {
  source = "./../../../modules/iam_policy_sys"
  role_name = "sso_dev_ops"
  depends_on = ["module.sso_role"]
}

output "role_arn" {
  value = "${module.sso_role.role_arn}"
}
