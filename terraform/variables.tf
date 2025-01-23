variable "force_update" {
  description = "A dummy variable to force Lambda function updates"
  type        = string
  default     = "0"
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "us-east-1"  # Change this to your desired region
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}