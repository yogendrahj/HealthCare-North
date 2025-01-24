variable "dev_bucket" {
  description = "This is the name of the development bucket for HealthCare North"
  type        = string
  default     = "healthcarenorth-devs3"
}

variable "prod_bucket" {
  description = "This is the name of the production bucket for HealthCare North"
  type        = string
  default     = "healthcarenorth-prods3"
}

variable "aws_region" {
  description = "This is the main region where the resources for HealthCare North will be deployed"
  type        = string
  default     = "eu-west-2"
}

variable "github_connection_arn" {
  description = "The ARN of the GitHub CodeStar connection"
  type        = string
  default     = "arn:aws:codeconnections:eu-west-2:216989108476:connection/e46ad609-8755-4b5c-a70f-65286b7c3100"
}
