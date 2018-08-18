// Environment variables for deploy
variable "AWS_ACCESS_KEY_ID" {
  type = "string"
  description = "AWS Access key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = "string"
  description = "AWS Access key"
}

variable "AWS_DEFAULT_REGION" {
  type = "string"
  description = "AWS Access key"
}

// Environment variable for Infra App
variable "GITHUB_APP_TOKEN" {
  type = "string"
  description = "AWS Access key"
}

variable "GITHUB_APP_SECRET" {
  type = "string"
  description = "AWS Access key"
}

variable "GITHUB_APP_URL" {
  type = "string"
  description = "AWS Access key"
}

// Environment variables for the Website
variable "GOOGLE_APP_JWT" {
  type = "string"
  description = "The google JWT app token"
}

variable "MOLLIE_API_KEY" {
  type = "string"
  description = "The mollie API key for the donations"
}

variable "stage" {
  type = "string"
  description = "The stage for the api gateway"
  default = "prod"
}

variable "infra_api_deploy_tag" {
  type = "string"
  description = "The function deploy tag"
}

variable "website_api_deploy_tag" {
  type = "string"
  description = "The function deploy tag"
}

variable "s3_bucket_name_web_private_upload" {
  type = "string"
  description = "The bucket where the website sends the uploads"
  default = "hyf-website-uploads"
}
